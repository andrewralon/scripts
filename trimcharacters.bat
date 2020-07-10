@ECHO OFF
REM Trims trailing 11 characters from ALL files in a folder
REM Example: "Filename - Shortcut.txt" -> "Filename.txt"
SETLOCAL EnableDelayedExpansion
SET FOLDER_PATH=C:\PATH\GOES\HERE
ECHO(%FOLDER_PATH%
FOR %%G IN ("%FOLDER_PATH%"*) DO (
	ECHO(%%G 
    SET "filename=%%~nG"
	ECHO(%filename%
    REN "%%G" "!filename:~0,-11!%%~xG"
)
PAUSE
