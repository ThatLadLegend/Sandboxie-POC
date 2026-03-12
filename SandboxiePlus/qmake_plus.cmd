call "%~dp0..\Installer\buildVariables.cmd" %*

IF "%1"=="Win32" (
  set "qt_path=%~dp0..\..\Qt\%qt_version%\msvc2022"

  Xcopy /E /I /Y /Q "%~dp0..\..\Qt\%qt_version%\msvc2022\include\QtCore\%qt_version%\QtCore" "%~dp0..\..\Qt\%qt_version%\msvc2022\include\QtCore"
  
  set build_arch=Win32
  set qt_params=
  call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars32.bat"
)

IF "%1"=="x64" (
  set "qt_path=%~dp0..\..\Qt\%qt_version%\msvc2022_64"
  
  Xcopy /E /I /Y /Q "%~dp0..\..\Qt\%qt_version%\msvc2022_64\include\QtCore\%qt_version%\QtCore" "%~dp0..\..\Qt\%qt_version%\msvc2022_64\include\QtCore"
  
  set build_arch=x64
  set qt_params=
  call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
)

IF "%1"=="ARM64" (
  set "qt_path=%~dp0..\..\Qt\%qt6_version%\msvc2022_64"
  
  Xcopy /E /I /Y /Q "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\include\QtCore\%qt6_version%\QtCore" "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\include\QtCore"
  
  set build_arch=ARM64

  echo [DevicePaths] > "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo Prefix=C:/Qt/Qt-%qt6_version% >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo [Paths] >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo Prefix=../ >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo HostPrefix=../../msvc2022_64 >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo HostData=../msvc2022_arm64 >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo Sysroot= >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo SysrootifyPrefix=false >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo TargetSpec=win32-arm64-msvc >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"
  echo HostSpec=win32-msvc >> "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf"

  set "qt_params=-qtconf "%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64\bin\my_target_qt.conf""

  call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsamd64_arm64.bat"
)

@echo on

mkdir "%~dp0Build_UGlobalHotkey_%build_arch%"
cd /d "%~dp0Build_UGlobalHotkey_%build_arch%"

"%qt_path%\bin\qmake.exe" "%~dp0UGlobalHotkey\uglobalhotkey.qc.pro" %qt_params%
"%~dp0..\..\Qt\Tools\QtCreator\bin\jom.exe" -f Makefile.Release -j 8
IF %ERRORLEVEL% NEQ 0 goto :error

mkdir "%~dp0Build_qtsingleapp_%build_arch%"
cd /d "%~dp0Build_qtsingleapp_%build_arch%"

"%qt_path%\bin\qmake.exe" "%~dp0QtSingleApp\qtsingleapp\qtsingleapp\qtsingleapp.qc.pro" %qt_params%
"%~dp0..\..\Qt\Tools\QtCreator\bin\jom.exe" -f Makefile.Release -j 8
IF %ERRORLEVEL% NEQ 0 goto :error

mkdir "%~dp0Build_MiscHelpers_%build_arch%"
cd /d "%~dp0Build_MiscHelpers_%build_arch%"

"%qt_path%\bin\qmake.exe" "%~dp0MiscHelpers\MiscHelpers.qc.pro" %qt_params%
"%~dp0..\..\Qt\Tools\QtCreator\bin\jom.exe" -f Makefile.Release -j 8
IF %ERRORLEVEL% NEQ 0 goto :error

mkdir "%~dp0Build_QSbieAPI_%build_arch%"
cd /d "%~dp0Build_QSbieAPI_%build_arch%"

"%qt_path%\bin\qmake.exe" "%~dp0QSbieAPI\QSbieAPI.qc.pro" %qt_params%
"%~dp0..\..\Qt\Tools\QtCreator\bin\jom.exe" -f Makefile.Release -j 8
IF %ERRORLEVEL% NEQ 0 goto :error

mkdir "%~dp0Build_SandMan_%build_arch%"
cd /d "%~dp0Build_SandMan_%build_arch%"

if "%qt_version:~0,1%"=="5" (
    "%qt_path%\bin\qmake.exe" "%~dp0SandMan\SandMan.qc.pro" %qt_params%
)

if "%qt_version:~0,1%"=="6" (
    "%qt_path%\bin\qmake.exe" "%~dp0SandMan\SandMan-Qt6.qc.pro" %qt_params%
)

"%~dp0..\..\Qt\Tools\QtCreator\bin\jom.exe" -f Makefile.Release -j 8
IF %ERRORLEVEL% NEQ 0 goto :error

cd /d "%~dp0"
goto :eof

:error
echo Build failed
exit /b 1
