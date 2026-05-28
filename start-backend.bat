@echo off
title AI Life Manager - Backend

echo ============================================
echo 🚀 Iniciando AI Life Manager Backend
echo ============================================

cd /d "%~dp0backend"

echo.
echo ⚡ Ejecutando servidor...
node src\index.js

pause