@echo off
echo Importing Windows 10 machine from OVA...
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" import "E:\Windows_Client_10.ova" --vsys 0 --vmname "Win10Client"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Win10Client" --memory 4096 --cpus 2

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "Win10Client" --nic1 intnet --intnet1 "intnet"

echo Starting the machine...
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "Win10Client" --type headless
echo Windows 10 machine imported and started.