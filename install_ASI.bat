@ECHO OFF

SETLOCAL EnableExtensions
SET MY_NAME=install_ASI.bat


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::  This seeks to only install the ASI rather than full Lua build.
::
::  It does this safely, checking if GTA is running and asking user if they would like to kill.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: When setting MANUAL_PATH_TO_GTA5 , use quotes around the path.
::
::   Example: Set it to a local directory.
::
::   SET  MANUAL_PATH_TO_GTA5="C:\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\"
::
::   Example: Set it to a remote directory.
::
::   SET MANUAL_PATH_TO_GTA5="\\FAMILYLAPTOP\C\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\"
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET  MANUAL_PATH_TO_GTA5="\\FAMILYLAPTOP\C\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\"


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: When setting MANUAL_PATH_TO_PROJECT , use quotes around the path.
::
::   Example:
::
::   SET  MANUAL_PATH_TO_PROJECT="\\JAKE\SDRIVE\Downloads\Games\GTA5\GTALua-master"
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET  MANUAL_PATH_TO_PROJECT="\\JAKE\SDRIVE\Downloads\Games\GTA5\GTALua-master"




::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Do not modify past here
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET UPDATE_HOST=%COMPUTERNAME%

IF "%MANUAL_PATH_TO_GTA5:~1,2%" == "\\" FOR /F "tokens=2 delims=\" %%i in ('echo ^%MANUAL_PATH_TO_GTA5^%') do SET UPDATE_HOST=%%i

SET PATH_TO_PROJECT=%~0

FOR %%i IN ("%~0") DO SET PATH_TO_PROJECT=%%~di%%~pi

IF  DEFINED  MANUAL_PATH_TO_PROJECT  IF EXIST %MANUAL_PATH_TO_PROJECT%  SET PATH_TO_PROJECT=%MANUAL_PATH_TO_PROJECT%

ECHO PATH_TO_PROJECT=%PATH_TO_PROJECT%

SET  USERINPUT=

ECHO Would you like to update your GTA5 installation with this build?

ECHO [y,N]

SET  /P USERINPUT=

IF    NOT DEFINED USERINPUT     ECHO User chose to quit without update.&& GOTO :END

IF /I NOT "%USERINPUT%" == "y"  ECHO User chose to quit without update.&& GOTO :END

ECHO Checking if GTA5.exe is running on %UPDATE_HOST%...

SET GTA_RUNNING=

( TASKLIST  /S %UPDATE_HOST%  /FI "IMAGENAME EQ GTA5.EXE" | FIND /I "GTA5.EXE" >NUL ) && TASKLIST  /S %UPDATE_HOST%  /FI "IMAGENAME EQ GTA5.EXE" | FIND /I "GTA5.EXE" && ECHO GTA5.EXE appears to be running. && SET GTA_RUNNING=true

SET USERINPUT=

IF DEFINED  GTA_RUNNING  ECHO Would you like to kill gta5.exe so update can take place?

IF DEFINED  GTA_RUNNING  SET /P USERINPUT=

IF DEFINED  GTA_RUNNING  IF NOT DEFINED USERINPUT  ECHO User chose to quit without update. && GOTO :END

IF DEFINED  GTA_RUNNING  IF /I  NOT  "%USERINPUT%" == "y"  ECHO User chose to quit without update. && GOTO :END

:::::::::::::::::::::::::
:KILL_AND_CHECK_RUNNING
:::::::::::::::::::::::::
IF  DEFINED GTA_RUNNING  TASKKILL  /S %UPDATE_HOST%  /F /FI "IMAGENAME EQ GTA5.EXE"

IF  DEFINED GTA_RUNNING  TASKKILL  /S %UPDATE_HOST%  /F /FI "IMAGENAME EQ GTA5.EXE" >NUL

TASKLIST  /S %UPDATE_HOST%  /FI "IMAGENAME EQ GTA5.EXE" | FIND /I "GTA5.EXE" && GOTO :KILL_AND_CHECK_RUNNING

:::::::::::::::::::::::::
:GET_GTA_DIR
:::::::::::::::::::::::::
SET FOLDER_TYPE=

SET GTA5_PATH=

IF  DEFINED MANUAL_PATH_TO_GTA5 SET FOLDER_TYPE=MANUAL

IF  DEFINED MANUAL_PATH_TO_GTA5 SET GTA5_PATH=%MANUAL_PATH_TO_GTA5%

FOR /F "tokens=1,2,* delims= " %%i in ('REG QUERY ^"\\%UPDATE_HOST%\hklm\software\wow6432node\Rockstar Games\GTAV^" ^| FIND /I ^"InstallFolder^"') DO SET GTA5_PATH=%%k

IF  NOT DEFINED GTA5_PATH  ECHO Unable to locate your GTA installation.  Edit %MY_NAME%, to manually set this path.  In fact, I'll open it in notepad for you now...

IF  NOT DEFINED GTA5_PATH  @ECHO ON

IF  NOT DEFINED GTA5_PATH  START  "" NOTEPAD.EXE "%PATH_TO_PROJECT:~1,-1%\%MY_NAME%"

IF  NOT DEFINED GTA5_PATH  @ECHO OFF

IF  NOT DEFINED GTA5_PATH  PAUSE&& GOTO :END

IF "%GTA5_PATH:~-5,5%" == "\GTAV"  IF EXIST "%GTA5_PATH%\..\GTA5.exe"  SET GTA5_PATH=%GTA5_PATH:~0,-5%

IF NOT EXIST "%GTA5_PATH%"           ECHO %GTA5_PATH% does not exist.  Make sure GTA5 is installed and all that jazz...&& PAUSE&& GOTO :END

IF NOT EXIST "%GTA5_PATH%\GTA5.exe"  ECHO %GTA5_PATH% does not contain GTA5.exe  WTF???&& PAUSE&& GOTO :END

 ECHO  Installing build...
@ECHO ON
   IF  NOT  EXIST  "%GTA5_PATH%\ASI"        MKDIR  "%GTA5_PATH%\ASI"
   IF  NOT  EXIST  "%GTA5_PATH%\scripts"    MKDIR  "%GTA5_PATH%\scripts"
   IF       EXIST  "%GTA5_PATH%\GTALua.asi" MOVE   /Y "%GTA5_PATH%\GTALua.asi"  "%GTA5_PATH%\GTALua.4si"
  FOR  %%a in ("%PATH_TO_PROJECT:~1,-1%\build\GTALua.asi") do (xcopy /s /y "%%~a" "%GTA5_PATH%\ASI\")
::FOR  %%a in ("%PATH_TO_PROJECT:~1,-1%\build\*.dll")      do (xcopy /s /y "%%~a" "%GTA5_PATH%")
::FOR  %%a in ("%PATH_TO_PROJECT:~1,-1%\build\GTALua")     do (xcopy /s /y "%%~a" "%GTA5_PATH%\GTALua\")
@ECHO OFF
 GOTO  :END

:::::::::::::::::::::::::
:END
:::::::::::::::::::::::::
PING -n 9 %COMPUTERNAME% >NUL 2>NUL

GOTO :EOF
