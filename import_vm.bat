@echo off
cd "C:\Program Files\Oracle\VirtualBox"
REM Dodaj stałą rezerwację dla określonego MAC adresu
VBoxManage.exe dhcpserver add --macaddress 080027000010 --ipaddress 192.168.56.10 --netname HostInterfaceNetworking-VirtualBox Host-Only Ethernet Adapter

REM Sprawdź czy maszyna już istnieje
echo Sprawdzam czy maszyna już istnieje...
VBoxManage.exe list vms | findstr "DC1" >nul
if %errorlevel% == 0 (
echo Maszyna DC1 już istnieje.
) else (
echo Importowanie nowej maszyny...
VBoxManage.exe import "E:\Windows Server 2022_sysprep.ova" --vsys 0 --vmname DC1
)

REM Konfiguracja maszyny
VBoxManage.exe modifyvm DC1 --cpus 2 --memory 2048

REM Ustawienie statycznego MAC adresu dla drugiego adaptera sieciowego
VBoxManage.exe modifyvm DC1 --macaddress2 080027000010

REM Konfiguracja adapterów sieciowych
VBoxManage.exe modifyvm DC1 --nic1 nat
VBoxManage.exe modifyvm DC1 --nic2 hostonly --hostonlyadapter2 "VirtualBox Host-Only Ethernet Adapter"
VBoxManage.exe modifyvm DC1 --natpf1 "winrm,tcp,,5985,,5985"

REM Uruchomienie maszyny
VBoxManage.exe showvminfo DC1 | findstr "running" >nul
if %errorlevel% == 1 (
VBoxManage.exe startvm DC1 --type headless
) else (
echo Maszyna już jest uruchomiona
)