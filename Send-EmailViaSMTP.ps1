# Send-EmailViaSMTP.ps1

# Force TLS 1.2 assuming older protocols are disabled
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$smtpServer = "smtpserver.company.com"
$smtpPort = 25

$from = "Lastname, Firstname <firstname.lastname@company.com>"
$to = @( 
	"Lastname2, Firstname2 <firstname2.lastname2@company.com>" 
)
$cc = @( 
	"Lastname3, Firstname3 <firstname3.lastname3@company.com>",
	"Lastname4, Firstname4 <firstname4.lastname4@company.com>"
)
$subject = "Email Subject"
$body = "HTML Body"

Send-MailMessage -From $from -To $to -Cc $cc -Subject $subject -Body $body -BodyAsHtml -SmtpServer $smtpServer -Port $smtpPort
