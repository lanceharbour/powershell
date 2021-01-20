<#
internal_dns_switch.ps1
Version 0.1 - 09/17/2020
Author: Lance Harbour
Description:  Use to switch the IP addresses between two records
When prompted type prod or dr to switch
#>

$DCs = Get-ADDomainController -Filter * | Sort-Object
$zone = "zone.com"
$record1 = "prod"
$record2 = "dr"
$ip1 = "0.0.0.0"
$ip2 = "0.0.0.0"

$switchto = Read-Host -Prompt "Switch to server Prod or DR?"

if ($switchto -like "prod")
    {
        Write-Host "Switching to Prod server"
        $swip1 = $ip1
        $swip2 = $ip2
    }
elseif ($switchto -like "dr")
    {
        Write-Host "Switching to DR server"
        $swip1 = $ip2
        $swip2 = $ip1
    }

foreach ($DC in $DCs)
    {
        Write-Host $DC
        $olddns = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $zone -name $record1
        $newdns = $olddns.Clone()
        $newdns.RecordData.IPv4Address = [System.Net.IPAddress]::parse($swip1)
        Set-DnsServerResourceRecord -ComputerName $DC -NewInputObject $newdns -OldInputObject $olddns -ZoneName $zone

        $olddns = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $zone -name $record2
        $newdns = $olddns.Clone()
        $newdns.RecordData.IPv4Address = [System.Net.IPAddress]::parse($swip2)
        Set-DnsServerResourceRecord -ComputerName $DC -NewInputObject $newdns -OldInputObject $olddns -ZoneName $zone
    }