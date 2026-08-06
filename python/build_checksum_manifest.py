#!/usr/bin/env python3
"""Build or verify the repository SHA-256 manifest.

The default mode reads CHECKSUMS.scope, retained as a historical development
scope. Versioned release verification uses --all-tracked so that every tracked
file, except the manifest itself, is included in the frozen release archive.
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SCOPE = ROOT / "CHECKSUMS.scope"
DEFAULT_MANIFEST = ROOT / "CHECKSUMS.sha256"


def normalized_relative(path: Path) -> str:
    try:
        relative = path.resolve().relative_to(ROOT.resolve())
    except ValueError as exc:
        raise SystemExit(f"Path is outside repository root: {path}") from exc
    return relative.as_posix()


def read_scope(path: Path) -> list[str]:
    if not path.is_file():
        raise SystemExit(f"Checksum scope file not found: {path}")
    entries: list[str] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        relative = normalized_relative(ROOT / line)
        if relative in entries:
            raise SystemExit(f"Duplicate checksum-scope entry: {relative}")
        entries.append(relative)
    if not entries:
        raise SystemExit("Checksum scope is empty")
    return sorted(entries, key=str.casefold)


def tracked_files() -> list[str]:
    completed = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if completed.returncode:
        raise SystemExit(
            "git ls-files failed: "
            + completed.stderr.decode("utf-8", errors="replace").strip()
        )
    entries = [
        item.decode("utf-8")
        for item in completed.stdout.split(b"\0")
        if item
    ]
    excluded = {
        "CHECKSUMS.sha256",
    }
    result = sorted(
        (entry.replace("\\", "/") for entry in entries if entry not in excluded),
        key=str.casefold,
    )
    if not result:
        raise SystemExit("No tracked files found")
    return result


def digest_file(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        raise SystemExit(f"Checksum input is missing or not a file: {relative}")
    return hashlib.sha256(path.read_bytes()).hexdigest()


def render(entries: list[str], mode: str) -> str:
    if mode == "all-tracked":
        scope_text = (
            "complete tracked-file release scope generated with "
            "--all-tracked"
        )
    else:
        scope_text = "interim stable-file scope defined in CHECKSUMS.scope"
    header = [
        "# SHA-256 checksums for SuRT-GeoHarmonizer.",
        f"# Scope: {scope_text}.",
        "# Verify release: python python/build_checksum_manifest.py --all-tracked --check",
        "# Rebuild release: python python/build_checksum_manifest.py --all-tracked --write",
    ]
    rows = [f"{digest_file(relative)}  {relative}" for relative in entries]
    return "\n".join(header + rows) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--scope",
        type=Path,
        default=DEFAULT_SCOPE,
        help="Path to interim scope file (default: CHECKSUMS.scope).",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=DEFAULT_MANIFEST,
        help="Manifest path (default: CHECKSUMS.sha256).",
    )
    parser.add_argument(
        "--all-tracked",
        action="store_true",
        help="Hash every Git-tracked file except CHECKSUMS.sha256.",
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument(
        "--check",
        action="store_true",
        help="Fail unless the manifest exactly matches the selected scope.",
    )
    mode.add_argument(
        "--write",
        action="store_true",
        help="Write the selected manifest.",
    )
    args = parser.parse_args()

    entries = tracked_files() if args.all_tracked else read_scope(args.scope)
    expected = render(entries, "all-tracked" if args.all_tracked else "scope")
    manifest = args.manifest.resolve()

    if args.write:
        manifest.write_text(expected, encoding="utf-8", newline="\n")
        print(
            f"[WRITE] {normalized_relative(manifest)}: "
            f"{len(entries)} SHA-256 entries"
        )
        return

    if not manifest.is_file():
        raise SystemExit(f"Manifest not found: {manifest}")
    actual = manifest.read_text(encoding="utf-8")
    if actual != expected:
        raise SystemExit(
            "Checksum manifest is out of date for the selected scope. "
            "Rebuild it with --write."
        )
    print(
        f"[PASS] {normalized_relative(manifest)} matches the selected scope "
        f"({len(entries)} files)"
    )


if __name__ == "__main__":
    main()
