param(
    [switch]$NoGui
)

$REPO_URL = "https://github.com/Cleedee/pdf2img.git"
$PROJECT_DIR = if ($MyInvocation.MyCommand.Path -and (Test-Path -LiteralPath $MyInvocation.MyCommand.Path)) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    Join-Path $env:USERPROFILE "pdf2img"
}

$VENV_DIR = Join-Path $PROJECT_DIR ".venv"
$PYTHON_VERSION = "3.12"
$PYTHON_PATH = Join-Path (Join-Path $VENV_DIR "Scripts") "python.exe"
$GUI_SCRIPT = Join-Path $PROJECT_DIR "pdf2img_gui.py"

# Step 1: ensure project is cloned
if (-not (Test-Path -LiteralPath (Join-Path $PROJECT_DIR "pdf2img_gui.py"))) {
    Write-Host "[*] Baixando pdf2img do GitHub..." -ForegroundColor Cyan
    if (Get-Command git -ErrorAction SilentlyContinue) {
        git clone $REPO_URL $PROJECT_DIR
    } else {
        $zipUrl = "https://github.com/Cleedee/pdf2img/archive/refs/heads/main.zip"
        $zipPath = Join-Path $env:TEMP "pdf2img.zip"
        $extractPath = Join-Path $env:TEMP "pdf2img-extract"
        Remove-Item -LiteralPath $zipPath -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $extractPath -Recurse -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $extractPath
        $inner = Join-Path $extractPath "pdf2img-main"
        if (Test-Path -LiteralPath $PROJECT_DIR) {
            Remove-Item -LiteralPath "$PROJECT_DIR\*" -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            New-Item -ItemType Directory -Path $PROJECT_DIR -Force | Out-Null
        }
        Get-ChildItem -LiteralPath $inner | Move-Item -Destination $PROJECT_DIR -Force
        Remove-Item -LiteralPath $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
    }
}

# Step 2: ensure uv is installed
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "[*] Instalando uv (gerenciador de Python)..." -ForegroundColor Cyan
    Invoke-Expression (Invoke-RestMethod "https://astral.sh/uv/install.ps1")
}

# Step 3: ensure Python version
Write-Host "[*] Verificando Python $PYTHON_VERSION..." -ForegroundColor Cyan
uv python install $PYTHON_VERSION 2>$null

# Step 4: ensure venv and dependencies
if (-not (Test-Path -LiteralPath $PYTHON_PATH)) {
    Write-Host "[*] Criando ambiente virtual..." -ForegroundColor Cyan
    uv venv --python $PYTHON_VERSION $VENV_DIR
}

Write-Host "[*] Instalando dependencias (PyMuPDF)..." -ForegroundColor Cyan
uv pip install --python $PYTHON_PATH PyMuPDF 2>$null

Write-Host "[*] Instalacao concluida!" -ForegroundColor Green

# Step 5: run GUI
if (-not $NoGui) {
    Write-Host "[*] Iniciando pdf2img_gui.py..." -ForegroundColor Cyan
    & $PYTHON_PATH $GUI_SCRIPT
}
