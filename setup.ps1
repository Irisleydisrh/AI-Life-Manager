# AI Life Manager - Setup inicial
# Este script se ejecuta UNA SOLA VEZ al clonar el proyecto

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI Life Manager - Setup Inicial" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Instalar dependencias
Write-Host "[1/4] Instalando dependencias..." -ForegroundColor Yellow
cd "$scriptDir\backend"
npm install

# 2. Generar Prisma Client
Write-Host ""
Write-Host "[2/4] Generando Prisma Client..." -ForegroundColor Yellow
npx prisma generate

# 3. Sincronizar schema con base de datos
Write-Host ""
Write-Host "[3/4] Sincronizando base de datos..." -ForegroundColor Yellow
npx prisma db push

# 4. Listo
Write-Host ""
Write-Host "[4/4] ✅ Setup completado!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ahora podés iniciar con:" -ForegroundColor White
Write-Host "  npm start" -ForegroundColor Cyan
Write-Host "  o" -ForegroundColor Gray
Write-Host "  ./start-app.ps1" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan