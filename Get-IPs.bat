@ECHO off
SETLOCAL
SETLOCAL EnableDelayedExpansion
FOR /f "usebackq tokens=2 delims=:" %%a IN (`ipconfig ^| findstr /r "IPv4.*[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"`) DO (
  SET _temp=%%a
  REM Remove leading space
  SET _ipaddress=!_temp:~1!
  ECHO !_ipaddress!
  )
ENDLOCAL
