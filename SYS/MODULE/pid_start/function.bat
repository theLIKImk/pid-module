:start
	if /i not "%2"=="SOLO" (
		if not exist "%PIDMD_ROOT%SYS\PID\*-%2" (
			echo -ERR- Rely on pid not exist!
			exit /b
		)
	)
	
	if DEFINED PID_START_PATH_SET (getpid %PID_START_PATH_SET%) else 	(
		if not "%3"=="" (getpid %3 %4 %5 %6 %7 %8 %9) else (echo -ERR- Path not set & exit /b -1)
	)

	set PG_PID=%errorlevel%
	
	if "%PG_PID%"=="0" echo -ERR- Create fail & exit /b -1
	
	goto SET_PID_FILE

:SET_PID_FILE
	echo PID=%PG_PID%>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	echo NAME=%3>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	
	if DEFINED PID_START_PATH_SET (
		echo COMVAL=%PID_START_PATH_SET%>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	) else (
		echo COMVAL=%3 %4 %5 %6 %7 %8>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	)
	echo RELY_ON=%2>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	start hiderun PID.cmd /check_pid %PG_PID% %2
	
	
	set PID_START_PATH_SET=
	SET PID_RUN_PATH_SET=
	
	exit /b %PG_PID%