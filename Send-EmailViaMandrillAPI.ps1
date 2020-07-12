# Send-EmailViaMandrillAPI.ps1
# References:
#  * https://stackoverflow.com/questions/38012564/how-do-i-correctly-convert-a-hashtable-to-json-in-powershell

# Force TLS 1.2 assuming older protocols are disabled
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$apiKey = "REDACTED"
$url = "https://mandrillapp.com/api/1.0/messages/send.json"
$headers = @{ }

$fromEmail = "firstname.lastname@company.com"
$fromName = "Lastname, Firstname"
$to = @( "firstname1.lastname2@company.com" )
$subject = "Email Subject"
$body = "HTML Body"

$requestBody = @{
	key     = "$apiKey"
	message = @{
		subject    = "$subject"
		html       = "$body"
		from_email = "$fromEmail"
		from_name  = "$fromName"
		to         = @(
			@{
				email = "$to"
				type  = "to"
			}
		)
	}
} | ConvertTo-Json -Depth 4

Write-Output $requestBody

Invoke-RestMethod $url -Method Post -Headers $headers -ContentType "application/json" -Body $requestBody
