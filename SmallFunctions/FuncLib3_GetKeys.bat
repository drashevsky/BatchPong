@echo off
if exist KEYSTREAM.txt del KEYSTREAM.txt
:LOOP
setlocal EnableDelayedExpansion
	for /f "delims=¬ eol=¬" %%A IN ('xcopy /w "%~f0" "%~f0" 2^> NUL') DO (
		if not defined stopKeyFetch set "keyraw=%%A"
		set "stopKeyFetch=1"
	) 1>NUL 2>&1
	set "keyraw=!keyraw:~-1!"
	if "!keyraw!" EQU "w" set "key=-1"
	if "!keyraw!" EQU "s" set "key=+1"
	if "!keyraw!" EQU "i" set "key=-1"
	if "!keyraw!" EQU "k" set "key=+1"
	echo.!key!%nl% >> KEYSTREAM.txt
endlocal
goto :LOOP
