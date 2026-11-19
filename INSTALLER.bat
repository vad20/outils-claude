@echo off
chcp 65001 >nul
echo ============================================
echo   Installation des outils Claude de Vadim
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer.ps1"
echo.
pause
