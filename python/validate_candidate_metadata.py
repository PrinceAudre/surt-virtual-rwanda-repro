#!/usr/bin/env python3
"""Validate the version 1.2.0 pre-DOI release freeze and package consistency."""

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
EXPECTED_DESCRIPTION_VERSION = "1.2.0"
EXPECTED_CFF_VERSION = "1.2.0"
BASE_VERSION = "1.1.1"
BASE_DOI = "10.5281/zenodo.21677162"
BRANCH = "codex/earth-science-informatics-refinement-v1.3.0"
ORCID = "0009-0002-0799-3140"


class MetadataError(ValueError):
    """Raised when candidate metadata are incomplete or inconsistent."""


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
    pattern = re.compile(rf"^{re.escape(key)}:\s*(.*?)\s*$", re.MULTILINE)
    match = pattern.search(text)
    if not match:
        return None
    return match.group(1).strip().strip("\"'")


def description_value(text: str, key: str) -> str | None:
    pattern = re.compile(rf"^{re.escape(key)}:\s*(.*?)\s*$", re.MULTILINE)
    match = pattern.search(text)
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

    require(
        manuscript.startswith(f"# {EXPECTED_TITLE}\n"),
        "manuscript title matches the designated candidate title",
    )
    require(
        EXPECTED_TITLE in readme,
        "README names the same candidate manuscript",
    )

    description_version = description_value(description, "Version")
    require(
        description_version == EXPECTED_DESCRIPTION_VERSION,
        f"DESCRIPTION version is {EXPECTED_DESCRIPTION_VERSION}",
    )
    cff_version = top_level_yaml_value(citation, "version")
    require(
        cff_version == EXPECTED_CFF_VERSION,
        f"CITATION.cff freeze version is {EXPECTED_CFF_VERSION}",
    )
    require(
        top_level_yaml_value(citation, "cff-version") == "1.2.0",
        "CITATION.cff declares schema version 1.2.0",
    )
    require(
        top_level_yaml_value(citation, "doi") is None,
        "pre-DOI freeze has no invented top-level DOI",
    )
    require(
        top_level_yaml_value(citation, "date-released") is None,
        "pre-DOI freeze has no premature release date",
    )

    for label, text in {
        "README": readme,
        "manuscript": manuscript,
        "CITATION.cff": citation,
        "CHANGELOG": changelog,
    }.items():
        require(
            BASE_VERSION in text and BASE_DOI in text,
            f"{label} identifies published base version {BASE_VERSION} and its DOI",
        )

    require(BRANCH in readme, "README identifies the candidate branch")
    require(BRANCH in manuscript, "manuscript identifies the candidate branch")
    require(ORCID in manuscript, "manuscript contains the designated ORCID")
    require(ORCID in citation, "CITATION.cff contains the designated ORCID")

    abstract = manuscript_abstract(manuscript)
    abstract_words = word_count(abstract)
    require(
        150 <= abstract_words <= 250,
        f"abstract length is within 150 to 250 words ({abstract_words})",
    )
    keywords = manuscript_keywords(manuscript)
    require(
        4 <= len(keywords) <= 6,
        f"manuscript contains four to six keywords ({len(keywords)})",
    )
    require(
        len({keyword.casefold() for keyword in keywords}) == len(keywords),
        "manuscript keywords are unique",
    )

    paths = tracked_paths()
    forbidden_active_paths = [
        path
        for path in paths
        if "f1000" in path.casefold() and not path.startswith("paper/archive/")
    ]
    require(
        not forbidden_active_paths,
        "no active tracked path is specific to the historical F1000 submission",
    )
    active_submission_files = [
        path
        for path in paths
        if path.startswith("paper/submission/")
    ]
    require(
        not active_submission_files,
        "active submission directory is empty until the Earth Science Informatics build",
    )

    require(
        "release freeze" in citation.casefold() and "doi" in citation.casefold(),
        "CITATION.cff explicitly labels the pre-DOI release freeze",
    )
    require(
        "reserved version doi" in manuscript.casefold() and "before submission" in manuscript.casefold(),
        "manuscript requires DOI insertion and immutable archival before submission",
    )

    print("\nVersion 1.2.0 pre-DOI release-freeze metadata validation passed.")


if __name__ == "__main__":
    try:
        main()
    except MetadataError as exc:
        raise SystemExit(f"Candidate metadata validation failed: {exc}") from exc
