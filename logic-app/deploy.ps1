
. ../login.ps1

$resourceGroup = "ms-workshop-logic-app"

New-AzureRmResourceGroup -Force `
    -Name $resourceGroup `
    -Location $defaultLocation

New-AzureRmResourceGroupDeployment -Verbose `
    -ResourceGroupName $resourceGroup `
    -TemplateFile ./template.json `
    -TemplateParameterFile ./parameters.json

# Delete the Resource Group with PS
Remove-AzureRmResourceGroup -Verbose -Force -AsJob `
    -ResourceGroupName $resourceGroup

# Or with the CLI
az group delete --no-wait --yes --name $resourceGroup