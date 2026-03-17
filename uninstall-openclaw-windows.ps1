param([switch]$DryRun, [switch]$Yes, [switch]$Help)

$ErrorActionPreference = "SilentlyContinue"
$OfficialOk = $false

if ($Help) {
    Write-Host "Usage: .\uninstall-openclaw-windows.ps1 [-DryRun] [-Yes] [-Help]"
    exit 0
}

$CommandPaths = [System.Collections.Generic.List[string]]::new()
$Processes = [System.Collections.Generic.List[string]]::new()
$Services = [System.Collections.Generic.List[string]]::new()
$FilePaths = [System.Collections.Generic.List[string]]::new()
$Packages = [System.Collections.Generic.List[string]]::new()
$PathHints = [System.Collections.Generic.List[string]]::new()
$ProfileHints = [System.Collections.Generic.List[string]]::new()
$RegistryKeys = [System.Collections.Generic.List[string]]::new()

function Step($idx, $msg) { Write-Host "`n==> [$idx] $msg" -ForegroundColor Cyan }
function Info($msg) { Write-Host " - $msg" }
function Warn($msg) { Write-Host " ! $msg" -ForegroundColor Yellow }

function Add-Unique($list, [string]$value) {
    if ([string]::IsNullOrWhiteSpace($value)) { return }
    if (-not $list.Contains($value)) { [void]$list.Add($value) }
}

function Invoke-Action($description, [scriptblock]$action) {
    if ($DryRun) {
        Info "[dry-run] $description"
    } else {
        Info "running: $description"
        & $action
    }
}

