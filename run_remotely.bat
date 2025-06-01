@echo off
echo Uruchamiam zdalnie plik BAT na serwerze

net use Z: \\192.168.56.106\c$ /user:Administrator zaq1@WSX /persistent:no

REM Uruchamianie procesu bezpośrednio na serwerze przez WMI
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "$securePass = ConvertTo-SecureString 'zaq1@WSX' -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential('Administrator',$securePass); Invoke-WmiMethod -ComputerName 192.168.56.106 -Credential $cred -Class Win32_Process -Name Create -ArgumentList 'cmd.exe /c C:\temp\run_promotion.bat'"

echo Plik BAT uruchomiony. Poczekaj na restart serwera.
ping -n 15 127.0.0.1 > nul

REM Sprawdź logi przed zamknięciem połączenia
echo Aktualne logi (jeśli istnieją):
if exist Z:\temp\dc_log.txt (
type Z:\temp\dc_log.txt
) else (
echo Plik logu nie istnieje - promocja mogla się rozpoczac lub wystąpił błąd.
)

net use Z: /delete