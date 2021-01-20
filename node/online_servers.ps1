#################################################################################
#Generates list of all AD computers that are servers then tests if online       #
#################################################################################

$ErrorActionPreference = "SilentlyContinue"
del C:\scripts\online_servers.csv

$servers = Get-ADComputer -Filter {(OperatingSystem -like "Windows Server*") -and (enabled -eq "true")} | Select-Object name | Sort-Object name
$oservers = @()
ForEach ($server in $servers)
{
    If (Test-Connection $server.name -Count 2 -ea 0 -Quiet)
    {
    Write-Host $server.name
    $server.name | Out-File -Append -FilePath C:\scripts\online_servers.csv
    }   
}



