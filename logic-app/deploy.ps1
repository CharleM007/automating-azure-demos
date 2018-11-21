. ../login.ps1

$resourceGroup = "ms-workshop-logic-app"

New-AzureRmResourceGroup -Force `
    -Name $resourceGroup `
    -Location $defaultLocation

New-AzureRmResourceGroupDeployment -Verbose `
    -ResourceGroupName $resourceGroup `
    -TemplateFile ./template.json `
    -TemplateParameterFile ./parameters.json
