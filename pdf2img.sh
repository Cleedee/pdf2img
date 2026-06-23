#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
PYTHON_VERSION="3.12"

main() {
    case "${1:-}" in
    install) cmd_install ;;
    gui) ensure_env; "$VENV_DIR/bin/python" "$SCRIPT_DIR/pdf2img_gui.py" ;;
    help|"") cmd_help ;;
    *) ensure_env; "$VENV_DIR/bin/python" "$SCRIPT_DIR/pdf2img.py" "$@" ;;
    esac
}

cmd_install() {
    echo "[*] Verificando se o uv esta instalado..."
    if ! command -v uv &>/dev/null; then
        echo "[*] Instalando uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    echo "[*] Instalando Python $PYTHON_VERSION via uv..."
    uv python install "$PYTHON_VERSION"

    echo "[*] Criando ambiente virtual..."
    uv venv --python "$PYTHON_VERSION" "$VENV_DIR"

    echo "[*] Instalando dependencias (PyMuPDF)..."
    uv pip install --python "$VENV_DIR/bin/python" PyMuPDF

    echo "[*] Instalacao concluida."
}

ensure_env() {
    if [ ! -f "$VENV_DIR/bin/python" ]; then
        echo "[*] Ambiente nao encontrado. Execute primeiro: $(basename "$0") install"
        exit 1
    fi
}

cmd_help() {
    cat <<EOF

PDF2IMG - Extrai paginas de PDF como imagens ou novo PDF

Uso:
  $(basename "$0") install                                  Instala Python e dependencias
  $(basename "$0") page <PDF> <N> [--jpg|--png]            Extrai a pagina N como imagem
  $(basename "$0") pages <PDF> <RANGE> [--jpg|--png]       Extrai paginas como imagem
  $(basename "$0") cut <PDF> <RANGE> [-o saida.pdf]        Extrai paginas para novo PDF

Exemplos:
  $(basename "$0") install
  $(basename "$0") page documento.pdf 1 --png
  $(basename "$0") page documento.pdf 3 --jpg
  $(basename "$0") pages documento.pdf 1-5 --png
  $(basename "$0") pages documento.pdf 1,3,5 --jpg
  $(basename "$0") cut documento.pdf 1-3
  $(basename "$0") cut documento.pdf 1-3 -o resumo.pdf

EOF
}

main "$@"
