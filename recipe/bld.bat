@echo on

:: remove m2-pkg-config's pkg-config in favor of native
if exist %BUILD_PREFIX%\Library\usr\bin\pkg-config.exe del /f %BUILD_PREFIX%\Library\usr\bin\pkg-config.exe

echo source %SYS_PREFIX:\=/%/etc/profile.d/conda.sh    > conda_build.sh
echo conda activate "${PREFIX}"                       >> conda_build.sh
echo conda activate --stack "${BUILD_PREFIX}"         >> conda_build.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_build.sh
type "%RECIPE_DIR%\build.sh"                          >> conda_build.sh

FOR /F "delims=" %%i in ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%BUILD_PREFIX%"') DO set "BUILD_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%CONDA_PREFIX%"') DO set "CONDA_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
set MSYSTEM=UCRT64
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
bash -lc "./conda_build.sh"
if errorlevel 1 exit 1

:: Generate MSVC-compatible import library
FOR /F %%i in ("%LIBRARY_BIN%\libosmodsp*.dll") DO (
  dumpbin /exports "%%i" > exports.txt
  echo LIBRARY %%~nxi > osmodsp.def
  echo EXPORTS >> osmodsp.def
  FOR /F "usebackq tokens=4" %%A in (`findstr /R /C:" cfile.*" /C:" osmo.*" exports.txt`) DO echo %%A >> osmodsp.def
  lib /def:osmodsp.def /out:osmodsp.lib /machine:x64
  copy osmodsp.lib "%LIBRARY_LIB%\osmodsp.lib"
)
if errorlevel 1 exit 1
