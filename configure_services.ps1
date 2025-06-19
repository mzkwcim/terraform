Start-Transcript -Path "C:\temp\configure_services.log" -Force
Write-Host "========== STARTED CONFIGURING ADDITIONAL SERVICES: $(Get-Date) =========="

Write-Host "Installing DHCP Server..."
Install-WindowsFeature -Name DHCP -IncludeManagementTools

Write-Host "Authorizing DHCP server in Active Directory..."
Add-DhcpServerInDC

Write-Host "Configuring DHCP range..."
Add-DhcpServerv4Scope -Name "Inner range" -StartRange 192.168.56.100 -EndRange 192.168.56.200 -SubnetMask 255.255.255.0 -State Active

Write-Host "Configuring DHCP options..."
Set-DhcpServerv4OptionValue -ScopeId 192.168.56.0 -DnsDomain "corp.local" -DnsServer 192.168.56.106 -Router 192.168.56.1

Write-Host "Reserving IP for DC..."
Add-DhcpServerv4Reservation -ScopeId 192.168.56.0 -IPAddress 192.168.56.106 -ClientId "00-00-00-00-00-01" -Description "DC1"

Write-Host "Installing Group Policy Management..."
Install-WindowsFeature -Name GPMC -IncludeManagementTools

Write-Host "Creating new GPO..."
New-GPO -Name "Default Domain Security Policy" -Comment "Default Domain Security Policy"

Write-Host "Linking GPO to domain..."
New-GPLink -Name "Default Domain Security Policy" -Target "dc=corp,dc=local" -LinkEnabled Yes

Write-Host "==========CONFIGURATION FINISHED: $(Get-Date) =========="
Stop-Transcript