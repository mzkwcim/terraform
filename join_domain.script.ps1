# Parametry domeny
$DomainName = "CORP.LOCAL"
$DomainAdmin = "Administrator"
$DomainPassword = "zaq1@WSX"

# Konfiguracja DNS na kontroler domeny
$interface = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
Set-DnsClientServerAddress -InterfaceIndex $interface.ifIndex -ServerAddresses "192.168.56.106"

# Tworzenie obiektu poświadczeń
$SecPassword = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("$DomainName\$DomainAdmin", $SecPassword)

# Dołączanie do domeny
Write-Output "Dołączanie do domeny $DomainName..."
try {
    Add-Computer -DomainName $DomainName -Credential $Credential -Restart -Force -ErrorAction Stop
  
    # Upewnienie się, że wszyscy użytkownicy domeny mogą się logować
    Add-LocalGroupMember -Group "Użytkownicy" -Member "$DomainName\Domain Users" -ErrorAction SilentlyContinue
  
    Write-Output "Komputer pomyślnie dołączony do domeny. System zostanie zrestartowany."
}
catch {
    Write-Error "Błąd podczas dołączania do domeny: $_"
    exit 1
}