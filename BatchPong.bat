@echo off
:PROCESSCONTROL & REM Check for which process to start - the game has several during the actual game play, including one to get the KEYS and another to update the DISPlay
	if "%1" EQU "KEYS" goto :KEYS
	if "%1" EQU "DISP" goto :INIT
	if "%1" EQU "CNTL" goto :INIT



:INIT & REM This label is used by the program in order to reinitialize itself, at the end of a subroutine such as a singleplayer game



:INIT.VARS.SETTINGS & REM Set basic settings and routines
	:Set the main data directory location
		set "DATADIR=%APPDATA%"

	:Set the version string
		set "ver=1.0"

	:Set the screen size
		set "lines=25"
		set "cols=80"
		mode con: lines=%lines% cols=%cols%

	:Routine to display the title - requires an ENDLOCAL statement after routine completes
		set "routines.displayTitle=cls & setlocal EnableDelayedExpansion & for /f "tokens=1,2 delims=:." %%I IN ("!time!") DO (set "ltime=%%I:%%J") & for /f "tokens=* eol=¬ delims=¬" %%I IN (%DATADIR%\BatchPong\TitleData\TitleChrs) DO (echo %%I) ^& title Batch Pong Version %ver%"

	

:INIT.VARS.GAMEVARS & REM Sets various settings to be used by the game, such as special characters
	:Sets the length of the paddle
		set "paddle.global.length=4"
	
	:Sets newline character - space between NLM and NL is required
		set NLM=^


		set NL=^^^%NLM%%NLM%^%NLM%%NLM%

	:Sets backspace character
		for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"

	:Sets bell character, for sounds, using certutil
		echo 07 > BELL & certutil -f -decodehex BELL BELL 2>&1 1>NUL & for /f %%a IN (BELL) DO set "BELL=%%a" 2>&1 1>NUL & del BELL

	:The game display is based on empty strings that are then modified to contain the paddles and ball: change emptychar to see the mechanics of the display
	:The following code generates one empty line for reference
		setlocal EnableDelayedExpansion
			set "emptychar= "
			set "emptyline=!emptychar!"
			for /l %%I IN (4,1,%cols%) DO set "emptyline=!emptychar!!emptyline!"
		endlocal & set "emptyline=%emptyline%"
	
	:Sets the last addressable emptyline available for modification
		set /a "linelimit=%lines%-1"

	:Creates the buffer that can be modified by the game, consisting of emptylines
		for /l %%I IN (2,1,%linelimit%) DO (set "framebuffer.%%I=%emptyline%")



:INIT.RUN & REM Runs "housekeeping" subroutines
	if %lines% LSS 25 cls & echo Error: Line size. Please reconfigure. & pause > nul & exit
	if %cols% LSS 80 cls & echo Error: Column size. Please reconfigure. & pause > nul & exit
	if "%1" EQU "DISP" goto :DISP
	if "%1" EQU "CNTL" goto :CNTL
	call :ROUTINES.DIR.MAIN
	call :ROUTINES.DIR.SCORES
	call :ROUTINES.DIR.TITLEDATA


::--------------------------------------------------------------------------------Menus--------------------------------------------------------------------------------

:MENU & REM Display main menu
	call :ROUTINES.DIR.TITLEDATA
	%routines.displayTitle%

	echo ------------------------------------------------------------
	echo      Batch Pong Ver. %ver% Time: %ltime% [Press any key...]
	set /p "=------------------------------------------------------------" 0> nul & pause > nul & endlocal
	
	call :ROUTINES.DIR.TITLEDATA
	%routines.displayTitle%

	echo ------------------------------------------------------------
	echo             [P]lay [S]cores [R]eset Time: %ltime%
	set /p "=------------------------------------------------------------" 0> nul & choice.exe /c PSR /n > nul & endlocal

	if %ERRORLEVEL% EQU 1 goto :LOADPLAY
	if %ERRORLEVEL% EQU 2 goto :SCORES
	if %ERRORLEVEL% EQU 3 goto :RESET
	pause > nul
	exit



:RESET & REM Reset Scores
	call :ROUTINES.DIR.TITLEDATA
	%routines.displayTitle%

	echo ------------------------------------------------------------
	echo     	        Reset? [Y]es [N]o Time: %ltime%
	set /p "=------------------------------------------------------------" 0> nul & choice.exe /c YN /n > nul & endlocal

	if %ERRORLEVEL% EQU 1 (
		if exist %DATADIR%\BatchPong\Scores\ScoreDB copy /y NUL %DATADIR%\BatchPong\Scores\ScoreDB >NUL
	)
	if %ERRORLEVEL% EQU 2 goto :MENU
	goto :INIT



