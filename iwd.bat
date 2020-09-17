@echo off

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set create_dir=%~dp0
set zone_src=%~dp0zone_source\english\assetinfo
set image_dir=%game_dir%\raw\images

IF EXIST "%create_dir%%map_name%" rmdir /S /Q "%create_dir%%map_name%"

mkdir "%create_dir%%map_name%"
cd "%create_dir%%map_name%"

pause