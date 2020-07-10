@ECHO OFF
REM To use this script:
REM  1) Create C:\Shortcuts and add it to the system path
REM  2) Copy this script to C:\Shortcuts
REM  3) Change the URLBASE variable to your Atlassian organization name
REM  4) Type "Win+R" and "wiki" or "wiki search terms here"

REM SET URLBASE="https://company.atlassian.net/wiki"
SET URLBASE=%JIRAURL%/wiki
SET DEFAULTPAGE=/spaces/OPS/overview

IF '%1'=='-?' GOTO :HELP
IF '%1'=='/?' GOTO :HELP
IF '%1'=='?' GOTO :HELP
IF NOT '%1'=='' GOTO :OPENWIKISEARCH
GOTO :OPENWIKIPAGE

:HELP
ECHO wiki ([search terms])
ECHO Examples:
ECHO   wiki
ECHO   wiki appdynamics
ECHO   wiki compete ops
GOTO :EXIT

:OPENWIKISEARCH
SET URL="%URLBASE%/dosearchsite.action?cql=siteSearch+~+%%22%*%%22"
START "" %URL%
GOTO :EXIT

:OPENWIKIPAGE
SET URL="%URLBASE%%DEFAULTPAGE%"
START "" %URL%
GOTO :EXIT

:EXIT
REM PAUSE
EXIT
