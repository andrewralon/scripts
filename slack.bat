@ECHO OFF
REM To use this script:
REM  1) Create C:\Shortcuts and add it to the system path
REM  2) Copy this script to C:\Shortcuts
REM  3) Type "Win+R" and "slack" or "slack [channel name without a #]"

REM References:
REM * Slack documentation:      https://api.slack.com/reference/deep-linking
REM * Stack Overflow:           https://stackoverflow.com/questions/40940327/what-is-the-simplest-way-to-find-a-slack-team-id-and-a-channel-id
REM * Open app:                 slack://open
REM * Open app to team:         slack://open?team=[TEAMID]
REM * Open app to channel:      https://slack.com/app_redirect?channel=[CHANNELNAME]
REM * Open channel in browser:  https://app.slack.com/client/[TEAMID]/[CHANNELID]

REM Examples:
REM * Open app to #general:      https://slack.com/app_redirect?channel=general
REM * Open app to team by ID:    slack://open?team=%TEAMID%
REM * Open app to channel by ID: slack://channel?team=%TEAMID%&id=%CHANNELID%
REM * Open #general in browser:  https://app.slack.com/client/%TEAMID%/%CHANNELID%

REM CHANGE THESE VARIABLES:
SET TEAMID=

REM DO NOT CHANGE THESE VARIABLES:
SET URLBASE=slack://open
SET URLREDIRECT=https://slack.com/app_redirect

REM THESE VARIABLES ARE NOT USED:
REM SET TEAMID=
REM SET APPPATH=%USERPROFILE%\AppData\Local\slack\slack.exe
REM SET APPPATH=%LOCALAPPDATA%\slack\slack.exe

IF '%1'=='-?' GOTO :HELP
IF '%1'=='/?' GOTO :HELP
IF '%1'=='?' GOTO :HELP
IF NOT '%1'=='' GOTO :OPENCHANNEL
GOTO :OPENAPP

:HELP
ECHO slack ([channel name without a #])
ECHO slack
ECHO slack general
GOTO :EXIT

:OPENCHANNEL
SET URL=%URLREDIRECT%?channel=%1
START %URL%
GOTO :EXIT

:OPENAPP
START %APPPATH%
REM START %URLBASE%
GOTO :EXIT

:EXIT
REM PAUSE
EXIT
