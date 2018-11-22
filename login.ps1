. $PSScriptRoot/vars.ps1

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $servicePrincipalAppId, $securePassword

Connect-AzureRmAccount `
    -Credential $credential `
    -TenantId $tenantId `
    -ServicePrincipal

# Also log in with the az cli
# az login --service-principal -u $servicePrincipalAppId -p $password --tenant $tenantId

$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"