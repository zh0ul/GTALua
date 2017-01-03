@ECHO OFF


SETLOCAL EnableExtensions


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: This script can auto detect both the project directory (duh!) and the GTA5 install directory
::
:: regardless if steam or not.  That it is named 'install_steam.bat'
::
:: is only an artifact of its creation.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: When setting MANUAL_PATH_TO_GTA5 , use quotes around the path.
::
::   Example:
::
::   SET  MANUAL_PATH_TO_GTA5="C:\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto V\"
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


SET  MANUAL_PATH_TO_GTA5=


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: When setting MANUAL_PATH_TO_PROJECT , use quotes around the path.
::
::   Example:
::
::   SET  MANUAL_PATH_TO_PROJECT="\\JAKE\SDRIVE\Downloads\Games\GTA5\GTALua-master"
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


SET  MANUAL_PATH_TO_PROJECT=



SET PATH_TO_PROJECT=%~0
SET PATH_TO_PROJECT="%PATH_TO_PROJECT:install_steam.bat=%"

IF   DEFINED  MANUAL_PATH_TO_PROJECT  IF EXIST "%MANUAL_PATH_TO_PROJECT%"  SET PATH_TO_PROJECT=%MANUAL_PATH_TO_PROJECT%

ECHO PATH_TO_PROJECT=%PATH_TO_PROJECT%

SET  USERINPUT=
ECHO Would you like to update your GTA5 installation with this build?
ECHO [y,N]
SET  /P USERINPUT=

IF    NOT DEFINED USERINPUT     ECHO User chose to quit without update. && GOTO :END
IF /I NOT "%USERINPUT%" == "y"  ECHO User chose to quit without update. && GOTO :END

ECHO Checking if GTA5.exe is running...

SET GTA_RUNNING=
( TASKLIST /FI "IMAGENAME EQ GTA5.EXE" | FIND /I "GTA5.EXE" >NUL ) && TASKLIST /FI "IMAGENAME EQ GTA5.EXE" | FIND /I "GTA5.EXE" && ECHO GTA5.EXE appears to be running. && SET GTA_RUNNING=true

SET USERINPUT=
IF DEFINED GTA_RUNNING  ECHO Would you like to kill gta5.exe so update can take place?
IF DEFINED GTA_RUNNING  SET /P USERINPUT=

IF   DEFINED GTA_RUNNING  IF NOT DEFINED USERINPUT  ECHO User chose to quit without update. && GOTO :END
IF   DEFINED GTA_RUNNING  IF /I  NOT  "%USERINPUT%" == "y"  ECHO User chose to quit without update. && GOTO :END

:::::::::::::::::::::::::
:KILL_AND_CHECK_RUNNING
:::::::::::::::::::::::::
IF  DEFINED GTA_RUNNING  TASKKILL /F /FI "IMAGENAME EQ GTA5.EXE"
IF  DEFINED GTA_RUNNING  TASKKILL /F /FI "IMAGENAME EQ GTA5.EXE" >NUL
TASKLIST /FI "IMAGENAME EQ GTA5.EXE" | FIND /I "GTA5.EXE" && GOTO :KILL_AND_CHECK_RUNNING

:::::::::::::::::::::::::
:GET_GTA_DIR
:::::::::::::::::::::::::
SET FOLDER_TYPE=
SET FOLDER_PATH=
IF  DEFINED MANUAL_PATH_TO_GTA5 SET FOLDER_TYPE=MANUAL
IF  DEFINED MANUAL_PATH_TO_GTA5 SET FOLDER_PATH=%MANUAL_PATH_TO_GTA5%

FOR /F "tokens=1,2,* delims= " %%i in ('REG QUERY ^"hklm\software\wow6432node\Rockstar Games\GTAV^" ^| FIND /I ^"InstallFolder^"') DO SET FOLDER_PATH=%%k
IF  NOT DEFINED FOLDER_PATH  ECHO Unable to locate your GTA installation.  Edit install_steam.bat, to manually set this path.  In fact, I'll open it in notepad for you now...
IF  NOT DEFINED FOLDER_PATH  echo START "" NOTEPAD.EXE "%PATH_TO_PROJECT:~2,-1%\install_steam.bat"
IF  NOT DEFINED FOLDER_PATH  START "" NOTEPAD.EXE "%PATH_TO_PROJECT:~1,-1%\install_steam.bat"
IF  NOT DEFINED FOLDER_PATH  PAUSE&& GOTO :END

IF "%FOLDER_PATH:~-5,5%" == "\GTAV"  IF EXIST "%FOLDER_PATH%\..\GTA5.exe"  SET FOLDER_PATH=%FOLDER_PATH:~0,-5%

IF NOT EXIST "%FOLDER_PATH%"           ECHO %FOLDER_PATH% does not exist.  Make sure GTA5 is installed and all that jazz...&& PAUSE&& GOTO :END
IF NOT EXIST "%FOLDER_PATH%\GTA5.exe"  ECHO %FOLDER_PATH% does not contain GTA5.exe  WTF???&& PAUSE&& GOTO :END

 ECHO  Installing build...
   IF  NOT  EXIST  "%FOLDER_PATH%\GTALua"   MKDIR  "%FOLDER_PATH%\GTALua"
  FOR  %%a in ("%PATH_TO_PROJECT:~1,-1%\build\GTALua.asi") do (xcopy /s /y "%%~a" "%FOLDER_PATH%")
  FOR  %%a in ("%PATH_TO_PROJECT:~1,-1%\build\*.dll")      do (xcopy /s /y "%%~a" "%FOLDER_PATH%")
  FOR  %%a in ("%PATH_TO_PROJECT:~1,-1%\build\GTALua")     do (xcopy /s /y "%%~a" "%FOLDER_PATH%\GTALua\")
 GOTO  :END

:::::::::::::::::::::::::
:END
:::::::::::::::::::::::::
GOTO :EOF
