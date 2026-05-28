# AI Life Manager - Iniciar todo junto
# Ejecuta: powershell -ExecutionPolicy Bypass -File "./start-app.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI Life Manager - Start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = "$scriptDir\backend"
$mobileDir = "$scriptDir\mobile"

# ==================== VERIFICAR PRISMA ====================
Write-Host "[Prisma] Verificando cliente..." -ForegroundColor Yellow
$prismaClientExists = Test-Path "$backendDir\node_modules\@prisma\client\index.js"

if (-not $prismaClientExists) {
    Write-Host "[Prisma] ⚠️ Cliente no encontrado. Ejecutando setup..." -ForegroundColor Yellow
    Write-Host "   powershell -ExecutionPolicy Bypass -File ./setup.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   O ejecutá manualmente:" -ForegroundColor Cyan
    Write-Host "   cd backend" -ForegroundColor White
    Write-Host "   npx prisma generate" -ForegroundColor White
    Write-Host "   npx prisma db push" -ForegroundColor White
    Write-Host ""
    Write-Host "   Luego volvé a ejecutar este script." -ForegroundColor Yellow
    exit 1
}

Write-Host "[Prisma] ✅ Cliente OK" -ForegroundColor Green

# ==================== BACKEND ====================
Write-Host ""
Write-Host "[Backend] Verificando..." -ForegroundColor Yellow
$backendRunning = $false
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 3 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) { $backendRunning = $true }
} catch { $backendRunning = $false }

if ($backendRunning) {
    Write-Host "[Backend] ✅ Ya corriendo en http://localhost:3000" -ForegroundColor Green
} else {
    Write-Host "[Backend] Iniciando..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendDir'; npm start" -WindowStyle Normal
    Start-Sleep -Seconds 5
    
    # Verificar que inició
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 5 -UseBasicParsing
        Write-Host "[Backend] ✅ Corriendo" -ForegroundColor Green
    } catch {
        Write-Host "[Backend] ⚠️ Iniciando..." -ForegroundColor Yellow
    }
}

# ==================== APK ====================
Write-Host ""
Write-Host "[APK] Construyendo..." -ForegroundColor Yellow

cd "$mobileDir"
flutter build apk --debug

$apkPath = "$mobileDir\build\app\outputs\flutter-apk\app-debug.apk"
$apkSize = (Get-Item $apkPath).Length / 1MB
Write-Host "[APK] ✅ Listo ($([math]::Round($apkSize, 2)) MB)" -ForegroundColor Green

# ==================== INSTALAR ====================
Write-Host ""
Write-Host "[Device] Buscando Android..." -ForegroundColor Yellow

$devices = flutter devices 2>&1 | Out-String

if ($devices -match "SM |Android") {
    Write-Host "[Device] ✅ Android detectado" -ForegroundColor Green
    Write-Host "[Device] Instalando..." -ForegroundColor Yellow
    flutter install
    Write-Host "[Device] ✅ App actualizada!" -ForegroundColor Green
} else {
    Write-Host "[Device] ⚠️ Device no conectado por USB" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  APK: $apkPath" -ForegroundColor Gray
    Write-Host "  Mándalo a tu Android e instalá" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✅ Todo listo!" -ForegroundColor Green
Write-Host ""
Write-Host "  Backend:  http://localhost:3000" -ForegroundColor White
Write-Host "  APK:      $apkPath" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan