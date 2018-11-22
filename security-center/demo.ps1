##
# Use the REST API to get SC recommendations
##
.  ../vars.ps1


$authUrl = "https://login.microsoftonline.com/$($tenantId)/oauth2/token"

$postParams = @{
    grant_type = 'client_credentials';
    client_id = $servicePrincipalAppId;
    client_secret = $credential.GetNetworkCredential().Password;
    resource = 'https://management.core.windows.net';
}

$response = Invoke-WebRequest `
    -Uri  $authUrl `
    -Headers $headers `
    -Method "Post" `
    -Body $postParams

$authObject = ConvertFrom-Json -InputObject $response.Content
$authObject

$headers = @{
    Authorization = "Bearer " + $authObject.access_token
}

$apiEndpoint = "https://management.azure.com/subscriptions/$($subscriptionId)/providers/Microsoft.Security/tasks?api-version=2015-06-01-preview"

$apiResponse = Invoke-WebRequest `
    -Method "Get" `
    -Headers $headers `
    -Uri $apiEndpoint

$responseContent = ConvertFrom-Json -InputObject $apiResponse.Content

Write-Host "Security Center:" -ForegroundColor Yellow
foreach($compliance in $responseContent.value)
{
    Write-Host "Recommendation:" $compliance.properties.securityTaskParameters.name -ForegroundColor Yellow
    if ($compliance.properties.securityTaskParameters.vmName) {
        Write-Host "VM:" $vmName  -ForegroundColor Green
    }
}
