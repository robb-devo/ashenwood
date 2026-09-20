@echo off
setlocal
title Ashenwood - Play on PC
cd /d "%~dp0"

set "GODOT="
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" (
  set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
)

if "%GODOT%"=="" (
  echo Godot 4.7.2 was not found.
  echo Install Godot 4.7 from https://godotengine.org/download
  echo Then open project.godot from this folder.
  pause
  exit /b 1
)

echo Starting Ashenwood...
echo Controls: drag left stick  OR  WASD / arrow keys
echo.
"%GODOT%" --path "%~dp0"
exit /b %ERRORLEVEL%
