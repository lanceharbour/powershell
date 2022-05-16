<#
cloudflare_zone_add_bulk_fw_rule.ps1
Version 0.1 - 10/07/2021
Author: Lance Harbour
Description:  Imports users and IP's from csv and creates firewall rules for specified zone.
Documentation: https://api.cloudflare.com/#firewall-access-rule-for-a-zone-list-access-rules
#>
#import users and IP addresses
$fwUsers = Import-Csv -Path .\fw_users.csv

#import Cloudflare account info from cf.json file
$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json
$zoneID = $config.zoneID
$uri = "https://api.cloudflare.com/client/v4/zones/$zoneID/firewall/access_rules/rules"

#loop through csv data and create firewall rules
foreach ($fwUser in $fwUsers){
    $mode = "whitelist" #valid values: block, challenge, whitelist, js_challenge
    $configuration = '"target":"ip","value":"'+$fwUser.Address+'"'
    $notes = $fwUser.Name
    $body = '{"mode":"'+$mode+'","configuration":{'+$configuration+'},"notes":"'+$notes+'"}'
    Write-Host $body

    $headers = @{
        "X-Auth-Email" = $config.email
        "X-Auth-Key" = $config.apikey
        }

    #creating firewall rule
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ContentType "application/json" -Body $body
}