# Skrypt tworzący zaawansowane obiekty Group Policy dla jednostek organizacyjnych
Start-Transcript -Path "C:\temp\create_advanced_gpo.log" -Force
Write-Host "========== ROZPOCZECIE TWORZENIA ZAAWANSOWANYCH GPO: $(Get-Date) =========="

# Domena
$domainDN = (Get-ADDomain).DistinguishedName

# 1. Tworzenie tapet dla grup
$wallpapersDir = "C:\Wallpapers"
if (-not (Test-Path $wallpapersDir)) {
    New-Item -Path $wallpapersDir -ItemType Directory -Force | Out-Null
}

# Funkcja do tworzenia prostej tapety
function New-SimpleWallpaper {
    param (
        [string]$FilePath,
        [string]$Text,
        [System.Drawing.Color]$BackgroundColor,
        [System.Drawing.Color]$TextColor
    )
  
    Add-Type -AssemblyName System.Drawing
  
    $bitmap = New-Object System.Drawing.Bitmap 1920, 1080
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear($BackgroundColor)
  
    $font = New-Object System.Drawing.Font("Arial", 48, [System.Drawing.FontStyle]::Bold)
    $brush = New-Object System.Drawing.SolidBrush($TextColor)
  
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
  
    $rectangle = New-Object System.Drawing.RectangleF(0, 0, $bitmap.Width, $bitmap.Height)
    $graphics.DrawString($Text, $font, $brush, $rectangle, $stringFormat)
  
    $bitmap.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $graphics.Dispose()
    $bitmap.Dispose()
  
    Write-Host "Tapeta została utworzona: $FilePath"
}

# Tworzenie tapet dla grup
$dyrektorzyWallpaper = "$wallpapersDir\dyrektorzy.jpg"
$handlowcyWallpaper = "$wallpapersDir\handlowcy.jpg"

Add-Type -AssemblyName System.Drawing
New-SimpleWallpaper -FilePath $dyrektorzyWallpaper -Text "DYREKTORZY" -BackgroundColor [System.Drawing.Color]::DarkBlue -TextColor [System.Drawing.Color]::White
New-SimpleWallpaper -FilePath $handlowcyWallpaper -Text "HANDLOWCY" -BackgroundColor [System.Drawing.Color]::DarkGreen -TextColor [System.Drawing.Color]::White

# 2. Tworzenie zaawansowanych GPO i konfigurowanie uprawnień
Write-Host "Tworzenie i konfigurowanie zaawansowanych GPO..."

# ========== DYREKTORZY ==========
$gpoName = "dyrektorzy-blokada"
$ouPath = "OU=Dyrektorzy,$domainDN"

# Sprawdzenie czy GPO istnieje, jeśli tak - usunięcie
$gpoExists = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if ($gpoExists) {
    Write-Host "Usuwanie istniejącego GPO: $gpoName"
    Remove-GPO -Name $gpoName -Force
}

Write-Host "Tworzenie GPO: $gpoName"
New-GPO -Name $gpoName -Comment "Polityka blokad dla Dyrektorów"

# Konfiguracja GPO dla Dyrektorów
Write-Host "Konfigurowanie uprawnień dla Dyrektorów"

# Stała tapeta
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "Wallpaper" -Type String -Value $dyrektorzyWallpaper
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WallpaperStyle" -Type String -Value "2" # 2 = Rozciągnij
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -ValueName "NoChangingWallpaper" -Type DWord -Value 1

# Blokada edycji panelu sterowania
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1

# Usuń porady dymkowe dla menu start
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "StartButtonBalloonTip" -Type DWord -Value 0

# Usuń opcję "Udostępnij w trybie offline"
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoMakeAvailableOffline" -Type DWord -Value 1

# Linkowanie GPO do jednostki organizacyjnej
Write-Host "Linkowanie GPO do $ouPath"
New-GPLink -Name $gpoName -Target $ouPath -LinkEnabled Yes -Enforced Yes

# ========== HANDLOWCY ==========
$gpoName = "handlowcy-blokada"
$ouPath = "OU=Handlowcy,$domainDN"

# Sprawdzenie czy GPO istnieje, jeśli tak - usunięcie
$gpoExists = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if ($gpoExists) {
    Write-Host "Usuwanie istniejącego GPO: $gpoName"
    Remove-GPO -Name $gpoName -Force
}

Write-Host "Tworzenie GPO: $gpoName"
New-GPO -Name $gpoName -Comment "Polityka blokad dla Handlowców"

# Konfiguracja GPO dla Handlowców
Write-Host "Konfigurowanie uprawnień dla Handlowców"

# Stała tapeta
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "Wallpaper" -Type String -Value $handlowcyWallpaper
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WallpaperStyle" -Type String -Value "2" # 2 = Rozciągnij
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -ValueName "NoChangingWallpaper" -Type DWord -Value 1

# Brak polecenia uruchom w menu start
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoRun" -Type DWord -Value 1

# Brak możliwości edycji narzędzi rejestru
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DisableRegistryTools" -Type DWord -Value 1

# Wyłączenie menu spersonalizowanego
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "Start_ShowMyDocs" -Type DWord -Value 0
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "Start_ShowMyPics" -Type DWord -Value 0
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "Start_ShowMyMusic" -Type DWord -Value 0

# Nie zapisuj ustawień przy zamykaniu systemu
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoSaveSettings" -Type DWord -Value 1

# Linkowanie GPO do jednostki organizacyjnej
Write-Host "Linkowanie GPO do $ouPath"
New-GPLink -Name $gpoName -Target $ouPath -LinkEnabled Yes -Enforced Yes

# ========== MAGAZYNIERZY ==========
$gpoName = "magazynierzy-blokada"
$ouPath = "OU=Magazynierzy,$domainDN"

# Sprawdzenie czy GPO istnieje, jeśli tak - usunięcie
$gpoExists = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if ($gpoExists) {
    Write-Host "Usuwanie istniejącego GPO: $gpoName"
    Remove-GPO -Name $gpoName -Force
}

Write-Host "Tworzenie GPO: $gpoName"
New-GPO -Name $gpoName -Comment "Polityka blokad dla Magazynierów"

# Konfiguracja GPO dla Magazynierów
Write-Host "Konfigurowanie uprawnień dla Magazynierów"

# Brak możliwości edycji narzędzi rejestru
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DisableRegistryTools" -Type DWord -Value 1

# Ukryj dysk C (wartość 4 dla dysku C)
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoDrives" -Type DWord -Value 4

# Zabroń dostępu do wiersza polecenia
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWord -Value 1

# Nie wyszukuj w Internecie
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoInternetSearch" -Type DWord -Value 1

# Linkowanie GPO do jednostki organizacyjnej
Write-Host "Linkowanie GPO do $ouPath"
New-GPLink -Name $gpoName -Target $ouPath -LinkEnabled Yes -Enforced Yes

Write-Host "========== ZAKONCZENIE TWORZENIA ZAAWANSOWANYCH GPO: $(Get-Date) =========="
Stop-Transcript