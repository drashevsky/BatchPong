@echo off
	echo 07 > BELL & certutil -f -decodehex BELL BELL 2>&1 1>NUL & for /f %%a IN (BELL) DO set "BELL=%%a" 2>&1 1>NUL & del BELL
	set /p "=%BELL%" 0> NUL
pause > nul & exit

:OLD
	echo CA 1>SOUNDSTR.STREAM & choice.exe /c A /n 0<SOUNDSTR.STREAM 1>NUL & del SOUNDSTR.STREAM