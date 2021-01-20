##################################################################
#Searches AD for specified computers then checks to see if       #
#retrieves list of users in local admin group.                   #
##################################################################
Out-File C:\scripts\server_local_admin.txt -Force
$devices = Get-ADComputer -Filter {(OperatingSystem -like "Windows Server*")} -Properties name, enabled | Select-Object name, enabled | Sort-Object name

foreach ($device in $devices)
    {
    If ($device.enabled -eq $true)
        {
        If (Test-Connection $device.name -Count 1 -ea 0 -Quiet)
            {
            Write-Host $device.name 

            $ADSIcomputer = [ADSI](”WinNT://” + $device.name + “,computer”)
            $group = $ADSIcomputer.psbase.children.find('Administrators', 'Group')
            $local_admins = $group.psbase.invoke("members") | ForEach{

              $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
            } 

            $ladmin = $null
            foreach ($local_admin in $local_admins)
                {
                $ladmin = $local_admin+","+$ladmin
                Write-Host $ladmin
                }
            $device.name+","+$ladmin| Out-File C:\scripts\server_local_admin.txt -Append
            }
        }
    }