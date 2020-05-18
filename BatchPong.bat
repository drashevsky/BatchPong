@echo off
:INIT & REM Program Phase I - Initialize

::Main dir
if not exist %APPDATA%\BatchPong mkdir %APPDATA%\BatchPong

::Scores folder
if not exist %APPDATA%\BatchPong\Scores mkdir %APPDATA%\BatchPong\Scores

::Scores file
if not exist %APPDATA%\BatchPong\Scores\ScoreDB copy /y NUL %APPDATA%\BatchPong\Scores\ScoreDB >NUL

::Title folder
if not exist %APPDATA%\BatchPong\TitleData mkdir %APPDATA%\BatchPong\TitleData

::Title file
if not exist %APPDATA%\BatchPong\TitleData\TitleChrs copy /y NUL %APPDATA%\BatchPong\TitleData\TitleChrs >NUL && call :TITLESTORE

::Programs
(
	if exist %APPDATA%\BatchPong\Prog rmdir /s /q %APPDATA%\BatchPong\Prog
	if not exist %APPDATA%\BatchPong\Prog mkdir %APPDATA%\BatchPong\Prog
	if exist %APPDATA%\BatchPong\Prog call :UNPACK
)

::Time function
set "getTime=for /f "tokens=1,2 delims=:." %%I IN ("%time%") DO (set "ltime=%%I:%%J")"

::Version
set "ver=1.0"

::Title display function
set "displayTitle=for /f "tokens=* eol=¬ delims=¬" %%I IN (%APPDATA%\BatchPong\TitleData\TitleChrs) DO (echo %%I)"



:MENU & REM Program Phase II - Display Menu
cls
%getTime%
%displayTitle%
echo ------------------------------------------------------------
echo     Batch Pong Ver. %ver% Time: %ltime% [Press any key...]
set /p "=------------------------------------------------------------" 0> nul & pause > nul
cls
%displayTitle%
%getTime%
echo ------------------------------------------------------------
echo  [M]ultiplayer [S]ingleplayer [T]Scores [R]eset Time: %ltime%
set /p "=------------------------------------------------------------" 0> nul & choice.exe /c MSTR /n > nul
if %ERRORLEVEL% EQU 1 echo Multiplayer
if %ERRORLEVEL% EQU 2 echo Singleplayer
if %ERRORLEVEL% EQU 3 goto :SCORES
if %ERRORLEVEL% EQU 4 goto :RESET
pause > nul
exit



:RESET & REM Program Phase III-I - Reset Scores
cls
%getTime%
%displayTitle%
echo ------------------------------------------------------------
echo     	             Reset? [Y]es [N]o
set /p "=------------------------------------------------------------" 0> nul & choice.exe /c YN /n > nul
if %ERRORLEVEL% EQU 1 if exist %APPDATA%\BatchPong\Scores\ScoreDB copy /y NUL %APPDATA%\BatchPong\Scores\ScoreDB >NUL
if %ERRORLEVEL% EQU 2 goto:MENU
goto:MENU



:SCORES & REM Program Phase III-II
cls
%getTime%
if not exist %APPDATA%\BatchPong\Scores mkdir %APPDATA%\BatchPong\Scores & copy /y NUL %APPDATA%\BatchPong\Scores\ScoreDB >NUL
if not exist %APPDATA%\BatchPong\Scores\ScoreDB copy /y NUL %APPDATA%\BatchPong\Scores\ScoreDB >NUL
echo ------------------------Scores Viewer-----------------------
setlocal EnableDelayedExpansion
	set "FAIL=1"
	for /f "tokens=1,2,3,4,5 delims=:" %%I IN (%APPDATA%\BatchPong\Scores\ScoreDB) DO (
		echo.
		if %%K EQU M echo Game %%I: %%J points against %%L in multiplayer: %%M & set "FAIL=0"
		if %%K EQU S echo Game %%I: %%J points at Level %%L in singleplayer: %%M & set "FAIL=0"
	)
	if %FAIL% EQU 1 echo You have no scores to be displayed.
endlocal
set "FAIL="
pause > nul
goto :MENU



:TITLESTORE ::Outputs Title Banner Data into Dir
setlocal EnableDelayedExpansion 
set title=
set title1=    II                                       ------------------
set title2=    II IIIIII                                ^|Coding ^& Design:^|
set title3=    IIIIIIIIII                               ^|----------------^|
set title4=  IIIIII     III                             ^|Daniel Rashevsky^|
set title5= III III     III                             ------------------
set title6=III  III     III
set title7=III  III     III
set title8=III  III     III
set title9=III  III     III   IIIIIIIIIII    IIII  IIIII       IIIIII
set title10=III  III     III  IIIIIIIIIIIII  IIIIIIIIIIIII     IIIIIIII
set title11=III  III     III  III III   III III  III     III  III    III
set title12=III  IIIIIIIII    III  III  IIIIII   III     III  III    III
set title13=III  IIIIIIII     III   IIIIIIIII    III     III  III    III
set title14=III  III III	  III       III      III     III  IIIIIIIIII
set title15=III  III  IIII    III       III      III     III  IIIIIIIIII
set title16=IIIIIIII    IIIIIIIIIIIIIIIIIII      III      IIIIIIIII  III
set title17=IIIIII        IIIIIIIIIIIIIIII       III       III  II   III
set title18=                                                   III   III
set title19=                                                   III   III
set title20=                                                   III  III
set title21=                                                   IIIIIII
set title22=                                                    IIIII
for /l %%I IN (1,1,22) DO echo !title%%I! >> %APPDATA%\BatchPong\TitleData\TitleChrs
endlocal
goto:eof



:UNPACK 
goto:eof
