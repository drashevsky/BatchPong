@echo off
call :RESIZE
call :SIDELINE

call :DRAWBALL 10 10

pause > nul

:DRAWBALL & REM A prototype function for drawing the Pong ball
setlocal EnableDelayedExpansion
	::All variables: left and down positions, the main buffer, empty char, and newline
	set /a "left=%~1-1" & set /a "down=%~2-1" & set "buffer=" & set "blankchar= " & set NLM=^


	set NL=^^^%NLM%%NLM%^%NLM%%NLM%
	for /L %%F IN (1,1,!left!) DO (
		set "buffer=!blankchar!!buffer!"
	)
	for /L %%H IN (1,1,!down!) DO (
		set buffer=%nl%!buffer!
	)
	set buffer=!buffer!O
	echo !buffer!
endlocal
goto:eof



:EMPTYSPACE & REM A prototype function for handling the empty space after the ball
setlocal EnableDelayedExpansion
	::Taken space - other used lines except for ball
	set "taken=%~1"

	::Down coords of ball
	set "down=%~2"

	::# of empty lines needed
	set /a "needed=%lines%-%taken%-%down%"

	for /L %%F IN (1,1,%needed%) DO (
		echo.
	)

endlocal
goto:eof



:RESIZE & REM Get lines and cols, optimize, may be used at the INIT phase
	mode con: lines=25 cols=80
	for /f "tokens=1,2" %%I IN ('MODE CON ^| FINDSTR /R "[0-9]"') DO (
		if "%%I" EQU "Lines:" set /a "lines=%%J"
		if "%%I" EQU "Columns:" set /a "cols=%%J"
	)
goto:eof



:SIDELINE & REM A prototype for generating sidelines in a frame from the pong game
setlocal EnableDelayedExpansion
	set "char=-"
	set "sideline=!char!"
	for /l %%I IN (2,1,%cols%) DO set "sideline=!char!!sideline!"
endlocal & set "sideline=%sideline%"
goto:eof