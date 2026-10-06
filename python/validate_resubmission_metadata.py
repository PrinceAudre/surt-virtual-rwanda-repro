#!/usr/bin/env python3
"""Validate metadata invariants during the v1.4 Array transfer and remediation cycle.

This gate supports both remediation and the DOI-bearing v1.4 release freeze. The
reserved release DOI is validated before tagging and archival publication. The
immutable published v1.3.0 release remains the historical baseline.
"""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOFTWARE_NAME = "SuRT-GeoHarmonizer"
TARGET_VERSION = "1.4.0"
DEVELOPMENT_BRANCH = "review/softwarex-resubmission-v1.4.0"
PREVIOUS_VERSION = "1.3.0"
PREVIOUS_TAG = "v1.3.0"
PREVIOUS_DOI = "10.5281/zenodo.21840177"
CONCEPT_DOI = "10.5281/zenodo.21671788"
RELEASE_DOI = "10.5281/zenodo.23162055"
MANUSCRIPT_ID = "SOFTX-D-26-01014"
TARGET_JOURNAL = "Array"
ACTIVE_TITLE = "SuRT-GeoHarmonizer: A contract-first workflow for verifiable raster-to-administrative data harmonization"
CURRENT_AFFILIATION = (
    "School of Public Health, College of Medicine and Health Sciences, "
    "University of Rwanda, Kigali, Rwanda"
)


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
    manuscript = read("paper/array-manuscript.md")
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
    require(CURRENT_AFFILIATION in manuscript,
            "manuscript uses the author's current University of Rwanda affiliation")

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

    citation = read("CITATION.cff")
    codemeta_text = read("codemeta.json")
    codemeta = json.loads(codemeta_text)
    require(codemeta.get("name") == SOFTWARE_NAME, "CodeMeta product name remains canonical")
    require("all-tracked" in checksum_builder,
            "checksum builder supports the all-tracked integrity contract")
    if release_is_frozen:
        require(CURRENT_AFFILIATION in citation and "University of Rwanda" in codemeta_text,
                "frozen v1.4 release metadata uses the current University of Rwanda affiliation")
        require(f"version: {TARGET_VERSION}" in citation and f"doi: {RELEASE_DOI}" in citation,
                "CITATION.cff binds v1.4.0 to the reserved release DOI")
        require(codemeta.get("version") == TARGET_VERSION and RELEASE_DOI in codemeta.get("identifier", ""),
                "CodeMeta binds v1.4.0 to the reserved release DOI")
        require(all(RELEASE_DOI in text for text in (readme, manuscript, runner)),
                "README, manuscript, and verification summary share the reserved v1.4.0 DOI")
    else:
        require(PREVIOUS_VERSION in citation and PREVIOUS_VERSION in codemeta_text,
                "development tree preserves immutable v1.3 metadata until the v1.4 release freeze")

    # Historical submission records remain in-tree for auditability. Any non-archive
    # paper document that still contains an earlier journal-targeting declaration
    # must be explicitly bannered as superseded so it cannot be mistaken for the
    # active Array submission state.
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
        "legacy non-Array targeting records are explicitly marked superseded"
        + (f" ({', '.join(stale_unbannered)})" if stale_unbannered else ""),
    )

    # Final review must be tool-independent. Historical Claude review files may be
    # retained as explicitly superseded audit records, but no active release gate may
    # depend on them.
    require((ROOT / "paper" / "FINAL_REVIEW_PROTOCOL.md").is_file(),
            "active evidence-led final-review protocol exists")
    require(not (ROOT / "paper" / "CLAUDE_FABLE5_SOFTWAREX_FINAL_PROMPT.md").exists(),
            "active Claude-dependent final-review prompt has been retired")

    # Submission-facing sources previously survived a journal cycle with stale
    # release identity and an incorrect statement that external peer review had not
    # occurred. Lock those regressions out of the active branch.
    cover = read("paper/submission/cover_letter.md")
    submission_readme = read("paper/submission/README.md")
    submission_checklist = read("paper/submission/ARRAY_SUBMISSION_CHECKLIST.md")
    em_entry_sheet = read("paper/submission/ARRAY_EDITORIAL_MANAGER_ENTRY_SHEET.md")
    highlights = [line.strip() for line in read("paper/submission/highlights.txt").splitlines() if line.strip()]
    submission_material = "\n".join([cover, submission_readme, submission_checklist, em_entry_sheet])

    require(MANUSCRIPT_ID in cover,
            "cover letter identifies the externally reviewed SoftwareX manuscript provenance")
    require("external peer review" in cover.casefold(),
            "cover letter discloses prior external peer review")
    require(TARGET_JOURNAL in cover and TARGET_JOURNAL in submission_readme and TARGET_JOURNAL in submission_checklist,
            "submission-facing sources target Array")
    require(ACTIVE_TITLE in cover and ACTIVE_TITLE in submission_readme and ACTIVE_TITLE in submission_checklist,
            "submission-facing sources use the active Array title")
    require("An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling" not in cover,
            "cover letter does not retain the transferred SoftwareX title as the active title")
    require("has not undergone external peer review" not in cover.casefold(),
            "false pre-review cover-letter claim is absent")
    require(CURRENT_AFFILIATION in submission_checklist,
            "submission checklist records the current University of Rwanda affiliation")
    require(ACTIVE_TITLE in em_entry_sheet,
            "Editorial Manager entry sheet uses the active Array title")
    require("TUYISHIME AUDRE PRINCE" in em_entry_sheet and
            "priplee@gmail.com" in em_entry_sheet and
            "0009-0002-0799-3140" in em_entry_sheet and
            CURRENT_AFFILIATION in em_entry_sheet,
            "Editorial Manager entry sheet matches the finalized author identity")
    require(RELEASE_DOI in em_entry_sheet and CONCEPT_DOI in em_entry_sheet,
            "Editorial Manager entry sheet uses the released Zenodo identifiers")
    require("49a87472c3581b6f1912cde97c900ec3dbd17335" in em_entry_sheet,
            "Editorial Manager entry sheet binds the immutable v1.4.0 commit")
    require("Regular Paper" in em_entry_sheet and "Technical Note" in em_entry_sheet,
            "Editorial Manager entry sheet records the bounded article-type decision")
    require("explicit owner approval" in em_entry_sheet.casefold() and
            "Approve Submission" in em_entry_sheet,
            "Editorial Manager entry sheet preserves the final owner-approval gate")
    require("University of Rwanda" in cover and "affiliation has changed" in cover,
            "cover letter transparently explains the changed affiliation")
    require(TARGET_VERSION in cover and TARGET_VERSION in submission_readme and TARGET_VERSION in submission_checklist,
            "submission sources identify v1.4.0 as the reviewer-remediated target")
    if release_is_frozen:
        require(all(RELEASE_DOI in text for text in (cover, submission_readme, submission_checklist)),
                "submission sources share the reserved v1.4.0 DOI")
    require("exact validated version `1.3.0` release" not in submission_material,
            "submission sources do not present v1.3.0 as the rebuilt submission release")
    require("48 explicit behavioural" not in submission_material,
            "stale hard-coded verification total is absent from submission sources")
    require("Only CHIRPS is claimed" not in submission_material,
            "submission sources do not retain the superseded CHIRPS-only validation claim")
    if not release_is_frozen:
        require("DO NOT SUBMIT" in cover,
                "unreleased v1.4.0 cover letter is fail-closed with a do-not-submit banner")

    require(len(highlights) == 5, "exactly five Array highlights are supplied")
    require(all(len(line) <= 85 for line in highlights),
            "every Array highlight is at most 85 characters")
    require(any("Uganda" in line and "Rwanda" in line for line in highlights),
            "highlights include demonstrated second-country reuse")
    require(any("Climate" in line and "terrain" in line and "independent" in line for line in highlights),
            "highlights represent independent environmental cross-check evidence")
    require(not any(re.search(r"\b[A-Z]{2,}\b", line) for line in highlights),
            "highlights avoid all-caps acronyms for a general audience")

    forbidden = [
        "TODO_REVIEWER",
        "TBD_REVIEWER",
        "PLACEHOLDER_REVIEWER",
    ]
    active = "\n".join([readme, manuscript, runner, read("R/harmonize_admin_raster.R"), submission_material])
    for token in forbidden:
        require(token not in active, f"reviewer placeholder token is absent: {token}")

    print("\nv1.4 Array transfer metadata validation passed.")


if __name__ == "__main__":
    try:
        main()
    except (MetadataError, json.JSONDecodeError) as exc:
        raise SystemExit(f"v1.4 Array transfer metadata validation failed: {exc}") from exc
