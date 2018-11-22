

. ..\vars.ps1

$resourceGroup = "ms-workshop-default"
$location = "West Europe"

$securePassword = $adminPassword | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList 'demouser', $securePassword

# Create resource groups
foreach ($rg in ($resourceGroup)) {
    Write-Host "Creating Resource Group -->" $rg -ForegroundColor Green
    New-AzureRmResourceGroup -Force -Name $rg -Location $location
}

$newSubnetParams = @{
    'Name' = 'demosubnet01'
    'AddressPrefix' = '10.0.1.0/24'
}
$subnet = New-AzureRmVirtualNetworkSubnetConfig @newSubnetParams

$newVNetParams = @{
    'Name' = 'demonetwork01'
    'ResourceGroupName' = $resourceGroup
    'Location' = $location
    'AddressPrefix' = '10.0.0.0/16'
}
$vNet = New-AzureRmVirtualNetwork @newVNetParams -Subnet $subnet

$newStorageAcctParams = @{
    'Name' = 'rsworkshopdemosa01' ## Must be globally unique and all lowercase
    'ResourceGroupName' = $resourceGroup
    'Location' = $location
    'SkuName' = "Standard_LRS"
}
$storageAccount = New-AzureRmStorageAccount @newStorageAcctParams

$newPublicIpParams = @{
    'Name' = 'demopip1'
    'ResourceGroupName' = $resourceGroup
    'Location' = $location
    'AllocationMethod' = 'Dynamic' ## Dynamic or Static
    'DomainNameLabel' = 'rsworkshopdemo01'
}
$publicIp = New-AzureRmPublicIpAddress @newPublicIpParams

$newVNicParams = @{
    'Name' = 'demonic01'
    'ResourceGroupName' = $resourceGroup
    'Location' = $location
}
$vNic = New-AzureRmNetworkInterface @newVNicParams `
    -SubnetId $vNet.Subnets[0].Id `
    -PublicIpAddressId $publicIp.Id

$newConfigParams = @{
    'VMName' = 'demovm01'
    'VMSize' = 'Standard_A3'
}
$vmConfig = New-AzureRmVMConfig @newConfigParams

$newVmOsParams = @{
    'Windows' = $true
    'ComputerName' = 'demovm01'
    'Credential' = $credential
    'ProvisionVMAgent' = $true
    'EnableAutoUpdate' = $true
}
$vm = Set-AzureRmVMOperatingSystem @newVmOsParams -VM $vmConfig

$newSourceImageParams = @{
    'PublisherName' = 'MicrosoftWindowsServer'
    'Version' = 'latest'
    'Skus' = '2012-R2-Datacenter'
}

$offer = Get-AzureRmVMImageOffer -Location $location –PublisherName 'MicrosoftWindowsServer'

$vm = Set-AzureRmVMSourceImage @newSourceImageParams -VM $vm -Offer $offer[1].Offer
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $vNic.Id

$osDiskName = 'demodisk01'
$osDiskUri = $storageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName + $osDiskName + ".vhd"

$newOsDiskParams = @{
    'Name' = 'OSDisk'
    'CreateOption' = 'fromImage'
}

$vm = Set-AzureRmVMOSDisk @newOsDiskParams -VM $vm -VhdUri $osDiskUri

New-AzureRmVM -VM $vm -ResourceGroupName $resourceGroup -Location $location

# Delete the Resource Groups with PS
foreach ($rg in ($resourceGroup)) {
    Remove-AzureRmResourceGroup -Verbose -Force -AsJob `
        -ResourceGroupName $rg
}
