. .\vars.ps1

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $servicePrincipalAppId, $securePassword

Connect-AzureRmAccount `
    -Credential $credential `
    -TenantId $tenantId `
    -ServicePrincipal
