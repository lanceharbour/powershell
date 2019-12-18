###############################################################################
# Searches specified OU for user accounts that haven't logged in during the 
# last 30 days then disables and moves to Disabled OU.  Deletes any accounts 
# that have been disabled for 30 days.
###############################################################################
$timestamp = Get-Date
$day = (Get-Date).ToString('ddd')
$date = (Get-Date).ToString('d')
$Count = 0
$DCount = 0
$logpath = "C:\scripts\logs\"
$deleted = "_accounts_deleted.txt"
$disabled = "_accounts_disabled.txt"

#Checks log files timestamp for appending or deleting.
If ((Get-ChildItem $logpath$day"_accounts_disabled.txt").LastAccessTime -gt (Get-Date).Day)
    {
    #Write-Host "Overwriting accounts disabled file"
    New-Item $logpath$day"_accounts_disabled.txt" -type file -Force
    }
Else 
    {
    #Write-Host "Appending accounts disabled file"
    "********Appending disable users $timestamp********" | Out-File -Append $logpath$day"_accounts_disabled.txt"
    }
    
If ((Get-ChildItem $logpath$day"_accounts_deleted.txt").LastAccessTime -gt (Get-Date).Day)
    {
    #Write-Host "Overwriting accounts deleted file"
    New-Item $logpath$day"_accounts_deleted.txt" -type file -Force
    }
Else 
    {
    #Write-Host "Appending accounts deleted file"
    "********Appending deleted users $timestamp********" | Out-File -Append $logpath$day"_accounts_deleted.txt"
    }

#Checks disabled user accounts in Disabled OU and deletes if disabled more then 30 days
$DUsers = Get-ADUser -Filter * -SearchBase "Active Directory path to search" -Properties modifyTimeStamp
ForEach ($Duser in $Dusers)
    {
    If ($Duser.Enabled -eq 0)
        {
        If ($Duser.modifyTimeStamp -le (get-date).adddays(-31))
            {
            $DCount = $DCount + 1
            Remove-ADUser -Identity $Duser.SamAccountName -Confirm:$false
            $Dsamaccountname = $Duser.SamAccountName
            $DName = $Duser.DistinguishedName
            $DmodifyTimeStamp = $Duser.modifyTimeStamp
            "$DmodifyTimeStamp|$Dsamaccountname|$DName" | Out-File -Append $logpath$day"_accounts_deleted.txt"
            }
        }
    }
#Write-Host "Deleted count $DCount"

#Checking for users who haven't logged on in the last 30 days, disables and moves to Disabled OU
$WPUsers = Get-ADUser -Filter * -SearchBase "Active Directory path to search" -Properties samaccountname | Select-Object samaccountname | Sort-Object samaccountname -Descending 
ForEach ($WPUser in $WPUsers)
    {
    $UserInfo = Get-ADUser $WPuser.samaccountname -Properties Description, LastLogonTimestamp, Title, modifyTimeStamp | Select-Object SamAccountName, Description,LastLogonTimestamp, Title, modifyTimeStamp, DistinguishedName
    $LLTS = [DateTime]::FromFileTime([Int64] $UserInfo.LastLogonTimestamp)
    If ($UserInfo.modifyTimeStamp -le (get-date).adddays(-31))
        {
        If ($LLTS -le (get-date).adddays(-31))
            {
            $Count = $Count + 1
            Disable-ADAccount -Identity $UserInfo.SamAccountName -Confirm:$false
            Move-ADObject -Identity $UserInfo.DistinguishedName -TargetPath "Active Directory path" -Confirm:$false
            Write-host $UserInfo.DistinguishedName
            #Write-Host $LLTS "|" $WPUser.samaccountname "|" $UserInfo.description "|" $UserInfo.Title
            $samaccountname = $WPUser.samaccountname
            $description = $UserInfo.Description
            $title = $UserInfo.Title
            "$LLTS|$samaccountname|$description|$title" | Out-File -Append $logpath$day"_accounts_disabled.txt"
            }
        }
    }
#Write-Host "30 day count $Count"

#Emails list of users disabled and deleted.
If (((Get-ChildItem $logpath$day$deleted).Length -gt 0kb) -and ((Get-ChildItem $logpath$day$disabled).Length -gt 0kb))
    {
    $Attachment1 = "$logpath$day$disabled"
    $Attachment2 = "$logpath$day$deleted"
    $emailbody = "$Count users were disabled today.<br>"
    $emailbody += "$DCount users were deleted today.<br>"
    $emailbody += "See attached for details.<br>"
    Send-MailMessage -From "from email address" -To "to email address" -Subject "*** User accounts disabled or deleted $date ***" -Body $emailbody -BodyAsHtml -Attachments $Attachment1, $Attachment2 -Priority High -SmtpServer mail
    #Write-Host "Data for both."
    }
ElseIf ((Get-ChildItem $logpath$day$deleted).Length -gt 0kb)     
    {
    $Attachments = "$logpath$day$deleted"
    $emailbody += "$DCount users were deleted today.<br>"
    $emailbody += "See attached for details.<br>"
    Send-MailMessage -From "from email address" -To "to email address" -Subject "*** User accounts disabled or deleted $date ***" -Body $emailbody -BodyAsHtml -Attachments $Attachments  -Priority High -SmtpServer mail
    #Write-Host "No data for disabled"
    }
ElseIf ((Get-ChildItem $logpath$day$disabled).Length -gt 0kb) 
    {
    $Attachments = "$logpath$day$disabled"
    $emailbody = "$Count users were disabled today.<br>"
    $emailbody += "See attached for details.<br>"
    Send-MailMessage -From "from email address" -To "to email address" -Subject "*** User accounts disabled or deleted $date ***" -Body $emailbody -BodyAsHtml -Attachments $Attachments  -Priority High -SmtpServer mail
    #Write-Host "No data for deleted"
    }