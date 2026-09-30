# Compile and inspect

For `.tex` edits in Codex, open the saved source in the built-in LaTeX editor and use its compiler when available. For terminal compilation with a TeX toolchain, run from the repository root so the local class, bibliography, and images resolve:

```sh
pdflatex -interaction=nonstopmode -halt-on-error -file-line-error BSP_BA_IEEE_en.tex &&
biber BSP_BA_IEEE_en &&
pdflatex -interaction=nonstopmode -halt-on-error -file-line-error BSP_BA_IEEE_en.tex &&
pdflatex -interaction=nonstopmode -halt-on-error -file-line-error BSP_BA_IEEE_en.tex
```

Substitute the edited document's basename. Use `bibtex` in place of `biber` only when its class options select BibTeX. Missing executables or packages are a compilation blocker, not evidence of a bad document.

Completion requires a fresh successful compilation, resolved citations and references, and inspection of affected PDF pages for cover alignment, front matter, page numbering, captions, bibliography, and overflow. A class-wide layout change also needs representative body and back-matter pages inspected. Report any remaining compilation or rendering limitation explicitly.
