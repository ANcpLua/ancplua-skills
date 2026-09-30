# Sources and ownership

- Document content and metadata belong in the `.tex` document; citation records belong in `Literatur.bib`. The example contains placeholder text and identities, not verified thesis content.
- Shared typography and class behavior belong in `twbook.cls`. `PICs/` contains the cover and example artwork.
- The class and manual identify `twbook.dtx` as their generation source, but that source and its extraction driver are absent here. For class changes, locate the generator first; update and regenerate it when available. If only the checked-in class can be edited, disclose the missing regeneration source.
- Regenerate document PDFs from their `.tex` inputs instead of editing PDFs.
