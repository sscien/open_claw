@echo off
REM ============================================================================
REM OpenCLAW Windows Deployment Launcher
REM Launches the PowerShell deployment script with proper execution policy
REM Usage: deploy_windows.bat [native|wsl|docker]
REM ============================================================================

echo.
echo +==============================================+
echo ^|    OpenCLAW Windows Deployment Launcher      ^|
echo +==============================================+
echo.

set MODE=%1
if "%MODE%"=="" set MODE=native

echo Launching PowerShell deployment script (Mode: %MODE%)...
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy_windows.ps1" -Mode %MODE%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Deployment script failed with exit code %ERRORLEVEL%
    echo.
    echo Troubleshooting:
    echo   1. Run this script as Administrator
    echo   2. Ensure PowerShell 5.1+ is installed
    echo   3. Check your internet connection
    echo.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Deployment complete!
pause
