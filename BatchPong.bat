@echo off
REM Batch Pong 1.0 by Daniel Rashevsky
REM Developed 2016 & 2020
REM
REM Controls:
REM 	W/S for Player 1
REM	I/K for Player 2
REM	[ENTER] to unfreeze key input when it glitches
REM
REM Developed in pure batch (no external programs). This means flickering!
REM Works best on a beefier computer running Windows 10
REM Creates "BatchPong" folder in AppData
REM Required commands: taskkill, tasklist, xcopy


:PROCESSCONTROL & REM Check for which process to start - the game has several during the actual game play, including one to get the KEYS and another to update the DISPlay
	if "%1" EQU "KEYS" goto :KEYS
	if "%1" EQU "DISP" goto :INIT
	if "%1" EQU "CNTL" goto :INIT


::--------------------------------------------------------------------------------Initialization--------------------------------------------------------------------------------

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
	echo     [P]lay [M]ultiplayer [S]cores [R]eset Time: %ltime%
	set /p "=------------------------------------------------------------" 0> nul & choice.exe /c PMSR /n > nul & endlocal

	if %ERRORLEVEL% EQU 1 goto :LOADPLAY
	if %ERRORLEVEL% EQU 2 set "multiplayer=on" & goto :LOADPLAY
	if %ERRORLEVEL% EQU 3 goto :SCORES
	if %ERRORLEVEL% EQU 4 goto :RESET



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



:SCORES & REM Display scores over multiple pages
	cls
	call :ROUTINES.DIR.SCORES

	echo ------------------------Scores Viewer-----------------------

	setlocal EnableDelayedExpansion
		set "FAIL=1"
		for /f "tokens=1,2,3,4,5,6,7 delims=:" %%I IN (%DATADIR%\BatchPong\Scores\ScoreDB) DO (
			echo.
			if %%J EQU M echo Game %%I: %%L: %%M point^(s^), %%N: %%O point^(s^), Level %%K multiplayer & set "FAIL=0"
			if %%J EQU S echo Game %%I: %%L: %%M point^(s^), Computer: %%O point^(s^), Level %%K singleplayer & set "FAIL=0"
			
			set /a "turnPage=%%I %% 10"
			if !turnPage! EQU 0 echo. & pause & cls & echo ------------------------Scores Viewer-----------------------
		)
		if %FAIL% EQU 1 echo. & echo You have no scores to be displayed.
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



REM Start the game process, save own PID so it can kill child processes when the game process ends

:LOADPLAY
	call :ROUTINES.DIR.MAIN
	call :ROUTINES.DIR.SCORES
	call :ROUTINES.DIR.GAMEDATA
	call :ROUTINES.DIR.TITLEDATA

	title mainpong
	for /f "tokens=2 USEBACKQ" %%F IN (`tasklist /NH /FI "WindowTitle eq mainpong*"`) DO set mainPID=%%F
	
	start "" /b /w cmd /c ^""%~f0" CNTL 3^>"%DATADIR%\BatchPong\GameData\COMMANDSTREAM" 4^<"%DATADIR%\BatchPong\GameData\KEYSTREAM"^"
	for /f "tokens=2 USEBACKQ" %%F IN (`tasklist /fi "imagename eq cmd.exe" /fo list /v ^| findstr PID`) DO (
		if %%F NEQ %mainPID% (
			taskkill /PID %%F /F >nul 2>&1
		)
	)
	taskkill /f /im xcopy.exe >nul 2>&1
	goto :INIT



REM Child process that runs alongside main game loop and streams keys back to it

:KEYS
setlocal EnableDelayedExpansion	
	for /f "delims=¬ eol=¬" %%A IN ('xcopy /w "%~f0" "%~f0" 2^> NUL') DO (
		taskkill /f /im xcopy.exe
		if not defined stopKeyFetch set "keyraw=%%A"
		set "stopKeyFetch=1"
	) 1>NUL 2>&1
	set "keyraw=!keyraw:~-1!"
	if "!keyraw!" EQU "w" echo.w>&3
	if "!keyraw!" EQU "s" echo.s>&3
	if "!keyraw!" EQU "i" echo.i>&3
	if "!keyraw!" EQU "k" echo.k>&3
	if "!keyraw!" EQU "q" echo.q>&3
	endlocal
	goto :KEYS



REM Child process that runs alongside main game loop and redraws the screen on command,
REM stores entire frame (including spaces, newlines, backspaces) in variable before outputing

:DISP
setlocal EnableDelayedExpansion
	set /p status=<&4
	if "!status!" EQU "terminate" goto:eof
	for /f "tokens=1,2,3,4,5 delims=:" %%A IN ("!status!") DO (
		if "%%A" EQU "update_disp" (
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
			set "framebuffer.%%C=!framebuffer.%%C:~0,%%B!%bs%@!framebuffer.%%C:~%%B,%cols%!"
			for /l %%I IN (2,1,!linelimit!) DO (
				set screenbuffer=!screenbuffer!%nl%!framebuffer.%%I!%bs%
			)
			
			cls
			echo.!screenbuffer!
		)
	)
	endlocal
	goto :DISP



