<#
cloudflare_loudbalancer_properties.ps1
Version 0.1 - 1/21/2022
Author: Lance Harbour
Description:  Lists properties for single load balancer
Documentation: https://api.cloudflare.com/#load-balancers-load-balancer-details
#>

$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json

$params = @{
    Method = "Get"
    Uri = "https://api.cloudflare.com/client/v4/zones/"+$config.zoneID+"/load_balancers/"+$config.loadbalancerID
    ContentType = "application/json"
    Headers = @{
        "X-Auth-Email" = $config.email
        "X-Auth-Key" = $config.apikey
    }
}

$lbProps = Invoke-RestMethod @params

$lbProps.result