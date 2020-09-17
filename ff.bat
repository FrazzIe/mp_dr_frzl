@echo off

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set bin_dir=%game_dir%\bin
set zone_src_dir=%game_dir%\zone_source
set zone_dir=%game_dir%\zone\english
set git_zone_src_dir=%~dp0zone_source\english\assetinfo
set git_zone_dir=%~dp0zone\english

IF NOT EXIST %git_zone_src_dir%\%map_name%.csv (
 echo work
 echo "ignore,code_post_gfx_mp"> %git_zone_src_dir%\%map_name%.csv
 echo "ignore,common_mp">> %git_zone_src_dir%\%map_name%.csv
 echo "ignore,localized_code_post_gfx_mp">> %git_zone_src_dir%\%map_name%.csv
 echo "ignore,localized_common_mp">> %git_zone_src_dir%\%map_name%.csv
 echo "col_map_mp,maps/mp/%map_name%.d3dbsp">> %git_zone_src_dir%\%map_name%.csv
 echo "rawfile,maps/mp/%map_name%.gsc">> %git_zone_src_dir%\%map_name%.csv
 echo "impactfx,%map_name%">> %git_zone_src_dir%\%map_name%.csv
 echo "sound,common,%map_name%,!all_mp">> %git_zone_src_dir%\%map_name%.csv
 echo "sound,generic,%map_name%,!all_mp">> %git_zone_src_dir%\%map_name%.csv
 echo "sound,voiceovers,%map_name%,!all_mp">> %git_zone_src_dir%\%map_name%.csv
 echo "sound,multiplayer,%map_name%,!all_mp">> %git_zone_src_dir%\%map_name%.csv

 echo "ignore,code_post_gfx_mp"> %git_zone_src_dir%\%map_name%_load.csv
 echo "ignore,common_mp">> %git_zone_src_dir%\%map_name%_load.csv
 echo "ignore,localized_code_post_gfx_mp">> %git_zone_src_dir%\%map_name%_load.csv
 echo "ignore,localized_common_mp">> %git_zone_src_dir%\%map_name%_load.csv
 echo "ui_map,maps/%map_name%">> %git_zone_src_dir%\%map_name%_load.csv
)

IF EXIST "%zone_src_dir%\%map_name%.csv" del "%zone_src_dir%\%map_name%.csv"
IF EXIST "%zone_src_dir%\%map_name%_load.csv" del "%zone_src_dir%\%map_name%_load.csv"
IF EXIST "%zone_dir%\%map_name%.ff" del "%zone_dir%\%map_name%.ff"
IF EXIST "%zone_dir%\%map_name%_load.ff" del "%zone_dir%\%map_name%_load.ff"

robocopy "%git_zone_src_dir%" "%zone_src_dir%" %map_name%.csv %map_name%_load.csv

cd "%bin_dir%"
"%bin_dir%\linker_pc.exe" %map_name% %map_name%_load

IF EXIST "%zone_src_dir%\%map_name%.csv" (
 del "%git_zone_src_dir%\%map_name%.csv"
 robocopy "%zone_src_dir%" "%git_zone_src_dir%" %map_name%.csv
 del "%zone_src_dir%\%map_name%.csv"
)
IF EXIST "%zone_src_dir%\%map_name%_load.csv" (
 del "%git_zone_src_dir%\%map_name%_load.csv"
 robocopy "%zone_src_dir%" "%git_zone_src_dir%" %map_name%_load.csv
 del "%zone_src_dir%\%map_name%_load.csv"
)
IF EXIST "%zone_dir%\%map_name%.ff" (
 del "%git_zone_dir%\%map_name%.ff"
 robocopy "%zone_dir%" "%git_zone_dir%" %map_name%.ff
 del "%zone_dir%\%map_name%.ff"
)
IF EXIST "%zone_dir%\%map_name%_load.ff" (
 del "%git_zone_dir%\%map_name%_load.ff"
 robocopy "%zone_dir%" "%git_zone_dir%" %map_name%_load.ff
 del "%zone_dir%\%map_name%_load.ff"
)