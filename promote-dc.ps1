Start-Transcript -Path "C:\temp\dc_transcript.log" -Force

Write-Host "========== STARTED DC PROMOTION: $(Get-Date) =========="

$DomainName = "corp.local"
$DomainNetBIOSName = "CORP"
$SafeModePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

Write-Host "Installing AD DS role..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$osInfo = Get-WmiObject -Class Win32_OperatingSystem
if ($osInfo.ProductType -eq 2) {
  Write-Host "Server is already a domain controller. Promotion skipped."
  exit 0
}

Write-Host "Starting domain controller promotion..."
Write-Host "Domain: $DomainName"

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

  Write-Host "Promotion completed. Server will restart."
}
catch {
  Write-Host "ERROR during promotion: $_"
  Write-Host $_.Exception.Message
  Write-Host $_.ScriptStackTrace
  exit 1
}

Write-Host "========== SCRIPT ENDED: $(Get-Date) =========="
Stop-Transcript