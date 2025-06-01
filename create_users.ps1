# Skrypt tworzący jednostki organizacyjne i użytkowników w Active Directory
Start-Transcript -Path "C:\temp\create_users.log" -Force
Write-Host "========== ROZPOCZECIE TWORZENIA STRUKTURY OU I UZYTKOWNIKOW: $(Get-Date) =========="

# Domena
$domainDN = (Get-ADDomain).DistinguishedName

# 1. Tworzenie jednostek organizacyjnych
$OUList = @("Dyrektorzy", "Handlowcy", "Magazynierzy")
foreach ($OU in $OUList) {
    try {
        # Sprawdź czy OU już istnieje
        $ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" -ErrorAction SilentlyContinue
      
        if (-not $ouExists) {
            Write-Host "Tworzenie jednostki organizacyjnej: $OU"
            New-ADOrganizationalUnit -Name $OU -Path $domainDN -ProtectedFromAccidentalDeletion $true
        }
        else {
            Write-Host "Jednostka organizacyjna $OU już istnieje"
        }
    }
    catch {
        Write-Host "Błąd przy tworzeniu OU $OU : $_" -ForegroundColor Red
    }
}

# 2. Tworzenie użytkowników w każdej jednostce organizacyjnej
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
            # Sprawdź czy użytkownik już istnieje
            $userExists = Get-ADUser -Filter "SamAccountName -eq '$user'" -ErrorAction SilentlyContinue
          
            if (-not $userExists) {
                Write-Host "Tworzenie użytkownika $user w $OU"
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
                Write-Host "Użytkownik $user już istnieje"
            }
        }
        catch {
            Write-Host "Błąd przy tworzeniu użytkownika $user : $_" -ForegroundColor Red
        }
    }
}

Write-Host "========== ZAKONCZENIE TWORZENIA STRUKTURY: $(Get-Date) =========="
Stop-Transcript