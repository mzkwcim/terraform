@echo off
cd "C:\Program Files\Oracle\VirtualBox"
VBoxManage.exe dhcpserver add --macaddress 080027000010 --ipaddress 192.168.56.10 --netname HostInterfaceNetworking-VirtualBox Host-Only Ethernet Adapter

echo Checking if the machine already exists...
VBoxManage.exe list vms | findstr "DC1" >nul
if %errorlevel% == 0 (
    echo Machine DC1 already exists.
) else (
    echo Importing new machine...
    VBoxManage.exe import "E:\Windows Server 2022_sysprep.ova" --vsys 0 --vmname DC1
)

echo Configuring the machine...
VBoxManage.exe modifyvm DC1 --cpus 2 --memory 2048

echo Setting static MAC address for the second network adapter...
VBoxManage.exe modifyvm DC1 --macaddress2 080027000010

echo Configuring network adapters...
VBoxManage.exe modifyvm DC1 --nic1 nat
VBoxManage.exe modifyvm DC1 --nic2 hostonly --hostonlyadapter2 "VirtualBox Host-Only Ethernet Adapter"
VBoxManage.exe modifyvm DC1 --natpf1 "winrm,tcp,,5985,,5985"

echo Starting the machine...
VBoxManage.exe showvminfo DC1 | findstr "running" >nul
if %errorlevel% == 1 (
    VBoxManage.exe startvm DC1 --type headless
) else (
    echo Machine is already running
)