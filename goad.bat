@echo off

set goad="%~dp0goad.ps1"
call powershell "&(""%goad%"")"
if %ERRORLEVEL% EQU 0 (
	goto :eof
) else (
	echo "ERROR: %ERRORLEVEL%"
)

pause
