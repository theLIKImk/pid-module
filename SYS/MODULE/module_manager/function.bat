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