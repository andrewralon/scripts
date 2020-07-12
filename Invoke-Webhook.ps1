# Invoke-Webhook.ps1
# Purpose:  Hit a webhook URL with Basic Authentication and check if the response status code is as expected.
# Usage:    .\Invoke-Webhook.ps1 -Url $url -Username $username -ApiToken $apiToken (-StatusCode $statusCode)
# Examples: .\Invoke-Webhook.ps1 -Url webhook.company.com -Username asdf -ApiToken 1234
#           .\Invoke-Webhook.ps1 -Url webhook.company.com -Username asdf -ApiToken 1234 -StatusCode 201
# Output:   200 OK
#           201 Created
# Notes:    If status code is not given, 200 will be the assumed correct response.
# References:
#   https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
#   https://www.middlewareinventory.com/blog/jenkins-remote-build-trigger-url/

param(
    [string] $Url
    , [string] $Username
    , [string] $ApiToken
    , [string] $StatusCode = 200
)

$basicAuthEncoded = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Username):$($ApiToken)"))
$headers = @{ Authorization = "Basic $basicAuthEncoded" }
$response = Invoke-WebRequest $Url -Headers $headers

Write-Host "$($response.StatusCode) $($response.StatusDescription)"

if ($response.StatusCode -ne $StatusCode) {
    # FAILED - Bad URL, creds, path, trigger token, or parameters
    throw "Error: Status Code was not '$StatusCode'"
} else {
	# WORKED - If it didn't work, the problem is not on this end
	Write-Host "Done"
}
