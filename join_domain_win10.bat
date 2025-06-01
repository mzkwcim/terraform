@echo off
echo Konfigurowanie komputera Windows 10 do dołączenia do domeny...

:: Mapowanie dysku
net use Z: \\192.168.1.100\c$ /user:Administrator "Hasło_Lokalne" /persistent:no

:: Tworzenie folderu tymczasowego
if not exist Z:\temp md Z:\temp

:: Kopiowanie skryptu PowerShell
echo Kopiowanie skryptu dołączania do domeny...
copy join_domain_script.ps1 Z:\temp\join_domain_script.ps1

:: Wykonanie skryptu
echo Uruchamianie skryptu dołączania do domeny...
powershell.exe -Command "$securePass = ConvertTo-SecureString 'Hasło_Lokalne' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('Administrator',$securePass); Invoke-WmiMethod -ComputerName 192.168.1.100 -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'powershell.exe -ExecutionPolicy Bypass -File C:\temp\join_domain_script.ps1'"

:: Odmapowanie dysku
net use Z: /delete

echo Komputer Windows 10 zostanie teraz dołączony do domeny i zrestartowany.