@echo off
if not exist "%1" echo %1 not exist! & exit /b

set CFGINI_DIR=%~dp1
set CFGINI_FILE=%~nx1

pushd "%cd%"
cd /d "%CFGINI_DIR%"

FOR /F "delims=* eol=#" %%f in (%CFGINI_FILE%) do (
	call :setload %%f
)

set config_parent_tag=
popd
exit /b

:setload
	set obj=%*
	if "%obj:~0,1%"=="[" set config_parent_tag=%obj:~1,-1%_
	if not "%obj:~0,1%"=="[" set %config_parent_tag%%obj%
goto :eof