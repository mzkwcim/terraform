@echo off
setlocal

set "CONFIG_FILE=settings.json"

REM Wyciąganie zmiennych z config.json za pomocą jq
for /f "tokens=*" %%a in ('jq ".server_ip" "%CONFIG_FILE%" -r') do set "SERVER_IP=%%a"
for /f "tokens=*" %%a in ('jq ".user" "%CONFIG_FILE%" -r') do set "USER=%%a"
for /f "tokens=*" %%a in ('jq ".initial_password" "%CONFIG_FILE%" -r') do set "INITIAL_PASSWORD=%%a"

echo Mappowanie dysku do DC
net use Z: \\%SERVER_IP%\c$ /user:%USER% %INITIAL_PASSWORD% /persistent:no

echo Kopiowanie skryptu konfiguracyjnego
copy configure_services.ps1 Z:\temp\configure_services.ps1

echo Uruchamianie skryptu przez WMI
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "$securePass = ConvertTo-SecureString '%INITIAL_PASSWORD%' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('%USER%',$securePass); Invoke-WmiMethod -ComputerName %SERVER_IP% -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'powershell.exe -ExecutionPolicy Bypass -File C:\temp\configure_services.ps1'"

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
endlocal