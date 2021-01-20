<#
internal_dns_record_test.ps1
Version 0.1 - 09/17/2020
Author: Lance Harbour
Description:  Use to verify DNS record on all domain controllers
#>
$DCs = Get-ADDomainController -Filter * | Sort-Object

$rercord = Read-Host -Prompt 'Input record to test DNS'

While ($rercord){
    
    $list = @()

    Write-host
    Write-host "Testing DNS for $rercord."
    get-date
    
    Foreach ($DC in $DCs){
        try {
            $list = $list + [object](Resolve-DnsName $rercord -server $DC -ErrorAction Stop | select-object @{name='DNSServer';expression={$DC}}, "IPAddress",  "Name" ) 
        }
        catch {
            $list = $list + [PSCustomObject]@{DNSServer = $DC; IPAddress = "No DNS record "; Name = $rercord}
            continue
        }
    }
    
    $list |Sort-Object "DNSServer" | Format-Table
    
    $cname = (Read-Host "Press Enter to repeat test for $rercord, type in a new rercord, or Ctrl-C to quit.")
    if ($cname -ne "") {$rercord = $Cname}
}