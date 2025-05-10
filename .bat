@echo off
REM Batch file to run the Turn-Based RPG Game in MARS MIPS Simulator

REM Set the path to the MARS simulator JAR file
set MARS_PATH="C:\Nash\Projects\ASMOrder\Mars4_5.jar"

REM Set the path to the game.asm file
set GAME_PATH="C:\Nash\Projects\ASMOrder\game.asm"

REM Run the game in the MARS simulator
java -jar %MARS_PATH% %GAME_PATH%

pause