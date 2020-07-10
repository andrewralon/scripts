@ECHO OFF
REM setvariable.bat
REM Purpose:  Create an environment variable with a given value in the local user environment (default) or system environment (requires adding "/M" to the end of the command below)
REM Requires: Administrator privileges
REM Usage:    setvariable [variable] [value]
REM           setvariable [variable] [value with spaces]
REM           setvariable [variable] "[value with spaces and quotes]"
REM Examples: setvariable VARIABLE1 ValueWithoutSpaces
REM           setvariable VARIABLE2 Value With Spaces
REM           setvariable VARIABLE3 "C:\Value With Spaces And Quotes"
REM Notes:    
REM * Everything after the first argument (variable) will be included as the value
REM * Quotes are optional (quotes will be removed if they exist, then added when creating the variable) 
REM * After creating, reference the variable as %VARIABLE1%
REM References:
REM * https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/setx
REM * https://ss64.com/nt/setx.html
REM * https://ss64.com/nt/syntax-args.html
REM * https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing/8162578#8162578
REM * https://stackoverflow.com/questions/935609/batch-parameters-everything-after-1

IF NOT '%1'=='' IF NOT '%2'=='' GOTO :SETVAR
GOTO :HELP

:HELP
ECHO setenvironmentvariable [variable] [value]
ECHO Examples: 
ECHO   setvariable VARIABLE1 ValueWithoutSpaces
ECHO   setvariable VARIABLE2 Value With Spaces
ECHO   setvariable VARIABLE3 "C:\Value With Spaces And Quotes"
GOTO :EXIT

:DEQUOTE
FOR /f "delims=" %%A in ('ECHO %%%1%%') DO SET %1=%%~A
GOTO :EXIT

:SETVAR
REM Get the variable as the first argument after removing quotes
SET VARIABLE=%~1
REM Get the value as all arguments AFTER the first one
FOR /f "tokens=1,* delims= " %%A in ("%*") DO SET VALUE=%%B
REM Remove quotes if they exist around the value (they will be added later)
SETLOCAL
CALL :DEQUOTE VALUE
CALL :DEQUOTE VARIABLE
REM ECHO VARIABLE: "%VARIABLE%"
REM ECHO VALUE:    "%VALUE%"
REM ECHO(
ECHO SETX %VARIABLE% "%VALUE%"
SETX %VARIABLE% "%VALUE%"
REM Add /M to the end for system variable (vs local user, which is default)
GOTO :EXIT

:EXIT
REM PAUSE
REM EXIT
