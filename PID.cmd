@echo off & REM 2025/03/27 周四  7:23:13.99
SET PATH=%PATH%;%~dp0
REM #    HEAD    ###############################################################################
REM ECHO Example load!

if not exist "%~dp0TMP\MODULE_LOAD" mkdir "%~dp0TMP\MODULE_LOAD"


set PIDMD_ROOT=%~dp0
set PATH=%PATH%;%PIDMD_ROOT%
set PM_VER=1.1.1-lite
set PIDMD_DISABLE_RUN=true

set LANG=zh
:: DO NOT CHANG LANG STR
set en_check_pid_info=INFO:
set zh_check_pid_info=信息:

if not exist "%PIDMD_ROOT%SYS\PID\" mkdir "SYS\PID"
if not exist "%PIDMD_ROOT%TMP\" mkdir "TMP\"





REM #  TRIGGER   ###############################################################################
IF /I "%1"=="/example" goto :example 
IF /I "%1"=="/test" goto :example 

IF /I "%1"=="/help" goto :help 

IF /I "%1"=="/module" goto :module 
IF /I "%1"=="/module-list" goto :module 
IF /I "%1"=="/module-merge" goto :module 

IF /I "%1"=="/check_pid" goto :check_pid 

IF /I "%1"=="/exist_pid" goto :exist_pid 

IF /I "%1"=="/#" goto :EOF 

IF /I "%1"=="/killpid" goto :kill 
IF /I "%1"=="/killpid-f" goto :kill 

IF /I "%1"=="/list" goto :list 

IF /I "%1"=="/run" goto :run 

IF /I "%1"=="/start" goto :start 

IF /I "%1"=="/version" goto :version 

exit /b 0 
REM #  FUNCTION  ###############################################################################
:example
	echo [EXAMPLE] ~ Hello World ~
exit /b 0
:help
	call loadcfg.cmd "%~dp0SYS\MODULE\module_manager\data.ini"
	if not exist "%PIDMD_ROOT%help.txt" echo -ERR- help doc lost & exit /b
	type "%PIDMD_ROOT%help.txt"
	echo.
	echo call %module_main_name% /module
	echo call %module_main_name% /module-list
	echo call %module_main_name% /module-merge
exit /b 0
:module
	if "%1"=="/module-list" goto module_list
	if "%1"=="/module-merge" goto module_merge
exit /b 0

:module_list
	pushd "%~dp0SYS\MODULE\"
	for /d %%m in (*) do (
		call :module_list_getinfo %%m
	)
	popd
exit /b 0

:module_list_getinfo
	set MODULE_NAME=%1
	call loadcfg ".\%1\data.ini"
	echo %module_name%(%module_version%)(%module_author%) %module_info%
exit /b 0

:module_merge
	call loadcfg "%~dp0SYS\MODULE\module_manager\data.ini"
	set module_merge_main=%module_main_name%
	echo -- %module_merge_main%
	pushd "%~dp0SYS\MODULE\"
	set module_merge_file_num=0
	for /d %%m in (*) do (
		call :module_merge_copy %%m
	)
	popd
	
	echo -- File consolidation[%module_merge_file_num%]
	
	if exist "%~dp0TMP\.TEMP_MODULE_LOAD" del "%~dp0TMP\.TEMP_MODULE_LOAD" >nul
	if not exist "%~dp0TMP\.TEMP_ENTER" echo.>"%~dp0TMP\.TEMP_ENTER"
	
	echo.@echo off ^& REM %DATE% %TIME%>"%~dp0TMP\.TEMP_MODULE_LOAD
	echo.SET PATH=%%PATH%%%;%;%%~dp0>>"%~dp0TMP\.TEMP_MODULE_LOAD

	REM HEAD
	echo.  - HEAD
	echo.REM #    HEAD    ###############################################################################>> "%~dp0TMP\.TEMP_MODULE_LOAD"
	for /l %%a in (1,1,%module_merge_file_num%) do (
		type "%~dp0TMP\MODULE_LOAD\A%%a.bat" >> "%~dp0TMP\.TEMP_MODULE_LOAD"
		type "%~dp0TMP\.TEMP_ENTER" >> "%~dp0TMP\.TEMP_MODULE_LOAD"
	)
	
	REM TRIGGER
	echo.  - TRIGGER
	echo.REM #  TRIGGER   ###############################################################################>> "%~dp0TMP\.TEMP_MODULE_LOAD"
	for /l %%a in (1,1,%module_merge_file_num%) do (
		type "%~dp0TMP\MODULE_LOAD\B%%a.bat" >> "%~dp0TMP\.TEMP_MODULE_LOAD"
		type "%~dp0TMP\.TEMP_ENTER" >> "%~dp0TMP\.TEMP_MODULE_LOAD"
	)
	echo.exit /b 0 >> "%~dp0TMP\.TEMP_MODULE_LOAD"
	
	REM FUNCTION
	echo.  - FUNCTION
	echo.REM #  FUNCTION  ###############################################################################>> "%~dp0TMP\.TEMP_MODULE_LOAD"
	for /l %%a in (1,1,%module_merge_file_num%) do (
		type "%~dp0TMP\MODULE_LOAD\C%%a.bat" >> "%~dp0TMP\.TEMP_MODULE_LOAD"
		type "%~dp0TMP\.TEMP_ENTER" >> "%~dp0TMP\.TEMP_MODULE_LOAD"
	)
	
	echo.REM #  END  ###############################################################################>> "%~dp0TMP\.TEMP_MODULE_LOAD"
	echo.REM #  TO:%DATE% %TIME%>> "%~dp0TMP\.TEMP_MODULE_LOAD"

	echo -- Move
	::copy "%~dp0TMP\.TEMP_MODULE_LOAD" "%~dp0%module_merge_main%" >nul
	move "%~dp0TMP\.TEMP_MODULE_LOAD" "%~dp0%module_merge_main%" >nul
	
exit /b 0

:module_merge_copy
	SET /a module_merge_file_num+=1
	copy ".\%1\head.bat" "%~dp0TMP\MODULE_LOAD\A%module_merge_file_num%.bat" >nul
	copy ".\%1\function.bat" "%~dp0TMP\MODULE_LOAD\C%module_merge_file_num%.bat" >nul
	call loadcfg "%1\data.ini"
	echo.  - %module_name%: %module_trigger%
	
	IF exist "%~dp0TMP\MODULE_LOAD\B%module_merge_file_num%.bat" del "%~dp0TMP\MODULE_LOAD\B%module_merge_file_num%.bat" >nul
	for %%t in (%module_trigger%) do (
		for /F "tokens=1,2 delims=:" %%1 in ("%%t") do call :module_merge_set_trigger %%1 %%2
	)
exit /b 0

:module_merge_set_trigger
	set module_merge_set_trigger_1=%1
	set module_merge_set_trigger_2=%2
	set t=%%%
	echo IF /I "%t%1"=="/%module_merge_set_trigger_1%" goto :%module_merge_set_trigger_2% >> "%~dp0TMP\MODULE_LOAD\B%module_merge_file_num%.bat"
exit /b 0
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
:list
	set _cd=%cd%
	cd /d "%PIDMD_ROOT%"
	for /r %%f in (SYS/PID/*) do echo %%~nxf
	cd /d "%cd%"
exit /b 0
:run
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
:version
	echo.%PM_VER%
exit /b 0
REM #  END  ###############################################################################
REM #  TO:2025/03/27 周四  7:23:15.10
