<#
cloudflare_zone_list.ps1
Version 0.2 - 04/15/2022
Author: Lance Harbour
Description:  Lists zones based off of search criteria in uri
Documentation: https://api.cloudflare.com/#zone-list-zones
#>

$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json
$accountId = $config.accountID

$params = @{
    Method = "Get"
    Uri = "https://api.cloudflare.com/client/v4/zones?account.id="+$accountId+"&page=1&per_page=20&order=status&direction=desc&match=all"
    ContentType = "application/json"
    Headers = @{
        "X-Auth-Email" = $config.email
        "X-Auth-Key" = $config.apikey
    }
}

$zoneList = Invoke-RestMethod @params

foreach ($zone in $zoneList.result) {
    Write-Host $zone.name, $zone.id
}

$zoneList.result | Out-File "C:\scripts\logs\cloudflare_zones.txt"