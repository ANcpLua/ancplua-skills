#!/usr/bin/env python3
"""Privacy self-test for the `agentlog.py scan` and `slice` subcommands.

Without --show-text the scanner prints only signatures, counts, tool names
and coordinates. A signature is derived from the error text of a failed
tool result, so it must not carry the identities or credentials in that
text: this fixture's only error names an e-mail address and a GitHub
token, and neither may appear in scan (md and json) or slice output.

Run: python3 test_scan.py              (exit 0 = pass, 1 = fail)
Stdlib only, no network, no reads outside its own temp dir.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
AGENTLOG = os.path.join(HERE, "agentlog.py")

EMAIL = "alice.smith@example.com"
TOKEN = "ghp_AbCdEfGhIjKlMnOpQrStUvWxYz0123456789"


def jline(obj):
    return json.dumps(obj) + "\n"


def build_fixture(root):
    path = os.path.join(root, "session.jsonl")
    with open(path, "w") as f:
        f.write(jline({
            "type": "assistant", "timestamp": "2026-09-30T10:00:00Z",
            "message": {"role": "assistant", "content": [
                {"type": "tool_use", "id": "t1", "name": "Bash",
                 "input": {}}]},
        }))
        f.write(jline({
            "type": "user", "timestamp": "2026-09-30T10:00:01Z",
            "message": {"role": "user", "content": [
                {"type": "tool_result", "tool_use_id": "t1",
                 "is_error": True,
                 "content": "Error: auth failed for %s token=%s"
                            % (EMAIL, TOKEN)}]},
        }))
    return path


_failures = []


def check(name, cond, detail=""):
    if cond:
        print("ok   %s" % name)
    else:
        _failures.append(name)
        print("FAIL %s %s" % (name, detail))


def run(args):
    proc = subprocess.run(
        [sys.executable, AGENTLOG] + args,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return proc.returncode, proc.stdout.decode("utf-8", "replace")


def main():
    root = tempfile.mkdtemp(prefix="agentlog-scan-fixture-")
    try:
        session = build_fixture(root)
        outputs = {
            "scan md": run(["scan", session]),
            "scan json": run(["scan", session, "--json"]),
            "slice": run(["slice", session, "2", "--around", "1"]),
        }
        rc, md = outputs["scan md"]
        check("scan exit 2 (api-dead-end found)", rc == 2, str(rc))
        check("signature still clusters the error",
              "Error: auth failed for <email> token=<secret>" in md,
              md)
        for name, (_rc, out) in sorted(outputs.items()):
            check("privacy: %s hides the e-mail" % name, EMAIL not in out)
            check("privacy: %s hides the token" % name,
                  TOKEN[:12] not in out)
    finally:
        shutil.rmtree(root, ignore_errors=True)

    if _failures:
        print("%d check(s) FAILED" % len(_failures))
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
