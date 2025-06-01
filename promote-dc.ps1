# Skrypt do promocji serwera do kontrolera domeny
# Zapisz ten plik jako UTF-8 z BOM!

# Rozpocznij logowanie
Start-Transcript -Path "C:\temp\dc_transcript.log" -Force

Write-Host "========== ROZPOCZECIE PROMOCJI DO DC: $(Get-Date) =========="

# Parametry domeny
$DomainName = "corp.local"
$DomainNetBIOSName = "CORP"
$SafeModePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

# Instalacja roli Active Directory Domain Services
Write-Host "Instalacja roli AD DS..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Sprawdz czy serwer nie jest juz kontrolerem domeny
$osInfo = Get-WmiObject -Class Win32_OperatingSystem
if ($osInfo.ProductType -eq 2) {
  Write-Host "Serwer jest juz kontrolerem domeny. Promocja pominieta."
  exit 0
}

Write-Host "Rozpoczecie promocji do kontrolera domeny..."
Write-Host "Domena: $DomainName"

# Promocja serwera do roli kontrolera domeny w nowym lesie
try {
  Import-Module ADDSDeployment
  Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetBIOSName `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $SafeModePassword `
    -Force:$true

  # Ten kod moze nie zostac wykonany, jesli NoRebootOnCompletion to $false
  Write-Host "Promocja zakonczona. Serwer zostanie uruchomiony ponownie."
}
catch {
  Write-Host "ERROR podczas promocji: $_"
  Write-Host $_.Exception.Message
  Write-Host $_.ScriptStackTrace
  exit 1
}

Write-Host "========== KONIEC SKRYPTU: $(Get-Date) =========="
Stop-Transcript