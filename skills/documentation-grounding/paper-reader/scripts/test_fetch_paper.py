#!/usr/bin/env python3
"""Self-test: an arXiv e-print is author-uploaded, so fetch_arxiv_files must
not let a tar member write outside <paper>/source/.

The fixture tarball carries `../escaped.txt`, a symlink to `/` and one
legitimate `main.tex`; downloads are replaced by local copies.

Run: python3 test_fetch_paper.py       (exit 0 = pass, 1 = fail)
Stdlib only, no network.
"""

import io
import shutil
import sys
import tarfile
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import fetch_paper  # noqa: E402

_failures = []


def check(name, cond, detail=""):
    if cond:
        print("ok   %s" % name)
    else:
        _failures.append(name)
        print("FAIL %s %s" % (name, detail))


def build_eprint(path: Path) -> None:
    with tarfile.open(path, "w:gz") as tf:
        for name, data in (("../escaped.txt", b"x"),
                           ("main.tex", b"\\documentclass{article}")):
            info = tarfile.TarInfo(name)
            info.size = len(data)
            tf.addfile(info, io.BytesIO(data))
        link = tarfile.TarInfo("root-link")
        link.type = tarfile.SYMTYPE
        link.linkname = "/"
        tf.addfile(link)


def main() -> int:
    root = Path(tempfile.mkdtemp(prefix="paper-reader-fixture-"))
    try:
        eprint = root / "eprint.tar.gz"
        build_eprint(eprint)

        def fake_download(url, dest, timeout=60):
            if url.endswith(".pdf"):
                Path(dest).write_bytes(b"%PDF-1.4")
            else:
                shutil.copyfile(eprint, dest)

        fetch_paper._http_download = fake_download
        paper = root / "library" / "paper"
        paper.mkdir(parents=True)
        fetch_paper.fetch_arxiv_files("1706.03762", paper)

        source = paper / "source"
        check("legitimate member extracted", (source / "main.tex").is_file())
        check("../ member stays out of the paper dir",
              not (paper / "escaped.txt").exists())
        check("symlink member skipped",
              not (source / "root-link").is_symlink())
    finally:
        shutil.rmtree(root, ignore_errors=True)

    if _failures:
        print("%d check(s) FAILED" % len(_failures))
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
