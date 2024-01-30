@echo off
setlocal enabledelayedexpansion
color a

REM Check for administrative privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if !errorLevel! neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath \"%~dp0%~nx0\" -Verb RunAs"
    exit /b
)

:MENU
cls
echo ---------------
echo System Optimizer
echo ---------------
echo 1 ) Run Temp Cleanup
echo 2 ) Malware Scan
echo 3 ) Run System File Checker (SFC)
echo 4 ) Run DISM (Restore Disk Image Online)
echo 99) Run All Recomended Options
echo 0 ) Exit
echo ---------------
set /p choice=Enter your choice: 

if "%choice%"=="1" (
    call :RunTempCleanup
) else if "%choice%"=="2" (
    call :MalwareScanInterface
) else if "%choice%"=="3" (
    call :RunSFC
) else if "%choice%"=="4" (
    call :RunDISM
) else if "%choice%"=="99" (
    call :RunAllOptions
) else if "%choice%"=="0" (
    exit
) else (
    echo Invalid choice. Please try again.
    timeout /nobreak /t 2 >nul
    goto MENU
)

:RunTempCleanup
echo Running Temp Cleanup...

REM Delete temporary files in Windows and user-specific temporary folders
echo Deleting temporary files...
for %%F in (C:\Windows\Temp\*.* %TEMP%\*.* !USERPROFILE!\AppData\Local\Temp\*.*) do (
    if exist "%%F" (
        del /q /f "%%F"
    )
)

REM Clear Windows Update cache
echo Clearing Windows Update cache...
net stop wuauserv
del /q /s /f %SystemRoot%\SoftwareDistribution\*.*
net start wuauserv

REM Clear Event Viewer logs
echo Clearing Event Viewer logs...

for /F "tokens=*" %%G in ('wevtutil.exe el') do (
    echo Clearing log: %%G
    wevtutil.exe cl "%%G"
    
    REM Check the exit code of the last command
    if !errorlevel! neq 0 (
        echo Failed to clear log: %%G. Access denied or other error.
    ) else (
        echo Log: %%G cleared successfully.
    )
)

echo Running Disk Cleanup...
cleanmgr /sagerun:1

echo Temp Cleanup completed successfully.

echo Press any Keys to Exit
pause >nul
exit

:MalwareScanInterface
:MALWARE_MENU
cls
echo -----------------
echo Malware Scan Options
echo -----------------
echo Note: Press any key for default
echo 1) Quick Scan
echo 2) Full Scan (Warning: Might Take Several Hours)
echo 0) Back to Main Menu
echo -----------------
set /p malware_choice=Enter your Malware Scan option:

if "%malware_choice%"=="1" (
    call :QuickMalwareScan
) else if "%malware_choice%"=="2" (
    call :FullMalwareScan
) else if "%malware_choice%"=="0" (
    goto MENU
) else (
    echo Invalid Malware Scan option. Selecting default Quick Scan....
    timeout /nobreak /t 2 >nul
    call :QuickMalwareScan
)

:QuickMalwareScan
echo Running Microsoft Safety Scanner (Quick Scan)...
start /wait mrt.exe /Q

REM Check the exit code of the Microsoft Safety Scanner
if %errorlevel% equ 0 (
    echo No malware detected in Quick Scan.
) else if %errorlevel% equ 1 (
    echo Malware detected and cleaned in Quick Scan.
) else if %errorlevel% equ 2 (
    echo Malware detected but not cleaned in Quick Scan.
) else (
    echo Error running Microsoft Safety Scanner for Quick Scan.
)

echo Quick Scan completed successfully.

echo Press any Keys to Exit
pause >nul
exit

:FullMalwareScan
echo Running Microsoft Safety Scanner (Full Scan)...
start /wait mrt.exe /Q /FullScan

REM Check the exit code of the Microsoft Safety Scanner
if %errorlevel% equ 0 (
    echo No malware detected in Full Scan.
) else if %errorlevel% equ 1 (
    echo Malware detected and cleaned in Full Scan.
) else if %errorlevel% equ 2 (
    echo Malware detected but not cleaned in Full Scan.
) else (
    echo Error running Microsoft Safety Scanner for Full Scan.
)

echo Full Scan completed successfully.

echo Press any Keys to Exit
pause >nul
exit

:RunSFC
echo Running System File Checker...
sfc /scannow

echo System File Checker completed successfully.

echo Press any Keys to Exit
pause >nul
exit

:RunDISM
echo Running DISM to restore the Windows image...
DISM /Online /Cleanup-Image /RestoreHealth

echo DISM completed successfully.

echo Press any Keys to Exit
pause >nul
exit

:RunAllOptions
echo Running Temp Cleanup...

REM Delete temporary files in Windows and user-specific temporary folders
echo Deleting temporary files...
for %%F in (C:\Windows\Temp\*.* %TEMP%\*.* !USERPROFILE!\AppData\Local\Temp\*.*) do (
    if exist "%%F" (
        del /q /f "%%F"
    )
)

REM Clear Windows Update cache
echo Clearing Windows Update cache...
net stop wuauserv
del /q /s /f %SystemRoot%\SoftwareDistribution\*.*
net start wuauserv

REM Clear Event Viewer logs
echo Clearing Event Viewer logs...
for /F "tokens=*" %%G in ('wevtutil.exe el') do wevtutil.exe cl "%%G"

echo Running Disk Cleanup...
cleanmgr /sagerun:1

echo Running Microsoft Safety Scanner (Quick Scan)...
start /wait mrt.exe /Q

REM Check the exit code of the Microsoft Safety Scanner
if %errorlevel% equ 0 (
    echo No malware detected in Quick Scan.
) else if %errorlevel% equ 1 (
    echo Malware detected and cleaned in Quick Scan.
) else if %errorlevel% equ 2 (
    echo Malware detected but not cleaned in Quick Scan.
) else (
    echo Error running Microsoft Safety Scanner for Quick Scan.
)
echo Running System File Checker...
sfc /scannow

echo All recomended optimization options completed successfully.

echo Press any Keys to Exit
pause >nul
exit
