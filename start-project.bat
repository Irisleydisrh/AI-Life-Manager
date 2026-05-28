@echo off
title AI Life Manager

echo ================================================
echo  AI Life Manager - Iniciando Proyecto
echo ================================================
echo.

echo [1/3] Iniciando backend...
start "Backend-Server" cmd /k "cd /d "%~dp0backend" && node src\index.js"

echo [2/3] Esperando backend (3s)...
timeout /t 3 /nobreak >nul

echo [3/3] Iniciando app Flutter...
start "Flutter-App" cmd /k "cd /d "%~dp0mobile" && flutter run"

echo.
echo ================================================
echo  Proyecto iniciado!
echo  - Backend: http://localhost:3000
echo  - Mobile: flutter run (ejecutando)
echo ================================================
echo.
echo Presiona cualquier tecla para salir...
pause >nul