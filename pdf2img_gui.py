import pathlib
import sys
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

try:
    import fitz
except ImportError:
    tk.Tk().withdraw()
    messagebox.showerror(
        "Erro",
        "PyMuPDF nao instalado.\n\n"
        "Execute no terminal:\n"
        "pdf2img install",
    )
    sys.exit(1)

SRC_DIR = pathlib.Path(__file__).parent / "src"
OUT_DIR = pathlib.Path(__file__).parent / "out"


def parse_pages(spec: str) -> list[int]:
    pages: list[int] = []
    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            start, end = part.split("-", 1)
            pages.extend(range(int(start.strip()), int(end.strip()) + 1))
        else:
            pages.append(int(part))
    return pages


class App:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("PDF2IMG")
        self.root.resizable(False, False)

        self.pdf_path: str | None = None

        OUT_DIR.mkdir(parents=True, exist_ok=True)

        row = 0

        tk.Label(self.root, text="Arquivo PDF:").grid(row=row, column=0, padx=8, pady=4, sticky="w")
        self.pdf_label = tk.Label(self.root, text="(nenhum)", fg="gray", anchor="w", width=50)
        self.pdf_label.grid(row=row, column=1, padx=8, pady=4, sticky="ew")
        tk.Button(self.root, text="Selecionar", command=self.selecionar_pdf).grid(
            row=row, column=2, padx=8, pady=4
        )
        row += 1

        sep = ttk.Separator(self.root, orient="horizontal")
        sep.grid(row=row, column=0, columnspan=3, sticky="ew", pady=8)
        row += 1

        # --- Page (imagem) ---
        tk.Label(self.root, text="Extrair pagina como imagem", font=("", 10, "bold")).grid(
            row=row, column=0, columnspan=3, padx=8, pady=(0, 4), sticky="w"
        )
        row += 1

        tk.Label(self.root, text="Pagina:").grid(row=row, column=0, padx=8, pady=2, sticky="w")
        self.page_entry = tk.Entry(self.root, width=8)
        self.page_entry.grid(row=row, column=1, padx=8, pady=2, sticky="w")

        self.page_fmt = tk.StringVar(value="png")
        tk.Radiobutton(self.root, text="PNG", variable=self.page_fmt, value="png").grid(
            row=row, column=1, padx=(80, 0), pady=2, sticky="w"
        )
        tk.Radiobutton(self.root, text="JPG", variable=self.page_fmt, value="jpg").grid(
            row=row, column=1, padx=(140, 0), pady=2, sticky="w"
        )
        tk.Button(self.root, text="Extrair", command=self.extrair_pagina).grid(
            row=row, column=2, padx=8, pady=2
        )
        row += 1

        # --- Pages (imagens) ---
        tk.Label(self.root, text="Extrair paginas como imagens", font=("", 10, "bold")).grid(
            row=row, column=0, columnspan=3, padx=8, pady=(8, 4), sticky="w"
        )
        row += 1

        tk.Label(self.root, text="Paginas:").grid(row=row, column=0, padx=8, pady=2, sticky="w")
        self.pages_entry = tk.Entry(self.root, width=20)
        self.pages_entry.grid(row=row, column=1, padx=8, pady=2, sticky="w")
        tk.Label(self.root, text="ex: 1-5 ou 1,3,5", fg="gray", font=("", 8)).grid(
            row=row, column=1, padx=(140, 0), pady=2, sticky="w"
        )

        self.pages_fmt = tk.StringVar(value="png")
        tk.Radiobutton(self.root, text="PNG", variable=self.pages_fmt, value="png").grid(
            row=row, column=1, padx=(80, 0), pady=2, sticky="w"
        )
        tk.Radiobutton(self.root, text="JPG", variable=self.pages_fmt, value="jpg").grid(
            row=row, column=1, padx=(140, 0), pady=2, sticky="w"
        )
        tk.Button(self.root, text="Extrair", command=self.extrair_paginas).grid(
            row=row, column=2, padx=8, pady=2
        )
        row += 1

        # --- Cut PDF ---
        tk.Label(self.root, text="Extrair paginas para novo PDF", font=("", 10, "bold")).grid(
            row=row, column=0, columnspan=3, padx=8, pady=(8, 4), sticky="w"
        )
        row += 1

        tk.Label(self.root, text="Paginas:").grid(row=row, column=0, padx=8, pady=2, sticky="w")
        self.cut_entry = tk.Entry(self.root, width=20)
        self.cut_entry.grid(row=row, column=1, padx=8, pady=2, sticky="w")
        tk.Label(self.root, text="ex: 1-5 ou 1,3,5", fg="gray", font=("", 8)).grid(
            row=row, column=1, padx=(140, 0), pady=2, sticky="w"
        )
        tk.Button(self.root, text="Extrair", command=self.extrair_pdf).grid(
            row=row, column=2, padx=8, pady=2
        )
        row += 1

        self.status = tk.Label(self.root, text="", fg="gray", anchor="w")
        self.status.grid(row=row, column=0, columnspan=3, padx=8, pady=8, sticky="ew")

        self.root.mainloop()

    def selecionar_pdf(self):
        path = filedialog.askopenfilename(
            title="Selecionar PDF",
            initialdir=str(SRC_DIR) if SRC_DIR.exists() else None,
            filetypes=[("Arquivos PDF", "*.pdf")],
        )
        if path:
            self.pdf_path = path
            self.pdf_label.config(text=path, fg="black")
            self.status.config(text="")

    def _pdf_ou_erro(self) -> str | None:
        if not self.pdf_path:
            messagebox.showwarning("Aviso", "Selecione um arquivo PDF primeiro.")
            return None
        if not pathlib.Path(self.pdf_path).exists():
            messagebox.showerror("Erro", "Arquivo nao encontrado.")
            return None
        return self.pdf_path

    def _salvar_em_out(self, nome: str) -> pathlib.Path:
        out = OUT_DIR / nome
        out.parent.mkdir(parents=True, exist_ok=True)
        return out

    def extrair_pagina(self):
        pdf = self._pdf_ou_erro()
        if not pdf:
            return
        try:
            pg = int(self.page_entry.get().strip())
        except ValueError:
            messagebox.showwarning("Aviso", "Digite um numero de pagina valido.")
            return
        fmt = self.page_fmt.get()

        doc = fitz.open(pdf)
        if pg < 1 or pg > doc.page_count:
            doc.close()
            messagebox.showwarning("Aviso", f"O PDF tem {doc.page_count} paginas (pagina {pg} invalida).")
            return
        page = doc.load_page(pg - 1)
        pix = page.get_pixmap()
        out = self._salvar_em_out(pathlib.Path(pdf).stem + f"_p{pg}.{fmt}")
        pix.save(out)
        doc.close()
        self.status.config(text=f"Salvo: {out}", fg="green")

    def extrair_paginas(self):
        pdf = self._pdf_ou_erro()
        if not pdf:
            return
        spec = self.pages_entry.get().strip()
        if not spec:
            messagebox.showwarning("Aviso", "Digite as paginas.")
            return
        try:
            pages = parse_pages(spec)
        except ValueError:
            messagebox.showwarning("Aviso", "Formato invalido. Use ex: 1-5 ou 1,3,5")
            return
        fmt = self.pages_fmt.get()

        doc = fitz.open(pdf)
        if any(p < 1 or p > doc.page_count for p in pages):
            doc.close()
            messagebox.showwarning("Aviso", f"Alguma pagina esta fora do intervalo (1-{doc.page_count}).")
            return

        saved = []
        for pg in pages:
            pix = doc.load_page(pg - 1).get_pixmap()
            out = self._salvar_em_out(pathlib.Path(pdf).stem + f"_p{pg}.{fmt}")
            pix.save(out)
            saved.append(out)
        doc.close()
        self.status.config(text=f"Salvos: {', '.join(str(s) for s in saved)}", fg="green")

    def extrair_pdf(self):
        pdf = self._pdf_ou_erro()
        if not pdf:
            return
        spec = self.cut_entry.get().strip()
        if not spec:
            messagebox.showwarning("Aviso", "Digite as paginas.")
            return
        try:
            pages = parse_pages(spec)
        except ValueError:
            messagebox.showwarning("Aviso", "Formato invalido. Use ex: 1-5 ou 1,3,5")
            return

        doc = fitz.open(pdf)
        if any(p < 1 or p > doc.page_count for p in pages):
            doc.close()
            messagebox.showwarning("Aviso", f"Alguma pagina esta fora do intervalo (1-{doc.page_count}).")
            return
        doc.select([p - 1 for p in pages])
        out = self._salvar_em_out(pathlib.Path(pdf).stem + "_cortado.pdf")
        doc.save(out)
        doc.close()
        self.status.config(text=f"Salvo: {out}", fg="green")


if __name__ == "__main__":
    App()
