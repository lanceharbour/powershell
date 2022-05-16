<#
cfca_dns_a_record_switch.ps1
Version 0.2 - 02/14/2022
Author: Lance Harbour
Description:  Checks internal and external DNS records for two records.
Documentation: https://api.cloudflare.com/#dns-records-for-a-zone-patch-dns-record
#>

#build internal dns server list
$domainControllers = Get-ADDomainController -Filter * | Sort-Object

#get config data for parameters
$cfConfig = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json

$cfZoneID = $cfConfig.zoneID
$internalZone = $cfConfig.internalZone
$internalDNSRecord1 = $cfConfig.internalDNSRecord1
$internalDNSRecord2 = $cfConfig.internalDNSRecord2

$headers = @{
    "X-Auth-Email" = $cfConfig.email
    "X-Auth-Key" = $cfConfig.apikey
}

function checkDNS() {
    #check new cloudflare DNS values
    Write-Host "*****Checking Cloudflare DNS records*****"
    $uri = "https://api.cloudflare.com/client/v4/zones/"+$cfZoneID+"/dns_records?type=A&page=1&per_page=100&order=type&direction=desc&match=all"
    $zoneDNSList = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

    foreach ($zone in $zoneDNSList.result){
        if ($zone.name -like "access*" -or $zone.name -like "drca*"){
            Write-Host $zone.name $zone.content
        }
    }

    #check internal DNS records
    Write-Host "*****Checking internal DNS records*****"
    foreach ($domainController in $domainControllers)
    {
        $iRecord1 = Get-DnsServerResourceRecord -ComputerName $domainController -ZoneName $internalZone -name $internalDNSRecord1 -ErrorAction SilentlyContinue
        Write-Host $iRecord1.HostName $iRecord1.RecordData.IPv4Address $domainController
        $iRecord2 = Get-DnsServerResourceRecord -ComputerName $domainController -ZoneName $internalZone -name $internalDNSRecord2 -ErrorAction SilentlyContinue
        Write-Host $iRecord2.HostName $iRecord2.RecordData.IPv4Address $domainController
    }
}

checkDNS