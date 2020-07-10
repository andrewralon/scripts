@ECHO OFF
REM SET JIRAURL=https://company.atlassian.net
SET FILENAME=%~n0
START %JIRAURL%/browse/%FILENAME%-%1%
EXIT
