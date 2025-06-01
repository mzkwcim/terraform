@echo off
echo ===== Rozpoczynam promocje kontrolera domeny - %date% %time% ===== > C:\temp\dc_log.txt
echo Uruchamiam skrypt PowerShell... >> C:\temp\dc_log.txt

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File C:\temp\promote-dc.ps1 >> C:\temp\dc_log.txt 2>&1

echo ===== Zakonczono wykonanie skryptu - %date% %time% ===== >> C:\temp\dc_log.txt