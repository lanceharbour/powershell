<#
dns_record_host_a_add.ps1
Version 0.1 - 07/12/2021
Author: Lance Harbour
Description:  Use to add a new Host A record on all DNS servers
#>

$DCs = Get-ADDomainController -Filter * | Sort-Object
$zone = "dadco.com"
$record = "eun"
$ip = "10.3.55.20"
$ttl = "01:00:00"

foreach ($DC in $DCs)
    {
    Write-Host "Creating new A record on $DC"
    Add-DnsServerResourceRecord -ComputerName $DC -A -ZoneName $zone -Name $record  -AllowUpdateAny -IPv4Address $ip -TimeToLive $ttl
    }