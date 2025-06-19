Start-Transcript -Path "C:\temp\create_advanced_gpo.log" -Force
Write-Host "========== STARTED CREATING ADVANCED GPO: $(Get-Date) =========="

$domainDN = (Get-ADDomain).DistinguishedName

$wallpapersDir = "C:\Wallpapers"
if (-not (Test-Path $wallpapersDir)) {
    New-Item -Path $wallpapersDir -ItemType Directory -Force | Out-Null
}

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

    Write-Host "Wallpaper created: $FilePath"
}

$dyrektorzyWallpaper = "$wallpapersDir\dyrektorzy.jpg"
$handlowcyWallpaper = "$wallpapersDir\handlowcy.jpg"

Add-Type -AssemblyName System.Drawing
New-SimpleWallpaper -FilePath $dyrektorzyWallpaper -Text "DYREKTORZY" -BackgroundColor [System.Drawing.Color]::DarkBlue -TextColor [System.Drawing.Color]::White
New-SimpleWallpaper -FilePath $handlowcyWallpaper -Text "HANDLOWCY" -BackgroundColor [System.Drawing.Color]::DarkGreen -TextColor [System.Drawing.Color]::White

Write-Host "Creating and Configuring advanced GPO..."

$gpoName = "dyrektorzy-blokada"
$ouPath = "OU=Dyrektorzy,$domainDN"

$gpoExists = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if ($gpoExists) {
    Write-Host "Deleting existing GPO: $gpoName"
    Remove-GPO -Name $gpoName -Force
}

Write-Host "Creating GPO: $gpoName"
New-GPO -Name $gpoName -Comment "Polityka blokad dla Dyrektorów"

Write-Host "Configuring permissions for Directors"

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "Wallpaper" -Type String -Value $dyrektorzyWallpaper
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WallpaperStyle" -Type String -Value "2"
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -ValueName "NoChangingWallpaper" -Type DWord -Value 1

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "StartButtonBalloonTip" -Type DWord -Value 0

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoMakeAvailableOffline" -Type DWord -Value 1

Write-Host "Linking GPO to $ouPath"
New-GPLink -Name $gpoName -Target $ouPath -LinkEnabled Yes -Enforced Yes

$gpoName = "handlowcy-blokada"
$ouPath = "OU=Handlowcy,$domainDN"

$gpoExists = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if ($gpoExists) {
    Write-Host "Deleting existing GPO: $gpoName"
    Remove-GPO -Name $gpoName -Force
}

Write-Host "Creating GPO: $gpoName"
New-GPO -Name $gpoName -Comment "Polityka blokad dla Handlowców"

Write-Host "Configuring permissions for Sales"

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "Wallpaper" -Type String -Value $handlowcyWallpaper
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WallpaperStyle" -Type String -Value "2"
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -ValueName "NoChangingWallpaper" -Type DWord -Value 1

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoRun" -Type DWord -Value 1

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DisableRegistryTools" -Type DWord -Value 1

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "Start_ShowMyDocs" -Type DWord -Value 0
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "Start_ShowMyPics" -Type DWord -Value 0
Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "Start_ShowMyMusic" -Type DWord -Value 0

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoSaveSettings" -Type DWord -Value 1

Write-Host "Linking GPO to $ouPath"
New-GPLink -Name $gpoName -Target $ouPath -LinkEnabled Yes -Enforced Yes

$gpoName = "magazynierzy-blokada"
$ouPath = "OU=Magazynierzy,$domainDN"

$gpoExists = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if ($gpoExists) {
    Write-Host "Deleting existing GPO: $gpoName"
    Remove-GPO -Name $gpoName -Force
}

Write-Host "Creating GPO: $gpoName"
New-GPO -Name $gpoName -Comment "Polityka blokad dla Magazynierów"

Write-Host "Configuring permissions for Warehouse Staff"

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DisableRegistryTools" -Type DWord -Value 1

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoDrives" -Type DWord -Value 4

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWord -Value 1

Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoInternetSearch" -Type DWord -Value 1

Write-Host "Linking GPO to $ouPath"
New-GPLink -Name $gpoName -Target $ouPath -LinkEnabled Yes -Enforced Yes

Write-Host "========== FINISHED CREATING ADVANCED GPO: $(Get-Date) =========="
Stop-Transcript