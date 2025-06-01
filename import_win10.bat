@echo off
echo Importowanie maszyny Windows 10 z OVA...
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" import "E:\Windows_Client_10.ova" --vsys 0 --vmname "Win10Client"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Win10Client" --memory 4096 --cpus 2

:: Konfiguracja sieci - dopasuj do twojej konfiguracji
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Win10Client" --nic1 intnet --intnet1 "intnet"

:: Uruchomienie maszyny
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "Win10Client" --type headless
echo Maszyna Windows 10 zaimportowana i uruchomiona.