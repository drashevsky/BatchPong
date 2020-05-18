@echo off
:RESIZE
	mode con: lines=25 cols=80
	for /f "tokens=1,2" %%I IN ('MODE CON ^| FINDSTR /R "[0-9]"') DO (
		if "%%I" EQU "Lines:" set /a "lines=%%J"
		if "%%I" EQU "Columns:" set /a "cols=%%J"
	)



:GETGAMEVARS
	set NLM=^


	set NL=^^^%NLM%%NLM%^%NLM%%NLM%
	setlocal EnableDelayedExpansion
		set "char= "
		set "emptyline=!char!"
		for /l %%I IN (4,1,%cols%) DO set "emptyline=!char!!emptyline!"
	endlocal & set "emptyline=%emptyline%"
	for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"
	echo 07 > BELL & certutil -f -decodehex BELL BELL 2>&1 1>NUL & for /f %%a IN (BELL) DO set "BELL=%%a" 2>&1 1>NUL & del BELL
	set "paddle.global.length=4"
	set /a "linelimit=%lines%-1"
	for /l %%I IN (2,1,%linelimit%) DO (set "framebuffer.%%I=%emptyline%")



:MAINPROC
	title [BatchPong Singleplayer] You: 45 pts ^| Computer: 29 pts ^| Level: 3
	set "num.all=10"
	call :RENDERFRAME %num.all% %num.all% %num.all% %num.all%
	:LOOP
		cls
		call :RENDERFRAME %num.all% %num.all% %num.all% %num.all%
		choice.exe /c WS /n > NUL
		if %errorlevel% EQU 1 set /a "num.all-=1"
		if %errorlevel% EQU 2 set /a "num.all+=1"
		goto :LOOP
	pause > nul & exit

	


:RENDERFRAME
setlocal EnableDelayedExpansion
		set /a "paddle.LINE.START.1=%~3+1"
		set /a "paddle.LINE.START.2=%~4+1"
		set /a "paddle.LINE.END.1=%~3+%paddle.global.length%"
		set /a "paddle.LINE.END.2=%~4+%paddle.global.length%"
		for /l %%I IN (!paddle.LINE.START.1!,1,!paddle.LINE.END.1!) DO (
			set "framebuffer.%%I=^|!framebuffer.%%I!!bs!"
		)
		for /l %%I IN (!paddle.LINE.START.2!,1,!paddle.LINE.END.2!) DO (
			set "framebuffer.%%I=!framebuffer.%%I!^|"
		)
		set "framebuffer.%~2=!framebuffer.%~2:~0,%~1!%bs%O!framebuffer.%~2:~%~1,%cols%!"
		for /l %%I IN (2,1,!linelimit!) DO (
			set screenbuffer=!screenbuffer!%nl%!framebuffer.%%I!%bs%
		)
		REM 3>FRAME.STREAM (echo !screenbuffer! 1>&3)
		echo.!screenbuffer!
endlocal
goto:eof