@echo off
@setlocal enableextensions enabledelayedexpansion

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set /p zip_dir=<7z_directory.txt
set create_dir=%~dp0..\
set output_dir=%~dp0..\output
set bin_dir=%game_dir%\bin
set image_dir=%game_dir%\raw\images
set material_dir=%game_dir%\raw\materials
set source_data=%game_dir%\source_data
set texture_src=%game_dir%\texture_src
set git_zone_src=%~dp0..\zone_source\english\assetinfo
set git_source_data=%~dp0..\source_data
set git_texture_src=%~dp0..\texture_src
set git_raw_dir=%~dp0..\raw

IF EXIST "%create_dir%%map_name%" rmdir /S /Q "%create_dir%%map_name%"
IF EXIST "%output_dir%\%map_name%.iwd" del "%output_dir%\%map_name%.iwd"

mkdir "%create_dir%%map_name%"
cd "%create_dir%%map_name%"

FOR /F "tokens=1-2* delims=," %%A IN (%git_zone_src%\%map_name%.csv) DO (
 IF "%%~A" == "image" (
  CALL :findTexture %%~B < nul
 )
 IF "%%~A" == "material" (
  CALL :findTexture %%~B < nul
 )
)

robocopy "%git_raw_dir%\images" "%create_dir%%map_name%\images" /E
robocopy "%git_raw_dir%\sound" "%create_dir%%map_name%\sound" /E
robocopy "%git_raw_dir%\weapons" "%create_dir%%map_name%\weapons" /E

cd "%output_dir%"
CALL "%zip_dir%\7z" -tzip a %map_name%.iwd "%create_dir%%map_name%\*"
rmdir /S /Q "%create_dir%%map_name%"

GOTO :end 
:findTexture
SET assetName=%~1
SET assetType=0
SET colorMap=0

IF EXIST "%git_source_data%\%assetName%.gdt" (
    FOR /F tokens^=2-4delims^=^<^"^= %%A IN (%git_source_data%\%assetName%.gdt) DO (
     IF NOT "%%~A" == "" (
    	   IF NOT "%%~C" == "" (
          SET value=%%~C
    	    SET extension="!value:.gdf=!"
    
    	    IF NOT "%%~C" == !extension! (
           SET assetType=!extension!
    	    )
    
    	    IF "%%~A" == "colorMap" (
           SET colorMap="%%~C"
    	    )
    	   )
     )
    )
    
    CALL :compileTexture !assetName! !assetType! !colorMap! < nul
)
GOTO :end

:compileTexture
SET assetName=%~1
SET assetType=%~2
SET colorMap=%~3

cd "%bin_dir%"

IF NOT assetName == 0 (
 IF NOT assetType == 0 (
  IF NOT colorMap == 0 (
    IF NOT EXIST "%git_raw_dir%\images\%assetName%.iwi" (
     IF EXIST "%source_data%\%assetName%.gdt" del "%source_data%\%assetName%.gdt"
     IF EXIST "%game_dir%\%colorMap%" del "%game_dir%\%colorMap%"

     robocopy "%git_source_data%" "%source_data%" %assetName%.gdt
     copy "%~dp0..\%colorMap%" "%game_dir%\%colorMap%"

     CALL "%bin_dir%\converter" -nocachedownload -single %assetType% "%assetName%"

     IF EXIST "%image_dir%\%assetName%.iwi" (
      robocopy "%image_dir%" "%git_raw_dir%\images" %assetName%.iwi
     )
     IF EXIST "%material_dir%\%assetName%" (
      robocopy "%material_dir%" "%git_raw_dir%\materials" %assetName%
     )
    )
  )
 )
)

:end
pause
