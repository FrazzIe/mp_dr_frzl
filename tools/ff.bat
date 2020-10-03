@echo off

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set bin_dir=%game_dir%\bin
set zone_dir=%game_dir%\zone\english
set zone_src_dir=%game_dir%\zone_source
set output_dir=%~dp0..\output
set raw_dir=%game_dir%\raw
set git_zone_src_dir=%~dp0..\zone_source\english\assetinfo
set git_raw_dir=%~dp0..\raw

IF EXIST "%zone_src_dir%\%map_name%.csv" del "%zone_src_dir%\%map_name%.csv"
IF EXIST "%zone_src_dir%\%map_name%_load.csv" del "%zone_src_dir%\%map_name%_load.csv"
IF EXIST "%zone_dir%\%map_name%.ff" del "%zone_dir%\%map_name%.ff"
IF EXIST "%zone_dir%\%map_name%_load.ff" del "%zone_dir%\%map_name%_load.ff"

robocopy "%git_zone_src_dir%" "%zone_src_dir%" %map_name%.csv %map_name%_load.csv
robocopy "%git_raw_dir%" "%raw_dir%" /E

cd "%bin_dir%"
"%bin_dir%\linker_pc.exe" %map_name% %map_name%_load

IF EXIST "%zone_dir%\%map_name%.ff" (
 del "%output_dir%\%map_name%.ff"
 robocopy "%zone_dir%" "%output_dir%" %map_name%.ff
 del "%zone_dir%\%map_name%.ff"
)
IF EXIST "%zone_dir%\%map_name%_load.ff" (
 del "%output_dir%\%map_name%_load.ff"
 robocopy "%zone_dir%" "%output_dir%" %map_name%_load.ff
 del "%zone_dir%\%map_name%_load.ff"
)