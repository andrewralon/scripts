@ECHO OFF
REM runps.bat
REM Purpose:  Run a PowerShell script from a .cmd or .bat file with the
REM            full path to the script WITHOUT the extension.
REM Requires: PowerShell
REM Usage:    runps [scriptpath] ([args])
REM Examples: runps tfsfreeze
REM             This will run "tfsfreeze.ps1" in the current directory
REM           runps tfsfreeze asdf
REM             This will run "tfsfreeze.ps1 asdf" in the current directory
REM           runps "C:\Path With Spaces\Invoke-Webhook"
REM             This will run "C:\Path With Spaces\Invoke-Webhook.ps1"
REM Notes:    Use double quotes around the path if it contains spaces!

REM ECHO ARG 0 - %0
REM ECHO ARG 1 - %1

IF '%1'=='' GOTO HELP
SET SCRIPT=%1
SET EXTENSION=%~x0
IF '%EXTENSION%'=='' GOTO SETEXTENSION
GOTO RUN

:HELP
ECHO runps [scriptpath] ([args])
ECHO runps tfsfreeze
ECHO   This will run "tfsfreeze.ps1" in the current directory
ECHO runps tfsfreeze asdf
ECHO   This will run "tfsfreeze.ps1 asdf" in the current directory
ECHO runps "C:\Path With Spaces\Invoke-Webhook"
ECHO   This will run "C:\Path With Spaces\Invoke-Webhook.ps1"
ECHO(
GOTO EOF

:SETEXTENSION
ECHO SETEXTENSION
SET SCRIPT=%FILENAME%.ps1
GOTO :RUN

:RUN
SET ARGS=%*
CALL SET PSARGS=%%ARGS:*%1=%%
REM ECHO %SCRIPT%
START powershell.exe -Command "& '%SCRIPT%' %PSARGS%"
GOTO EOF

:EOF
