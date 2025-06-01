@echo off
echo Czekam na pelne uruchomienie servera
timeout /t 30
echo Mappowanie dysku
net use Z: \\192.168.56.106\c$ /user:Administrator zaq1@WSX /persistent:no

echo Tworzenie nowego katalogu
if not exist Z:\temp mkdir Z:\temp

echo Kopiowanie pliku promote-dc.ps1
copy promote-dc.ps1 Z:\temp\promote-dc.ps1

echo Kopiowanie pliku run_promotion.bat
copy run_promotion.bat Z:\temp\run_promotion.bat

echo Kopiowanie pliku konfiguracyjnego usług
copy configure_services.ps1 Z:\temp\configure_services.ps1

echo Kopiowanie pliku tworzacego użytkownikow
copy create_users.ps1 Z:\temp\create_users.ps1

echo Kopiowanie pliku tworzacego gpo
copy create_gpo.ps1 Z:\temp\create_gpo.ps1

echo Kopiowanie pliku tworzacego gpo
copy create_shares.ps1 Z:\temp\create_shares.ps1

echo Odmapowanie dysku
net use Z: /delete

echo Kopiowanie zakonczone pomyslnie