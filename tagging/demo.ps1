. ..\login.ps1

$resourceGroupName = "ms-workshop-posh-demo"
$location = "West Europe"
$vnetName = 'msworkshop-vnet'
$tag = @{"msworkshop"="demo"}
$publicIpName = "rackspacemsworkshop"
$dnsPrefix = "rackspacemsworkshopdemo"
$storageaccountName = "rackspacedemostorage"
$storageAccountNum = (1,2,3,4)

# Create resource group and a storage account
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
Write-Host "Creating Resource Group -->" $resourceGroupName -ForegroundColor Green

foreach ($item in $storageAccountNum) {
    $name = $storageaccountName+$item
    New-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroupName `
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
  -ResourceGroupName $resourceGroupName `
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
    -ResourceGroupName $resourceGroupName `
    -DomainNameLabel $dnsPrefix `
    -Location $location `
    -Tag $tag

Write-Host "Creating public ip -->" $resourceGroupName -ForegroundColor Green

Write-Host "Public IP is: " $publicIp.IpAddress.ToString()

Get-AzureRmResource –Tag @{"msworkshop"="demo"}

Set-AzureRmResource `
    -ResourceType "Microsoft.Storage/storageAccounts" `
    -Name "rackspacedemostorage1" `
    -Tags @{"msworkshop"="demo"} `
    -ResourceGroupName "ms-workshop-posh-demo"

Get-AzureRmResource -Tag @{“msworkshop”=“demo”}