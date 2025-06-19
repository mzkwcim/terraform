@echo off
setlocal
set "CONFIG_FILE=settings.json"

for /f "tokens=*" %%a in ('jq ".server_ip" "%CONFIG_FILE%" -r') do set "SERVER_IP=%%a"
for /f "tokens=*" %%a in ('jq ".user" "%CONFIG_FILE%" -r') do set "USER=%%a"
for /f "tokens=*" %%a in ('jq ".initial_password" "%CONFIG_FILE%" -r') do set "INITIAL_PASSWORD=%%a"

echo Mapping disk to DC
net use Z: \\%SERVER_IP%\c$ /user:%USER% %INITIAL_PASSWORD% /persistent:no

echo Copying file create_advanced_gpo.ps1
copy create_advanced_gpo.ps1 Z:\temp\create_advanced_gpo.ps1

echo Running script via WMI
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "$securePass = ConvertTo-SecureString '%INITIAL_PASSWORD%' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('%USER%',$securePass); Invoke-WmiMethod -ComputerName %SERVER_IP% -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'powershell.exe -ExecutionPolicy Bypass -File C:\temp\create_advanced_gpo.ps1'"

echo Wait for a script to end
ping -n 60 127.0.0.1 > nul

echo Checking logs...
if exist Z:\temp\create_advanced_gpo.log (
    type Z:\temp\create_advanced_gpo.log
) else (
    echo Log file isn't available yet
)

echo Unmapping disk
net use Z: /delete
endlocal