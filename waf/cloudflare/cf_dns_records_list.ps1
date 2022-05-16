<#
cf_dns_records_list.ps1
Version 0.1 - 1/21/2022
Author: Lance Harbour
Description:  Lists dns records for specified zone based off of search criteria in uri
Documentation: https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records
#>

$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json

$params = @{
    Method = "Get"
    Uri = "https://api.cloudflare.com/client/v4/zones/"+$config.zoneID+"/dns_records?type=A&page=1&per_page=100&order=type&direction=desc&match=all"
    ContentType = "application/json"
    Headers = @{
        "X-Auth-Email" = $config.email
        "X-Auth-Key" = $config.apikey
    }
}

$zoneDNSList = Invoke-RestMethod @params
$zoneDNSList.result
$zoneDNSList.result | Out-File C:\scripts\logs\cloudflare_zone_dns_list.txt