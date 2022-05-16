<#
cf_spectrum_list.ps1
Version 0.2 - 04/15/2022
Author: Lance Harbour
Description:  Lists spectrum app in the zone based off of search criteria in uri
Documentation: https://api.cloudflare.com/#spectrum-applications-list-spectrum-applications
#>

$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json
$zoneId = $config.zoneID

$params = @{
    Method = "Get"
    Uri = "https://api.cloudflare.com/client/v4/zones/"+$config.zoneID+"/spectrum/apps?page=1&per_page=20&direction=desc&order=protocol"
    ContentType = "application/json"
    Headers = @{
        "X-Auth-Email" = $config.email
        "X-Auth-Key" = $config.apikey
    }
}

$salist = Invoke-RestMethod @params
$salist.result