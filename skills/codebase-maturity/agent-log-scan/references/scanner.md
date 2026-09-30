# Scanner

A corpus is hundreds of megabytes; the lesson it carries fits on a page.

- `scripts/agentlog.py` is Python 3 stdlib, streaming, deterministic. Never open or `cat` a `.jsonl`: one line can be a 5 MB base64 image and one file can be 100 MB+.
- Privacy default: the scanner emits signatures, counts, tool names, and `file:line @offset` only. `--show-text` (snippets <=160 chars) is opt-in, and only when the human asked for text.
- Drill down by coordinates, not by reading: `slice <file> <line> --around K` prints K one-line node summaries either side of a finding; `bisect <file>` reports the top cohesion boundaries of one session with byte offsets, so you jump O(1) into the middle of a huge session and divide and conquer instead of reading forward.
- Exit code 2 means the detectors (retry-loop, permission-thrash, api-dead-end, limit-interrupt) found antipatterns, so CI and scripts can gate on it. Exit 0 is a clean corpus; exit 1 is bad usage/paths.
