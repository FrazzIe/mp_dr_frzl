@echo off
@setlocal enableextensions enabledelayedexpansion

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set create_dir=%~dp0
set bin_dir=%game_dir%\bin
set image_dir=%game_dir%\raw\images
set source_data=%game_dir%\source_data
set texture_src=%game_dir%\texture_src
set git_zone_src=%~dp0zone_source\english\assetinfo
set git_source_data=%~dp0source_data
set git_texture_src=%~dp0texture_src

IF EXIST "%create_dir%%map_name%" rmdir /S /Q "%create_dir%%map_name%"

mkdir "%create_dir%%map_name%"
cd "%create_dir%%map_name%"

FOR /F "tokens=1-2* delims=," %%A IN (%git_zone_src%\%map_name%.csv) DO (
 IF "%%~A" == "image" (
  SET assetType=0
  SET colorMap=0

  FOR /F tokens^=2-4delims^=^<^"^= %%A IN (%git_source_data%\%%~B.gdt) DO (
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

  CALL :compileTexture %%~B !assetType! !colorMap! < nul
 )
)

FOR /F "tokens=1-2* delims=," %%A IN (%git_zone_src%\%map_name%.csv) DO (
 IF "%%~A" == "image" (
  IF EXIST "%image_dir%\%%~B.iwi" (
   IF NOT EXIST "%create_dir%%map_name%\images" (
	   mkdir "%create_dir%%map_name%\images"
	   cd "%create_dir%%map_name%\images"
   )

   robocopy "%image_dir%" "%create_dir%%map_name%\images" %%~B.iwi
  )  
 )
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
    IF EXIST "%source_data%\%assetName%.gdt" del "%source_data%\%assetName%.gdt"
    IF EXIST "%game_dir%\%colorMap%" del "%game_dir%\%colorMap%"

    robocopy "%git_source_data%" "%source_data%" %assetName%.gdt
    copy "%~dp0%colorMap%" "%game_dir%\%colorMap%"

    CALL "%bin_dir%\converter" -nocachedownload -single %assetType% "%assetName%"
  )
 )
)

:end
pause
