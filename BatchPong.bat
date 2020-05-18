@echo off

:INIT & REM Initialize
	::Directory root
		set "DATADIR=%APPDATA%"
		if not exist %DATADIR%\BatchPong mkdir %DATADIR%\BatchPong

	::Scores folder/file
		if not exist %DATADIR%\BatchPong\Scores mkdir %DATADIR%\BatchPong\Scores
		if not exist %DATADIR%\BatchPong\Scores\ScoreDB copy /y NUL %DATADIR%\BatchPong\Scores\ScoreDB >NUL

	::Title folder/file
		if not exist %DATADIR%\BatchPong\TitleData mkdir %DATADIR%\BatchPong\TitleData
		if not exist %DATADIR%\BatchPong\TitleData\TitleChrs (
			copy /y NUL %DATADIR%\BatchPong\TitleData\TitleChrs >NUL && call :TITLESTORE
		)

	::Version, Title, and Window variables
		set "ver=1.0"
		title Batch Pong Version %Ver%
		mode con: lines=25 cols=80
		for /f "tokens=1,2" %%I IN ('MODE CON ^| FINDSTR /R "[0-9]"') DO (
			if "%%I" EQU "Lines:" set /a "lines=%%J"
			if "%%I" EQU "Columns:" set /a "cols=%%J"
		)
		set /a "linelimit=%lines%-1"

	::Get time and display title package - getTime needs an endlocal after it
		set "getTime=setlocal EnableDelayedExpansion & for /f "tokens=1,2 delims=:." %%I IN ("!time!") DO (set "ltime=%%I:%%J")"
		set "displayTitle=for /f "tokens=* eol=¬ delims=¬" %%I IN (%DATADIR%\BatchPong\TitleData\TitleChrs) DO (echo %%I)"
		set "displayTtlA=cls & %getTime% & %displayTitle%"

	goto :MENU



:MENU & REM Display Menu
	if not exist %DATADIR%\BatchPong\TitleData\TitleChrs goto :INIT
	%displayTtlA%

	echo ------------------------------------------------------------
	echo      Batch Pong Ver. %ver% Time: %ltime% [Press any key...]
	set /p "=------------------------------------------------------------" 0> nul & pause > nul & endlocal
	
	if not exist %DATADIR%\BatchPong\TitleData\TitleChrs goto :INIT
	%displayTtlA%

	echo ------------------------------------------------------------
	echo  [M]ultiplayer [S]ingleplayer [T]Scores [R]eset Time: %ltime%
	set /p "=------------------------------------------------------------" 0> nul & choice.exe /c MSTR /n > nul & endlocal

	if %ERRORLEVEL% EQU 1 echo Multiplayer
	if %ERRORLEVEL% EQU 2 echo Singleplayer
	if %ERRORLEVEL% EQU 3 goto :SCORES
	if %ERRORLEVEL% EQU 4 goto :RESET
	pause > nul
	exit



:RESET & REM Reset Scores
	if not exist %DATADIR%\BatchPong\TitleData\TitleChrs (
		cls & set /p "=Reset unsuccessful. Press any key to go back to the main menu and try again." 0> nul
		pause > nul
		goto :INIT
	)
	%displayTtlA%

	echo ------------------------------------------------------------
	echo     	        Reset? [Y]es [N]o Time: %ltime%
	set /p "=------------------------------------------------------------" 0> nul & choice.exe /c YN /n > nul & endlocal

	if %ERRORLEVEL% EQU 1 (
		if exist %DATADIR%\BatchPong\Scores\ScoreDB copy /y NUL %DATADIR%\BatchPong\Scores\ScoreDB >NUL
	)
	if %ERRORLEVEL% EQU 2 goto :MENU
	goto :INIT



:SCORES & REM Display Scores
	cls
	if not exist %DATADIR%\BatchPong\Scores mkdir %DATADIR%\BatchPong\Scores
	if not exist %DATADIR%\BatchPong\Scores copy /y NUL %DATADIR%\BatchPong\Scores\ScoreDB >NUL
	if not exist %DATADIR%\BatchPong\Scores\ScoreDB copy /y NUL %DATADIR%\BatchPong\Scores\ScoreDB >NUL

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



:UNPACK 
	goto:eof
