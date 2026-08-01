#!/usr/bin/env python3
"""One-time exact-base fix for Supplementary Figure S1 clipping."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "R" / "make_manuscript_figures.R"
EXPECTED_GIT_BLOB = "427a5f0c4fe37d9e396b4ecb8b0b074eb5270779"
OLD_PAR = '  par(mar = c(8.4, 4.2, 2.2, 0.5), xpd = NA)\n'
NEW_PAR = '  par(mar = c(8.4, 4.2, 2.2, 0.5), xpd = FALSE)\n'
OLD_LEGEND = '  abline(h = 0, lty = 3)\n  legend(\n'
NEW_LEGEND = '  abline(h = 0, lty = 3)\n  par(xpd = NA)\n  legend(\n'


def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()


def main() -> None:
    data = PATH.read_bytes()
    actual = git_blob_sha(data)
    if actual != EXPECTED_GIT_BLOB:
        raise SystemExit(
            f"Refusing stale S1 edit: expected Git blob {EXPECTED_GIT_BLOB}, found {actual}"
        )
    text = data.decode("utf-8")
    if text.count(OLD_PAR) != 1 or text.count(OLD_LEGEND) != 1:
        raise SystemExit("Expected exactly one S1 clipping anchor for each replacement")
    result = text.replace(OLD_PAR, NEW_PAR).replace(OLD_LEGEND, NEW_LEGEND).encode("utf-8")
    PATH.write_bytes(result)
    print(f"Fixed S1 clipping; SHA-256={hashlib.sha256(result).hexdigest()}")


if __name__ == "__main__":
    main()
