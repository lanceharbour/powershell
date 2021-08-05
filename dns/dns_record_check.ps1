<#
dns_record_check.ps1
Version 0.1 - 07/16/2021
Author: Lance Harbour
Description:  Use to check the TTL on a record.
#>

$rarray = @()

$DCs = Get-ADDomainController -Filter * | Sort-Object
$zone = "docmain.com"
$record = "record"

foreach ($DC in $DCs)
    {
    $rdata = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $zone -name $record
    #Write-Host $DC $rdata.HostName $rdata.RecordData.IPv4Address $rdata.TimeToLive
    $Row = "" | Select DC,Record,RecordType,IPAddress,TTL
    $Row.DC = $DC
    $Row.Record = $rdata.HostName
    $Row.IPAddress = $rdata.RecordData.IPv4Address
    $Row.TTL = $rdata.TimeToLive

    $rarray += $Row
    }

$rarray | ft -AutoSize
