<#
cf_get_ips.ps1
Version 0.1 - 1/21/2022
Author: Lance Harbour
Description:  Retrieves a list of cloudflare IP's for whitelisting
#>

$cf_ips = Invoke-WebRequest -Uri "https://api.cloudflare.com/client/v4/ips"
$cf_ips.Content  | Out-File C:\scripts\logs\cloudflare_ip.txt