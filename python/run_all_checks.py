#!/usr/bin/env python3
"""Run all account-free reproducibility checks from any working directory."""

from __future__ import annotations

import hashlib
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]


def run(label: str, command: list[str]) -> None:
    print(f"\n=== {label} ===", flush=True)
    completed = subprocess.run(command, cwd=ROOT, check=False)
    if completed.returncode:
        raise SystemExit(f"{label} failed with exit code {completed.returncode}")


def verify_checksums() -> None:
    manifest = ROOT / "CHECKSUMS.sha256"
    failures: list[str] = []
    checked = 0
    for raw in manifest.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        digest, relative = line.split(maxsplit=1)
        relative = relative.lstrip("*").strip().replace("\\", "/")
        path = ROOT / relative
        if not path.is_file():
            failures.append(f"missing: {relative}")
            continue
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        checked += 1
        if actual.lower() != digest.lower():
            failures.append(f"checksum mismatch: {relative}")
    if failures:
        raise SystemExit("Checksum verification failed:\n" + "\n".join(failures))
    print(f"[PASS] {checked} SHA-256 checksums verified")


def main() -> None:
    rscript = shutil.which("Rscript")
    if not rscript:
        raise SystemExit("Rscript is required but was not found on PATH")
    run("provenance labelling demonstration", [rscript, str(ROOT / "R" / "demo_value_class.R")])
    run("hermetic environmental fixture pipeline", [rscript, str(ROOT / "R" / "test_fixture_pipeline.R")])
    print("\n=== release integrity ===")
    verify_checksums()
    print("\nAll reproducibility checks passed.")


if __name__ == "__main__":
    main()
