# Send-EmailViaMandrillSMTP.ps1

# Force TLS 1.2 assuming older protocols are disabled
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$smtpServer = "smtp.mandrillapp.com"
$smtpPort = 587
$username = "firstname.lastname@company.com"
$password = "[REDACTED]"

$from = "firstname.lastname@company.com"
$to = "firstname2.lastname2@company.com,firstname3.lastname3@company.com"
$subject = "Email Subject"
$body = "HTML Body"

$SMTPMessage = New-Object System.Net.Mail.MailMessage($from, $to, $subject, $body)
$SMTPClient = New-Object Net.Mail.SmtpClient($smtp, $port)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($username, $assword)
$SMTPClient.Send($SMTPMessage)
