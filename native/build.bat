@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0make_icon.ps1"
if errorlevel 1 exit /b 1
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
  echo Visual Studio Build Tools not found. Install the C++ build tools and Windows SDK.
  exit /b 2
)
for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -products * -property installationPath`) do set "VSROOT=%%I"
if not defined VSROOT exit /b 2
call "%VSROOT%\VC\Auxiliary\Build\vcvarsall.bat" x64
if errorlevel 1 exit /b 3
if not exist build mkdir build
rc /nologo /fo build\PortableAppsStart.res PortableAppsStart.rc
if errorlevel 1 exit /b 4
cl /nologo /std:c++17 /utf-8 /EHsc /O1 /GL /MT /W3 PortableAppsStart.cpp build\PortableAppsStart.res /link /LTCG /OPT:REF /OPT:ICF /SUBSYSTEM:WINDOWS /DYNAMICBASE /NXCOMPAT /OUT:build\PortableAppsStart.exe
exit /b %errorlevel%
