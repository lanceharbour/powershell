<#
dns_record_host_a_remove.ps1
Version 0.1 - 09/17/2020
Author: Lance Harbour
Description:  Use to remove a new Host A record on all DNS servers
#>

$DCs = Get-ADDomainController -Filter * | Sort-Object
$zone = "devdadavidson.com"
$record = "dnstest1"
$ip = "10.11.42.94"

foreach ($DC in $DCs)
    {
    Write-Host "Removing A record on $DC"
    Remove-DnsServerResourceRecord -ComputerName $DC -ZoneName $zone -RRType A -Name $record -RecordData $ip -Force
    }