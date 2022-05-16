<#
dns_record_cname_change.ps1
Version 0.1 - 06/29/2021
Author: Lance Harbour
Description:  Use to switch the CNAME alias for a single DNS host record
#>

$DCs = Get-ADDomainController -Filter * | Sort-Object
$zonename = "example.com"
$record = "api"
$newAlias = "new.api.example.com"

foreach ($DC in $DCs)
    {
    $olddns = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $zonename -Name $record
    $newdns = [CimInstance]::new($olddns)
    $newdns.RecordData.HostNameAlias = $newAlias
    Set-DnsServerResourceRecord -ComputerName $DC -NewInputObject $newdns -OldInputObject $olddns -ZoneName $zonename
    }