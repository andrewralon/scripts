@ECHO OFF
REM To use this script:
REM  1) Create C:\Shortcuts and add it to the system path
REM  2) Copy this script to C:\Shortcuts
REM  3) Change the URLBASE variable to your Atlassian organization name
REM  4) Type "Win+R" and "snow" or "snow [change request number]"

REM THIS WORKS:
REM https://company.service-now.com/nav_to.do?uri=%2Fchange_request.do%3Fsysparm_query%3Dnumber%3DCHG0192129

REM SET URLBASE=https://company.service-now.com
SET URLBASE=%SERVICENOWURL%
SET DEFAULTPAGE=nav_to.do?uri=%2Fhome.do%3F

IF '%1'=='-?' GOTO :HELP
IF '%1'=='/?' GOTO :HELP
IF '%1'=='?' GOTO :HELP
IF NOT '%1'=='' GOTO :OPENTICKET
GOTO :OPENHOME

:HELP
ECHO snow ([change request number])
ECHO Examples: 
ECHO   snow
ECHO   snow CHG0192129
GOTO :EXIT

:OPENTICKET
SET TICKET=%1
SET URL="%URLBASE%/nav_to.do?uri=%%2Fchange_request.do%%3Fsysparm_query=number%%3D%TICKET%"
START "" %URL%
GOTO :EXIT

:OPENHOME
START %URLBASE%
REM /%DEFAULTPAGE%
GOTO :EXIT

:EXIT
REM PAUSE
EXIT
