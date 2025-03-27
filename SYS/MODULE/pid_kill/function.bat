:kill
	call :exist_pid %2
	if "%errorlevel%"=="1" (
		echo -ERR- %2 Not exist
		if exist "%PIDMD_ROOT%SYS\PID\*-%2" echo -ERR- Clear file &del "%PIDMD_ROOT%SYS\PID\*-%2"
		exit /b -1
	)
	if /i "%1"=="/killpid-f" (taskkill /F /PID %2>nul) else (taskkill /PID %2>nul)
	del "%PIDMD_ROOT%SYS\PID\*-%2" >nul
exit /b 0