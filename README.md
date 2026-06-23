# PDF2IMG

Extração de páginas de PDF para imagem (PNG/JPG) ou novo PDF.

## Requisitos

- Windows 10+ ou Linux
- Conexão com internet (apenas na primeira execução)

## Instalação

### Windows

**Opção A — Terminal:**

```batch
pdf2img install
```

**Opção B — Clicando no arquivo:**

1. Abra a pasta onde estão os arquivos
2. Clique duas vezes em `pdf2img.bat`
3. Digite `install` e pressione Enter

### Linux

Abra o terminal na pasta e execute:

```bash
./pdf2img.sh install
```

O instalador baixa o [uv](https://astral.sh/uv/) (gerenciador de Python), instala o Python 3.12, cria um ambiente virtual (`.venv`) e instala a biblioteca [PyMuPDF](https://pypi.org/project/PyMuPDF/).

## Uso — Terminal

### Windows

```batch
pdf2img install                    Instala/atualiza tudo
pdf2img page <PDF> <N> [--jpg]     Extrai a página N como imagem
pdf2img pages <PDF> <RANGE> [--jpg] Extrai múltiplas páginas como imagem
pdf2img cut <PDF> <RANGE> [-o saida.pdf] Extrai páginas para novo PDF
pdf2img help                       Mostra a ajuda
```

### Linux

```bash
./pdf2img.sh install                    Instala/atualiza tudo
./pdf2img.sh page <PDF> <N> [--jpg]     Extrai a página N como imagem
./pdf2img.sh pages <PDF> <RANGE> [--jpg] Extrai múltiplas páginas como imagem
./pdf2img.sh cut <PDF> <RANGE> [-o saida.pdf] Extrai páginas para novo PDF
./pdf2img.sh help                       Mostra a ajuda
```

### Exemplos

```bash
./pdf2img.sh page documento.pdf 1 --png
./pdf2img.sh page documento.pdf 3 --jpg
./pdf2img.sh pages documento.pdf 1-5 --png
./pdf2img.sh pages documento.pdf 1,3,5 --jpg
./pdf2img.sh cut documento.pdf 1-3
./pdf2img.sh cut documento.pdf 1-3 -o resumo.pdf
```

## Uso — Interface Gráfica

### Windows
Clique duas vezes em `pdf2img_gui.bat` (ou `pdf2img_gui.py`).

### Linux
```bash
./pdf2img.sh gui
```

A janela permite:
1. Clicar em **Selecionar** para escolher um PDF
2. Preencher o número da página ou intervalo
3. Escolher PNG ou JPG
4. Clicar em **Extrair**

As imagens/PDF gerados são salvos na pasta `out/`.

Coloque os PDFs de origem na pasta `src/` para facilitar (ou informe o caminho completo).

## Formato dos intervalos

| Intervalo | Páginas extraídas |
|-----------|-------------------|
| `1-5`     | 1, 2, 3, 4, 5 |
| `1,3,5`   | 1, 3, 5 |
| `1-3,7`   | 1, 2, 3, 7 |
| `2-4,6-8` | 2, 3, 4, 6, 7, 8 |

## Arquivos gerados

| Arquivo | Descrição |
|---------|-----------|
| `documento_p1.png` | Página 1 em PNG |
| `documento_p3.jpg` | Página 3 em JPG |
| `documento_cortado.pdf` | PDF com apenas as páginas selecionadas |

## Solução de problemas

**"Não é reconhecido como comando"**
- Use `pdf2img.bat install` em vez de `pdf2img install`
- Ou abra a pasta e digite `.\pdf2img.bat install`

**"PyMuPDF não instalado"**
- Execute `pdf2img install` ou clique duas vezes em `pdf2img.bat` e digite `install`

**"Ambiente não encontrado"**
- Execute o comando `install` primeiro

## Desinstalação

Basta apagar a pasta inteira com todos os arquivos.
