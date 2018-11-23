
.  ../login.ps1

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$resourceGroup = "ms-workshop-tag"
$location = $defaultLocation
$vnetName = 'msworkshop-vnet'
$tag = @{"msworkshop"="demo"}
$publicIpName = "rackspacemsworkshop"
$dnsPrefix = "rackspacemsworkshopdemo"
$storageaccountName = "msworkshopdemosatag"
$storageAccountNum = (1,2,3)

# Create resource group and a storage account
New-AzureRmResourceGroup -Force -Name $resourceGroup -Location $location
Write-Host "Creating Resource Group -->" $resourceGroup -ForegroundColor Green

foreach ($item in $storageAccountNum) {
    $name = $storageaccountName+$item
    New-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroup `
        -Name $name `
        -SkuName "Standard_LRS" `
        -Location $location
    Write-Host "Creating storage account -->" $name -ForegroundColor Green
}

# Create a subnet
$subnet = New-AzureRmVirtualNetworkSubnetConfig `
    -Name 'frontendSubnet' `
    -AddressPrefix "10.0.1.0/24"

# Create a vnet
$virtualNetwork = New-AzureRmVirtualNetwork `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Name $vnetName `
  -AddressPrefix 10.0.0.0/16 `
  -Tag $tag `
  -Subnet $subnet

Write-Host "Creating vnet -->" $vnetName -ForegroundColor Green
$virtualNetwork | Set-AzureRmVirtualNetwork

$publicIp = New-AzureRmPublicIpAddress `
    -AllocationMethod Static `
    -Name $publicIpName `
    -ResourceGroupName $resourceGroup `
    -DomainNameLabel $dnsPrefix `
    -Location $location `
    -Tag $tag

Write-Host "Creating public ip -->" $resourceGroup -ForegroundColor Green

Write-Host "Public IP is: " $publicIp.IpAddress.ToString()

Get-AzureRmResource –Tag @{"msworkshop"="demo"}

Set-AzureRmResource `
    -ResourceType "Microsoft.Storage/storageAccounts" `
    -Name "msworkshopdemosatag1" `
    -Tags @{"msworkshop"="demo"} `
    -ResourceGroupName $resourceGroup

Get-AzureRmResource -Verbose `
    -Tag @{"msworkshop"="demo"}

# Delete the Resource Group with PS
Remove-AzureRmResourceGroup -Verbose -Force -AsJob `
    -ResourceGroupName $resourceGroup