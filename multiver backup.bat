@echo off
setlocal enabledelayedexpansion
set ver=v1.0
set "githubAPI=https://api.github.com/repos/unethicalteam/multiverbackup/releases/latest"
set "githubURL=https://github.com/unethicalteam/multiverbackup/releases/latest"
title multiver backup: %ver%

for /f "tokens=2 delims=:" %%I in ('curl -s "%githubAPI%" ^| find "tag_name"') do set "latestTag=%%~I"
set "latestTag=!latestTag:~1,-1!"
set "latestTag=!latestTag:"=!"
if /i "!latestTag!" neq "!ver!" (
    echo   A new version of mutiver backup: !latestTag! was found on GitHub!
    echo   You can download it from: [36m!githubURL![0m
    echo   Press any key to exit...
    pause >nul
    exit /b )

:: this checks for lunar client's launcher version and sets it as a variable
for /f "tokens=2 delims=: " %%a in ('curl -s https://launcherupdates.lunarclientcdn.com/latest.yml ^| findstr "version:"') do (
    set "LAUNCHER_VERSION=%%a"
)

:: this checks for output.txt, and if it exists, it'll be renamed to previous_output.txt.
if exist "output.txt" (
    :: if previous_output.txt already exists, it'll delete itself.
    if exist "previous_output.txt" (
        del "previous_output.txt"
    )
    ren "output.txt" "previous_output.txt"
)

cls
:: this makes a cURL request to lunar client's api for multiver changes.
curl -X POST -H "Content-Type: application/json; charset=UTF-8" -H "User-Agent: Lunar Client Launcher v%LAUNCHER_VERSION%" -d "{\"version\":\"1.8.9\",\"branch\":\"master\",\"os\":\"win32\",\"arch\":\"x64\",\"launcher_version\":\"%LAUNCHER_VERSION%\",\"hwid\":\"0\"}" "https://api.lunarclientprod.com/launcher/launch" > "output.txt" && (
    echo Successfully requested from Lunar Client's API.
) || (
    :: this is "error handling" incase for whatever reason the request is unsuccessful.
    echo Request unsuccessful.
    exit /b 1
)

if exist "previous_output.txt" (    
    :: this compares output.txt & previous_output.txt for any changes.
    fc "output.txt" "previous_output.txt" > nul

    if errorlevel 1 (
        set "LunarUpdated=true"
    ) else (
        set "LunarUpdated=false"
    )

    if "!LunarUpdated!"=="true" ( 
	:: this informs the user, yes lunar has updated.
	echo Lunar has updated.
	:: timestamp creation
        for /f "tokens=2-4 delims=/ " %%a in ('date /t') do ( 
            set "day=%%a"
            set "month=%%b"
            set "year=%%c"
        )
        for /f "tokens=1-3 delims=: " %%a in ('time /t') do (
            set "hour=%%a"
            set "minute=%%b"
            set "second=%%c"
        )
	:: we follow ISO 8601.
        set "timestamp=!year!!month!!day!_!hour!!minute!!second!" 
        set "folderToBackup=%USERPROFILE%\.lunarclient\offline\multiver"

        echo Creating backup: multiver !timestamp! backup.zip
	:: this zips multiver into a timestamped file for better organization.
        powershell.exe -nologo -noprofile -command "Compress-Archive -Path '!folderToBackup!' -DestinationPath 'multiver !timestamp! backup.zip'" > nul
            
        if exist "multiver !timestamp! backup.zip" (
            echo Backup created successfully.
	    echo [40;31mDo not delete output.txt or previous_output.txt, this is for change detection from the API.[40;37m	
            pause
        ) else (
            echo Failed to create the backup.
            pause
        )
    ) else (
	:: this informs the user nothing's new. no backup will be created.
        echo No update detected.
	echo [40;31mDo not delete output.txt or previous_output.txt, this is for change detection from the API.[40;37m
	pause
    )
) else (
    :: if this is the inital run, output.txt will exist but previous_output.txt will not. so a backup is made.
    if exist "output.txt" (
	:: timestamp creation
        for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
            set "day=%%a"
            set "month=%%b"
            set "year=%%c"
        )
        for /f "tokens=1-3 delims=: " %%a in ('time /t') do (
            set "hour=%%a"
            set "minute=%%b"
            set "second=%%c"
        )
	:: we follow ISO 8601.
        set "timestamp=!year!!month!!day!_!hour!!minute!!second!"
        set "folderToBackup=%USERPROFILE%\.lunarclient\offline\multiver"

        echo Creating backup: multiver !timestamp! backup.zip
        powershell.exe -nologo -noprofile -command "Compress-Archive -Path '!folderToBackup!' -DestinationPath 'multiver !timestamp! backup.zip'" > nul
            
        if exist "multiver !timestamp! backup.zip" (
            echo Backup created successfully.	
	    echo [40;31mDo not delete output.txt, this is for change detection from the API.[40;37m
            pause
        )
    )
)

:: credits screen, only shows on first run.
if exist "output.txt" ( 
    :: if previous_output.txt already exists, it'll exit.
    if exist "previous_output.txt" (
        exit /b 1
    )
    cls
    echo special thanks to decencies for api direction.
    echo.
    echo made possible by a very good conversation:
    echo "i want to add automated multiver backups in lcbud" -uchks 2023, 09-24
    echo "then do it" -Syz 2023, 09-24
    echo. 
    echo this isn't lcbud, but i did it.
    echo made by uchks. unethicalteam.
    pause
)

endlocal
exit /b 1
