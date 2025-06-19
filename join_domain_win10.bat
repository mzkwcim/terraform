@echo off
echo Configuring Windows 10 machine to join domain...

net use Z: \\192.168.1.100\c$ /user:Administrator "Hasło_Lokalne" /persistent:no

if not exist Z:\temp md Z:\temp

echo Copying domain join script...
copy join_domain_script.ps1 Z:\temp\join_domain_script.ps1

echo Executing domain join script...
powershell.exe -Command "$securePass = ConvertTo-SecureString 'Hasło_Lokalne' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('Administrator',$securePass); Invoke-WmiMethod -ComputerName 192.168.1.100 -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'powershell.exe -ExecutionPolicy Bypass -File C:\temp\join_domain_script.ps1'"

net use Z: /delete

echo The Windows 10 machine will now join the domain and restart.