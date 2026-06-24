#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
VENV_PYTHON="$VENV_DIR/bin/python"

check_tkinter() {
    "$1" -c "import tkinter; tkinter.Tk(); tkinter.Tk().destroy()" 2>/dev/null
}

# Find a Python with working tkinter
PYTHON=""
if [ -f "$VENV_PYTHON" ] && check_tkinter "$VENV_PYTHON"; then
    PYTHON="$VENV_PYTHON"
elif command -v python3 &>/dev/null && check_tkinter "$(command -v python3)"; then
    PYTHON="$(command -v python3)"
    echo "[*] Aviso: tkinter no ambiente virtual (.venv) nao funciona."
    echo "    Usando Python do sistema: $PYTHON"
else
    echo "[*] Erro: nenhum Python com tkinter funcional encontrado."
    echo "    Instale o tkinter: sudo apt install python3-tk (ou equivalente)"
    exit 1
fi

echo "[*] Instalando PyInstaller..."
"$PYTHON" -m pip install --quiet PyInstaller

echo "[*] Compilando executavel..."
"$PYTHON" -m PyInstaller \
    --onefile \
    --windowed \
    --name pdf2img \
    --distpath "$SCRIPT_DIR/dist" \
    --workpath "$SCRIPT_DIR/build" \
    --specpath "$SCRIPT_DIR" \
    "$SCRIPT_DIR/pdf2img_gui.py"

echo "[*] Limpando artefatos temporarios..."
rm -rf "$SCRIPT_DIR/build" "$SCRIPT_DIR/pdf2img.spec"

echo "[*] Executavel gerado: $SCRIPT_DIR/dist/pdf2img"
ls -lh "$SCRIPT_DIR/dist/pdf2img"
