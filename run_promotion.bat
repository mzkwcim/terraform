@echo off
echo ===== Starting domain controller promotion - %date% %time% ===== > C:\temp\dc_log.txt
echo Running PowerShell script... >> C:\temp\dc_log.txt

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File C:\temp\promote-dc.ps1 >> C:\temp\dc_log.txt 2>&1

echo ===== Script execution finished - %date% %time% ===== >> C:\temp\dc_log.txt