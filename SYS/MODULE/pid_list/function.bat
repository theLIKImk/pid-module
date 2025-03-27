:list
	set _cd=%cd%
	cd /d "%PIDMD_ROOT%"
	for /r %%f in (SYS/PID/*) do echo %%~nxf
	cd /d "%cd%"
exit /b 0