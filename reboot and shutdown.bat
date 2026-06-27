@echo off
rem Turn off console output.

rem Variables used exists only in this instance.
setlocal

rem Get the path to this .bat file.
set BatchFile=%0

rem Read the previous saved data, if it exists.
set RSRegKey=HKCU\Software\RebootShutdown
set RSRegVal=Rebooted
set RSRebooted=0
for /f "tokens=3" %%a in ('reg query "%RSRegKey%" /v "%RSRegVal%" 2^>nul') do (
	set RSRebooted=%%a
)

rem Check if any saved data was read.
if %RSRebooted% equ 1 (
	rem Data was found! This means Windows just rebooted. Continue to shutdown.
	goto cleanupandshutdown
)

rem Save data so that we know that this script just rebooted the computer.
set RebootVal=1
reg add %RSRegKey% /f > nul
reg add %RSRegKey% /v %RSRegVal% /t REG_SZ /d %RebootVal% /f > nul

rem Register .bat file to run automatically after next login.
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /v RebootShutdown /t REG_SZ /d %BatchFile% /f > nul

rem Reboot the computer.
shutdown /r /t 0
goto exitnopause

:cleanupandshutdown
rem Delete all saved data. Clean up after ourselves.
reg delete %RSRegKey% /f >nul

rem Shut down the computer.
shutdown /s /t 0
goto exitnopause

:exitnopause
rem Exit the script and close console window.
exit /b