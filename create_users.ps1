Start-Transcript -Path "C:\temp\create_users.log" -Force
Write-Host "========== STARTED CREATING OU STRUCTURE AND USERS: $(Get-Date) =========="

$domainDN = (Get-ADDomain).DistinguishedName

$OUList = @("Dyrektorzy", "Handlowcy", "Magazynierzy")
foreach ($OU in $OUList) {
    try {
        $ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" -ErrorAction SilentlyContinue
  
        if (-not $ouExists) {
            Write-Host "Creating Organizational Unit: $OU"
            New-ADOrganizationalUnit -Name $OU -Path $domainDN -ProtectedFromAccidentalDeletion $true
        }
        else {
            Write-Host "Organizational Unit $OU already exists"
        }
    }
    catch {
        Write-Host "Error creating OU $OU : $_" -ForegroundColor Red
    }
}

$password = ConvertTo-SecureString "P@`$`$w0rD" -AsPlainText -Force
$users = @{
    "Dyrektorzy"   = @("dyrektor1", "dyrektor2")
    "Handlowcy"    = @("handlowiec1", "handlowiec2")
    "Magazynierzy" = @("magazynier1", "magazynier2")
}

foreach ($OU in $OUList) {
    $ouDN = "OU=$OU,$domainDN"

    foreach ($user in $users[$OU]) {
        try {
            $userExists = Get-ADUser -Filter "SamAccountName -eq '$user'" -ErrorAction SilentlyContinue
      
            if (-not $userExists) {
                Write-Host "Creating user $user in $OU"
                New-ADUser -Name $user `
                    -SamAccountName $user `
                    -UserPrincipalName "$user@corp.local" `
                    -Path $ouDN `
                    -AccountPassword $password `
                    -Enabled $true `
                    -PasswordNeverExpires $true `
                    -DisplayName $user
            }
            else {
                Write-Host "User $user already exists"
            }
        }
        catch {
            Write-Host "Error creating user $user : $_" -ForegroundColor Red
        }
    }
}

Write-Host "========== FINISHED CREATING OU STRUCTURE AND USERS: $(Get-Date) =========="
Stop-Transcript