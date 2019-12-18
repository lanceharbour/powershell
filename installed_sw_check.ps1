##################################################################
#Searches AD for specified computers then checks to see if       #
#specified system is online then checks if software is installed.#
##################################################################
$logfile = "C:\scripts\sw_check.txt" 
$searchOU = ""
$sw = "softare to search for"
$servers = Get-ADComputer -Filter {((OperatingSystem -like "Windows 10*") -or (OperatingSystem -like "Windows 7*")) -and (enabled -eq "true")} -SearchBase "$searchOU" | Select-Object name | Sort-Object name
$oservers = @()

Out-File -FilePath $logfile -Force
foreach ($server in $servers)
    {
        if (Test-Connection $server.name -Count 1 -ea 0 -Quiet)
        {
        $oservers = $oservers + $server.name
        } 
        else
        {
        $server.name+","+"unreachable" | Out-File -FilePath $logfile -Append       
        }  
    }

foreach ($oserver in $oservers)
    {
    $oserver
    $sw_ver = Get-WmiObject -ComputerName $oserver -Class win32_product -ErrorAction Continue -ErrorVariable noresult | 
    Select-Object Name, Version | Where-Object {$_.name -like "*$sw*"} 

    if ($noresult)
        {
        $oserver+","+"Run Error" | Out-File -FilePath $logfile -Append
        }
    else
        {
        if ($sw_ver.name -like "*$sw*")
            {
            $oserver+","+$sw_ver.name+","+$sw_ver.version | Out-File -FilePath $logfile -Append    
            }
        else
            {
            $oserver+","+"not installed" | Out-File -FilePath $logfile -Append 
            }
        }
    }
