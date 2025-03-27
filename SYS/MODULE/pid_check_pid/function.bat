:check_pid
	:check_pid_loop
		if /i not "%3"=="SOLO" (
			IF NOT EXIST "%PIDMD_ROOT%SYS\PID\*-%3" (
				start hiderun call PID.cmd /killpid-f %PG_PID%
				exit /b
			)
		)
		
		if not exist "%PIDMD_ROOT%SYS\PID\*-%2" (
			start hiderun call PID.cmd /killpid-f %PG_PID%
			exit /b
		)
		
		call :exist_pid %2
		if "%errorlevel%"=="1" (
			start hiderun call PID.cmd /killpid %PG_PID%
			exit /b
		)
	goto check_pid_loop
