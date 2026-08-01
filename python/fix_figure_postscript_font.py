#!/usr/bin/env python3
"""One-time exact-base fix for the Figure 3 PostScript font declaration."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "R" / "make_manuscript_figures.R"
EXPECTED_GIT_BLOB = "d08c03638bafc0cc6d4e4f8a864a428ff7498f9b"
OLD = '    text(cx, 8.18, function_name, cex = 0.62, family = "mono")\n'
NEW = '    text(cx, 8.18, function_name, cex = 0.62)\n'


def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()


def main() -> None:
    data = PATH.read_bytes()
    actual = git_blob_sha(data)
    if actual != EXPECTED_GIT_BLOB:
        raise SystemExit(
            f"Refusing stale figure edit: expected Git blob {EXPECTED_GIT_BLOB}, found {actual}"
        )
    text = data.decode("utf-8")
    if text.count(OLD) != 1:
        raise SystemExit("Expected exactly one unsupported mono-family declaration")
    result = text.replace(OLD, NEW).encode("utf-8")
    PATH.write_bytes(result)
    print(f"Removed unsupported PostScript mono override; SHA-256={hashlib.sha256(result).hexdigest()}")


if __name__ == "__main__":
    main()
