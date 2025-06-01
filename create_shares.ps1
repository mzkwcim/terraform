# Skrypt tworzący udziały sieciowe z odpowiednimi uprawnieniami
Start-Transcript -Path "C:\temp\create_shares.log" -Force
Write-Host "========== ROZPOCZECIE TWORZENIA UDZIALOW SIECIOWYCH: $(Get-Date) =========="

# Główny katalog na udziały
$sharesRoot = "C:\Shares"
if (-not (Test-Path $sharesRoot)) {
    New-Item -Path $sharesRoot -ItemType Directory -Force | Out-Null
    Write-Host "Utworzono główny katalog udziałów: $sharesRoot"
}

# Definicje udziałów i uprawnień
$shares = @(
    @{
        Name        = "PUBLICZNY"
        Path        = "$sharesRoot\PUBLICZNY"
        Description = "Udział dostępny dla wszystkich grup"
        Permissions = @(
            @{Group = "CORP\Dyrektorzy"; Access = "Full" }
            @{Group = "CORP\Handlowcy"; Access = "Full" }
            @{Group = "CORP\Magazynierzy"; Access = "Full" }
        )
    },
    @{
        Name        = "PRYWATNY"
        Path        = "$sharesRoot\PRYWATNY"
        Description = "Udział z ograniczonym dostępem"
        Permissions = @(
            @{Group = "CORP\Dyrektorzy"; Access = "Full" }
            @{Group = "CORP\Handlowcy"; Access = "Read" }
            @{Group = "CORP\Magazynierzy"; Access = "None" }
        )
    },
    @{
        Name        = "DANE"
        Path        = "$sharesRoot\DANE"
        Description = "Udział dla danych z różnymi poziomami dostępu"
        Permissions = @(
            @{Group = "CORP\Dyrektorzy"; Access = "None" }
            @{Group = "CORP\Handlowcy"; Access = "Read" }
            @{Group = "CORP\Magazynierzy"; Access = "Full" }
        )
    }
)

# Funkcja mapująca poziom dostępu na uprawnienia NTFS i udostępniania
function Set-SharePermissions {
    param (
        [string]$Path,
        [string]$Group,
        [string]$Access
    )

    # Resetujemy dziedziczenie uprawnień
    icacls $Path /reset | Out-Null

    # Ustawiamy uprawnienia w zależności od poziomu dostępu
    switch ($Access) {
        "Full" {
            Write-Host "Ustawianie pełnego dostępu dla $Group do $Path"
            icacls $Path /grant "${Group}:(OI)(CI)F" | Out-Null
        }
        "Read" {
            Write-Host "Ustawianie dostępu do odczytu dla $Group do $Path"
            icacls $Path /grant "${Group}:(OI)(CI)RX" | Out-Null
        }
        "None" {
            Write-Host "Brak dostępu dla $Group do $Path"
            # W przypadku braku dostępu nie dodajemy żadnych uprawnień
        }
    }
}

# Utworzenie grup AD jeśli nie istnieją (zabezpieczenie)
$groups = @("Dyrektorzy", "Handlowcy", "Magazynierzy")
foreach ($group in $groups) {
    try {
        $groupObj = Get-ADGroup -Identity $group -ErrorAction SilentlyContinue
        if (-not $groupObj) {
            Write-Host "Tworzenie grupy $group w AD"
            New-ADGroup -Name $group -GroupScope Global -GroupCategory Security
        }
    }
    catch {
        Write-Host "Błąd przy sprawdzaniu/tworzeniu grupy $group $_" -ForegroundColor Yellow
        Write-Host "Upewnij się, że grupy te są już utworzone w AD"
    }
}

# Tworzenie i konfiguracja udziałów
foreach ($share in $shares) {
    # Tworzenie katalogów
    if (-not (Test-Path $share.Path)) {
        New-Item -Path $share.Path -ItemType Directory -Force | Out-Null
        Write-Host "Utworzono katalog: $($share.Path)"
    }
    else {
        Write-Host "Katalog $($share.Path) już istnieje"
    }

    # Dodanie przykładowych plików
    $sampleFilePath = "$($share.Path)\README.txt"
    "To jest przykładowy plik w udziale $($share.Name)" | Out-File -FilePath $sampleFilePath -Force
    Write-Host "Utworzono przykładowy plik w $sampleFilePath"

    # Resetowanie uprawnień i usuwanie dziedziczenia
    icacls $share.Path /reset | Out-Null
    icacls $share.Path /inheritance:r | Out-Null

    # Dodanie podstawowych uprawnień dla Administratorów i SYSTEM
    icacls $share.Path /grant "Administrators:(OI)(CI)F" | Out-Null
    icacls $share.Path /grant "SYSTEM:(OI)(CI)F" | Out-Null

    # Ustawianie uprawnień dla grup
    foreach ($perm in $share.Permissions) {
        Set-SharePermissions -Path $share.Path -Group $perm.Group -Access $perm.Access
    }

    # Usuwanie istniejącego udziału (jeśli istnieje)
    $existingShare = Get-SmbShare -Name $share.Name -ErrorAction SilentlyContinue
    if ($existingShare) {
        Write-Host "Usuwanie istniejącego udziału: $($share.Name)"
        Remove-SmbShare -Name $share.Name -Force
    }

    # Tworzenie udziału sieciowego
    Write-Host "Tworzenie udziału sieciowego: $($share.Name)"
    New-SmbShare -Name $share.Name -Path $share.Path -Description $share.Description -FullAccess "Everyone" | Out-Null

    Write-Host "Udział $($share.Name) został pomyślnie utworzony i skonfigurowany"
}

Write-Host "========== ZAKONCZENIE TWORZENIA UDZIALOW SIECIOWYCH: $(Get-Date) =========="
Stop-Transcript