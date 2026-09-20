@echo off
setlocal EnableExtensions
title Ashenwood - Build Android Debug APK
cd /d "%~dp0\.."

set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
set "OUT=%~dp0android\Ashenwood-debug.apk"

if not exist "%GODOT%" (
  echo Godot console binary not found.
  exit /b 1
)

if not exist "%APPDATA%\Godot\export_templates\4.7.2.stable" (
  echo Missing Godot Android export templates for 4.7.2.
  echo Open Godot -^> Editor -^> Manage Export Templates -^> Download
  exit /b 1
)

if "%ANDROID_HOME%"=="" if "%ANDROID_SDK_ROOT%"=="" (
  if exist "%LOCALAPPDATA%\Android\Sdk" set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
)

if "%ANDROID_HOME%"=="" (
  echo Android SDK not found. Install Android Studio / SDK first.
  exit /b 1
)

if not exist "export_presets.cfg" (
  echo export_presets.cfg missing. Open Godot once and add an Android export preset named "Android".
  exit /b 1
)

echo Exporting debug APK to:
echo   %OUT%
"%GODOT%" --headless --path "%CD%" --export-debug "Android" "%OUT%"
if errorlevel 1 (
  echo Export failed.
  exit /b 1
)

echo Done.
echo Install with:
echo   adb install -r "%OUT%"
exit /b 0
