Start-Transcript -Path "C:\temp\create_shares.log" -Force
Write-Host "========== STARTED CREATING NETWORK SHARES: $(Get-Date) =========="

$sharesRoot = "C:\Shares"
if (-not (Test-Path $sharesRoot)) {
    New-Item -Path $sharesRoot -ItemType Directory -Force | Out-Null
    Write-Host "Created main shares directory: $sharesRoot"
}

$shares = @(
    @{
        Name        = "PUBLIC"
        Path        = "$sharesRoot\PUBLIC"
        Description = "Share accessible to all groups"
        Permissions = @(
            @{Group = "CORP\Dyrektorzy"; Access = "Full" }
            @{Group = "CORP\Handlowcy"; Access = "Full" }
            @{Group = "CORP\Magazynierzy"; Access = "Full" }
        )
    },
    @{
        Name        = "PRIVATE"
        Path        = "$sharesRoot\PRIVATE"
        Description = "Share with restricted access"
        Permissions = @(
            @{Group = "CORP\Dyrektorzy"; Access = "Full" }
            @{Group = "CORP\Handlowcy"; Access = "Read" }
            @{Group = "CORP\Magazynierzy"; Access = "None" }
        )
    },
    @{
        Name        = "DATA"
        Path        = "$sharesRoot\DATA"
        Description = "Share for data with different access levels"
        Permissions = @(
            @{Group = "CORP\Dyrektorzy"; Access = "None" }
            @{Group = "CORP\Handlowcy"; Access = "Read" }
            @{Group = "CORP\Magazynierzy"; Access = "Full" }
        )
    }
)

function Set-SharePermissions {
    param (
        [string]$Path,
        [string]$Group,
        [string]$Access
    )

    icacls $Path /reset | Out-Null

    switch ($Access) {
        "Full" {
            Write-Host "Setting full access for $Group to $Path"
            icacls $Path /grant "${Group}:(OI)(CI)F" | Out-Null
        }
        "Read" {
            Write-Host "Setting read access for $Group to $Path"
            icacls $Path /grant "${Group}:(OI)(CI)RX" | Out-Null
        }
        "None" {
            Write-Host "No access for $Group to $Path"
        }
    }
}

$groups = @("Dyrektorzy", "Handlowcy", "Magazynierzy")
foreach ($group in $groups) {
    try {
        $groupObj = Get-ADGroup -Identity $group -ErrorAction SilentlyContinue
        if (-not $groupObj) {
            Write-Host "Creating group $group in AD"
            New-ADGroup -Name $group -GroupScope Global -GroupCategory Security
        }
    }
    catch {
        Write-Host "Error checking/creating group $group $_" -ForegroundColor Yellow
        Write-Host "Ensure these groups are already created in AD"
    }
}

foreach ($share in $shares) {
    if (-not (Test-Path $share.Path)) {
        New-Item -Path $share.Path -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $($share.Path)"
    }
    else {
        Write-Host "Directory $($share.Path) already exists"
    }

    $sampleFilePath = "$($share.Path)\README.txt"
    "This is a sample file in the $($share.Name) share" | Out-File -FilePath $sampleFilePath -Force
    Write-Host "Created sample file in $sampleFilePath"

    icacls $share.Path /reset | Out-Null
    icacls $share.Path /inheritance:r | Out-Null

    icacls $share.Path /grant "Administrators:(OI)(CI)F" | Out-Null
    icacls $share.Path /grant "SYSTEM:(OI)(CI)F" | Out-Null

    foreach ($perm in $share.Permissions) {
        Set-SharePermissions -Path $share.Path -Group $perm.Group -Access $perm.Access
    }

    $existingShare = Get-SmbShare -Name $share.Name -ErrorAction SilentlyContinue
    if ($existingShare) {
        Write-Host "Removing existing share: $($share.Name)"
        Remove-SmbShare -Name $share.Name -Force
    }

    Write-Host "Creating network share: $($share.Name)"
    New-SmbShare -Name $share.Name -Path $share.Path -Description $share.Description -FullAccess "Everyone" | Out-Null

    Write-Host "Share $($share.Name) successfully created and configured"
}

Write-Host "========== FINISHED CREATING NETWORK SHARES: $(Get-Date) =========="
Stop-Transcript