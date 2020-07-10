@ECHO OFF
REM keycuts 0.1.1.5 © 2020 TeamRalon
REM <file>C:\Shortcuts\toggleproxy.bat</file>
SET filename=%~dpn0.ps1
powershell.exe -Command "& '%filename%'"
PAUSE
EXIT
