@ECHO OFF
REM https://ss64.com/nt/syntax-dequote.html
REM SETLOCAL ???
FOR /f "delims=" %%A IN ('ECHO %%%1%%') DO SET %1=%%~A