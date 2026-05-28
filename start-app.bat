@echo off
echo ========================================
echo   AI Life Manager - Starting App
echo ========================================
echo.

echo [1/3] Starting backend...
cd backend
start "Backend Server" cmd /k "npm start"
cd ..

echo.
echo [2/3] Waiting for backend to be ready...
timeout /t 5 /nobreak > nul

echo [3/3] Starting Flutter...
cd mobile
flutter run
cd ..

echo.
echo ========================================
echo   App closed. Backend still running.
echo   Close the backend window manually.
echo ========================================