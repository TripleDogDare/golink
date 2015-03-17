@echo off
net file 1>nul 2>nul

if ERRORLEVEL 1 (
	echo You must right click and select "Run as administrator".
	pause
	exit /D
)
REM ... proceed here with admin rights ...

set goad="%~dp0goad.ps1"
call powershell "&(""%goad%"")"
if %ERRORLEVEL% EQU 0 (
	exit
) else (
	echo "ERROR: %ERRORLEVEL%"
)
pause
