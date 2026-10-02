#!/usr/bin/env python3
"""Validate metadata invariants during the v1.4 peer-review remediation cycle.

This development gate intentionally does not require a v1.4 tag or DOI. Those are
release-time artifacts and must only be minted after the exact approved commit is
frozen. The immutable published v1.3.0 release remains the historical baseline.
"""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOFTWARE_NAME = "SuRT-GeoHarmonizer"
TARGET_VERSION = "1.4.0"
DEVELOPMENT_BRANCH = "review/softwarex-resubmission-v1.4.0"
PREVIOUS_VERSION = "1.3.0"
PREVIOUS_TAG = "v1.3.0"
PREVIOUS_DOI = "10.5281/zenodo.21840177"
CONCEPT_DOI = "10.5281/zenodo.21671788"


class MetadataError(ValueError):
    """Raised when development metadata violate a remediation invariant."""


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        raise MetadataError(f"missing required file: {relative}")
    return path.read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise MetadataError(message)
    print(f"[PASS] {message}")


def main() -> None:
    readme = read("README.md")
    manuscript = read("paper/manuscript.md")
    description = read("DESCRIPTION")
    runner = read("python/run_all_checks.py")
    checksum_builder = read("python/build_checksum_manifest.py")
    workflow = read(".github/workflows/softwarex-manifest-refresh.yml")

    require(SOFTWARE_NAME in readme, "README identifies SuRT-GeoHarmonizer")
    require(SOFTWARE_NAME in manuscript, "manuscript identifies SuRT-GeoHarmonizer")
    require(PREVIOUS_VERSION in readme or PREVIOUS_VERSION in manuscript,
            "historical v1.3.0 release remains documented")
    require(PREVIOUS_DOI in readme and PREVIOUS_DOI in manuscript,
            "published v1.3.0 Zenodo DOI remains documented")
    require(CONCEPT_DOI in readme and CONCEPT_DOI in manuscript,
            "Zenodo concept DOI remains documented")

    require((ROOT / "R" / "zonal_area_summary.R").is_file(),
            "reviewer-remediation zonal aggregation module exists")
    require((ROOT / "R" / "test_zonal_area_summary.R").is_file(),
            "reviewer-remediation spatial regression test exists")
    require("valid_data_fraction" in read("R/harmonize_admin_raster.R"),
            "generic interface exposes valid-data coverage")
    require("cellSize" in read("R/zonal_area_summary.R"),
            "generic area weighting uses explicit raster-cell surface area")
    require("min_valid_fraction" in read("R/harmonize_admin_raster.R"),
            "generic interface exposes a minimum valid-data fraction gate")

    require(DEVELOPMENT_BRANCH in workflow,
            "checksum refresh workflow targets the v1.4 remediation branch")
    require("--all-tracked" in workflow and "CHECKSUMS.sha256" in workflow,
            "development branch retains complete tracked-file checksum refresh")
    require("--all-tracked" in runner,
            "account-free runner checks the complete tracked-file manifest")
    require("review/softwarex-resubmission-v1.4.0" in runner,
            "verification summary identifies the v1.4 remediation branch")
    require(TARGET_VERSION in runner,
            "verification summary identifies v1.4.0 as the development target")
    require(PREVIOUS_DOI in runner,
            "verification summary preserves the immutable v1.3.0 DOI")

    # During remediation the DESCRIPTION/CFF/CodeMeta files may still identify the
    # last published release. They are moved to v1.4.0 only at the release freeze.
    require(f"Version: {PREVIOUS_VERSION}" in description or f"Version: {TARGET_VERSION}" in description,
            "DESCRIPTION identifies either the published baseline or the frozen v1.4.0 release")

    codemeta = json.loads(read("codemeta.json"))
    require(codemeta.get("name") == SOFTWARE_NAME, "CodeMeta product name remains canonical")
    require("all-tracked" in checksum_builder,
            "checksum builder supports the all-tracked integrity contract")

    forbidden = [
        "TODO_REVIEWER",
        "TBD_REVIEWER",
        "PLACEHOLDER_REVIEWER",
    ]
    active = "\n".join([readme, manuscript, runner, read("R/harmonize_admin_raster.R")])
    for token in forbidden:
        require(token not in active, f"reviewer placeholder token is absent: {token}")

    print("\nv1.4 peer-review remediation metadata validation passed.")


if __name__ == "__main__":
    try:
        main()
    except (MetadataError, json.JSONDecodeError) as exc:
        raise SystemExit(f"v1.4 remediation metadata validation failed: {exc}") from exc
