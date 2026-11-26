@echo off
setlocal DisableDelayedExpansion
title Free Windows 11 Single-Folder SHA-256 Hash Checker (v1.3)

:START
cls
echo ====================================================================
echo   FREE WINDOWS 11 SINGLE-FOLDER SHA-256 HASH CHECKER (v1.3)
echo   (Zero-Install ^| Read-Only ^| Top-Level Files Only)
echo ====================================================================
echo.
set "target="
set /p "target=Paste or drag-and-drop a folder or drive path (or Q to quit): "
if not defined target goto START
if /i "%target%"=="Q" exit /b 0
set "target=%target:"=%"
if not defined target goto START
if "%target:~-1%"=="\" set "target=%target:~0,-1%"

echo.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check-Folder-SHA256.ps1" -TargetPath "%target%"
echo.
pause
goto START
