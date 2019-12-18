###############################################################################
# Checks all servers for local account renamed local admin accounts
#
# lance.harbour
###############################################################################
$emailbody = "Local account is missing on the following servers:<br><br>"
$fcount = 0
$sender = "email address"
$recipients = "email address"

$user1 = ""
$user2 = ""
$servers = Get-ADComputer -Filter {(OperatingSystem -like "Windows Server*") -and (enabled -eq "true") -and (name -notlike "*godc*")} | Select-Object name | Sort-Object name
foreach ($server in $servers)
    {
    if (Test-Connection $server.name -Count 2 -ea 0 -Quiet)
        {
        $usearch = Get-WmiObject -ComputerName $server.name win32_useraccount | where {($_.name -eq $user1) -or ($_.name -eq $user2)}
        if ($usearch.Name -notlike $user1)
            {
            $fcount = $fcount + 1
            Write-Host $server.name " $user1 missing"   
            #$emailbody = "$emailbody"+$server.name+"<br>"
            }
        if ($usearch.Name -notlike $user2)
            {
            $fcount = $fcount + 1
            Write-Host $server.Name " $user2 missing"
            }
        }
    }

if ($fcount -gt 0)
    {  
    Send-MailMessage -From $sender -To $recipients -Subject "*** Local Account Missing ***" -Body $emailbody -BodyAsHtml -Priority High -SmtpServer mail
    }