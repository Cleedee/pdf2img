import argparse
import pathlib
import sys

try:
    import fitz
except ImportError:
    print("Erro: PyMuPDF nao instalado. Execute 'pdf2img install' primeiro.")
    sys.exit(1)

SRC_DIR = pathlib.Path(__file__).parent / "src"
OUT_DIR = pathlib.Path(__file__).parent / "out"


def resolver_pdf(pdf: str) -> pathlib.Path:
    path = pathlib.Path(pdf)
    if path.exists():
        return path
    candidate = SRC_DIR / path
    if candidate.exists():
        return candidate
    print(f"Erro: arquivo nao encontrado: {pdf} (tentando em {SRC_DIR})")
    sys.exit(1)


def caminho_saida(arquivo: str, sufixo: str) -> pathlib.Path:
    return OUT_DIR / f"{pathlib.Path(arquivo).stem}{sufixo}"


def extrair_pagina(pdf: str, pagina: int, fmt: str):
    path = resolver_pdf(pdf)
    doc = fitz.open(path)
    page = doc.load_page(pagina - 1)
    pix = page.get_pixmap()
    out = caminho_saida(path.name, f"_p{pagina}.{fmt}")
    out.parent.mkdir(parents=True, exist_ok=True)
    pix.save(out)
    doc.close()
    print(f"Salvo: {out}")


def extrair_paginas(pdf: str, pages_spec: str, fmt: str):
    path = resolver_pdf(pdf)
    pages: list[int] = []
    for part in pages_spec.split(","):
        if "-" in part:
            start, end = part.split("-", 1)
            pages.extend(range(int(start), int(end) + 1))
        else:
            pages.append(int(part))
    doc = fitz.open(path)
    for pg in pages:
        page = doc.load_page(pg - 1)
        pix = page.get_pixmap()
        out = caminho_saida(path.name, f"_p{pg}.{fmt}")
        out.parent.mkdir(parents=True, exist_ok=True)
        pix.save(out)
        print(f"Salvo: {out}")
    doc.close()


def parse_pages_spec(spec: str) -> list[int]:
    pages: list[int] = []
    for part in spec.split(","):
        if "-" in part:
            start, end = part.split("-", 1)
            pages.extend(range(int(start), int(end) + 1))
        else:
            pages.append(int(part))
    return pages


def extrair_pdf(pdf: str, pages_spec: str, output: str | None):
    path = resolver_pdf(pdf)
    pages = parse_pages_spec(pages_spec)
    if output:
        out_path = pathlib.Path(output)
    else:
        out_path = caminho_saida(path.name, "_cortado.pdf")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    doc = fitz.open(path)
    doc.select([p - 1 for p in pages])
    doc.save(out_path)
    doc.close()
    print(f"Salvo: {out_path}")


def main():
    parser = argparse.ArgumentParser(description="Extrai paginas de PDF como imagens")
    sub = parser.add_subparsers(dest="comando", required=True)

    p_page = sub.add_parser("page", help="Extrair uma pagina como imagem")
    p_page.add_argument("pdf", help="Arquivo PDF")
    p_page.add_argument("pagina", type=int, help="Numero da pagina")
    p_page.add_argument("--jpg", action="store_true", help="Formato JPG")
    p_page.add_argument("--png", action="store_true", help="Formato PNG")

    p_pages = sub.add_parser("pages", help="Extrair paginas como imagens")
    p_pages.add_argument("pdf", help="Arquivo PDF")
    p_pages.add_argument("intervalo", help="Ex: 1-5 ou 1,3,5")
    p_pages.add_argument("--jpg", action="store_true", help="Formato JPG")
    p_pages.add_argument("--png", action="store_true", help="Formato PNG")

    p_cut = sub.add_parser("cut", help="Extrair paginas para um novo PDF")
    p_cut.add_argument("pdf", help="Arquivo PDF")
    p_cut.add_argument("intervalo", help="Ex: 1-3 ou 1,3,5")
    p_cut.add_argument("-o", "--output", help="Arquivo de saida (opcional)")

    args = parser.parse_args()

    if args.comando == "page":
        fmt = "jpg" if args.jpg else "png"
        extrair_pagina(args.pdf, args.pagina, fmt)
    elif args.comando == "pages":
        fmt = "jpg" if args.jpg else "png"
        extrair_paginas(args.pdf, args.intervalo, fmt)
    elif args.comando == "cut":
        extrair_pdf(args.pdf, args.intervalo, args.output)


if __name__ == "__main__":
    main()