function Cmd-Exists($name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

function Remove-IfExists($path) {
    if (Test-Path $path) {
        Invoke-Action "Remove-Item -Path $path -Recurse -Force" { Remove-Item -Path $path -Recurse -Force }
    }
}

function Scan-Commands {
    $cmd = Get-Command openclaw -ErrorAction SilentlyContinue
    if ($cmd) { Add-Unique $CommandPaths $cmd.Source }
}

function Scan-Processes {
    Get-Process | Where-Object {
        $_.Name -match "openclaw|openclawd|openclaw-gateway|claw-gateway"
    } | ForEach-Object {
        Add-Unique $Processes ("{0} (PID {1})" -f $_.Name, $_.Id)
    }
}

function Scan-Services {
    Get-Service | Where-Object {
        $_.Name -match "openclaw|claw-gateway|openclaw-gateway|gateway.*openclaw|openclaw.*gateway" -or
        $_.DisplayName -match "openclaw|claw-gateway|openclaw-gateway|gateway.*openclaw|openclaw.*gateway"
    } | ForEach-Object {
        Add-Unique $Services ("{0} ({1})" -f $_.Name, $_.Status)
    }
}

function Scan-Files {
    $paths = @(
        "$env:USERPROFILE\.openclaw",
        "$env:USERPROFILE\.openclaw\bin\openclaw.exe",
        "$env:USERPROFILE\.local\bin\openclaw.exe",
        "$env:APPDATA\openclaw",
        "$env:LOCALAPPDATA\openclaw",
        "$env:LOCALAPPDATA\openclaw-gateway",
        "$env:APPDATA\npm\openclaw",
        "$env:APPDATA\npm\openclaw.cmd",
        "$env:APPDATA\npm\openclaw.ps1",
        "$env:APPDATA\npm\node_modules\openclaw",
        "$env:APPDATA\npm\node_modules\@openclaw",
        "$env:LOCALAPPDATA\Programs\OpenClaw",
        "$env:ProgramFiles\OpenClaw",
        "${env:ProgramFiles(x86)}\OpenClaw",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OpenClaw"
    )

    foreach ($p in $paths) {
        if (Test-Path $p) { Add-Unique $FilePaths $p }
    }
}

function Scan-Packages {
    $pkgNames = @("openclaw", "@openclaw/cli", "@openclaw/openclaw")
    foreach ($pkg in $pkgNames) {
        if (Cmd-Exists "npm") {
            npm list -g --depth=0 $pkg | Out-Null
            if ($LASTEXITCODE -eq 0) { Add-Unique $Packages "npm: $pkg" }
        }
        if (Cmd-Exists "pnpm") {
            pnpm list -g --depth=0 $pkg | Out-Null
            if ($LASTEXITCODE -eq 0) { Add-Unique $Packages "pnpm: $pkg" }
        }
        if (Cmd-Exists "yarn") {
            $result = yarn global list --pattern $pkg 2>$null
            if ($result -match [regex]::Escape($pkg)) { Add-Unique $Packages "yarn: $pkg" }
        }
    }
}

function Scan-Registry {
    $keys = @(
        "HKCU:\Software\OpenClaw",
        "HKLM:\SOFTWARE\OpenClaw",
        "HKLM:\SOFTWARE\WOW6432Node\OpenClaw"
    )
    foreach ($key in $keys) {
        if (Test-Path $key) { Add-Unique $RegistryKeys $key }
    }
}

function Scan-EnvHints {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")

    foreach ($entry in ($userPath -split ';')) {
        if ($entry -match 'openclaw|OpenClaw') { Add-Unique $PathHints ("User PATH: $entry") }
    }
    foreach ($entry in ($machinePath -split ';')) {
        if ($entry -match 'openclaw|OpenClaw') { Add-Unique $PathHints ("Machine PATH: $entry") }
    }

    $profiles = @($PROFILE.CurrentUserAllHosts, $PROFILE.CurrentUserCurrentHost)
    foreach ($profilePath in $profiles) {
        if ($profilePath -and (Test-Path $profilePath)) {
            $matches = Select-String -Path $profilePath -Pattern 'openclaw|OpenClaw' -SimpleMatch:$false
            if ($matches) { Add-Unique $ProfileHints $profilePath }
        }
    }
}

function Scan-All {
    $CommandPaths.Clear()
    $Processes.Clear()
    $Services.Clear()
    $FilePaths.Clear()
    $Packages.Clear()
    $PathHints.Clear()
    $ProfileHints.Clear()
    $RegistryKeys.Clear()

    Scan-Commands
    Scan-Processes
    Scan-Services
    Scan-Files
    Scan-Packages
    Scan-Registry
    Scan-EnvHints
}

function Print-Section($title, $items) {
    Write-Host "`n$title"
    if ($items.Count -eq 0) {
        Info "none detected"
        return
    }
    foreach ($item in $items) { Info $item }
}

function Print-Summary {
    Step "1/6" "Scan Environment and Preview Targets"
    Print-Section "[commands]" $CommandPaths
    Print-Section "[processes]" $Processes
    Print-Section "[services]" $Services
    Print-Section "[packages]" $Packages
    Print-Section "[files]" $FilePaths
    Print-Section "[registry]" $RegistryKeys
    Print-Section "[path hints]" $PathHints
    Print-Section "[profile hints]" $ProfileHints
}

function Confirm-Uninstall {
    if ($DryRun) {
        Info "dry-run mode: preview complete, no changes were made"
        exit 0
    }
    if ($Yes) {
        Info "auto-confirm enabled, continuing uninstall"
        return
    }

    $answer = Read-Host "Proceed with uninstall? [y/N]"
    if ($answer -notmatch '^(y|yes)$') {
        Info "uninstall cancelled by user"
        exit 0
    }
}

function Show-PathGuidance {
    if ($PathHints.Count -eq 0 -and $ProfileHints.Count -eq 0) { return }

    Step "6/6" "PATH and Profile Cleanup Guidance"
    if ($PathHints.Count -gt 0) {
        Warn "PATH still contains OpenClaw-related entries. Open: System Properties -> Advanced -> Environment Variables"
        Warn "Then edit User PATH or System PATH and remove the entries below:"
        foreach ($item in $PathHints) { Info $item }
    }

    if ($ProfileHints.Count -gt 0) {
        Warn "PowerShell profile files still mention OpenClaw. Open these files and remove PATH/alias/export lines:"
        foreach ($item in $ProfileHints) { Info $item }
    }

    Info "After editing PATH, close and reopen Terminal/PowerShell for the changes to take effect."
}

Step "0/6" "Flow Overview"
Info "1) Scan install traces, processes, services, packages, and leftover files"
Info "2) Show everything found and ask for confirmation"
Info "3) Try the official uninstall command first"
Info "4) If traces remain, stop processes/services and run fallback uninstall"
Info "5) Clean leftovers and verify again"
Info "6) If PATH or profile hints remain, show exactly where to edit"
if ($DryRun) { Info "dry-run mode enabled; no system changes will be made" }

Scan-All
if (
    $CommandPaths.Count -eq 0 -and
    $Processes.Count -eq 0 -and
    $Services.Count -eq 0 -and
    $Packages.Count -eq 0 -and
    $FilePaths.Count -eq 0 -and
    $RegistryKeys.Count -eq 0
) {
    Step "1/6" "Scan Environment and Preview Targets"
    Info "openclaw was not detected; uninstall skipped"
    Show-PathGuidance
    exit 0
}

Print-Summary
Confirm-Uninstall

Step "2/6" "Try Official Uninstall"
if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    Invoke-Action "openclaw uninstall --all --yes" { openclaw uninstall --all --yes | Out-Null }
    Scan-All
    if ($CommandPaths.Count -eq 0 -and $Processes.Count -eq 0 -and $Services.Count -eq 0) {
        $OfficialOk = $true
        Info "official uninstall completed successfully"
    } else {
        Warn "official uninstall finished but traces still remain"
    }
} else {
    Info "official cli not found, skip direct uninstall"
}

