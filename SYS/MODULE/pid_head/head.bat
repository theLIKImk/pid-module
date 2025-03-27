set PIDMD_ROOT=%~dp0
set PATH=%PATH%;%PIDMD_ROOT%
set PM_VER=1.1.1-lite
set PIDMD_DISABLE_RUN=true

set LANG=zh
:: DO NOT CHANG LANG STR
set en_check_pid_info=INFO:
set zh_check_pid_info=пео╒:

if not exist "%PIDMD_ROOT%SYS\PID\" mkdir "SYS\PID"
if not exist "%PIDMD_ROOT%TMP\" mkdir "TMP\"