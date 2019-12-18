#################################################################################
#Searches AD for servers created in the last 30 days.                           #
#################################################################################
$newservers = Get-ADComputer -Filter {(OperatingSystem -like "Windows Server*")} -Properties name,enabled,whencreated | Where-Object {$_.whencreated -ge (get-date).adddays(-31)} 
foreach ($newserver in $newservers)
    {
    Write-Host $newserver.name $newserver.whencreated
    }