REM Separately started game process that runs in same window as child processes (KEYS and DISP), receiving keys and sending commands
REM to redraw the screen. The CNTL portion gets player names and sets up game variables/state before jumping to the game loop portion.

:CNTL
setlocal EnableDelayedExpansion


	::Get player name(s), depending on single or multiplayer

	%routines.displayTitle%
	echo.
	set /p "playerName=Name of Player: "

	if "%playerName%" EQU "" (
		%routines.displayTitle%
		echo.
		echo Error: Player name is missing.
		pause > nul
		goto :CNTL
	)

	if defined multiplayer (
		%routines.displayTitle%
		echo.
		set /p "otherPlayerName=Name of Second Player: "
	) else (
		set "otherPlayerName=Computer"
	)

	if "%otherPlayerName%" EQU "" (
		%routines.displayTitle%
		echo.
		echo Error: Second player name is missing.
		pause > nul
		goto :CNTL
	)


	::Get game difficulty
	
	%routines.displayTitle%
	echo.
	set /p =Choose a difficulty: [1] [2] [3] [4] 0> nul
	choice /c 1234 /n
	
	set /a "difficulty=%errorlevel%"
	set /a "refreshrate.disp=30"
	if %difficulty% EQU 1 set /a "refreshrate.game=22"
	if %difficulty% EQU 2 set /a "refreshrate.game=18"
	if %difficulty% EQU 3 set /a "refreshrate.game=16"
	if %difficulty% EQU 4 set /a "refreshrate.game=14"

	
	::Initialize game variables/state such as score, game element positions and timing

	set "gametime=1"
	set "timer=100"
	set "refreshrate.timer=250"

	set /a "ball.Pos.X=%cols%/2"
	set /a "ball.Pos.Y=%lines%/2"
	set /a "paddle.Pos.1=%lines%/2-2"
	set /a "paddle.Pos.2=%lines%/2-2"
	set /a "ball.Dir.delta.X=%RANDOM% %% 2"
	set /a "ball.Dir.delta.Y=%RANDOM% %% 2"
	if "%ball.Dir.delta.X%" EQU "0" set "ball.Dir.delta.X=-1"
	if "%ball.Dir.delta.Y%" EQU "0" set "ball.Dir.delta.Y=-1"

	set /a player1=0
	set /a player2=0


	::Start KEYS and DISP child processes, display newly initialized game state in title
	
	title %playerName%: %player1%  %otherPlayerName%: %player2%  Difficulty: %difficulty%  Time Left: %timer%
	start "" /b cmd /c ^""%~f0" KEYS 3^>"%DATADIR%\BatchPong\GameData\KEYSTREAM" 1^>nul 2^>^&1^"
	start "" /b cmd /c ^""%~f0" DISP 4^<"%DATADIR%\BatchPong\GameData\COMMANDSTREAM"^"	



REM Game loop portion of game process, run the screen, keep track of score/time, etc

