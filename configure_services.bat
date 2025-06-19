@echo off
setlocal

set "CONFIG_FILE=settings.json"

for /f "tokens=*" %%a in ('jq ".server_ip" "%CONFIG_FILE%" -r') do set "SERVER_IP=%%a"
for /f "tokens=*" %%a in ('jq ".user" "%CONFIG_FILE%" -r') do set "USER=%%a"
for /f "tokens=*" %%a in ('jq ".initial_password" "%CONFIG_FILE%" -r') do set "INITIAL_PASSWORD=%%a"

echo Mapping disk to DC
net use Z: \\%SERVER_IP%\c$ /user:%USER% %INITIAL_PASSWORD% /persistent:no

echo Copying configuration script
copy configure_services.ps1 Z:\temp\configure_services.ps1

echo running script
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "$securePass = ConvertTo-SecureString '%INITIAL_PASSWORD%' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('%USER%',$securePass); Invoke-WmiMethod -ComputerName %SERVER_IP% -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'powershell.exe -ExecutionPolicy Bypass -File C:\temp\configure_services.ps1'"

ping -n 60 127.0.0.1 > nul

echo Checking logs
if exist Z:\temp\configure_services.log (
    type Z:\temp\configure_services.log
) else (
    echo Log file isn't available yet
)

echo demapping disk
net use Z: /delete
endlocal