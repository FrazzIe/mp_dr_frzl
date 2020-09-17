@echo off

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set create_dir=%~dp0
set zone_src=%~dp0zone_source\english\assetinfo
set image_dir=%game_dir%\raw\images

IF EXIST "%create_dir%%map_name%" rmdir /S /Q "%create_dir%%map_name%"

mkdir "%create_dir%%map_name%"
cd "%create_dir%%map_name%"

FOR /F "tokens=1-2* delims=," %%A IN (%zone_src%\%map_name%.csv) DO (
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

pause