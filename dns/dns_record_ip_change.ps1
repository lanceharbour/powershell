<#
dns_record_ip_change.ps1
Version 0.1 - 09/17/2020
Author: Lance Harbour
Description:  Use to switch the IP address for a single DNS host record
#>

$DCs = Get-ADDomainController -Filter * | Sort-Object
$zone = "domain.com"
$record = "dnstest1"
$ip = "xxx.xxx.xxx.xxx"
foreach ($DC in $DCs)
    {
    Write-Host "Changing record on $DC"
    $olddns = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $zone -name $record
    $newdns = [CimInstance]::new($olddns)
    $newdns.RecordData.IPv4Address = [System.Net.IPAddress]::parse($ip)
    Set-DnsServerResourceRecord -ComputerName $DC -NewInputObject $newdns -OldInputObject $olddns -ZoneName $zone
    }