#!/usr/bin/env python3
"""Validate the final version 1.2.0 DOI-bearing release metadata."""

from __future__ import annotations

import re
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_TITLE = (
    "An auditable cross-provider workflow for district-scale Earth-data "
    "harmonization and provenance labelling: software design and a Rwanda "
    "implementation"
)
VERSION = "1.2.0"
RELEASE_DOI = "10.5281/zenodo.21744708"
RELEASE_DATE = "2026-08-01"
RELEASE_TAG = "v1.2.0"
BASE_VERSION = "1.1.1"
BASE_DOI = "10.5281/zenodo.21677162"
ORCID = "0009-0002-0799-3140"

class MetadataError(ValueError):
    """Raised when release metadata are incomplete or inconsistent."""

def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        raise MetadataError(f"missing required metadata file: {relative}")
    return path.read_text(encoding="utf-8")

def require(condition: bool, message: str) -> None:
    if not condition:
        raise MetadataError(message)
    print(f"[PASS] {message}")

def top_level_yaml_value(text: str, key: str) -> str | None:
    match = re.search(rf"^{re.escape(key)}:\s*(.*?)\s*$", text, re.MULTILINE)
    return match.group(1).strip().strip("\"'") if match else None

def description_value(text: str, key: str) -> str | None:
    match = re.search(rf"^{re.escape(key)}:\s*(.*?)\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else None

def manuscript_abstract(manuscript: str) -> str:
    match = re.search(
        r"^## Abstract\s*\n+(.*?)\n+\*\*Keywords:\*\*",
        manuscript,
        flags=re.MULTILINE | re.DOTALL,
    )
    if not match:
        raise MetadataError("manuscript abstract or keyword boundary is missing")
    return re.sub(r"\s+", " ", match.group(1)).strip()

def manuscript_keywords(manuscript: str) -> list[str]:
    match = re.search(r"^\*\*Keywords:\*\*\s*(.+)$", manuscript, re.MULTILINE)
    if not match:
        raise MetadataError("manuscript keyword line is missing")
    return [item.strip() for item in match.group(1).split(";") if item.strip()]

def word_count(text: str) -> int:
    return len(re.findall(r"\b[\w][\w’'\-]*\b", text, flags=re.UNICODE))

def tracked_paths() -> list[str]:
    completed = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if completed.returncode:
        raise MetadataError(
            "git ls-files failed: "
            + completed.stderr.decode("utf-8", errors="replace").strip()
        )
    return [
        item.decode("utf-8").replace("\\", "/")
        for item in completed.stdout.split(b"\0")
        if item
    ]

def main() -> None:
    manuscript = read("paper/manuscript.md")
    readme = read("README.md")
    citation = read("CITATION.cff")
    description = read("DESCRIPTION")
    changelog = read("CHANGELOG.md")

    require(manuscript.startswith(f"# {EXPECTED_TITLE}\n"), "manuscript title matches the designated release title")
    require(EXPECTED_TITLE in readme, "README names the same manuscript")
    require(description_value(description, "Version") == VERSION, f"DESCRIPTION version is {VERSION}")
    require(top_level_yaml_value(citation, "version") == VERSION, f"CITATION.cff version is {VERSION}")
    require(top_level_yaml_value(citation, "cff-version") == "1.2.0", "CITATION.cff declares schema version 1.2.0")
    require(top_level_yaml_value(citation, "doi") == RELEASE_DOI, f"CITATION.cff DOI is {RELEASE_DOI}")
    require(top_level_yaml_value(citation, "date-released") == RELEASE_DATE, f"CITATION.cff release date is {RELEASE_DATE}")

    for label, text in {
        "README": readme,
        "manuscript": manuscript,
        "CITATION.cff": citation,
        "CHANGELOG": changelog,
    }.items():
        require(VERSION in text and RELEASE_DOI in text, f"{label} identifies version {VERSION} and its DOI")
        require(BASE_VERSION in text and BASE_DOI in text, f"{label} preserves the historical base version and DOI")

    require(RELEASE_TAG in readme, "README identifies the exact release tag")
    require(RELEASE_TAG in manuscript, "manuscript identifies the exact release tag")
    require(ORCID in manuscript, "manuscript contains the designated ORCID")
    require(ORCID in citation, "CITATION.cff contains the designated ORCID")

    abstract_words = word_count(manuscript_abstract(manuscript))
    require(150 <= abstract_words <= 250, f"abstract length is within 150 to 250 words ({abstract_words})")
    keywords = manuscript_keywords(manuscript)
    require(4 <= len(keywords) <= 6, f"manuscript contains four to six keywords ({len(keywords)})")
    require(len({keyword.casefold() for keyword in keywords}) == len(keywords), "manuscript keywords are unique")

    paths = tracked_paths()
    forbidden_active_paths = [
        path for path in paths
        if "f1000" in path.casefold() and not path.startswith("paper/archive/")
    ]
    require(not forbidden_active_paths, "no active tracked path is specific to the historical F1000 submission")
    active_submission_files = [path for path in paths if path.startswith("paper/submission/")]
    require(not active_submission_files, "active submission directory is empty until the Earth Science Informatics build")

    release_facing = "\n".join([citation, description, readme, changelog, manuscript])
    for stale in ("pre-DOI", "pending DOI reservation", "not yet reserved", "1.2.0-dev", "1.2.0.9000"):
        require(stale.casefold() not in release_facing.casefold(), f"stale release token is absent: {stale}")

    doi_url = f"https://doi.org/{RELEASE_DOI}"
    require(doi_url in readme and doi_url in manuscript, "README and manuscript use the release DOI URL")
    require("archived" in manuscript.casefold() and RELEASE_DOI in manuscript, "manuscript identifies the immutable release archive")

    print("\nVersion 1.2.0 DOI-bearing release metadata validation passed.")

if __name__ == "__main__":
    try:
        main()
    except MetadataError as exc:
        raise SystemExit(f"Release metadata validation failed: {exc}") from exc
