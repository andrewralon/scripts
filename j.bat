@ECHO OFF
REM j.bat
REM Purpose:  Opens browser to Jira with given ticket search terms
REM Usage:    j ([search terms])
REM Examples: 
REM   j
REM   j AppDynamics
REM   j SQL config
REM To use this script:
REM   1) Create C:\Shortcuts and add it to the system path
REM   2) Copy this script to C:\Shortcuts
REM   3) Change the URLBASE variable to your Atlassian organization name
REM   4) Type "Win+R" and "j" or "j search terms here"

REM THIS WORKS:
REM https://company.atlassian.net/browse/OPS-1891?jql=project%20in%20(OPS%2C%20DEVOPS%2C%20CORE%2C%20GN1%2C%20GNC)%20AND%20text%20~%20sqlcmd%20ORDER%20BY%20updatedDate%20DESC

SET URLBASE=%JIRAURL%
SET DEFAULTPAGE=/secure/RapidBoard.jspa?rapidView=312

IF '%1'=='-?' GOTO :HELP
IF '%1'=='/?' GOTO :HELP
IF '%1'=='?' GOTO :HELP
IF NOT '%1'=='' GOTO :OPENJIRASEARCH
GOTO :OPENJIRABOARD

:HELP
ECHO j ([search terms])
ECHO Examples:
ECHO   j
ECHO   j AppDynamics
ECHO   j SQL config
GOTO :EXIT

:OPENJIRASEARCH
SET URL="%URLBASE%/issues/?jql=project%%20in%%20(OPS%%2C%%20DS%%2C%%20DEVOPS%%2C%%20CORE%%2C%%20GN1%%2C%%20GNC)%%20AND%%20text%%20~%%20%%22%*%%22%%20ORDER%%20BY%%20key%%20DESC%%2C%%20priority%%20DESC"
GOTO :RUN

:OPENJIRABOARD
ECHO "OPENJIRABOARD"
SET URL="%URLBASE%%DEFAULTPAGE%"
GOTO :RUN

:RUN 
ECHO %URL%
START "" %URL%
GOTO :EXIT

:EXIT
REM PAUSE
EXIT
