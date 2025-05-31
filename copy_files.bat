@echo off
echo Czekam na pelne uruchomienie servera
timeout /t 60 /nobreak > null

net use Z: \\192.168.56.106\c$ /user:Administrator zaq1@WSX /persistent:no

if not exist z:\temp (
    echo Tworzenie nowego katalogu
    mkdir Z:\temp
)

echo Kopiowanie pliku echo.ps1
copy echo.ps1 z:\temp\echo.ps1

echo Odmapowanie dysku
net use Z: /delete

echo Kopiowanie zakonczone pomyslnie