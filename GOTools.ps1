    <#
    GOTools.PS1
    Version 0.2 - 1/17/2014
    Author: Lance Harbour
    Description:  Tools to search AD for usernames, users groups, groups, group memberships, email addresses.
    #>

Function W-USearch($uname) {
    <#
    .SYNOPSIS
    Searches AD for a username
    #>
    If($uname.Length -eq 0) {
    $uname = Read-Host "Enter partial or full username"
    }
    $uname = "*" + $uname + "*"
    If($uname.Length -le 2) {
        Write-Warning "No username entered"
        } 
    Else {
         $uinfo = Get-ADuser -Filter {samaccountname -like $uname} -Properties mail,LockedOut,PasswordExpired,AccountExpirationDate, `
         msExchHideFromAddressLists | Sort-Object | FT name, samaccountname, mail, LockedOut, Enabled, PasswordExpired, AccountExpirationDate, msExchHideFromAddressLists  -AutoSize
        If($uinfo.Length -eq 0) {
            Write-Warning "No usernames similar to $uname found."
            }
        Else {
            $uinfo
            }
        }
    }

Function W-UGSearch($username) {
    <#
    .SYNOPSIS
    Display users group memberships
    #>
    If($username.length -eq 0) {
    $username = Read-Host "Enter full username"
    }
    If($username -eq "") {
        Write-Warning "No username entered"
        }
    Else {
        Get-ADPrincipalGroupMembership $username | Sort-Object groupcategory, name | ft name, groupcategory -AutoSize
        }
    }

Function W-GSearch($gname) {
    <#
    .SYNOPSIS
    Searches AD for groupname
    #>
    If($gname.length -eq 0) {
    $gname = Read-Host "Enter partial or full group name"
    }
    $gname = "*" + $gname + "*"
    If($gname.Length -le 2) {
        Write-Warning "No groupname entered"
        } 
    Else {
        $ginfo = Get-ADGroup -Filter {SamAccountName -like $gname} -Properties SamAccountName,GroupCategory,Description  | Sort-Object | FT SamAccountName,GroupCategory,Description -AutoSize
        If($ginfo.Length -eq 0) {
            Write-Warning "No groups simliar to $gname found."
            }
        Else {
            $ginfo
            }
        }
    }

Function W-GMSearch($gmname) {
    <#
    .SYNOPSIS
    Display groups members
    #>
    If($gmname.length -eq 0){
    $gmname = Read-Host "Enter full group name"
    }
    If($gmname -eq "") {
        Write-Warning "No groupname entered"
        }
    Else {
        Get-ADGroupMember $gmname | Sort-Object | FT SamAccountName -AutoSize
        }
    }

Function W-ESearch($email) {
    <#
    .SYNOPSIS
    Searches AD for user and group email addresses
    #>
    If($email.length -eq 0){
    $email = Read-Host "Enter full or partial email address to search"
    }
    $email = "*" + $email + "*"
    If($email.Length -lt 2) {
        Write-Warning "No email address entered"
        }
    Else {
        $EUsearch = Get-ADUser -Filter {mail -like $email} -Properties mail, ObjectClass | Select-Object mail, name, ObjectClass | Sort-Object mail
        $EGsearch = Get-ADGroup -Filter {mail -like $email} -Properties mail, ObjectClass | Select-Object mail, name, ObjectClass | Sort-Object mail
            If($EUsearch.length -eq 0 -and $EGsearch.length -eq 0) {
                Write-Warning "No matching email addresses found"
                }
            Else {
            $EUsearch | FT -AutoSize
            $EGsearch | FT -AutoSize
            }
        }
    }

Function W-CSearch($hostname) {
    <#
    .SYNOPSIS
    Searches AD for a computer name
    #>
If($hostname.Length -eq 0) {
    $hostname = Read-Host "Enter partial or full host name"
    }
    $hostname = "*" + $hostname + "*"
    If($hostname.Length -le 2) {
        Write-Warning "No host name entered"
        } 
    Else {
         $hostinfo = Get-ADComputer -Filter {samaccountname -like $hostname} -Properties Name,OperatingSystem,IPv4Address | Sort-Object | FT Name,OperatingSystem,IPv4Address -A
        If($hostinfo.Length -eq 0) {
            Write-Warning "No host names similar to $hostname found."
            }
        Else {
            $hostinfo
            }
        }
    }
   
Function W-PwdAge($username) {
    <#
    .SYNOPSIS
    Days left before password change required
    #>
    If($username.length -eq 0){
    $username = Read-Host "Enter full username"
    }
    If($username -eq "") {
    Write-Warning "No username entered"
    }
    Else{
        $searcher=New-Object DirectoryServices.DirectorySearcher
        $searcher.Filter="(&(samaccountname=$username))"
        $results=$searcher.findone()
        $pwage=((Get-Date)-([datetime]::fromfiletime($results.properties.pwdlastset[0]))).Days
        #$pwage=(New-TimeSpan -Start ([datetime]::fromfiletime($results.properties.pwdlastset[0])) -End (Get-Date)).Days
        #write-host $pwage
        $daysleft = 89 - $pwage
        If($pwage -ge 76) {
            Write-Warning "Password about to expire. The password for $username will expire in $daysleft days."
            }
        ElseIf($pwage -lt 76){
            Write-Host "The password for $username will expire in $daysleft days."}
            }
    } 

Function W-RTime ($hostname) {
    <#
    .SYNOPSIS
    Checks the last reboot time for the specified computer
    #>
    If($hostname.Length -eq 0) 
        {
        $hostname = Read-Host "Enter partial or full host name"
        }
        $hostname = "*" + $hostname + "*"
        If($hostname.Length -le 2) 
            {
            Write-Warning "No host name entered"
            } 
        Else 
            {
            $qhosts = Get-ADComputer -Filter {samaccountname -like $hostname} -Properties Name | Sort-Object
            If($qhosts.Length -eq 0) 
                {
                Write-Warning "No host names similar to $hostname found."
                }
            Else 
                {
                ForEach ($qhost in $qhosts.name)
                    {
                    $hname = $qhost
                    $LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Comp $hname | Select -Exp LastBootUpTime
                    $BT = [System.Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)
                    Write-Host $qhost $BT
                    }
                }
            }
    }
