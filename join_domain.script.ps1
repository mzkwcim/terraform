$DomainName = "CORP.LOCAL"
$DomainAdmin = "Administrator"
$DomainPassword = "zaq1@WSX"

$interface = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
Set-DnsClientServerAddress -InterfaceIndex $interface.ifIndex -ServerAddresses "192.168.56.106"

$SecPassword = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("$DomainName\$DomainAdmin", $SecPassword)

Write-Output "Joining domain $DomainName..."
try {
    Add-Computer -DomainName $DomainName -Credential $Credential -Restart -Force -ErrorAction Stop

    Add-LocalGroupMember -Group "Users" -Member "$DomainName\Domain Users" -ErrorAction SilentlyContinue

    Write-Output "Computer successfully joined the domain. The system will restart."
}
catch {
    Write-Error "Error joining domain: $_"
    exit 1
}