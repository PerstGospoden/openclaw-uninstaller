@echo off
setlocal

set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%uninstall-openclaw-windows.ps1

if not exist "%PS_SCRIPT%" (
  echo Could not find uninstall-openclaw-windows.ps1 next to this file.
  pause
  exit /b 1
)

echo Launching OpenClaw uninstaller...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
echo.
echo Finished. Press any key to close this window.
pause >nul
