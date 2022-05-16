<#
cloudflare_zone_add_single_fw_rule.ps1
Version 0.1 - 10/06/2021
Author: Lance Harbour
Description:  Creates a firewall rule for the specified zone
Documentation: https://api.cloudflare.com/#firewall-access-rule-for-a-zone-list-access-rules
#>
#import Cloudflare account info from cf.json file
$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json
$zoneID = $config.zoneID
$uri = "https://api.cloudflare.com/client/v4/zones/$zoneID/firewall/access_rules/rules"
$mode = "whitelist" #valid values: block, challenge, whitelist, js_challenge
$configuration = '"target":"ip","value":"0.0.0.0"'
$notes = "note here"
$body = '{"mode":"'+$mode+'","configuration":{'+$configuration+'},"notes":"'+$notes+'"}'
$headers = @{
    "X-Auth-Email" = $config.email
    "X-Auth-Key" = $config.apikey
    }
#creating firewall rule
Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ContentType "application/json" -Body $body