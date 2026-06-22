@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%SCRIPT_DIR%.venv"
set "PYTHON_VERSION=3.12"

if /i "%~1"=="install" goto :install
if /i "%~1"=="help" goto :help
if "%~1"=="" goto :help

call :ensure_env
"%VENV_DIR%\Scripts\python.exe" "%SCRIPT_DIR%pdf2img.py" %*
goto :eof

:install
echo [*] Verificando se o uv esta instalado...
where uv >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [*] Instalando uv...
    powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
)
echo [*] Instalando Python %PYTHON_VERSION% via uv...
uv python install %PYTHON_VERSION%
echo [*] Criando ambiente virtual...
uv venv --python %PYTHON_VERSION% "%VENV_DIR%"
echo [*] Instalando dependencias (PyMuPDF)...
uv pip install --python "%VENV_DIR%\Scripts\python.exe" PyMuPDF
echo [*] Instalacao concluida.
goto :eof

:ensure_env
if not exist "%VENV_DIR%\Scripts\python.exe" (
    echo [*] Ambiente nao encontrado. Execute primeiro: %~nx0 install
    exit /b 1
)
goto :eof

:help
echo.
echo PDF2IMG - Extrai paginas de PDF como imagens ou novo PDF
echo.
echo Uso:
echo   %~nx0 install                                  Instala Python e dependencias
echo   %~nx0 page ^<PDF^> ^<N^> [--jpg^|--png]          Extrai a pagina N como imagem
echo   %~nx0 pages ^<PDF^> ^<RANGE^> [--jpg^|--png]      Extrai paginas como imagem
echo   %~nx0 cut ^<PDF^> ^<RANGE^> [-o saida.pdf]        Extrai paginas para novo PDF
echo.
echo Exemplos:
echo   %~nx0 install
echo   %~nx0 page documento.pdf 1 --png
echo   %~nx0 page documento.pdf 3 --jpg
echo   %~nx0 pages documento.pdf 1-5 --png
echo   %~nx0 pages documento.pdf 1,3,5 --jpg
echo   %~nx0 cut documento.pdf 1-3
echo   %~nx0 cut documento.pdf 1-3 -o resumo.pdf
echo.
goto :eof