:SCORES & REM Display scores
	cls
	call :ROUTINES.DIR.SCORES

	echo ------------------------Scores Viewer-----------------------

	setlocal EnableDelayedExpansion
		set "FAIL=1"
		for /f "tokens=1,2,3,4,5 delims=:" %%I IN (%DATADIR%\BatchPong\Scores\ScoreDB) DO (
			echo.
			if %%K EQU M echo Game %%I: %%J points against %%L in multiplayer: %%M & set "FAIL=0"
			if %%K EQU S echo Game %%I: %%J points at Level %%L in singleplayer: %%M & set "FAIL=0"
		)
		if %FAIL% EQU 1 echo You have no scores to be displayed.
	endlocal

	set "FAIL=1"
	echo.
	set /p "=Press any key to exit..." 0> nul & pause > nul
	goto :INIT



::----------------------------------------------------------------------------------Subroutines------------------------------------------------------------------------



:TITLESTORE & REM Output title data
	setlocal EnableDelayedExpansion 
		set title=
		set title1=    êê                                    ------------------
		set title2=    êê êêêêêê                             ^|Coding ^& Design:^|
		set title3=    êêêêêêêêêê                            ^|----------------^|
		set title4=  êêêêêê     êêê                          ^|Daniel Rashevsky^|
		set title5= êêê êêê     êêê                          ------------------
		set title6=êêê  êêê     êêê
		set title7=êêê  êêê     êêê
		set title8=êêê  êêê     êêê
		set title9=êêê  êêê     êêê   êêêêêêêêêêê    êêêê  êêêêê       êêêêêê
		set title10=êêê  êêê     êêê  êêêêêêêêêêêêê  êêêêêêêêêêêêê     êêêêêêêê
		set title11=êêê  êêê     êêê  êêê êêê   êêê êêê  êêê     êêê  êêê    êêê
		set title12=êêê  êêêêêêêêê    êêê  êêê  êêêêêê   êêê     êêê  êêê    êêê
		set title13=êêê  êêêêêêêê     êêê   êêêêêêêêê    êêê     êêê  êêê    êêê
		set title14=êêê  êêê êêê	  êêê       êêê      êêê     êêê  êêêêêêêêêê
		set title15=êêê  êêê  êêêê    êêê       êêê      êêê     êêê  êêêêêêêêêê
		set title16=êêêêêêêê    êêêêêêêêêêêêêêêêêêê      êêê      êêêêêêêêê  êêê
		set title17=êêêêêê        êêêêêêêêêêêêêêêê       êêê       êêê  êê   êêê
		set title18=                                                   êêê   êêê
		set title19=                                                   êêê   êêê
		set title20=                                                   êêê  êêê
		set title21=                                                   êêêêêêê
		set title22=                                                    êêêêê 
		for /l %%I IN (1,1,22) DO (
			if not exist %DATADIR%\BatchPong\TitleData mkdir %DATADIR%\BatchPong\TitleData
			echo !title%%I! >> %DATADIR%\BatchPong\TitleData\TitleChrs
		)
	endlocal
	goto:eof



:ROUTINES.DIR.MAIN & REM Check for main directory
	if not exist %DATADIR%\BatchPong mkdir %DATADIR%\BatchPong
	goto:eof



:ROUTINES.DIR.SCORES & REM Check for scores directory
	if not exist %DATADIR%\BatchPong\Scores mkdir %DATADIR%\BatchPong\Scores
	if not exist %DATADIR%\BatchPong\Scores\ScoreDB copy /y NUL %DATADIR%\BatchPong\Scores\ScoreDB > NUL
	goto:eof



:ROUTINES.DIR.TITLEDATA & REM Check for title banner data directory
	if not exist %DATADIR%\BatchPong\TitleData mkdir %DATADIR%\BatchPong\TitleData
	if not exist %DATADIR%\BatchPong\TitleData\TitleChrs copy /y NUL %DATADIR%\BatchPong\TitleData\TitleChrs >NUL && call :TITLESTORE
	goto:eof



:ROUTINES.DIR.GAMEDATA & REM Check for data files/folders required by game
	if exist %DATADIR%\BatchPong\GameData rmdir /s /q %DATADIR%\BatchPong\GameData
	if not exist %DATADIR%\BatchPong\GameData mkdir %DATADIR%\BatchPong\GameData
	copy /y NUL %DATADIR%\BatchPong\GameData\KEYSTREAM >NUL 2>&1
	copy /y NUL %DATADIR%\BatchPong\GameData\COMMANDSTREAM >NUL 2>&1
	goto:eof



