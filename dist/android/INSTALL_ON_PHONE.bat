@echo off
setlocal
title Install Ashenwood APK on phone
cd /d "%~dp0"

set "APK=%~dp0Ashenwood-debug.apk"
if not exist "%APK%" (
  echo No APK found at:
  echo   %APK%
  echo Build it first with tools\build_android_debug.bat
  pause
  exit /b 1
)

where adb >nul 2>&1
if errorlevel 1 (
  echo adb not found. Re-open terminal after installing platform-tools, or add it to PATH.
  pause
  exit /b 1
)

echo Connected devices:
adb devices
echo.
echo Installing...
adb install -r "%APK%"
echo.
pause
