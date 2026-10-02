#!/usr/bin/env python3
"""Build deterministic integrity evidence for the account-free Snakemake DAG."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True)
    parser.add_argument("paths", nargs="+")
    return parser.parse_args()


def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def display(path: Path) -> str:
    try:
        return path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return str(path.resolve())


def main() -> None:
    args = parse_args()
    artifacts = []
    for raw in args.paths:
        path = Path(raw)
        if not path.is_file():
            raise SystemExit(f"FAIL-CLOSED: workflow evidence input not found: {path}")
        artifacts.append({
            "path": display(path),
            "bytes": path.stat().st_size,
            "sha256": digest(path),
        })

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "schema_version": "1.0",
        "status": "passed",
        "evidence_class": "controlled-software-verification",
        "workflow_engine": "Snakemake",
        "workflow_requirement": "snakemake==9.27.0",
        "stages": [
            "acquire_controlled_fixture",
            "transform_provider_raster",
            "validate_declarative_config",
            "harmonize_administrative_units",
            "validate_harmonized_output",
            "build_workflow_evidence",
        ],
        "artifacts": artifacts,
        "limitation": (
            "This DAG uses deterministic synthetic fixtures to verify orchestration, contracts, "
            "failure visibility, and evidence construction. It is not independent numerical "
            "validation of CHIRPS, ERA5-Land, MODIS, HAND, or another provider product."
        ),
    }
    output.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"[PASS] workflow evidence covers {len(artifacts)} prerequisite artifacts")
    print(f"[WRITE] {output}")


if __name__ == "__main__":
    main()