:GAME

	::Update internal refresh rates, which control how fast or slow the timer, display, and game state get updated

	if "%gametime%" EQU "100000" set /a "gametime=1"
	set /a "gametime+=1"
	set /a "doDispRefresh=%gametime% %% %refreshrate.disp%"
	set /a "doTimerRefresh=%gametime% %% %refreshrate.timer%"
	set /a "doGameRefresh=%gametime% %% %refreshrate.game%"

	
	::Update paddle positions in response to key presses. Because of the shoddy key detection I'm using only one paddle can be moving at a time

	set /p status=<&4
	if not defined multiplayer (		
		if "%status%" EQU "w" set /a "paddle.Pos.1-=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3
		if "%status%" EQU "s" set /a "paddle.Pos.1+=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3
	)

	if defined multiplayer (
		if %ball.Dir.delta.X% EQU -1 (
			if "%status%" EQU "w" set /a "paddle.Pos.1-=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3
			if "%status%" EQU "s" set /a "paddle.Pos.1+=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3
		) else (
			if "%status%" EQU "i" set /a "paddle.Pos.2-=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3
			if "%status%" EQU "k" set /a "paddle.Pos.2+=2" & echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3
		)
	)


	::Update timer and display at thier respective refresh rates. Display updating means sending the DISP process new positions for 
	::everything. Timer ticks down to 0, then ends game.

	if "%doDispRefresh%" EQU "0" (
		echo.update_disp:%ball.Pos.X%:%ball.Pos.Y%:%paddle.Pos.1%:%paddle.Pos.2%>&3
	)

	if "%doTimerRefresh%" EQU "0" (
		set /a "timer-=1"
		if %timer% LEQ 0 goto :ENDGAME
		title %playerName%: %player1%  %otherPlayerName%: %player2%  Difficulty: %difficulty%  Time Left: %timer%
	)


	::Update game state: the ball bouncing off the walls, scoring goals, colliding with the paddles, moving the "AI", and etc

	if "%doGameRefresh%" EQU "0" (
		if %ball.Pos.Y% LEQ 2 set /a "ball.Dir.delta.Y=1,ball.Pos.Y=2" & set /p "=%BELL%" 0> nul
		if %ball.Pos.Y% GEQ %linelimit% set /a "ball.Dir.delta.Y=-1,ball.Pos.Y=%linelimit%-1" & set /p "=%BELL%" 0> nul

		if %ball.Pos.X% LEQ 1 (
			set /p "=%BELL%" 0> nul
			set /a "ball.Dir.delta.X=1"
			set /a "ball.Pos.X=1"
			set /a "ball.Dir.delta.Y=!RANDOM! %% 2"
			set /a "lowerHitBoxBound=%paddle.Pos.1%"
			set /a "upperHitBoxBound=%paddle.Pos.1%+%paddle.global.length%+1"
			if %ball.Pos.Y% LSS !lowerHitBoxBound! set /a "player2+=1" & call :GOAL
			if %ball.Pos.Y% GTR !upperHitBoxBound! set /a "player2+=1" & call :GOAL
		)
		if %ball.Pos.X% GEQ %cols% (
			set /p "=%BELL%" 0> nul
			set /a "ball.Dir.delta.X=-1"
			set /a "ball.Pos.X=%cols%"
			set /a "ball.Dir.delta.Y=!RANDOM! %% 2"
			set /a "lowerHitBoxBound=%paddle.Pos.2%"
			set /a "upperHitBoxBound=%paddle.Pos.2%+%paddle.global.length%+1"
			if %ball.Pos.Y% LSS !lowerHitBoxBound! set /a "player1+=1" & call :GOAL
			if %ball.Pos.Y% GTR !upperHitBoxBound! set /a "player1+=1" & call :GOAL
		)
		if "%ball.Dir.delta.Y%" EQU "0" set "ball.Dir.delta.Y=-1"

		set /a "ball.Pos.X+=%ball.Dir.delta.X%"
		set /a "ball.Pos.Y+=%ball.Dir.delta.Y%"

		if not defined multiplayer (
			if %ball.Dir.delta.X% EQU 1 (
				set /a "adjustedPos=%paddle.Pos.2% + 2"
				if %ball.Pos.Y% GEQ !adjustedPos! set /a "paddle.Pos.2+=1"
				if %ball.Pos.Y% LSS !adjustedPos! set /a "paddle.Pos.2-=1"
			)
		) else (
			if %paddle.Pos.2% LEQ 1 set "paddle.Pos.2=1"
			if %paddle.Pos.2% GEQ %linelimit% set /a "paddle.Pos.2=%linelimit%-%paddle.global.length%"
		)

		if %paddle.Pos.1% LEQ 1 set "paddle.Pos.1=1"
		if %paddle.Pos.1% GEQ %linelimit% set /a "paddle.Pos.1=%linelimit%-%paddle.global.length%"
	)

	set status=
	goto :GAME


	
REM Subroutine that updates the score, title, and ball when a goal is scored

:GOAL
	set /a "ball.Pos.X=%cols%/2"
	set /a "ball.Pos.Y=%lines%/2"
	set /a "ball.Dir.delta.X=%RANDOM% %% 2"
	set /a "ball.Dir.delta.Y=%RANDOM% %% 2"
	if "%ball.Dir.delta.X%" EQU "0" set "ball.Dir.delta.X=-1"
	if "%ball.Dir.delta.Y%" EQU "0" set "ball.Dir.delta.Y=-1"
	title %playerName%: %player1%  %otherPlayerName%: %player2%  Difficulty: %difficulty%  Time Left: %timer%
	goto:eof



REM When the timer ticks down to 0, this saves the scores and stalls until the user presses a key to go to the main menu
REM I didn't use pause here because XCOPY from KEYS would make it so you would have to press a key twice.

:ENDGAME
	set /a "lastID=0"
	for /f "tokens=1,2,3,4,5 delims=:" %%I IN (%DATADIR%\BatchPong\Scores\ScoreDB) DO set /a "lastID=%%I"
	set /a "lastID+=1"

	if defined multiplayer (
		echo !lastID!:M:%difficulty%:%playerName%:%player1%:%otherPlayerName%:%player2% >> %DATADIR%\BatchPong\Scores\ScoreDB
	) else (
		echo !lastID!:S:%difficulty%:%playerName%:%player1%:%otherPlayerName%:%player2% >> %DATADIR%\BatchPong\Scores\ScoreDB
	)
	
	echo terminate>&3
	%routines.displayTitle%
	echo ------------------------------------------------------------
	echo              Game over^^! Press [q] to continue...
	set /p "=------------------------------------------------------------" 0> nul
	goto :WAITKEY

:WAITKEY
	set /p status=<&4
	if "%status%" NEQ "q" goto :WAITKEY
	exit
