set /a "paddle.global.MaxDownY=!lines!-!paddle.global.Length!-1"
set /a "paddle.global.MinDownY=0"


set "paddle.1.inY=!paddle.global.MaxDownY!"
set "paddle.2.inY=!paddle.global.MaxDownY!"

for /l %%I IN (1,1,!paddle.global.length!) DO (
	set /a "tmp=!paddle.1.LINE.%%I!-1"
	for /l %%N IN (!tmp!,1,!paddle.1.LINE.%%I!) DO (
		if %%N EQU !paddle.1.LINE.%%I! set "framebuffer.!paddle.1.LINE.%%I!=Û!framebuffer.%%N!!bs!"
				
	)
	set /a "tmp=!paddle.2.LINE.%%I!-1"
	for /l %%N IN (!tmp!,1,!paddle.2.LINE.%%I!) DO (
		if %%N EQU !paddle.2.LINE.%%I! set "framebuffer.!paddle.2.LINE.%%I!=!framebuffer.%%N!Û"
	)
	set tmp=
)

set "framebuffer.1=!sideline!"
set "framebuffer.!lines!=!sideline!"

	for /l %%I IN (1,0,1) DO (
		setlocal EnableDelayedExpansion
		3<FRAME.STREAM (
			set /P line= <&3
			if !line! NEQ !prev! set "prev=!line!" & cls & echo !prev!
        	)
		endlocal
	)

SET /a _rand=(%RANDOM%*2/32768)+1


::Programs folder/files
	if exist %DATADIR%\BatchPong\Prog rmdir /s /q %DATADIR%\BatchPong\Prog
	if not exist %DATADIR%\BatchPong\Prog mkdir %DATADIR%\BatchPong\Prog
	if exist %DATADIR%\BatchPong\Prog call :UNPACK

for /f %%a in ('"prompt $E&for %%b in (1) do rem"') do set "ESC=%%a"
for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"



:TIMETHIS
setlocal 
	set "cmd=%~1"
	set "startTime=%time%"
	%cmd% > NUL
        set "endTime=%time%"
	for /f "delims=:. tokens=3,4" %%I IN ("%startTime%") DO set "startTime=%%I%%J"
	for /f "delims=:. tokens=3,4" %%I IN ("%endTime%") DO set "endTime=%%I%%J"
	set /a "finalTime=%endTime%-%startTime%"
endlocal & set "execTime=%finalTime%"
goto:eof
