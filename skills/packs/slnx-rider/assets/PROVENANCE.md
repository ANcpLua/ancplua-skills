# Bundled assets

## Slnx.xsd

Verbatim copy of `src/Microsoft.VisualStudio.SolutionPersistence/Serializer/Xml/Slnx.xsd`
from [microsoft/vs-solutionpersistence](https://github.com/microsoft/vs-solutionpersistence)
at commit `ea32bc0` (2026-05-28).

Copyright (c) Microsoft Corporation, MIT licensed. The full license text is in
`Slnx.xsd.LICENSE` and applies to this file only.

It is bundled so the skill can validate offline and against a known, pinned version.
See [../references/xsd-gaps.md](../references/xsd-gaps.md) for where this schema disagrees
with the serializer, and for a one-liner that re-measures the gaps against current upstream.
