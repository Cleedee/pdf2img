param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir = Join-Path $ScriptDir ".venv"
$PythonPath = Join-Path (Join-Path $VenvDir "Scripts") "python.exe"

if (-not (Test-Path -LiteralPath $PythonPath)) {
    Write-Host "[*] Ambiente virtual nao encontrado. Execute install.ps1 primeiro." -ForegroundColor Red
    exit 1
}

Write-Host "[*] Instalando PyInstaller..." -ForegroundColor Cyan
uv pip install --python $PythonPath PyInstaller

Write-Host "[*] Compilando executavel..." -ForegroundColor Cyan
& $PythonPath -m PyInstaller `
    --onefile `
    --windowed `
    --name pdf2img `
    --distpath (Join-Path $ScriptDir "dist") `
    --workpath (Join-Path $ScriptDir "build") `
    --specpath $ScriptDir `
    (Join-Path $ScriptDir "pdf2img_gui.py")

Write-Host "[*] Limpando artefatos temporarios..." -ForegroundColor Cyan
Remove-Item -LiteralPath (Join-Path $ScriptDir "build") -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $ScriptDir "pdf2img.spec") -Force -ErrorAction SilentlyContinue

$ExePath = Join-Path (Join-Path $ScriptDir "dist") "pdf2img.exe"
if (Test-Path -LiteralPath $ExePath) {
    Write-Host "[*] Executavel gerado: $ExePath" -ForegroundColor Green
    $size = (Get-Item -LiteralPath $ExePath).Length
    if ($size -ge 1MB) {
        Write-Host ("    Tamanho: {0:N2} MB" -f ($size / 1MB)) -ForegroundColor Gray
    } else {
        Write-Host ("    Tamanho: {0:N0} KB" -f ($size / 1KB)) -ForegroundColor Gray
    }
}
