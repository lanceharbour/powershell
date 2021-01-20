$DC = hostname
Get-ADObject -Server $DC -SearchBase "cn=configuration,dc=domain,dc=com" -Filter "objectclass -eq 'dhcpclass' -AND Name -ne 'dhcproot'" -Properties name |
Select-Object name | 
Format-Table -Wrap -AutoSize #| 
Out-File c:\scripts\logs\dhcp_servers.txt -Force