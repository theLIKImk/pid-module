:exist_pid
::call :exist_pid [PID]
	FOR /F %%s in ('TASKLIST /FI "PID eq %1"') do set cmdput=%%s
	if /i "%LANG%"=="zh" (
		if "%cmdput%"=="%zh_check_pid_info%" exit /b 1
	)
	if /i "%LANG%"=="en" (
		if "%cmdput%"=="%en_check_pid_info%" exit /b 1
	)
exit /b 0
