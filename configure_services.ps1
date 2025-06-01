# Skrypt konfigurujący DHCP i Group Policy na kontrolerze domeny
Start-Transcript -Path "C:\temp\configure_services.log" -Force
Write-Host "========== ROZPOCZECIE KONFIGURACJI DODATKOWYCH USLUG: $(Get-Date) =========="

# 1. Instalacja roli DHCP Server
Write-Host "Instalowanie roli DHCP Server..."
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# 2. Autoryzacja serwera DHCP w AD
Write-Host "Autoryzowanie serwera DHCP w Active Directory..."
Add-DhcpServerInDC

# 3. Konfiguracja zakresu DHCP
Write-Host "Konfigurowanie zakresu DHCP..."
Add-DhcpServerv4Scope -Name "Zakres Wewnetrzny" -StartRange 192.168.56.100 -EndRange 192.168.56.200 -SubnetMask 255.255.255.0 -State Active

# 4. Ustawienie opcji DHCP
Write-Host "Konfigurowanie opcji DHCP..."
Set-DhcpServerv4OptionValue -ScopeId 192.168.56.0 -DnsDomain "corp.local" -DnsServer 192.168.56.106 -Router 192.168.56.1

# 5. Zarezerwowanie adresu IP dla DC
Write-Host "Rezerwowanie adresu IP dla DC..."
Add-DhcpServerv4Reservation -ScopeId 192.168.56.0 -IPAddress 192.168.56.106 -ClientId "00-00-00-00-00-01" -Description "DC1"

# 6. Instalacja narzedzi zarzadzania Group Policy
Write-Host "Instalowanie narzedzi Group Policy Management..."
Install-WindowsFeature -Name GPMC -IncludeManagementTools

# 7. Tworzenie przykladowej GPO
Write-Host "Tworzenie przykladowej GPO..."
New-GPO -Name "Default Domain Security Policy" -Comment "Domyslne zasady bezpieczenstwa domeny"

# 8. Linkowanie GPO do domeny
Write-Host "Linkowanie GPO do domeny..."
New-GPLink -Name "Default Domain Security Policy" -Target "dc=corp,dc=local" -LinkEnabled Yes

Write-Host "========== ZAKONCZENIE KONFIGURACJI: $(Get-Date) =========="
Stop-Transcript