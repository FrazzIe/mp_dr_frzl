@echo off

set /p game_dir=<game_directory.txt
set /p map_name=<map_name.txt
set tools_dir=%game_dir%\bin\CoD4CompileTools
set map_dir=%game_dir%\map_source
set bsp_dir=%game_dir%\raw\maps\mp
set git_map_dir=%~dp0map_source
set git_bsp_dir=%~dp0raw\maps\mp
cd "%tools_dir%"

IF EXIST "%map_dir%\%map_name%.map" del "%map_dir%\%map_name%.map"
IF EXIST "%map_dir%\%map_name%.grid" del "%map_dir%\%map_name%.grid"
IF EXIST "%map_dir%\%map_name%.lin" del "%map_dir%\%map_name%.lin"

IF EXIST "%bsp_dir%\%map_name%.d3dbsp" del "%bsp_dir%\%map_name%.d3dbsp"
IF EXIST "%bsp_dir%\%map_name%.gsc" del "%bsp_dir%\%map_name%.gsc"

robocopy "%git_map_dir%" "%map_dir%" %map_name%.map %map_name%.grid %map_name%.lin
robocopy "%git_bsp_dir%" "%bsp_dir%" %map_name%.d3dbsp %map_name%.gsc

CALL "%tools_dir%\cod4compiletools_compilebsp.bat" "%bsp_dir%\" "%map_dir%\" "%game_dir%\" %map_name% - -extra 1 1 1
CALL "%tools_dir%\cod4compiletools_reflections.bat" "%game_dir%\" %map_name% 1
CALL "%~dp0\ff.bat"

IF EXIST "%map_dir%\%map_name%.map" del "%map_dir%\%map_name%.map"
IF EXIST "%map_dir%\%map_name%.grid" del "%map_dir%\%map_name%.grid"
IF EXIST "%map_dir%\%map_name%.lin" del "%map_dir%\%map_name%.lin"

IF EXIST "%bsp_dir%\%map_name%.d3dbsp" (
 del "%git_bsp_dir%\%map_name%.d3dbsp"
 copy "%bsp_dir%\%map_name%.d3dbsp" "%git_bsp_dir%\%map_name%.d3dbsp"
 del "%bsp_dir%\%map_name%.d3dbsp"
)
IF EXIST "%bsp_dir%\%map_name%.gsc" del "%bsp_dir%\%map_name%.gsc"

pause