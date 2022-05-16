<#
cf_dns_a_record_update.ps1
Version 0.1 - 1/21/2022
Author: Lance Harbour
Description:  Updates single A record IP address
Documentation: https://api.cloudflare.com/#dns-records-for-a-zone-patch-dns-record
#>

$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json

$aRecordID = "redcord id"
$aRecordIPAddress = "0.0.0.0"


$headers = @{
    "X-Auth-Email" = $config.email
    "X-Auth-Key" = $config.apikey
    }

$uri = "https://api.cloudflare.com/client/v4/zones/"+$config.zoneID+"/dns_records/"+$aRecordID
$body = '{"content":"'+$aRecordIPAddress+'"}'

Write-Host $uri
Write-Host $body


$response = Invoke-RestMethod -Uri $uri -Method 'Patch' -Headers $headers -ContentType "application/json" -Body $body
Write-Host $response

