@echo off
setlocal
title Free Windows 11 Single-Folder SHA-256 Hash Checker

:START
cls
echo ============================================================
echo   FREE WINDOWS 11 SINGLE-FOLDER SHA-256 HASH CHECKER
echo   (Zero-Install ^| Read-Only ^| No Coding Required)
echo ============================================================
echo.
set /p target="Paste or drag-and-drop a folder path here (or press Q to quit): "
if /i "%target%"=="Q" exit /b
set "target=%target:"=%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check-Folder-SHA256.ps1" -TargetPath "%target%"
echo.
pause
goto START
