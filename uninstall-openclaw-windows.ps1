param([switch]$DryRun, [switch]$Help)

$ErrorActionPreference = "SilentlyContinue"
$OfficialOk = $false

if ($Help) {
    Write-Host "Usage: .\uninstall-openclaw-windows.ps1 [-DryRun] [-Help]"
    exit 0
}

function Step($idx, $msg) { Write-Host "`n==> [$idx] $msg" -ForegroundColor Cyan }
function Info($msg) { Write-Host " - $msg" }
function Invoke-Action($description, [scriptblock]$action) {
    if ($DryRun) {
        Info "[dry-run] $description"
    } else {
        & $action
    }
}
function Remove-IfExists($path) {
    if (Test-Path $path) {
        Info "removing $path"
        Invoke-Action "Remove-Item -Path $path -Recurse -Force" { Remove-Item -Path $path -Recurse -Force }
    }
}
function Cmd-Exists($name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

function Test-Remaining {
    if (Get-Command openclaw -ErrorAction SilentlyContinue) { return $true }

    $procMatch = Get-Process | Where-Object {
        $_.Name -match "openclaw|openclawd|openclaw-gateway|claw-gateway"
    }
    if ($procMatch) { return $true }

    return $false
}

function Test-Installed {
    if (Get-Command openclaw -ErrorAction SilentlyContinue) { return $true }

    $paths = @(
        "$env:USERPROFILE\.openclaw",
        "$env:APPDATA\openclaw",
        "$env:LOCALAPPDATA\openclaw",
        "$env:APPDATA\npm\openclaw",
        "$env:APPDATA\npm\openclaw.cmd",
        "$env:APPDATA\npm\node_modules\openclaw",
        "$env:APPDATA\npm\node_modules\@openclaw\cli",
        "$env:USERPROFILE\.local\bin\openclaw.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $true }
    }

    $procMatch = Get-Process | Where-Object {
        $_.Name -match "openclaw|openclawd|openclaw-gateway|claw-gateway"
    }
    if ($procMatch) { return $true }

    return $false
}

Step "0/5" "Flow Overview"
Info "1) Detect whether openclaw is installed"
Info "2) Try the official uninstall command first"
Info "3) If traces remain, stop related processes/services and run fallback uninstall"
Info "4) Clean leftover files and config"
Info "5) Verify final uninstall result"
if ($DryRun) { Info "dry-run mode enabled; no system changes will be made" }

Step "1/5" "Detect Installation"
if (-not (Test-Installed)) {
    Info "openclaw was not detected; uninstall skipped"
    exit 0
}
Info "openclaw traces detected; continuing uninstall"

Step "2/5" "Try Official Uninstall"
if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    Info "running official uninstall command"
    Invoke-Action "openclaw uninstall --all --yes" { openclaw uninstall --all --yes | Out-Null }
    if ((-not $DryRun) -and (-not (Test-Remaining))) {
        $OfficialOk = $true
        Info "official uninstall completed successfully"
    }
} else {
    Info "official cli not found, skip direct uninstall"
}

Step "3/5" "Fallback Uninstall"
if ($OfficialOk) {
    Info "official uninstall succeeded; skipping most fallback actions"
} elseif (Test-Remaining) {
    $targetProcesses = Get-Process | Where-Object {
        $_.Name -match "openclaw|openclawd|openclaw-gateway|claw-gateway"
    }
    if ($targetProcesses) {
        foreach ($p in $targetProcesses) {
            Info "stopping process $($p.Name) (PID $($p.Id))"
            Invoke-Action "Stop-Process -Id $($p.Id) -Force" { Stop-Process -Id $p.Id -Force }
        }
    } else {
        Info "no running openclaw process found"
    }

    $targetServices = Get-Service | Where-Object {
        $_.Name -match "openclaw|claw-gateway|openclaw-gateway|gateway.*openclaw|openclaw.*gateway" -or
        $_.DisplayName -match "openclaw|claw-gateway|openclaw-gateway|gateway.*openclaw|openclaw.*gateway"
    }
    foreach ($svc in $targetServices) {
        Info "stopping service $($svc.Name)"
        Invoke-Action "Stop-Service -Name $($svc.Name) -Force" { Stop-Service -Name $svc.Name -Force }
    }
} else {
    Info "official uninstall appears successful; fallback cleanup continues"
}

$pkgs = @("openclaw", "@openclaw/cli", "@openclaw/openclaw")
foreach ($pkg in $pkgs) {
    if (Cmd-Exists "npm")  { Invoke-Action "npm uninstall -g $pkg" { npm uninstall -g $pkg | Out-Null } }
    if (Cmd-Exists "pnpm") { Invoke-Action "pnpm remove -g $pkg" { pnpm remove -g $pkg | Out-Null } }
    if (Cmd-Exists "yarn") { Invoke-Action "yarn global remove $pkg" { yarn global remove $pkg | Out-Null } }
}
Info "node package uninstall attempted"

if (-not $OfficialOk) {
    if (Cmd-Exists "winget") { Invoke-Action "winget uninstall --id openclaw.openclaw --silent --accept-source-agreements" { winget uninstall --id openclaw.openclaw --silent --accept-source-agreements | Out-Null } }
    if (Cmd-Exists "scoop")  { Invoke-Action "scoop uninstall openclaw" { scoop uninstall openclaw | Out-Null } }
    if (Cmd-Exists "choco")  { Invoke-Action "choco uninstall openclaw -y" { choco uninstall openclaw -y | Out-Null } }
    Info "package manager uninstall attempted"
}

Step "4/5" "Cleanup Leftovers"
$cleanup = @(
    "$env:USERPROFILE\.local\bin\openclaw.exe",
    "$env:USERPROFILE\.openclaw\bin\openclaw.exe",
    "$env:APPDATA\npm\openclaw",
    "$env:APPDATA\npm\openclaw.cmd",
    "$env:APPDATA\npm\openclaw.ps1",
    "$env:APPDATA\npm\node_modules\openclaw",
    "$env:APPDATA\npm\node_modules\@openclaw",
    "$env:USERPROFILE\.openclaw",
    "$env:APPDATA\openclaw",
    "$env:LOCALAPPDATA\openclaw",
    "$env:LOCALAPPDATA\openclaw-gateway"
)
foreach ($p in $cleanup) { Remove-IfExists $p }

if ((Test-Path "$env:USERPROFILE\openclaw\.git") -or (Test-Path "$env:USERPROFILE\src\openclaw\.git")) {
    Info "detected possible git-based OpenClaw source checkout; repository is kept as-is"
}

Step "5/5" "Final Verification"
if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    $cmd = (Get-Command openclaw).Source
    Info "openclaw command still exists: $cmd"
    exit 1
}

$leftProcesses = Get-Process | Where-Object {
    $_.Name -match "openclaw|openclawd|openclaw-gateway|claw-gateway"
}
if ($leftProcesses) {
    Info "openclaw-related processes are still running; please inspect manually"
    exit 1
}

Write-Host "Uninstall complete: openclaw cleanup finished." -ForegroundColor Green
