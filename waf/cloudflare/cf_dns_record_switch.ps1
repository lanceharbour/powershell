<#
cfca_dns_a_record_switch.ps1
Version 0.2 - 02/14/2022
Author: Lance Harbour
Description:  Switches internal and external DNS records for records.
Documentation: https://api.cloudflare.com/#dns-records-for-a-zone-patch-dns-record
#>

#build internal dns server list
$domainControllers = Get-ADDomainController -Filter * | Sort-Object

#get config data for parameters
$cfConfig = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json

$cfZoneID = $cfConfig.zoneID
$cfDNSRecordID1 = $cfConfig.aRecordID1
$cfDNSRecordID2 = $cfConfig.aRecordID2
$internalZone = $cfConfig.internalZone
$internalDNSRecord1 = $cfConfig.internalDNSRecord1
$internalDNSRecord2 = $cfConfig.internalDNSRecord2
$internalIP1 = $cfConfig.internalIP1
$internalIP2 = $cfConfig.internalIP2

$headers = @{
    "X-Auth-Email" = $cfConfig.email
    "X-Auth-Key" = $cfConfig.apikey
}

function userPrompt() {
    #Prompt for input from user
    $switchto = Read-Host -Prompt "Switch to server Prod or DR?"

    #assign IP address to variables based off of choice
    if ($switchto -like "prod"){
        Write-Host "Switching to Prod server"
        $script:cfIP1 = $cfConfig.aRecordIPAddress1
        $script:cfIP2 = $cfConfig.aRecordIPAddress2
        $script:swip1 = $internalIP1
        $script:swip2 = $internalIP2
    }
    elseif ($switchto -like "dr"){
        Write-Host "Switching to DR server"
        $script:cfIP1 = $cfConfig.aRecordIPAddress2
        $script:cfIP2 = $cfConfig.aRecordIPAddress1
        $script:swip1 = $internalIP2
        $script:swip2 = $internalIP1
    }
    else {
        Write-Host "option not recogzined, try again"
        exit
    }
}

function changeDNS() {
    #updating cloudflare dns records
    Write-Host "*****Updating Cloudflare DNS records*****"
    $cfuri1 = "https://api.cloudflare.com/client/v4/zones/"+$cfZoneID+"/dns_records/"+$cfDNSRecordID1
    $cfBody1 = '{"content":"'+$cfIP1+'"}'
    $cfSwitchIP1 = Invoke-RestMethod -Uri $cfuri1 -Method Patch -Headers $headers -ContentType "application/json" -Body $cfBody1
    #Write-Host $cfSwitchIP1.result

    $cfuri2 = "https://api.cloudflare.com/client/v4/zones/"+$cfZoneID+"/dns_records/"+$cfDNSRecordID2
    $cfBody2 = '{"content":"'+$cfIP2+'"}'
    $cfSwitchIP2 = Invoke-RestMethod -Uri $cfuri2 -Method Patch -Headers $headers -ContentType "application/json" -Body $cfBody2
    #Write-Host $cfSwitchIP2.result

    #updating internal DNS records
    Write-Host "*****Updating internal DNS records*****"
    foreach ($domainController in $domainControllers)
    {
        $olddns = Get-DnsServerResourceRecord -ComputerName $domainController -ZoneName $internalZone -name $internalDNSRecord1 -ErrorAction SilentlyContinue
        $newdns = [CimInstance]::new($olddns)
        $newdns.RecordData.IPv4Address = [System.Net.IPAddress]::parse($swip1)
        Set-DnsServerResourceRecord -ComputerName $domainController -NewInputObject $newdns -OldInputObject $olddns -ZoneName $internalZone -ErrorAction SilentlyContinue

        $olddns = Get-DnsServerResourceRecord -ComputerName $domainController -ZoneName $internalZone -name $internalDNSRecord2 -ErrorAction SilentlyContinue
        $newdns = [CimInstance]::new($olddns)
        $newdns.RecordData.IPv4Address = [System.Net.IPAddress]::parse($swip2)
        Set-DnsServerResourceRecord -ComputerName $domainController -NewInputObject $newdns -OldInputObject $olddns -ZoneName $internalZone -ErrorAction SilentlyContinue
    }
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
        Write-Host $domainController $iRecord1.HostName $iRecord1.RecordData.IPv4Address
        $iRecord2 = Get-DnsServerResourceRecord -ComputerName $domainController -ZoneName $internalZone -name $internalDNSRecord2 -ErrorAction SilentlyContinue
        Write-Host $domainController $iRecord2.HostName $iRecord2.RecordData.IPv4Address
    }
}

userPrompt
changeDNS
checkDNS