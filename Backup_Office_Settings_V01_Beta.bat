@echo off
TITLE Office Settings, Add-ins and Registry Tool
color 0A

:: Force the command prompt to work in the exact folder where this batch file is saved
CD /D "%~dp0"

:MENU
cls
echo ========================================================
echo    Office Settings, Add-ins and Registry Manager
echo ========================================================
echo.
echo Working Directory: %CD%
echo.
echo Please choose an operation:
echo "[1] Backup Templates, Add-ins and Files Only (.rar / .zip)"
echo "[2] Restore Templates, Add-ins and Files Only"
echo "[3] Export/Backup Office Registry Keys Only (.reg)"
echo "[4] Import/Restore Office Registry Keys Only (.reg)"
echo "[5] Exit"
echo.
SET /P choice="Enter your choice (1 to 5): "

IF "%choice%"=="5" EXIT
IF "%choice%"=="4" GOTO RESTORE_REG
IF "%choice%"=="3" GOTO BACKUP_REG
IF "%choice%"=="2" GOTO RESTORE_FILES
IF "%choice%"=="1" GOTO BACKUP_FILES

echo [ERROR] Invalid choice. Please press a number from 1 to 5.
pause
GOTO MENU

:BACKUP_FILES
echo.
echo [1/2] Creating temporary file list...
IF EXIST "%~dp0filelist.txt" DEL "%~dp0filelist.txt"

echo %APPDATA%\Microsoft\Templates\Normal.dotm >> "%~dp0filelist.txt"
echo %APPDATA%\Microsoft\Templates\NormalEmail.dotm >> "%~dp0filelist.txt"
echo %USERPROFILE%\Documents\Custom Office Templates\* >> "%~dp0filelist.txt"
echo %APPDATA%\Microsoft\Templates\*.potx >> "%~dp0filelist.txt"
echo %APPDATA%\Microsoft\Templates\Document Themes\* >> "%~dp0filelist.txt"
echo %APPDATA%\Microsoft\Office\*.officeUI >> "%~dp0filelist.txt"
echo %LOCALAPPDATA%\Microsoft\Office\*.officeUI >> "%~dp0filelist.txt"
echo %APPDATA%\Microsoft\Office\ >> "%~dp0filelist.txt"
echo %APPDATA%\Microsoft\Excel\XLSTART\* >> "%~dp0filelist.txt"
echo %PROGRAMFILES%\Microsoft Office\root\Office16\XLSTART\* >> "%~dp0filelist.txt"
echo %APPDATA%\Microsoft\AddIns\* >> "%~dp0filelist.txt"
echo %USERPROFILE%\AppData\Roaming\Microsoft\AddIns\* >> "%~dp0filelist.txt"
echo %PROGRAMFILES%\Microsoft Office\root\Office16\Library\* >> "%~dp0filelist.txt"
echo %PROGRAMFILES(x86)%\Microsoft Office\root\Office16\Library\* >> "%~dp0filelist.txt"

echo [2/2] Packing files into archive...
IF EXIST "C:\Program Files\WinRAR\WinRAR.exe" (
    "C:\Program Files\WinRAR\WinRAR.exe" a -r -ep2 -oi "%~dp0OfficeSettings_Backup.rar" "@%~dp0filelist.txt"
    echo Archive created successfully: OfficeSettings_Backup.rar
) ELSE IF EXIST "C:\Program Files (x86)\WinRAR\WinRAR.exe" (
    "C:\Program Files (x86)\WinRAR\WinRAR.exe" a -r -ep2 -oi "%~dp0OfficeSettings_Backup.rar" "@%~dp0filelist.txt"
    echo Archive created successfully: OfficeSettings_Backup.rar
) ELSE (
    powershell -Command "Get-Content '%~dp0filelist.txt' | Where-Object { Test-Path $_ } | Compress-Archive -DestinationPath '%~dp0OfficeSettings_Backup.zip' -Force"
    echo WinRAR not found. Created ZIP archive: OfficeSettings_Backup.zip
)

IF EXIST "%~dp0filelist.txt" DEL "%~dp0filelist.txt"
echo.
pause
GOTO MENU

:RESTORE_FILES
echo.
SET "ARCHIVE_TYPE="
IF EXIST "%~dp0OfficeSettings_Backup.rar" SET "ARCHIVE_TYPE=RAR"
IF EXIST "%~dp0OfficeSettings_Backup.zip" SET "ARCHIVE_TYPE=ZIP"

IF "%ARCHIVE_TYPE%"=="" (
    echo [ERROR] No backup archive (RAR or ZIP) found in this folder!
    pause
    GOTO MENU
)

echo Restoring Office files and add-ins to their original system paths...
IF "%ARCHIVE_TYPE%"=="RAR" (
    IF EXIST "C:\Program Files\WinRAR\WinRAR.exe" (
        "C:\Program Files\WinRAR\WinRAR.exe" x -o+ "%~dp0OfficeSettings_Backup.rar" "C:\"
    ) ELSE (
        "C:\Program Files (x86)\WinRAR\WinRAR.exe" x -o+ "%~dp0OfficeSettings_Backup.rar" "C:\"
    )
) ELSE (
    powershell -Command "Expand-Archive -Path '%~dp0OfficeSettings_Backup.zip' -DestinationPath 'C:\' -Force"
)

echo.
echo File restoration completed successfully!
pause
GOTO MENU

:BACKUP_REG
echo.
echo [1/2] Exporting Office Registry configuration keys...
IF EXIST "%~dp0Office_Registry_Backup.reg" DEL "%~dp0Office_Registry_Backup.reg"
IF EXIST "%~dp0temp_export.reg" DEL "%~dp0temp_export.reg"

reg export "HKCU\Software\Microsoft\Office" "%~dp0temp_export.reg" /y >nul 2>&1

IF ERRORLEVEL 1 (
    echo [ERROR] Failed to export registry keys.
    GOTO BACKUP_REG_END
)

echo [2/2] Sanitizing paths for cross-PC portability...
powershell -NoProfile -Command ^
    "$content = Get-Content -Path '%~dp0temp_export.reg' -Raw; " ^
    "$profileEscaped = [Regex]::Escape($env:USERPROFILE); " ^
    "$updated = $content -replace $profileEscaped, '%%USERPROFILE%%'; " ^
    "$updated | Out-File -FilePath '%~dp0Office_Registry_Backup.reg' -Encoding ascii"

IF EXIST "%~dp0Office_Registry_Backup.reg" (
    echo.
    echo Registry backup saved and sanitized successfully as: Office_Registry_Backup.reg
) else (
    echo [ERROR] Failed to generate sanitized registry backup.
)

:BACKUP_REG_END
IF EXIST "%~dp0temp_export.reg" DEL "%~dp0temp_export.reg"
echo.
pause
GOTO MENU

:RESTORE_REG
echo.
IF NOT EXIST "%~dp0Office_Registry_Backup.reg" (
    echo [ERROR] "Office_Registry_Backup.reg" not found in this folder!
    pause
    GOTO MENU
)

echo Importing Office Registry keys into your system...
reg import "%~dp0Office_Registry_Backup.reg"

echo.
echo Registry restoration completed successfully!
pause
GOTO MENU