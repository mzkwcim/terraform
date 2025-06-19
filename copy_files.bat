@echo off
echo Waiting for server to start
timeout /t 30

echo Mapping disk
net use Z: \\192.168.56.106\c$ /user:Administrator zaq1@WSX /persistent:no

echo Creating new directory
if not exist Z:\temp mkdir Z:\temp

echo Copying file promote-dc.ps1
copy promote-dc.ps1 Z:\temp\promote-dc.ps1

echo Copying file run_promotion.bat
copy run_promotion.bat Z:\temp\run_promotion.bat

echo Copying file configure_services.ps1
copy configure_services.ps1 Z:\temp\configure_services.ps1

echo Copying file create_users.ps1
copy create_users.ps1 Z:\temp\create_users.ps1

echo Copying file create_gpo.ps1
copy create_gpo.ps1 Z:\temp\create_gpo.ps1

echo Copying file create_shares.ps1
copy create_shares.ps1 Z:\temp\create_shares.ps1

echo Unmapping a disk
net use Z: /delete

echo Copying finished successfuly 