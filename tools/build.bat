@echo off

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set tools_dir=%game_dir%\bin\CoD4CompileTools
set map_dir=%game_dir%\map_source
set bsp_dir=%game_dir%\raw\maps\mp
set zone_src_dir=%game_dir%\zone_source
set git_map_dir=%~dp0..\map_source
set git_bsp_dir=%~dp0..\raw\maps\mp
set git_zone_src_dir=%~dp0..\zone_source\english\assetinfo
cd "%tools_dir%"

IF EXIST "%map_dir%\%map_name%.map" del "%map_dir%\%map_name%.map"

IF EXIST "%bsp_dir%\%map_name%.d3dbsp" del "%bsp_dir%\%map_name%.d3dbsp"
IF EXIST "%bsp_dir%\%map_name%.gsc" del "%bsp_dir%\%map_name%.gsc"

IF EXIST "%zone_src_dir%\%map_name%.csv" del "%zone_src_dir%\%map_name%.csv"
IF EXIST "%zone_src_dir%\%map_name%_load.csv" del "%zone_src_dir%\%map_name%_load.csv"

IF NOT EXIST %git_zone_src_dir%\%map_name%.csv (
 echo ignore,code_post_gfx_mp> %git_zone_src_dir%\%map_name%.csv
 echo ignore,common_mp>> %git_zone_src_dir%\%map_name%.csv
 echo ignore,localized_code_post_gfx_mp>> %git_zone_src_dir%\%map_name%.csv
 echo ignore,localized_common_mp>> %git_zone_src_dir%\%map_name%.csv
 echo col_map_mp,maps/mp/%map_name%.d3dbsp>> %git_zone_src_dir%\%map_name%.csv
 echo rawfile,maps/mp/%map_name%.gsc>> %git_zone_src_dir%\%map_name%.csv
 echo impactfx,%map_name%>> %git_zone_src_dir%\%map_name%.csv
 echo sound,common,%map_name%,!all_mp>> %git_zone_src_dir%\%map_name%.csv
 echo sound,generic,%map_name%,!all_mp>> %git_zone_src_dir%\%map_name%.csv
 echo sound,voiceovers,%map_name%,!all_mp">> %git_zone_src_dir%\%map_name%.csv
 echo sound,multiplayer,%map_name%,!all_mp>> %git_zone_src_dir%\%map_name%.csv

 echo ignore,code_post_gfx_mp> %git_zone_src_dir%\%map_name%_load.csv
 echo ignore,common_mp>> %git_zone_src_dir%\%map_name%_load.csv
 echo ignore,localized_code_post_gfx_mp>> %git_zone_src_dir%\%map_name%_load.csv
 echo ignore,localized_common_mp>> %git_zone_src_dir%\%map_name%_load.csv
 echo ui_map,maps/%map_name%>> %git_zone_src_dir%\%map_name%_load.csv
)

robocopy "%git_map_dir%" "%map_dir%" %map_name%.map
robocopy "%git_bsp_dir%" "%bsp_dir%" %map_name%.d3dbsp %map_name%.gsc
robocopy "%git_zone_src_dir%" "%zone_src_dir%" %map_name%.csv %map_name%_load.csv

IF EXIST "%git_map_dir%\prefabs" (
 robocopy "%git_map_dir%\prefabs" "%map_dir%\prefabs" /E
)

CALL "%tools_dir%\cod4compiletools_compilebsp.bat" "%bsp_dir%\" "%map_dir%\" "%game_dir%\" %map_name% - -extra 1 1 1
CALL "%tools_dir%\cod4compiletools_reflections.bat" "%game_dir%\" %map_name% 1

IF EXIST "%bsp_dir%\%map_name%.d3dbsp" (
 del "%git_bsp_dir%\%map_name%.d3dbsp"
 copy "%bsp_dir%\%map_name%.d3dbsp" "%git_bsp_dir%\%map_name%.d3dbsp"
 del "%bsp_dir%\%map_name%.d3dbsp"
)

cd "%~dp0"
CALL "%~dp0ff.bat"
cd "%~dp0"
CALL "%~dp0iwd.bat"

IF EXIST "%map_dir%\%map_name%.map" del "%map_dir%\%map_name%.map"
IF EXIST "%bsp_dir%\%map_name%.gsc" del "%bsp_dir%\%map_name%.gsc"

pause