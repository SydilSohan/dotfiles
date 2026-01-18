#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows disk cleanup script - frees up disk space by removing caches, temp files, and unused data.
.DESCRIPTION
    This script performs various cleanup tasks to free disk space:
    - Development caches (npm, pip, nuget, gradle, maven)
    - Browser caches (Chrome, Edge, Brave, Firefox)
    - Docker cleanup and WSL disk compaction
    - Windows temp files and crash dumps
    - NVIDIA shader caches
    - Optional: Android SDK, WSL distros, Downloads cleanup
.NOTES
    Run as Administrator for full cleanup capabilities.
    Author: Auto-generated cleanup script
#>

param(
    [switch]$All,           # Run all cleanups without prompting
    [switch]$DevCaches,     # Clean development caches only
    [switch]$Browsers,      # Clean browser caches only
    [switch]$Docker,        # Docker prune and compact only
    [switch]$System,        # System temp files only
    [switch]$DryRun         # Show what would be cleaned without deleting
)

$ErrorActionPreference = "SilentlyContinue"

function Get-FolderSize {
    param([string]$Path)
    if (Test-Path $Path) {
        $bytes = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
                  Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        return [math]::Round($bytes/1GB, 2)
    }
    return 0
}

function Write-Header {
    param([string]$Text)
    Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host "$('=' * 60)" -ForegroundColor Cyan
}

function Remove-FolderContents {
    param(
        [string]$Path,
        [string]$Name,
        [switch]$Recurse
    )
    if (Test-Path $Path) {
        $size = Get-FolderSize $Path
        if ($size -gt 0.01) {
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would clean $Name : $size GB" -ForegroundColor Yellow
            } else {
                if ($Recurse) {
                    Remove-Item "$Path\*" -Recurse -Force -ErrorAction SilentlyContinue
                } else {
                    Remove-Item "$Path\*" -Force -ErrorAction SilentlyContinue
                }
                Write-Host "  Cleaned $Name : $size GB" -ForegroundColor Green
            }
            return $size
        }
    }
    return 0
}

# Track total space freed
$totalFreed = 0
$startFree = (Get-PSDrive C).Free / 1GB

Write-Host "`n  WINDOWS DISK CLEANUP SCRIPT" -ForegroundColor Magenta
Write-Host "  Current free space: $([math]::Round($startFree, 2)) GB`n" -ForegroundColor Gray

# =============================================================================
# DEVELOPMENT CACHES
# =============================================================================
if ($All -or $DevCaches -or (-not $PSBoundParameters.Count)) {
    Write-Header "Development Caches"

    # npm cache
    $npmCache = "$env:LOCALAPPDATA\npm-cache"
    $size = Get-FolderSize $npmCache
    if ($size -gt 0.01) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would clean npm cache : $size GB" -ForegroundColor Yellow
        } else {
            npm cache clean --force 2>$null
            Write-Host "  Cleaned npm cache : $size GB" -ForegroundColor Green
        }
        $totalFreed += $size
    }

    # pip cache
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\pip\Cache" "pip cache" -Recurse

    # nuget cache
    $totalFreed += Remove-FolderContents "$env:USERPROFILE\.nuget\packages" "NuGet cache" -Recurse

    # gradle cache
    $totalFreed += Remove-FolderContents "$env:USERPROFILE\.gradle\caches" "Gradle cache" -Recurse

    # maven cache
    $totalFreed += Remove-FolderContents "$env:USERPROFILE\.m2\repository" "Maven cache" -Recurse

    # yarn cache
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\Yarn\Cache" "Yarn cache" -Recurse
}

# =============================================================================
# BROWSER CACHES
# =============================================================================
if ($All -or $Browsers -or (-not $PSBoundParameters.Count)) {
    Write-Header "Browser Caches"

    # Chrome
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache" "Chrome cache" -Recurse
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache" "Chrome code cache" -Recurse

    # Edge
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache" "Edge cache" -Recurse
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache" "Edge code cache" -Recurse

    # Brave
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache" "Brave cache" -Recurse
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache" "Brave code cache" -Recurse

    # Firefox
    $firefoxProfiles = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $firefoxProfiles) {
        Get-ChildItem $firefoxProfiles -Directory | ForEach-Object {
            $totalFreed += Remove-FolderContents "$($_.FullName)\cache2" "Firefox cache" -Recurse
        }
    }
}

# =============================================================================
# SYSTEM CLEANUP
# =============================================================================
if ($All -or $System -or (-not $PSBoundParameters.Count)) {
    Write-Header "System Cleanup"

    # User temp
    $totalFreed += Remove-FolderContents $env:TEMP "User Temp" -Recurse

    # Windows temp
    $totalFreed += Remove-FolderContents "C:\Windows\Temp" "Windows Temp" -Recurse

    # Crash dumps
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\CrashDumps" "Crash dumps" -Recurse

    # NVIDIA caches
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\NVIDIA\DXCache" "NVIDIA DX cache" -Recurse
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\NVIDIA\GLCache" "NVIDIA GL cache" -Recurse

    # DirectX shader cache
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\D3DSCache" "DirectX shader cache" -Recurse

    # Windows Update cache (requires admin)
    $totalFreed += Remove-FolderContents "C:\Windows\SoftwareDistribution\Download" "Windows Update cache" -Recurse

    # Thumbnail cache
    $totalFreed += Remove-FolderContents "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" "Thumbnail cache" -Recurse
}

