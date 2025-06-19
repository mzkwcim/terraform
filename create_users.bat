@echo off
echo Mapping disk to DC
net use Z: \\192.168.56.106\c$ /user:CORP\Administrator zaq1@WSX /persistent:no

echo Copying script to create users
copy create_users.ps1 Z:\temp\create_users.ps1

echo Executing script via WMI
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "$securePass = ConvertTo-SecureString 'zaq1@WSX' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('CORP\Administrator',$securePass); Invoke-WmiMethod -ComputerName 192.168.56.106 -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'powershell.exe -ExecutionPolicy Bypass -File C:\temp\create_users.ps1'"

echo Script executed. Waiting for configuration to complete...
ping -n 30 127.0.0.1 > nul

echo Checking logs...
if exist Z:\temp\create_users.log (
type Z:\temp\create_users.log
) else (
echo Log file is not yet available
)

echo Unmapping disk
net use Z: /delete