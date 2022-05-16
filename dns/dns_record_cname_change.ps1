<#
dns_record_cname_change.ps1
Version 0.1 - 06/29/2021
Author: Lance Harbour
Description:  Use to switch the CNAME alias for a single DNS host record
#>


$DCs = Get-ADDomainController -Filter * | Sort-Object
$zonename = "domain.com"
$record = "record"
$newAlias = "newrecord.domain2.com"

foreach ($DC in $DCs)
    {
    $olddns = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $zonename -Name $record
    $newdns = $olddns.Clone()
    $newdns.RecordData.HostNameAlias = $newAlias
    Set-DnsServerResourceRecord -ComputerName $DC -NewInputObject $newdns -OldInputObject $olddns -ZoneName $zonename
    }