Step "3/6" "Run Fallback Uninstall"
if ($OfficialOk) {
    Info "skip process/service fallback because official uninstall already removed runtime traces"
} else {
    Get-Process | Where-Object {
        $_.Name -match "openclaw|openclawd|openclaw-gateway|claw-gateway"
    } | ForEach-Object {
        $processId = $_.Id
        Invoke-Action "Stop-Process -Id $processId -Force" { Stop-Process -Id $processId -Force }
    }

    Get-Service | Where-Object {
        $_.Name -match "openclaw|claw-gateway|openclaw-gateway|gateway.*openclaw|openclaw.*gateway" -or
        $_.DisplayName -match "openclaw|claw-gateway|openclaw-gateway|gateway.*openclaw|openclaw.*gateway"
    } | ForEach-Object {
        $serviceName = $_.Name
        Invoke-Action "Stop-Service -Name $serviceName -Force" { Stop-Service -Name $serviceName -Force }
    }
}

$pkgNames = @("openclaw", "@openclaw/cli", "@openclaw/openclaw")
foreach ($pkg in $pkgNames) {
    if (Cmd-Exists "npm")  { Invoke-Action "npm uninstall -g $pkg" { npm uninstall -g $pkg | Out-Null } }
    if (Cmd-Exists "pnpm") { Invoke-Action "pnpm remove -g $pkg" { pnpm remove -g $pkg | Out-Null } }
    if (Cmd-Exists "yarn") { Invoke-Action "yarn global remove $pkg" { yarn global remove $pkg | Out-Null } }
}

if (-not $OfficialOk) {
    if (Cmd-Exists "winget") { Invoke-Action "winget uninstall --id openclaw.openclaw --silent --accept-source-agreements" { winget uninstall --id openclaw.openclaw --silent --accept-source-agreements | Out-Null } }
    if (Cmd-Exists "scoop")  { Invoke-Action "scoop uninstall openclaw" { scoop uninstall openclaw | Out-Null } }
    if (Cmd-Exists "choco")  { Invoke-Action "choco uninstall openclaw -y" { choco uninstall openclaw -y | Out-Null } }
}

Step "4/6" "Clean Leftovers"
foreach ($path in $FilePaths) {
    Remove-IfExists $path
}
foreach ($key in $RegistryKeys) {
    Invoke-Action "Remove-Item -Path $key -Recurse -Force" { Remove-Item -Path $key -Recurse -Force }
}

Step "5/6" "Final Verification"
Scan-All
Print-Section "[remaining commands]" $CommandPaths
Print-Section "[remaining processes]" $Processes
Print-Section "[remaining services]" $Services
Print-Section "[remaining packages]" $Packages
Print-Section "[remaining files]" $FilePaths
Print-Section "[remaining registry]" $RegistryKeys

if (
    $CommandPaths.Count -gt 0 -or
    $Processes.Count -gt 0 -or
    $Services.Count -gt 0 -or
    $Packages.Count -gt 0 -or
    $FilePaths.Count -gt 0 -or
    $RegistryKeys.Count -gt 0
) {
    Warn "some traces still remain; please review the lists above for manual cleanup"
}

Show-PathGuidance
Write-Host "Uninstall flow completed." -ForegroundColor Green
