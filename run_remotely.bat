@echo off
echo Running BAT file remotely on the server

net use Z: \\192.168.56.106\c$ /user:Administrator zaq1@WSX /persistent:no

"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "$securePass = ConvertTo-SecureString 'zaq1@WSX' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('Administrator',$securePass); Invoke-WmiMethod -ComputerName 192.168.56.106 -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'cmd.exe /c C:\temp\run_promotion.bat'"

echo BAT file executed. Waiting for server restart.
ping -n 15 127.0.0.1 > nul

echo Current logs (if any):
if exist Z:\temp\dc_log.txt (
    type Z:\temp\dc_log.txt
) else (
    echo Log file does not exist - promotion might have started or an error occurred.
)

net use Z: /delete