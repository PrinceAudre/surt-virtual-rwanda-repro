#!/usr/bin/env python3
"""Run all account-free SuRT-GeoHarmonizer checks from any working directory."""

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
    """Run one gate, echo its complete output, and count explicit PASS records."""
    print(f"\n=== {label} ===", flush=True)
    started = time.perf_counter()
    completed = subprocess.run(
        command,
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    elapsed = time.perf_counter() - started
    output = completed.stdout or ""
    if output:
        print(output, end="" if output.endswith("\n") else "\n")
    if completed.returncode:
        raise SystemExit(f"{label} failed with exit code {completed.returncode}")
    pass_records = sum(line.lstrip().startswith("[PASS]") for line in output.splitlines())
    print(f"[TIME] {label}: {elapsed:.3f} seconds")
    return {
        "label": label,
        "command": command,
        "elapsed_seconds": round(elapsed, 6),
        "return_code": completed.returncode,
        "pass_records": pass_records,
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
        "pass_records": 1,
    }


def write_summary(steps: list[dict[str, Any]], total_seconds: float) -> Path:
    generated = ROOT / "generated"
    generated.mkdir(parents=True, exist_ok=True)
    output = generated / "verification_summary.json"
    pass_counts = {
        step["label"]: int(step.get("pass_records", 0))
        for step in steps
    }
    summary = {
        "schema_version": "1.4-dev",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "software": "SuRT-GeoHarmonizer",
        "repository": "PrinceAudre/surt-virtual-rwanda-repro",
        "published_baseline": {
            "version": "1.3.0",
            "git_tag": "v1.3.0",
            "zenodo_version_doi": "10.5281/zenodo.21840177",
            "zenodo_concept_doi": "10.5281/zenodo.21671788",
            "status": "immutable historical release",
        },
        "development": {
            "target_version": "1.4.0",
            "branch": "review/softwarex-resubmission-v1.4.0",
            "status": "SoftwareX peer-review remediation; not a release",
            "version_doi": None,
        },
        "integrity": {
            "scope": "complete tracked-file development scope",
            "manifest": "CHECKSUMS.sha256",
            "release_rule": (
                "Do not create v1.4.0 tag or Zenodo version DOI until reviewer remediation, "
                "independent validation, manuscript audit, and exact-commit release gates pass."
            ),
        },
        "status": "passed",
        "explicit_pass_records": {
            "by_step": pass_counts,
            "total": sum(pass_counts.values()),
            "definition": "Lines explicitly emitted as [PASS] by executable gates; derived at runtime.",
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
            "geometry-agnostic transformation fixture",
            [rscript, str(ROOT / "R" / "test_portability_fixture.R")],
        ),
        run(
            "generic administrative-unit harmonizer",
            [rscript, str(ROOT / "R" / "test_generic_harmonizer.R")],
        ),
        run(
            "spatial area weighting and valid-data coverage",
            [rscript, str(ROOT / "R" / "test_zonal_area_summary.R")],
        ),
        run(
            "ERA5 calendar-day annual temperature statistic",
            [rscript, str(ROOT / "R" / "test_temperature_annual_mean.R")],
        ),
        run(
            "HAND valid-area denominator and coverage",
            [rscript, str(ROOT / "R" / "test_hand_summary.R")],
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
            "complete tracked-file manifest consistency",
            [
                sys.executable,
                str(ROOT / "python" / "build_checksum_manifest.py"),
                "--all-tracked",
                "--check",
            ],
        ),
        run(
            "v1.4 peer-review remediation metadata consistency",
            [sys.executable, str(ROOT / "python" / "validate_resubmission_metadata.py")],
        ),
    ]
    print("\n=== listed-file integrity ===")
    steps.append(verify_listed_checksums())
    total_seconds = time.perf_counter() - started
    write_summary(steps, total_seconds)
    print(f"\nAll account-free checks passed in {total_seconds:.3f} seconds.")


if __name__ == "__main__":
    main()
