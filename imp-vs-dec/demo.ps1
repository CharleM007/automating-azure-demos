
.  ../login.ps1

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$resourceGroup = "ms-workshop-imp-vs-dec"
$location = $defaultLocation
$storageAccountBaseName1 = "msworkshopdemosa1"
$storageAccountBaseName2 = "msworkshopdemosa2"
$storageAccountNum = (1,2,3)

# Create resource groups
foreach ($rg in ($resourceGroup)) {
    Write-Host "Creating Resource Group -->" $rg -ForegroundColor Green
    New-AzureRmResourceGroup -Force -Name $rg -Location $location
}

function deployStorageAccounts1 {
    foreach ($item in $storageAccountNum) {
        $name = $storageAccountBaseName1+$item
        Write-Host "Imperative: Creating storage account -->" $name -ForegroundColor Green
        New-AzureRmStorageAccount -Verbose `
            -ResourceGroupName $resourceGroup `
            -Name $name `
            -SkuName "Standard_LRS" `
            -Location $location
    }
}
deployStorageAccounts1

function deployStorageAccounts2 {
    Write-Host "Declarative: Deploying ARM Template -->" $storageAccountBaseName2 -ForegroundColor Green
    New-AzureRmResourceGroupDeployment -Verbose `
        -ResourceGroupName $resourceGroup `
        -TemplateParameterObject @{ "storageAccountBaseName" = $storageAccountBaseName2 } `
        -TemplateFile ./template.json
}
deployStorageAccounts2

# Let's delete one from each group
Remove-AzureRmStorageAccount -Force `
    -ResourceGroupName $resourceGroup `
    -Name $storageAccountBaseName1"2"

Remove-AzureRmStorageAccount -Force `
    -ResourceGroupName $resourceGroup `
    -Name $storageAccountBaseName2"2"

# Let's run each one again and see what happens
deployStorageAccounts1
deployStorageAccounts2


# Delete the Resource Groups with PS
foreach ($rg in ($resourceGroup)) {
    Remove-AzureRmResourceGroup -Verbose -Force -AsJob `
        -ResourceGroupName $rg
}
