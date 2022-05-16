<#
dns_record_ttl_change.ps1
Version 0.1 - 07/15/2021
Author: Lance Harbour
Description:  Use to set the TTL on a record.
#>

$DCs = Get-ADDomainController -Filter * | Sort-Object
$zone = "example.com"
$record = "dnstest1"
#$ttl = [System.TimeSpan]::FromMinutes(5)
$ttl = [System.TimeSpan]::FromHours(1)
foreach ($DC in $DCs)
    {
    Write-Host "Changing record on $DC"
    $olddns = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $zone -name $record
    #Write-Host $olddns.TimeToLive
    $newdns = [CimInstance]::new($olddns)
    $newdns.TimeToLive = $ttl
    Set-DnsServerResourceRecord -ComputerName $DC -NewInputObject $newdns -OldInputObject $olddns -ZoneName $zone
    }