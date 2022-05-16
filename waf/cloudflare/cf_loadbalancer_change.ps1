<#
cfca_loadbalancer_change.ps1
Version 0.1 - 4/11/2022
Author: Lance Harbour
Description:  Enables or disables the requested loadbalancer
Documentation: https://api.cloudflare.com/#load-balancers-patch-load-balancer
#>

$config = Get-Content -Raw -Path "C:\scripts\powershell\vars\cf.json"| ConvertFrom-Json

$cfZoneID = $config.zoneID
$cfLoadbalancerID = $config.loadbalancerID

function lbStatus() {
    $params = @{
        Method = "Get"
        Uri = "https://api.cloudflare.com/client/v4/zones/"+$config.zoneID+"/load_balancers/"+$config.loadbalancerID
        ContentType = "application/json"
        Headers = @{
            "X-Auth-Email" = $config.email
            "X-Auth-Key" = $config.apikey
        }
    }

    #checks if loadbalancer is enabled
    $lbProps = Invoke-RestMethod @params
    $script:lbName = $lbProps.result.name
    if ($lbProps.result.enabled -eq $true){
        Write-Host $lbProps.result.name" is enabled"
    }
    else {
        Write-Host $lbProps.result.name" is disabled"
    }
}
function userPrompt() {
    #Prompt for input from user
    $switchto = Read-Host -Prompt "Enable(1) or Disable(2) loadbalancer?"

    #retrievesuser input
    if (($switchto -like "enable") -or ($switchto -like "1")){
        Write-Host "Enabling loadbalancer"$lbName
        $script:body = '{"enabled":true}'
    }
    elseif (($switchto -like "disable") -or ($switchto -like "2")){
        Write-Host "Disabling loadbalancer"$lbName
        $script:body = '{"enabled":false}'
    }
    else {
        Write-Host "option not recogzined, try again"
        exit
    }
}

    function changeLB() {
        #changes loadbalancer based off of user input
        $params = @{
            Method = "Patch"
            Uri = "https://api.cloudflare.com/client/v4/zones/"+$cfZoneID+"/load_balancers/"+$cfLoadbalancerID
            Body = $body
            ContentType = "application/json"
            Headers = @{
                "X-Auth-Email" = $config.email
                "X-Auth-Key" = $config.apikey
            }
        }

        $response = Invoke-RestMethod @params
        #Write-Host $response.result
        if ($response.result.enabled -eq $true){
            Write-Host $response.result.name"has been enabled"
        }
        else {
            Write-Host $response.result.name"has been disabled"
        }
    }

lbStatus
userPrompt
changeLB