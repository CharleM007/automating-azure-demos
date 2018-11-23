
. ../login.ps1

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$resourceGroup = "ms-workshop-logic-app"

New-AzureRmResourceGroup -Force `
    -Name $resourceGroup `
    -Location $defaultLocation

$params = @{
    "adminPassword"  = $adminPassword
    "slackChannelId" = $slackChannelId
}
New-AzureRmResourceGroupDeployment -Verbose `
    -ResourceGroupName $resourceGroup `
    -TemplateParameterObject $params `
    -TemplateFile ./template.json

# Delete the Resource Group with PS
Remove-AzureRmResourceGroup -Verbose -Force -AsJob `
    -ResourceGroupName $resourceGroup

# Or with the CLI
az group delete --no-wait --yes --name $resourceGroup