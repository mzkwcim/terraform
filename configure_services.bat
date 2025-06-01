@echo off
echo Mappowanie dysku do DC
net use Z: \\192.168.56.106\c$ /user:CORP\Administrator zaq1@WSX /persistent:no

echo Kopiowanie skryptu konfiguracyjnego
copy configure_services.ps1 Z:\temp\configure_services.ps1

echo Uruchamianie skryptu przez WMI
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "$securePass = ConvertTo-SecureString 'zaq1@WSX' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('CORP\Administrator',$securePass); Invoke-WmiMethod -ComputerName 192.168.56.106 -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'powershell.exe -ExecutionPolicy Bypass -File C:\temp\configure_services.ps1'"

echo Skrypt uruchomiony. Poczekaj na zakończenie konfiguracji...
ping -n 60 127.0.0.1 > nul

echo Sprawdzanie logów...
if exist Z:\temp\configure_services.log (
type Z:\temp\configure_services.log
) else (
echo Plik logów nie jest jeszcze dostępny
)

echo Odmapowanie dysku
net use Z: /delete