:help
	call loadcfg.cmd "%~dp0SYS\MODULE\module_manager\data.ini"
	if not exist "%PIDMD_ROOT%help.txt" echo -ERR- help doc lost & exit /b
	type "%PIDMD_ROOT%help.txt"
	echo.
	echo call %module_main_name% /module
	echo call %module_main_name% /module-list
	echo call %module_main_name% /module-merge
exit /b 0