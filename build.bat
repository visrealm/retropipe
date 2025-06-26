setlocal
@echo off

echo ---------------------------
echo RetroPIPE build
echo ---------------------------
echo.

echo Setting up build directories
echo.
echo Intermediates: build\tmp\asm
echo Binaries:      build
echo.

mkdir build 2> NUL
mkdir build\tmp 2> NUL
mkdir build\tmp\asm 2> NUL

del /Q /S build\*

set VERSION=v1-0-2
set FRIENDLYVER=%VERSION:-=.%

pushd build\tmp

echo.
echo ---------------------------------------------------------------------
echo Finding CVBasic compiler...


set PATH=..\..\tools\cvbasic;%PATH%

:: This is where I have my CVBasic fork, so grab it from here if available
set PATH=..\..\..\CVBasic\build\Release;%PATH%  
set PATH=..\..\..\gasm80\build\Release;%PATH%  
set LIBPATH=..\..\src\lib
for %%D in ("%LIBPATH%") do set LIBPATH=%%~fD

where cvbasic.exe
if %errorlevel% neq 0 (
    echo.
    echo cvbasic.exe not in %%PATH%%
    echo.
    echo %%PATH%%="%PATH%"
    exit /b %errorlevel%
)
for /f "tokens=1 delims=" %%A in ('where cvbasic.exe') do (
    echo.
    echo Using : %%A
    goto :end
)
:end
echo ---------------------------------------------------------------------


echo.
echo ---------------------------------------------------------------------
echo   Copying source files to %CD%
echo ---------------------------------------------------------------------


del *.bas
copy /Y ..\..\src\*.bas .
copy /Y ..\..\src\lib lib

:: TI-99

echo.
echo ---------------------------------------------------------------------
echo   Compiling for TI-99/4A
echo ---------------------------------------------------------------------

set BASENAME=retropipe_%VERSION%_ti99
cvbasic --ti994a retropipe.bas asm\%BASENAME%.a99 %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
python3.13 c:\tools\xdt99\xas99.py -b -R asm/%BASENAME%.a99
if %errorlevel% neq 0 exit /b %errorlevel%
REM linkticart.py %BASENAME%_b00.bin ..\%BASENAME%_8.bin "RETROPIPE"    :: banking
linkticart.py %BASENAME%.bin ..\%BASENAME%_8.bin "RETROPIPE"
echo Output: build\%BASENAME%_8.bin

:: ColecoVision

echo.
echo ---------------------------------------------------------------------
echo   Compiling for Colecovision
echo ---------------------------------------------------------------------

set BASENAME=retropipe_%VERSION%_cv
cvbasic retropipe.bas asm/%BASENAME%.asm %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
gasm80 asm\%BASENAME%.asm -o ..\%BASENAME%.rom
copy /Y ..\%BASENAME%.rom c:\tools\Classic99Phoenix
echo.
echo Output: build\%BASENAME%.rom


:: MSX

echo.
echo ---------------------------------------------------------------------
echo   Compiling for MSX
echo ---------------------------------------------------------------------

set BASENAME=retropipe_%VERSION%_msx_asc16
cvbasic --msx retropipe.bas asm/%BASENAME%.asm %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
gasm80 asm\%BASENAME%.asm -o ..\%BASENAME%.rom
echo Output: build\%BASENAME%.rom

set BASENAME=retropipe_%VERSION%_msx_konami
cvbasic --msx -konami retropipe.bas asm/%BASENAME%.asm %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
gasm80 asm\%BASENAME%.asm -o ..\%BASENAME%.rom
echo Output: build\%BASENAME%.rom


:: NABU

echo.
echo ---------------------------------------------------------------------
echo   Compiling for NABU
echo ---------------------------------------------------------------------

set BASENAME=retropipe_%VERSION%
cvbasic --nabu retropipe.bas asm/%BASENAME%_nabu.asm %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
gasm80 asm\%BASENAME%_nabu.asm -o ..\%BASENAME%.nabu
echo Output: build\%BASENAME%.nabu

echo.
echo   Compiling for NABU (MAME)

:: this is a different version as it is designed to allow running on a TMS99xxA
:: so don't be tempted to copy the .nabu file from above
set BASENAME=retropipe_%VERSION%_nabu_mame
cvbasic --nabu -DTMS9918_TESTING=1 retropipe.bas asm/%BASENAME%.asm %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
gasm80 asm\%BASENAME%.asm -o ..\000001.nabu
pushd ..
tar.exe -a -c -f %BASENAME%.zip 000001.nabu
copy /Y %BASENAME%.zip %BASENAME%.npz
del %BASENAME%.zip
del 000001.nabu
popd
echo Output: build\%BASENAME%.npz


:: SG-1000

echo.
echo ---------------------------------------------------------------------
echo   Compiling for SG-1000/SC-3000
echo ---------------------------------------------------------------------

set BASENAME=retropipe_%VERSION%_sc3000
cvbasic --sg1000 retropipe.bas asm/%BASENAME%.asm %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
gasm80 asm\%BASENAME%.asm -o ..\%BASENAME%.rom
echo Output: build\%BASENAME%.rom


:: CreatiVision

echo.
echo ---------------------------------------------------------------------
echo   Compiling for CreatiVision
echo ---------------------------------------------------------------------

set BASENAME=retropipe_%VERSION%_crv
cvbasic --creativision retropipe.bas asm\%BASENAME%.asm %LIBPATH%
if %errorlevel% neq 0 exit /b %errorlevel%
gasm80 asm\%BASENAME%.asm -o ..\%BASENAME%.bin
echo Output: build\%BASENAME%.bin
    

:: HBC56
::cvbasic --hbc56 retropipe-nobank.bas asm\retropipetool_hbc56.asm %LIBPATH%
::gasm80 asm\retropipetool_hbc56.asm -o bin\retropipetool_hbc56.rom

for %%A in (..\*.*) do @echo %%~nxA        %%~zA bytes

popd
echo.