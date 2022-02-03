@ECHO OFF
REM slack.bat
REM Purpose:  Run a PowerShell script from a .cmd or .bat file with the
REM            full path to the script WITHOUT the extension.
REM Requires: PowerShell
REM Usage:    slack [command] ([args])

SET ARGS=%*
SET FILENAME=%~n0
GOTO RUN

:RUN
START powershell.exe -Command "& '%FILENAME%' %ARGS%"
REM START powershell.exe -Command "& '%FILENAME%.ps1' %*"
GOTO EOF

:EOF