::--------------------------------------------------------------------------------Game---------------------------------------------------------------------------------



:LOADPLAY
	cls & echo Loading...
	ping 127.0.0.1 -n 2 -w 10000 > nul
	call :ROUTINES.DIR.MAIN
	call :ROUTINES.DIR.SCORES
	call :ROUTINES.DIR.GAMEDATA
	call :ROUTINES.DIR.TITLEDATA
	start "" /b cmd /c ^""%~f0" CNTL 3^>"%DATADIR%\BatchPong\GameData\COMMANDSTREAM" 4^<"%DATADIR%\BatchPong\GameData\KEYSTREAM"^"
	goto:eof


:KEYS
setlocal EnableDelayedExpansion
	for /f "delims=¬ eol=¬" %%A IN ('xcopy /w "%~f0" "%~f0" 2^> NUL') DO (
		taskkill /f /im xcopy.exe
		if not defined stopKeyFetch set "keyraw=%%A"
		set "stopKeyFetch=1"
	) 1>NUL 2>&1
	set "keyraw=!keyraw:~-1!"
	echo.NULL>&3
	if "!keyraw!" EQU "w" echo.w>&3
	if "!keyraw!" EQU "s" echo.s>&3
	set /p status=<&4
	if "%status%" EQU "terminate" taskkill /f /im xcopy.exe & goto:eof
	endlocal
	goto :KEYS



:DISP
setlocal EnableDelayedExpansion
	set /p status=<&4
	if "%status%" EQU "terminate" goto:eof
	for /f "tokens=1,2,3,4,5 delims=:" %%A IN ("!status!") DO (
		if "%%A" EQU "update_disp" (
			cls
			set /a "paddle.LINE.START.1=%%D+1"
			set /a "paddle.LINE.START.2=%%E+1"
			set /a "paddle.LINE.END.1=%%D+%paddle.global.length%"
			set /a "paddle.LINE.END.2=%%E+%paddle.global.length%"
			for /l %%I IN (!paddle.LINE.START.1!,1,!paddle.LINE.END.1!) DO (
				set "framebuffer.%%I=^|!framebuffer.%%I!!bs!"
			)
			for /l %%I IN (!paddle.LINE.START.2!,1,!paddle.LINE.END.2!) DO (
				set "framebuffer.%%I=!framebuffer.%%I!^|"
			)
			set "framebuffer.%%C=!framebuffer.%%C:~0,%%B!%bs%O!framebuffer.%%C:~%%B,%cols%!"
			for /l %%I IN (2,1,!linelimit!) DO (
				set screenbuffer=!screenbuffer!%nl%!framebuffer.%%I!%bs%
			)
			echo.!screenbuffer!
		)
	)
	endlocal
	goto :DISP



:CNTL
	setlocal EnableDelayedExpansion
	%routines.displayTitle%
	echo.
	set /p "playerName=Name of Player:"
	if "%playerName%" EQU "" (
		%routines.displayTitle%
		echo.
		echo Error: Player name is missing [Singleplayer].
		pause > nul
		goto :CNTL
	)
	%routines.displayTitle%
	echo.
	set /p =Choose a difficulty: [1] [2] [3] [4] 0> nul
	choice /c 1234 /n
	set "difficulty=%errorlevel%"
	set /a "ball.Pos.X=%cols%/2"
	set /a "ball.Pos.Y=%lines%/2"
	set /a "paddle.Pos.1=%lines%/2-2"
	set /a "paddle.Pos.2=%lines%/2-2"
	set /a "ball.Dir.lr=%RANDOM% %% 2"
	if "%ball.Dir.lr%" EQU  "1" set "ball.Dir.lr=2"
	set /a "ball.Dir.delta=%RANDOM% %% 2
	start "" /b cmd /c ^""%~f0" KEYS 3^>"%DATADIR%\BatchPong\GameData\KEYSTREAM" 4^<"%DATADIR%\BatchPong\GameData\COMMANDSTREAM" 1^>nul 2^>^&1^"
	start "" /b cmd /c ^""%~f0" DISP 4^<"%DATADIR%\BatchPong\GameData\COMMANDSTREAM"^"

:GAME
	set /p status=<&4
	if "%status%" EQU "w" set /a "paddle.Pos.1-=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3 & 	set /a "ball.Pos.X-=2"
	if "%status%" EQU "s" set /a "paddle.Pos.1+=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3 & 	set /a "ball.Pos.X+=2"
	set status=
	goto :GAME
