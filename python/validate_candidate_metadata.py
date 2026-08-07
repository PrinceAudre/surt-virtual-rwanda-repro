#!/usr/bin/env python3
"""Validate the SuRT-GeoHarmonizer SoftwareX version 1.3.0 candidate."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOFTWARE_NAME = "SuRT-GeoHarmonizer"
VERSION = "1.3.0"
BRANCH = "codex/softwarex-submission-v1.3.0"
RELEASE_TAG_URL = "https://github.com/PrinceAudre/surt-virtual-rwanda-repro/tree/v1.3.0"
HISTORICAL_VERSION = "1.2.0"
HISTORICAL_DOI = "10.5281/zenodo.21744708"
CONCEPT_DOI = "10.5281/zenodo.21671788"
VERSION_DOI = "10.5281/zenodo.21840177"
ORCID = "0009-0002-0799-3140"
EMAIL = "priplee@gmail.com"


class MetadataError(ValueError):
    """Raised when release-candidate metadata are incomplete or inconsistent."""


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        raise MetadataError(f"missing required file: {relative}")
    return path.read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise MetadataError(message)
    print(f"[PASS] {message}")


def yaml_value(text: str, key: str) -> str | None:
    match = re.search(rf"^{re.escape(key)}:\s*(.*?)\s*$", text, re.MULTILINE)
    return match.group(1).strip().strip("\"'") if match else None


def description_value(text: str, key: str) -> str | None:
    match = re.search(rf"^{re.escape(key)}:\s*(.*?)\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else None


def main() -> None:
    readme = read("README.md")
    citation = read("CITATION.cff")
    description = read("DESCRIPTION")
    changelog = read("CHANGELOG.md")
    manuscript = read("paper/manuscript.md")
    codemeta_text = read("codemeta.json")
    runner = read("python/run_all_checks.py")
    reproducibility = read("REPRODUCIBILITY.md")
    requirements = read("requirements-providers.txt")

    try:
        codemeta = json.loads(codemeta_text)
    except json.JSONDecodeError as exc:
        raise MetadataError(f"codemeta.json is invalid JSON: {exc}") from exc

    require(readme.startswith(f"# {SOFTWARE_NAME}\n"), "README starts with the software product name")
    require(SOFTWARE_NAME in citation, "CITATION.cff names the software product")
    require(SOFTWARE_NAME in manuscript, "manuscript names the software product")
    require(codemeta.get("name") == SOFTWARE_NAME, "CodeMeta name matches the product")

    require(description_value(description, "Version") == VERSION, f"DESCRIPTION version is {VERSION}")
    require(yaml_value(citation, "version") == VERSION, f"CITATION.cff version is {VERSION}")
    require(codemeta.get("version") == VERSION, f"CodeMeta version is {VERSION}")
    for label, text in {
        "README": readme,
        "CHANGELOG": changelog,
        "manuscript": manuscript,
        "REPRODUCIBILITY": reproducibility,
        "verification runner": runner,
    }.items():
        require(VERSION in text, f"{label} identifies version {VERSION}")

    for label, text in {
        "README": readme,
        "manuscript": manuscript,
        "REPRODUCIBILITY": reproducibility,
        "verification runner": runner,
    }.items():
        require(HISTORICAL_VERSION in text and HISTORICAL_DOI in text,
                f"{label} preserves immutable historical version {HISTORICAL_VERSION}")
    require(CONCEPT_DOI in readme and CONCEPT_DOI in manuscript and CONCEPT_DOI in runner,
            "concept DOI is consistent across candidate records")
    require(BRANCH in readme and BRANCH in runner,
            "SoftwareX candidate branch is identified in development-facing records")
    require(RELEASE_TAG_URL in manuscript,
            "manuscript records the immutable v1.3.0 release-tag URL")

    for label, text in {
        "README": readme,
        "CITATION.cff": citation,
        "manuscript": manuscript,
        "codemeta.json": codemeta_text,
        "verification runner": runner,
    }.items():
        require(VERSION_DOI in text, f"{label} records the reserved version-specific Zenodo DOI")

    for label, text in {
        "CITATION.cff": citation,
        "manuscript": manuscript,
        "codemeta.json": codemeta_text,
    }.items():
        require(ORCID in text, f"{label} contains the author ORCID")
        require(EMAIL in text, f"{label} contains the support or corresponding email")

    require(yaml_value(citation, "cff-version") == "1.2.0", "CITATION.cff uses schema 1.2.0")
    require(yaml_value(citation, "license") == "MIT", "CITATION.cff declares the MIT licence")
    require(yaml_value(citation, "doi") == VERSION_DOI, "CITATION.cff DOI matches the reserved v1.3.0 DOI")
    require(codemeta.get("license") == "https://spdx.org/licenses/MIT.html",
            "CodeMeta declares the MIT SPDX licence")
    require(codemeta.get("identifier") == f"https://doi.org/{VERSION_DOI}",
            "CodeMeta identifier matches the reserved v1.3.0 DOI")
    require(codemeta.get("codeRepository") == "https://github.com/PrinceAudre/surt-virtual-rwanda-repro",
            "CodeMeta repository is canonical")

    required_files = [
        "R/harmonize_admin_raster.R",
        "R/test_generic_harmonizer.R",
        "CONTRIBUTING.md",
        "codemeta.json",
        "requirements-providers.txt",
    ]
    for relative in required_files:
        require((ROOT / relative).is_file(), f"SoftwareX productization file exists: {relative}")

    require("cdsapi==0.7.7" in requirements, "Copernicus client is pinned")
    require("earthaccess==0.18.0" in requirements, "NASA Earthdata client is pinned")
    require("generic_administrative_harmonizer" in runner, "verification summary includes the generic interface")
    require('"total": sum(assertion_counts.values())' in runner, "verification total is calculated from named groups")
    require("48 explicit" in readme and "48 explicit" in manuscript,
            "README and manuscript report the current 48-outcome suite")

    active_release_facing = "\n".join([readme, citation, description, manuscript, codemeta_text, runner])
    for stale in (
        "Earth Science Informatics Software article",
        "Article type: Software article",
        "pre-DOI release freeze",
        '"version_doi": None',
        "pending DOI reservation",
        "1.2.0-dev",
        "1.2.0.9000",
    ):
        require(stale.casefold() not in active_release_facing.casefold(),
                f"stale active metadata token is absent: {stale}")

    require("Original Software Publication" in manuscript, "SoftwareX article type is declared")
    require("Independent Researcher, Kigali, Rwanda" in manuscript,
            "manuscript uses the truthful independent Rwanda affiliation")
    require("R/harmonize_admin_raster.R" in readme and "R/harmonize_admin_raster.R" in manuscript,
            "generic public interface is described in README and manuscript")
    require("DOI reserved; publish exact validated v1.3.0 tag" in runner,
            "verification evidence records the reserved-DOI release gate")
    require("TODO" not in active_release_facing and "TBD" not in active_release_facing,
            "active release-facing records contain no unresolved placeholders")

    print("\nSoftwareX version 1.3.0 candidate metadata validation passed.")


if __name__ == "__main__":
    try:
        main()
    except MetadataError as exc:
        raise SystemExit(f"SoftwareX candidate validation failed: {exc}") from exc
