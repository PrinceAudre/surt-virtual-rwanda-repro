#!/usr/bin/env python3
"""Run all account-free reproducibility checks from any working directory."""

from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import time
from typing import Any


ROOT = Path(__file__).resolve().parents[1]


def run(label: str, command: list[str]) -> dict[str, Any]:
    print(f"\n=== {label} ===", flush=True)
    started = time.perf_counter()
    completed = subprocess.run(command, cwd=ROOT, check=False)
    elapsed = time.perf_counter() - started
    if completed.returncode:
        raise SystemExit(f"{label} failed with exit code {completed.returncode}")
    print(f"[TIME] {label}: {elapsed:.3f} seconds")
    return {
        "label": label,
        "command": command,
        "elapsed_seconds": round(elapsed, 6),
        "return_code": completed.returncode,
    }


def verify_listed_checksums() -> dict[str, Any]:
    """Verify every file explicitly listed in CHECKSUMS.sha256."""
    started = time.perf_counter()
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
            failures.append(
                f"checksum mismatch: {relative} "
                f"(expected {digest.lower()}, actual {actual.lower()})"
            )
    elapsed = time.perf_counter() - started
    if failures:
        raise SystemExit("Listed-file checksum verification failed:\n" + "\n".join(failures))
    print(f"[PASS] {checked} listed SHA-256 checksums verified")
    print(f"[TIME] listed-file integrity: {elapsed:.3f} seconds")
    return {
        "label": "listed-file integrity",
        "checked_files": checked,
        "elapsed_seconds": round(elapsed, 6),
        "return_code": 0,
    }


def write_summary(steps: list[dict[str, Any]], total_seconds: float) -> Path:
    generated = ROOT / "generated"
    generated.mkdir(parents=True, exist_ok=True)
    output = generated / "verification_summary.json"
    assertion_counts = {
        "provenance": 9,
        "environmental_fixture": 9,
        "geometry_agnostic_portability_fixture": 6,
        "transformation_failure_injection": 7,
        "release_layer_contracts": 5,
        "release_contract_corruptions_rejected": 5,
    }
    summary = {
        "schema_version": "1.2",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "repository": "PrinceAudre/surt-virtual-rwanda-repro",
        "published_base_archive": {
            "version": "1.1.1",
            "zenodo_doi": "10.5281/zenodo.21677162",
        },
        "working_package": {
            "version": "1.2.0.9000",
            "status": "unreleased Earth Science Informatics journal candidate",
            "version_doi": None,
        },
        "integrity": {
            "scope": "interim stable files listed in CHECKSUMS.scope",
            "manifest": "CHECKSUMS.sha256",
            "final_release_requirement": "regenerate with --all-tracked",
        },
        "status": "passed",
        "assertions": {
            **assertion_counts,
            "total": sum(assertion_counts.values()),
        },
        "environment": {
            "python": sys.version.split()[0],
            "platform": platform.platform(),
            "machine": platform.machine(),
        },
        "steps": steps,
        "total_elapsed_seconds": round(total_seconds, 6),
    }
    output.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(f"[WRITE] {output.relative_to(ROOT)}")
    return output


def main() -> None:
    rscript = shutil.which("Rscript")
    if not rscript:
        raise SystemExit("Rscript is required but was not found on PATH")

    started = time.perf_counter()
    steps = [
        run(
            "provenance labelling demonstration",
            [rscript, str(ROOT / "R" / "demo_value_class.R")],
        ),
        run(
            "hermetic environmental fixture pipeline",
            [rscript, str(ROOT / "R" / "test_fixture_pipeline.R")],
        ),
        run(
            "geometry-agnostic portability fixture",
            [rscript, str(ROOT / "R" / "test_portability_fixture.R")],
        ),
        run(
            "transformation failure injection",
            [rscript, str(ROOT / "R" / "test_failure_modes.R")],
        ),
        run(
            "GeoJSON release contract and corruption rejection",
            [sys.executable, str(ROOT / "python" / "validate_release_contract.py")],
        ),
        run(
            "checksum scope and manifest consistency",
            [
                sys.executable,
                str(ROOT / "python" / "build_checksum_manifest.py"),
                "--check",
            ],
        ),
        run(
            "candidate metadata and submission-package consistency",
            [sys.executable, str(ROOT / "python" / "validate_candidate_metadata.py")],
        ),
    ]
    print("\n=== listed-file integrity ===")
    steps.append(verify_listed_checksums())
    total_seconds = time.perf_counter() - started
    write_summary(steps, total_seconds)
    print(f"\nAll account-free checks passed in {total_seconds:.3f} seconds.")


if __name__ == "__main__":
    main()
