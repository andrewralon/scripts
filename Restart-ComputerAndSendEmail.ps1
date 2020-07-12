# Restart-ComputerAndSendEmail.ps1
# Purpose:  Reboot local or remote PC right after sending an email announcing the reboot.
#           Originally intended to be run by a scheduled task.
# Notes:
# * As a precaution, "-WhatIf" is included below to prevent reboots until after testing.
# * To restart the local PC: Restart-Computer -Force
# * To restart a remote PC:  Restart-Computer -ComputerName Name1, Name2, Name3 -Force -Wait -For PowerShell -Timeout 300 -Delay 2
# References:
# * https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/restart-computer?view=powershell-5.1

# Setup variables
$scriptPath = "$($PSScriptRoot)\$($MyInvocation.MyCommand)"
$emailUsername = "firstname.lastname@company.com"
$emailPassword = "CHANGEME"
$emailSMTP = "smtp.mandrillapp.com"
$emailPort = 587

# Custom variables
$rebootDelayInSeconds = 60
$emailFrom = "firstname.lastname@company.com"
$emailTo = "firstname2.lastname2@company.com,firstname3.lastname3@company.com"
$emailSubject = "Reboot: $env:ComputerName"
$emailBody = @()

# Set the body of the email
$emailBody += "Server $env:ComputerName will reboot in $rebootDelayInSeconds seconds."
$emailBody += "Trigger:  Scheduled Task"
$emailBody += "Script:  $scriptPath"
$emailBody = $emailBody -join "`n`n"

Write-Output " * Email details:"
Write-Output "username:  '$emailUsername'"
Write-Output "password:  '[REDACTED]'"
Write-Output "server:    '$emailSMTP'"
Write-Output "port:      '$emailPort'"
Write-Output "from:      '$emailFrom'"
Write-Output "to:        '$emailTo'"
Write-Output "subject:   '$emailSubject'"
Write-Output "body:"
Write-Output "---"
Write-Output "$emailBody"
Write-Output "---"

Write-Output " * Sending email"

$SMTPMessage = New-Object System.Net.Mail.MailMessage($emailFrom, $emailTo, $emailSubject, $emailBody)
$SMTPClient = New-Object Net.Mail.SmtpClient($emailSMTP, $emailPort)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($emailUsername, $emailPassword)
$SMTPClient.Send($SMTPMessage)

Write-Output " * Email sent"
Write-Output " * Waiting $rebootDelayInSeconds seconds"
Start-Sleep -Seconds $rebootDelayInSeconds

# WARNING: Remove "-WhatIf" only after testing
Write-Output " * Rebooting"
Restart-Computer -Force -WhatIf
# Restart-Computer -ComputerName Name1, Name2, Name3 -Force -Wait -For PowerShell -Timeout 300 -Delay 2 -WhatIf
