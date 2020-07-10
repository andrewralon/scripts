@ECHO OFF
REM tfs.bat
REM Purpose:  Access TFS's tf.exe commands from anywhere
REM Requires: VS 2017
REM Help:     tf /?
REM Usage:    tfs [any tf.exe commands or arguments]
REM Example:  tfs changeset [changeset]

REM VS 2015: "\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\tf.exe"
REM VS 2017: "\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"

SET TFSPATH="C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
%TFSPATH% %*
ECHO(
REM PAUSE