# =============================================================================
# DOCKER CLEANUP
# =============================================================================
if ($All -or $Docker -or (-not $PSBoundParameters.Count)) {
    Write-Header "Docker Cleanup"

    # Check if Docker is running
    $dockerRunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue

    if ($dockerRunning) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would run: docker system prune -a --volumes -f" -ForegroundColor Yellow
        } else {
            Write-Host "  Running docker system prune..." -ForegroundColor Gray
            docker system prune -a --volumes -f 2>$null
            Write-Host "  Docker pruned" -ForegroundColor Green
        }
    } else {
        Write-Host "  Docker not running - skipping prune" -ForegroundColor Yellow
    }

    # Compact WSL disk
    $dockerVhdx = "$env:LOCALAPPDATA\Docker\wsl\disk\docker_data.vhdx"
    if (Test-Path $dockerVhdx) {
        $sizeBefore = (Get-Item $dockerVhdx).Length / 1GB

        if ($DryRun) {
            Write-Host "  [DRY RUN] Would compact Docker WSL disk ($([math]::Round($sizeBefore, 2)) GB)" -ForegroundColor Yellow
        } else {
            Write-Host "  Compacting Docker WSL disk..." -ForegroundColor Gray

            # Stop Docker and WSL
            Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
            Stop-Process -Name "com.docker*" -Force -ErrorAction SilentlyContinue
            Start-Sleep 3
            wsl --shutdown
            Start-Sleep 3

            # Compact using diskpart
            $diskpartScript = @"
select vdisk file="$dockerVhdx"
attach vdisk readonly
compact vdisk
detach vdisk
"@
            $diskpartScript | diskpart 2>$null

            $sizeAfter = (Get-Item $dockerVhdx).Length / 1GB
            $saved = $sizeBefore - $sizeAfter
            Write-Host "  Compacted Docker disk: saved $([math]::Round($saved, 2)) GB" -ForegroundColor Green
            $totalFreed += $saved
        }
    }
}

# =============================================================================
# SUMMARY
# =============================================================================
Write-Header "Summary"

$endFree = (Get-PSDrive C).Free / 1GB
$actualFreed = $endFree - $startFree

if ($DryRun) {
    Write-Host "  [DRY RUN] Estimated space to free: ~$([math]::Round($totalFreed, 2)) GB" -ForegroundColor Yellow
} else {
    Write-Host "  Space freed: $([math]::Round($actualFreed, 2)) GB" -ForegroundColor Green
    Write-Host "  Current free space: $([math]::Round($endFree, 2)) GB" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# INTERACTIVE OPTIONS (only if no flags specified)
# =============================================================================
if (-not $PSBoundParameters.Count -and -not $DryRun) {
    Write-Header "Additional Cleanup Options"

    # Check for large items
    $androidSdk = "$env:LOCALAPPDATA\Android\Sdk"
    if (Test-Path $androidSdk) {
        $size = Get-FolderSize $androidSdk
        if ($size -gt 0.5) {
            $response = Read-Host "  Android SDK found ($size GB). Remove? [y/N]"
            if ($response -eq 'y') {
                Remove-Item $androidSdk -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  Removed Android SDK" -ForegroundColor Green
            }
        }
    }

    # Check for WSL distros
    $wslDistros = wsl --list --quiet 2>$null | Where-Object { $_ -and $_ -notmatch "docker" }
    if ($wslDistros) {
        Write-Host "`n  WSL distributions found:" -ForegroundColor Gray
        $wslDistros | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
        $response = Read-Host "  Remove unused WSL distros? [y/N]"
        if ($response -eq 'y') {
            $wslDistros | ForEach-Object {
                $distro = $_.Trim()
                if ($distro) {
                    wsl --unregister $distro 2>$null
                    Write-Host "  Removed WSL: $distro" -ForegroundColor Green
                }
            }
        }
    }

    # Check Downloads for installers
    $installers = Get-ChildItem "$env:USERPROFILE\Downloads" -Include "*.exe","*.msi","*.apk" -Recurse -ErrorAction SilentlyContinue
    if ($installers) {
        $size = ($installers | Measure-Object -Property Length -Sum).Sum / 1GB
        if ($size -gt 0.1) {
            Write-Host "`n  Installers in Downloads: $([math]::Round($size, 2)) GB" -ForegroundColor Gray
            $response = Read-Host "  Remove installer files? [y/N]"
            if ($response -eq 'y') {
                $installers | Remove-Item -Force -ErrorAction SilentlyContinue
                Write-Host "  Removed installers" -ForegroundColor Green
            }
        }
    }
}
