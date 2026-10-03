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
MANUSCRIPT_ID = "SOFTX-D-26-01014"


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
    require(DEVELOPMENT_BRANCH in runner,
            "verification summary identifies the v1.4 remediation branch")
    require(TARGET_VERSION in runner,
            "verification summary identifies v1.4.0 as the development target")
    require(PREVIOUS_DOI in runner,
            "verification summary preserves the immutable v1.3.0 DOI")

    # During remediation the DESCRIPTION/CFF/CodeMeta files may still identify the
    # last published release. They are moved to v1.4.0 only at the release freeze.
    release_is_frozen = f"Version: {TARGET_VERSION}" in description
    require(f"Version: {PREVIOUS_VERSION}" in description or release_is_frozen,
            "DESCRIPTION identifies either the published baseline or the frozen v1.4.0 release")

    codemeta = json.loads(read("codemeta.json"))
    require(codemeta.get("name") == SOFTWARE_NAME, "CodeMeta product name remains canonical")
    require("all-tracked" in checksum_builder,
            "checksum builder supports the all-tracked integrity contract")

    # Historical submission records remain in-tree for auditability. Any non-archive
    # paper document that still contains an earlier journal-targeting declaration
    # must be explicitly bannered as superseded so it cannot be mistaken for the
    # active SoftwareX submission state.
    stale_target_markers = (
        "Primary target: Earth Science Informatics",
        "Manuscript target:** Earth Science Informatics",
        "Suggested reviewers for Earth Science Informatics",
        "Scope:** active Earth Science Informatics manuscript",
    )
    paper_root = ROOT / "paper"
    stale_unbannered: list[str] = []
    for path in sorted(paper_root.rglob("*.md")):
        if "archive" in path.relative_to(paper_root).parts:
            continue
        text = path.read_text(encoding="utf-8")
        if any(marker in text for marker in stale_target_markers):
            if "Superseded." not in text[:800]:
                stale_unbannered.append(path.relative_to(ROOT).as_posix())
    require(
        not stale_unbannered,
        "legacy non-SoftwareX targeting records are explicitly marked superseded"
        + (f" ({', '.join(stale_unbannered)})" if stale_unbannered else ""),
    )

    # Submission-facing sources previously survived a journal cycle with stale
    # release identity and an incorrect statement that external peer review had not
    # occurred. Lock those regressions out of the active branch.
    cover = read("paper/submission/cover_letter.md")
    submission_readme = read("paper/submission/README.md")
    submission_checklist = read("paper/submission/SOFTWAREX_SUBMISSION_CHECKLIST.md")
    highlights = [line.strip() for line in read("paper/submission/highlights.txt").splitlines() if line.strip()]
    submission_material = "\n".join([cover, submission_readme, submission_checklist])

    require(MANUSCRIPT_ID in cover,
            "cover letter identifies the externally reviewed SoftwareX manuscript")
    require("external peer review" in cover.casefold(),
            "cover letter discloses prior external peer review")
    require("has not undergone external peer review" not in cover.casefold(),
            "false pre-review cover-letter claim is absent")
    require(TARGET_VERSION in cover and TARGET_VERSION in submission_readme and TARGET_VERSION in submission_checklist,
            "submission sources identify v1.4.0 as the reviewer-remediated target")
    require("exact validated version `1.3.0` release" not in submission_material,
            "submission sources do not present v1.3.0 as the rebuilt submission release")
    require("48 explicit behavioural" not in submission_material,
            "stale hard-coded verification total is absent from submission sources")
    require("Only CHIRPS is claimed" not in submission_material,
            "submission sources do not retain the superseded CHIRPS-only validation claim")
    if not release_is_frozen:
        require("DO NOT SUBMIT" in cover,
                "unreleased v1.4.0 cover letter is fail-closed with a do-not-submit banner")

    require(len(highlights) == 5, "exactly five SoftwareX highlights are supplied")
    require(all(len(line) <= 85 for line in highlights),
            "every SoftwareX highlight is at most 85 characters")
    require(any("Uganda CHIRPS" in line for line in highlights),
            "highlights include demonstrated second-country reuse")
    require(any("ERA5-Land" in line and "MODIS" in line and "HAND" in line for line in highlights),
            "highlights represent the scoped multi-product cross-check evidence")

    forbidden = [
        "TODO_REVIEWER",
        "TBD_REVIEWER",
        "PLACEHOLDER_REVIEWER",
    ]
    active = "\n".join([readme, manuscript, runner, read("R/harmonize_admin_raster.R"), submission_material])
    for token in forbidden:
        require(token not in active, f"reviewer placeholder token is absent: {token}")

    print("\nv1.4 peer-review remediation metadata validation passed.")


if __name__ == "__main__":
    try:
        main()
    except (MetadataError, json.JSONDecodeError) as exc:
        raise SystemExit(f"v1.4 remediation metadata validation failed: {exc}") from exc
