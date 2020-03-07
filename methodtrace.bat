@echo off
cls
mode con cols=100 lines=80
title 记录手机操作调用的函数
set THIS_DIR=%~dp0
setlocal enabledelayedexpansion
IF exist v.txt (
for /f "tokens=1,2*" %%i in (v.txt) do (
	set localv=%%i %%j
)
) ELSE (set localv=0)

Echo open 10.92.16.29 31>ftp.updata
Echo 155627>>ftp.updata
Echo 155627>>ftp.updata
Echo binary>>ftp.updata
Echo prompt >>ftp.updata
Echo dir updata\methodtrace.bat>>ftp.updata
Echo bye>>ftp.updata
for /f "tokens=7,8" %%i in ('FTP -s:ftp.updata') do (
  set remotev=%%i %%j
)
del ftp.updata /q
)
echo %remotev% >v.txt

if not "%remotev%" == "%localv%" (
Echo open 10.92.16.29 31>ftp.get
Echo 155627>>ftp.get
Echo 155627>>ftp.get
Echo binary>>ftp.get
Echo prompt >>ftp.get
Echo get updata/methodtrace.bat>>ftp.get
Echo bye>>ftp.get
FTP -s:ftp.get 1>nul
del ftp.get /q
Echo 更新了bat文件
)


Echo 脚本功能:1.记录用例的函数调用 2.记录文件存在当前目录 3.上传记录文件
Echo 准备工作:1.请电脑连接手机 2.打开usb调试 3.打开待记录应用(debug版本)

adb shell setprop debug.traceview-buffer-size-mb 500
set /p package=请输入包名并按回车:
adb shell rm -r /data/local/tmp/%package% 1>nul 2>nul
adb shell mkdir /data/local/tmp/%package% 1>nul 2>nul

set Pan=%package%
if not exist %Pan% (
mkdir %Pan%
)



:start
set /p caseid=请输入用例编号或者q并按回车:
if "%caseid%" == "q" (
echo 用例执行完毕
) ELSE (
if "%caseid%" == "Q" (
echo 用例执行完毕
) ELSE (
For /F %%i in ('adb shell "ps -ef | grep %package%$ | grep -v grep | awk '{print $2}'"') do set pid= %%i
if "!pid!" == "" (
echo 请打开应用重新开始记录
GOTO start
)

adb shell "am profile start !pid! '/data/local/tmp/%package%/%caseid%.trace'"
echo 手机上操作完成后请按回车& PAUSE > nul

adb shell "am profile stop !pid!"

for /l %%i in (1,1,20) do (
    For /F %%i in ('adb shell "du -h '/data/local/tmp/%package%/%caseid%.trace' | awk '{print $1}'"') do set tracesize= %%i
    IF NOT "!tracesize!" == " 0" ( 
    GOTO profilestop
    )
    choice /t 1 /d y /n >nul
)
:profilestop
::adb shell "sed -i '/^*end/,$d' /data/local/tmp/%package%/%caseid%.trace

adb pull "/data/local/tmp/%package%/%caseid%.trace" %cd%\%package%"
echo 导出 %caseid%.trace 到电脑%cd%\%package%\%caseid%.trace

For /F "tokens=3" %%i in ('dir /a-d "%package%\%caseid%.trace" ^| findstr 文件') do set size= %%i
if "!size!" == " 0" echo 文件大小为0需要重新录制

echo ======================================================================
GOTO start
)
)

set /p upftp=请确认是否上传包名目录下的所有文件到服务器 y or n:
if "%upftp%" == "y" (
CALL :upftp
goto :eof
) ELSE (
if "%upftp%" == "Y" (
CALL :upftp
goto :eof
) ELSE (
echo 取消上传包名目录下的所有trace文件
Echo 按任意键退出 & pause > nul
goto :eof
)
)

:upftp
echo 开始上传...
echo  >%package%\%username%.username
For /F "delims=: tokens=2" %%i in ('adb shell "pm path %package%"') do (
	set apkpath=%%i
)
adb pull !apkpath! %package%\base.apk 1>nul
Echo open 10.92.16.29 31>ftp.up
Echo 155627>>ftp.up
Echo 155627>>ftp.up
Echo mkdir /%package%>>ftp.up
Echo Cd .\%package% >>ftp.up
Echo binary>>ftp.up
Echo prompt >>ftp.up
Echo lcd .\%package%>>ftp.up
Echo mput "*.*">>ftp.up
Echo bye>>ftp.up
FTP -s:ftp.up |findstr "Successfully transferred"
del ftp.up /q
echo 包名目录下的所有trace文件上传完毕
Echo 按任意键退出 & pause > nul
goto :eof
