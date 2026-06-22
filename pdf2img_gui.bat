@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%SCRIPT_DIR%.venv"

if not exist "%VENV_DIR%\Scripts\python.exe" (
    echo [*] Ambiente nao encontrado. Execute primeiro: pdf2img install
    pause
    exit /b 1
)

start "" "%VENV_DIR%\Scripts\python.exe" "%SCRIPT_DIR%pdf2img_gui.py"
