@echo off
echo ================================================
echo  AI Life Manager - Optimizador de Rendimiento
echo ================================================
echo.

echo [1/3] Verificando backend...
cd /d "%~dp0backend"
start "Backend" cmd /k "node src\index.js"

echo [2/3] Esperando backend (3s)...
timeout /t 3 /nobreak >nul

echo [3/3] Listo!
echo.
echo El backend esta corriendo en: http://localhost:3000
echo Ahora ejecuta: flutter run (en la carpeta mobile)
echo.
pause