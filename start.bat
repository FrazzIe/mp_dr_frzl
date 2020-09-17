@echo off
set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set tools_dir=%game_dir%\bin\CoD4CompileTools
set map_dir=%game_dir%\map_source\
set bsp_dir=%game_dir%\raw\maps\mp\
set git_map_dir=%~dp0map_source\
set git_bsp_dir=%~dp0raw\maps\mp\
set zone_src_dir=%game_dir%\zone_source
set zone_dir=%game_dir%\zone\english
set git_zone_src_dir=%~dp0zone_source\english\assetinfo
set git_zone_dir=%~dp0zone\english
set options="+set developer 1 +set developer_script 1 +set fs_game "mods/deathrun_dev" +set g_gametype deathrun +set gametype deathrun +set dr_freerun_time 9999"

IF EXIST "%map_dir%%map_name%.map" del "%map_dir%%map_name%.map"
IF EXIST "%map_dir%%map_name%.grid" del "%map_dir%%map_name%.grid"
IF EXIST "%map_dir%%map_name%.lin" del "%map_dir%%map_name%.lin"

IF EXIST "%bsp_dir%%map_name%.d3dbsp" del "%bsp_dir%%map_name%.d3dbsp"
IF EXIST "%bsp_dir%%map_name%.gsc" del "%bsp_dir%%map_name%.gsc"

IF EXIST "%zone_src_dir%\%map_name%.csv" del "%zone_src_dir%\%map_name%.csv"
IF EXIST "%zone_src_dir%\%map_name%_load.csv" del "%zone_src_dir%\%map_name%_load.csv"
IF EXIST "%zone_dir%\%map_name%.ff" del "%zone_dir%\%map_name%.ff"
IF EXIST "%zone_dir%\%map_name%_load.ff" del "%zone_dir%\%map_name%_load.ff"

copy "%git_map_dir%%map_name%.map" "%map_dir%%map_name%.map"
copy "%git_map_dir%%map_name%.grid" "%map_dir%%map_name%.grid"
copy "%git_map_dir%%map_name%.lin" "%map_dir%%map_name%.lin"

copy "%git_bsp_dir%%map_name%.d3dbsp" "%bsp_dir%%map_name%.d3dbsp"
copy "%git_bsp_dir%%map_name%.gsc" "%bsp_dir%%map_name%.gsc"

robocopy "%git_zone_src_dir%" "%zone_src_dir%" %map_name%.csv %map_name%_load.csv
robocopy "%git_zone_dir%" "%zone_dir%" %map_name%.ff %map_name%_load.ff

CALL "%tools_dir%\cod4compiletools_runmap.bat" "%game_dir%\" %map_name% 1 %options%