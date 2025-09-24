@echo off
setlocal

:: ============================================================================
:: Director AI Setup Script for Windows
:: ============================================================================
::
:: This script automates the setup process for the Director AI project on a
:: Windows environment. It performs the following steps:
::
:: 1. Checks for required dependencies (Python and Node.js).
:: 2. Sets up the backend, including:
::    - Creating a Python virtual environment.
::    - Installing Python dependencies from requirements.txt.
::    - Prompting for API keys and creating a .env file.
::    - Initializing the SQLite database.
:: 3. Sets up the frontend, including:
::    - Installing Node.js dependencies using npm.
::    - Creating a .env file for the frontend.
::
:: Usage:
::   Simply run this script from the root directory of the project.
::
:: ============================================================================

echo.
echo [INFO] Starting Director AI setup for Windows...
echo.

:: --- Dependency Checks ---
echo [INFO] Checking for required dependencies...

:: Check for Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not found in your PATH.
    echo Please install Python 3.9 or higher from https://www.python.org/downloads/ and ensure it's added to your PATH.
    goto :eof
) else (
    echo [OK] Python found.
)

:: Check for Node.js and npm
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed or not found in your PATH.
    echo Please install Node.js (which includes npm) from https://nodejs.org/ and ensure it's added to your PATH.
    goto :eof
) else (
    echo [OK] Node.js found.
)

where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed or not found in your PATH.
    echo npm is usually installed with Node.js. Please reinstall Node.js from https://nodejs.org/
    goto :eof
) else (
    echo [OK] npm found.
)

echo.
echo [INFO] All dependencies are satisfied.
echo.

:: --- Backend Setup ---
echo [INFO] Setting up the backend...
cd backend

echo [INFO] Creating Python virtual environment...
python -m venv venv
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create Python virtual environment.
    cd ..
    goto :eof
)

echo [INFO] Activating virtual environment and installing dependencies...
call .\\venv\\Scripts\\activate.bat

pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install backend dependencies from requirements.txt.
    cd ..
    goto :eof
)

pip install -r requirements-dev.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install backend dev dependencies from requirements-dev.txt.
    cd ..
    goto :eof
)

echo.
echo [ACTION] Please enter your VideoDB API Key. You can get one from https://console.videodb.io/
set /p VIDEO_DB_API_KEY="Enter VideoDB API Key (or press Enter to skip): "

echo [INFO] Creating backend .env file...
(
    echo VIDEO_DB_API_KEY=%VIDEO_DB_API_KEY%
) > .env

echo [INFO] Initializing the SQLite database...
python director/db/sqlite/initialize.py
if %errorlevel% neq 0 (
    echo [ERROR] Failed to initialize SQLite database.
    cd ..
    goto :eof
)

echo [OK] Backend setup complete.
cd ..
echo.


:: --- Frontend Setup ---
echo [INFO] Setting up the frontend...
cd frontend

echo [INFO] Installing frontend dependencies...
npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install frontend dependencies.
    cd ..
    goto :eof
)

echo [INFO] Creating frontend .env file...
(
    echo VITE_APP_BACKEND_URL=http://127.0.0.1:8000
    echo VITE_PORT=8080
    echo VITE_OPEN_BROWSER=true
) > .env

echo [OK] Frontend setup complete.
cd ..
echo.

:: --- Final Message ---
echo *******************************************
echo *                                         *
echo *   🎉 Setup Completed Successfully! 🎉   *
echo *                                         *
echo *      🚀 IMPORTANT: Next Steps 🚀        *
echo *                                         *
echo * 1. Review and Update .env Files:        *
echo *    - backend/.env                      *
echo *    - frontend/.env                     *
echo *                                         *
echo * 2. Start the Application:               *
echo *    Open two separate terminals:         *
echo *    - In terminal 1, run: cd backend ^&^& .\\venv\\Scripts\\activate.bat ^&^& python director/entrypoint/api/server.py
echo *    - In terminal 2, run: cd frontend ^&^& npm run dev
echo *                                         *
echo *   🎉 You're all set! Happy coding! 🎉    *
echo *                                         *
*******************************************

endlocal
