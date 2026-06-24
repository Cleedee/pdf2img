#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Cleedee/pdf2img.git"
PYTHON_VERSION="3.12"

if [[ -n "${BASH_SOURCE[0]}" && -f "${BASH_SOURCE[0]}" ]]; then
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    PROJECT_DIR="$HOME/.local/share/pdf2img"
fi

VENV_DIR="$PROJECT_DIR/.venv"
PYTHON_PATH="$VENV_DIR/bin/python"
GUI_SCRIPT="$PROJECT_DIR/pdf2img_gui.py"

# Step 1: ensure project is cloned
if [ ! -f "$GUI_SCRIPT" ]; then
    echo "[*] Baixando pdf2img do GitHub..."
    if command -v git &>/dev/null; then
        git clone "$REPO_URL" "$PROJECT_DIR.tmp"
        mkdir -p "$PROJECT_DIR"
        cp -r "$PROJECT_DIR.tmp"/* "$PROJECT_DIR/"
        rm -rf "$PROJECT_DIR.tmp"
    else
        url="https://github.com/Cleedee/pdf2img/archive/refs/heads/main.tar.gz"
        tmp="$(mktemp -d)"
        curl -sSL "$url" | tar -xz -C "$tmp"
        rm -rf "$PROJECT_DIR"
        mkdir -p "$PROJECT_DIR"
        cp -r "$tmp"/pdf2img-main/* "$PROJECT_DIR/"
        rm -rf "$tmp"
    fi
fi

# Step 2: ensure uv is installed
if ! command -v uv &>/dev/null; then
    echo "[*] Instalando uv (gerenciador de Python)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Step 3: ensure Python version
echo "[*] Verificando Python $PYTHON_VERSION..."
uv python install "$PYTHON_VERSION"

# Step 4: ensure venv and dependencies
if [ ! -f "$PYTHON_PATH" ]; then
    echo "[*] Criando ambiente virtual..."
    uv venv --python "$PYTHON_VERSION" "$VENV_DIR"
fi

echo "[*] Instalando dependencias (PyMuPDF)..."
uv pip install --python "$PYTHON_PATH" PyMuPDF

echo "[*] Instalacao concluida!"

# Step 5: run GUI (only if not sourced and --no-gui not passed)
if [[ ! "${BASH_SOURCE[0]}" || "${BASH_SOURCE[0]}" == "${0}" ]]; then
    no_gui=0
    for arg in "$@"; do
        if [[ "$arg" == "--no-gui" ]]; then
            no_gui=1
            break
        fi
    done
    if [[ $no_gui -eq 0 ]]; then
        echo "[*] Iniciando pdf2img_gui.py..."
        exec "$PYTHON_PATH" "$GUI_SCRIPT"
    fi
fi
