# Get-OutlookInbox.ps1
# Purpose:  Gets emails from the current user's Outlook inbox and exports them to a CSV file.
# Usage:    .\Get-OutlookInbox.ps1
# Examples: .\Get-OutlookInbox.ps1
# Output:   Get-OutlookInbox-Output.csv
# Source:   http://www.ScriptingGuys.com/blog

# Load Outlook Inbox
Add-Type -Assembly "Microsoft.Office.Interop.Outlook" | Out-Null
$outlook = New-Object -ComObject Outlook.Application
$namespace = $outlook.GetNameSpace("MAPI")
$olFolders = "Microsoft.Office.Interop.Outlook.olDefaultFolders" -as [type]
$inbox = $namespace.GetDefaultFolder($olFolders::olFolderInBox)

# Variables to filter folder and emails
$folderName = "FolderName" # Assumes folder is inside the Inbox folder!
$subject = "Email Subject"
$from = "firstname.lastname@company.com" # Not used in this example

# Load the desired folder
$folder = $inbox.Folders | Where-Object { $_.Name -eq $folderName }

# Get all emails matching the criteria
$emails = $folder.Items | Where-Object { $_.Subject -like "*$subject*" } | Select-Object -Property ReceivedTime,Subject,Body

# Write-Output $olFolders.GetEnumValues()
# $emails | Get-Member

# Export email information to a CSV file
$emails | Export-Csv -Path ".\Get-OutlookInbox-Output.csv" -NoTypeInformation -Force



##########
# Original source (not used; listed here for reference):
# ----------------------------------------------------------------------------- 
# Script: Get-OutlookInbox.ps1 
# Author: ed wilson, msft 
# Date: 05/10/2011 08:34:36 
# Keywords: Microsoft Outlook, Office 
# comments: 
# reference to HSG-1-29-09, HSG-5-24-11 
# HSG-5-25-11 
# ----------------------------------------------------------------------------- 
Function Get-OutlookInbox { 
  <# 
   .Synopsis 
    This function returns InBox items from default Outlook profile 
   .Description 
    This function returns InBox items from default Outlook profile. It 
    uses the Outlook interop assembly to use the olFolderInBox enumeration. 
    It creates a custom object consisting of Subject, ReceivedTime, Importance, 
    SenderName for each InBox item.  
    *** Important *** depending on the size of your InBox items this function 
    may take several minutes to gather your InBox items. If you anticipate  
    doing multiple analysis of the data, you should consider storing the  
    results into a variable, and using that.  
   .Example 
    Get-OutlookInbox |  
    where { $_.ReceivedTime -gt [datetime]"5/5/11" -AND $_.ReceivedTime -lt ` 
    [datetime]"5/10/11" } | sort importance  
    Displays Subject, ReceivedTime, Importance, SenderName for all InBox items that 
    are in InBox between 5/5/11 and 5/10/11 and sorts by importance of the email. 
   .Example 
    Get-OutlookInbox | Group-Object -Property SenderName | sort-Object Count  
    Displays Count, SenderName and grouping information for all InBox items. The most 
    frequently used contacts appear at bottom of list.  
   .Example 
    $InBox = Get-OutlookInbox 
    Stores Outlook InBox items into the $InBox variable for further 
    "offline" processing. 
   .Example 
    ($InBox | Measure-Object).count 
    Displays the number of messages in InBox Items 
   .Example 
    $InBox | where { $_.subject -match '2011 Scripting Games' } |  
     sort ReceivedTime -Descending | select subject, ReceivedTime -last 5  
    Uses $InBox variable (previously created) and searches subject field 
    for the string '2011 Scripting Games' it then sorts by the date InBox. 
    This sort is descending which puts the oldest messages at bottom of list. 
    The Select-Object cmdlet is then used to choose only the subject and ReceivedTime 
    properties and then only the last five messages are displayed. These last 
    five messages are the five oldest messages that meet the string.  
   .Notes 
    NAME:  Get-OutlookInbox 
    AUTHOR: ed wilson, msft 
    LASTEDIT: 05/13/2011 08:36:42 
    KEYWORDS: Microsoft Outlook, Office 
    HSG: HSG-05-26-2011 
   .Link 
     Http://www.ScriptingGuys.com/blog 
 #Requires -Version 2.0 
 #> 
  Add-Type -Assembly "Microsoft.Office.Interop.Outlook" | Out-Null
  $olFolders = "Microsoft.Office.Interop.Outlook.olDefaultFolders" -as [type]
  $outlook = New-Object -COMObject Outlook.Application
  $namespace = $outlook.GetNameSpace("MAPI")

  Write-Output "$($namespace.Folders)"

  #$inbox = $namespace.GetDefaultFolder($olFolders::olFolderInBox)
  #$APM = $namespace.Folders.Item('Andrew.Ralon@golfchannel.com').Folders.Item('APM')
  #$APM.Items |
  #Select-Object -Property Subject, ReceivedTime, Importance, SenderName, Body #,Attachments
} #end function Get-OutlookInbox
##########
