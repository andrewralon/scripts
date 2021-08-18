@ECHO OFF
REM newjira.bat
REM Purpose:  Opens a new OPS or CORE Jira ticket with common fields pre-populated
REM Requires: Change the JIRAUSER variable
REM Usage:    newjira ([KEY])
REM           newjira (OPS|CR|CORE|GN|G1|GC|GCD|QW)
REM Examples: newjira
REM           newjira GN
REM           newjira CORE

REM Change these:
REM SET JIRAUSER=firstname.lastname
SET JIRAUSER=%JIRAUSERNAME%

REM Do not change these:
SET ASSIGNEDDEVFIELD="^^^&customfield_11800"
SET ASSIGNEDDEVID=%JIRAUSER%
SET REQUESTORFIELD="^^^&customfield_19200"
SET REQUESTORID=15602
SET INFRASTRUCTUREFIELD="^^^&customfield_17600"
SET INFRASTRUCTUREID=
SET PRIORITYFIELD="^^^&customfield_14903"
SET PRIORITYID=12800
SET BUSINESSVALUEFIELD="^^^&customfield_14904"
SET BUSINESSVALUEID=12804
SET ASSIGNEDDEV="%ASSIGNEDDEVFIELD%=%JIRAUSER%"
SET REQUESTOR="%REQUESTORFIELD%=%REQUESTORID%"
SET PRIORITY="%PRIORITYFIELD%=%PRIORITYID%"
SET BUSINESSVALUE="%BUSINESSVALUEFIELD%=%BUSINESSVALUEID%"

REM Determine what commands to run
IF "%~1"=="" GOTO :OpsTicket
IF "%~1"=="ops" GOTO :OpsTicket
IF "%~1"=="OPS" GOTO :OpsTicket
IF "%~1"=="cr" GOTO :OpsChangeRequestTicket
IF "%~1"=="CR" GOTO :OpsChangeRequestTicket
IF "%~1"=="ec" GOTO :OpsEmergencyChangeTicket
IF "%~1"=="EC" GOTO :OpsEmergencyChangeTicket
IF "%~1"=="core" GOTO :CoreTicket
IF "%~1"=="CORE" GOTO :CoreTicket
IF "%~1"=="gn1" GOTO :G1Ticket
IF "%~1"=="GN1" GOTO :G1Ticket
IF "%~1"=="qw" GOTO :QWTicket
IF "%~1"=="QW" GOTO :QWTicket
IF "%~1"=="gn" SET INFRASTRUCTUREID=14900
IF "%~1"=="GN" SET INFRASTRUCTUREID=14900
IF "%~1"=="g1" SET INFRASTRUCTUREID=14901
IF "%~1"=="G1" SET INFRASTRUCTUREID=14901
IF "%~1"=="gc" SET INFRASTRUCTUREID=17136
IF "%~1"=="GC" SET INFRASTRUCTUREID=17136
IF "%~1"=="gcd" SET INFRASTRUCTUREID=17136
IF "%~1"=="GCD" SET INFRASTRUCTUREID=17136
GOTO :OpsTicket

:OpsTicket
SET PID=11900
REM issuetype=3 -> Task
REM issuetype=7 -> Story
IF NOT "%INFRASTRUCTUREID%"=="" (
  SET INFRASTRUCTURE="%INFRASTRUCTUREFIELD%=%INFRASTRUCTUREID%"
)
START %JIRAURL%/secure/CreateIssueDetails!init.jspa?pid=%PID%^&issuetype=7^&reporter=%JIRAUSER%^&assignee=%JIRAUSER%^&priority=6%ASSIGNEDDEV%%REQUESTOR%%INFRASTRUCTURE%
GOTO :EOF

:OpsChangeRequestTicket
SET PID=11900
SET ISSUETYPEID=12002
START %JIRAURL%/secure/CreateIssueDetails!init.jspa?pid=%PID%^&issuetype=%ISSUETYPEID%^&reporter=%JIRAUSER%^&assignee=%JIRAUSER%^&priority=6%ASSIGNEDDEV%%REQUESTOR%%INFRASTRUCTURE%
GOTO :EOF

:OpsEmergencyChangeTicket
SET PID=11900
SET ISSUETYPEID=12300
START %JIRAURL%/secure/CreateIssueDetails!init.jspa?pid=%PID%^&issuetype=%ISSUETYPEID%^&reporter=%JIRAUSER%^&assignee=%JIRAUSER%^&priority=6%ASSIGNEDDEV%%REQUESTOR%%INFRASTRUCTURE%
GOTO :EOF

:CoreTicket
SET PID=10108
START %JIRAURL%/secure/CreateIssueDetails!init.jspa?pid=%PID%^&issuetype=3^&reporter=%JIRAUSER%^&assignee=%JIRAUSER%^&priority=6%ASSIGNEDDEV%%REQUESTOR%
GOTO :EOF

:G1Ticket
SET PID=16202
START %JIRAURL%/secure/CreateIssueDetails!init.jspa?pid=%PID%^&issuetype=3^&reporter=%JIRAUSER%^&assignee=%JIRAUSER%^&priority=6%REQUESTOR%
GOTO :EOF

:QWTicket
SET PID=18100
START %JIRAURL%/secure/CreateIssueDetails!init.jspa?pid=%PID%^&issuetype=3^&reporter=%JIRAUSER%^&assignee=%JIRAUSER%^&priority=6%REQUESTOR%%PRIORITY%%BUSINESSVALUE%
GOTO :EOF

:EOF
EXIT
