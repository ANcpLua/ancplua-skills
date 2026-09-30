---
name: twbook
description: Edit the ArchCheck thesis workspace's twbook LaTeX class, document, bibliography, and PDF layout. Use when configuring the template, fixing bibliography or citation problems, compiling, or verifying PDF layout.
---

# twbook

Paths are relative to the thesis repository root, which contains `twbook.cls`; work from there. Before editing, read the relevant parts of `twbook.cls` and the example document `BSP_BA_IEEE_en.tex`. The class manual `twbook.pdf` documents its interface; the checked-in class determines current behavior. Before changing the class, bibliography, artwork, or PDFs, read [references/sources.md](references/sources.md).

## Edit the document

1. Preserve the document type, language, citation style, and backend unless the task changes them. The example uses `\documentclass[Bachelor,english,IEEE]{twbook}`; the class defaults to Biber. Read `\DeclareOption` in the class for supported options instead of passing arbitrary `scrbook` options through it.
2. Keep `\usepackage[utf8]{inputenc}` after `\documentclass`: the class requires it and loads `csquotes`, `biblatex`, and the citation helpers in its package hook. Keep the example's T1 font encoding for pdfLaTeX.
3. Set title, author, student number, degree course, supervisors, place, abstracts, and keywords through the class commands shown in the example. `\maketitle` generates the applicable front matter and contents; check its output before adding another title page, declaration, abstract, or contents.
4. Use `\addbibresource` and `\printbibliography` with the configured backend; `\citepic`, `\citefig`, and `\citefigm` support figure attribution. Follow the example for lists, appendices, and `\aitoolentry`/`\listaitools`; document actual tool use instead of carrying over its demonstration entries.
5. Before compiling or claiming completion, read [references/compile.md](references/compile.md).
