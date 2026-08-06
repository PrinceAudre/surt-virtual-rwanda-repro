#!/usr/bin/env python3
"""Audit the active SoftwareX Original Software Publication manuscript."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "paper" / "manuscript.md"
EXPECTED_TITLE = (
    "SuRT-GeoHarmonizer: An auditable R and Python workflow for "
    "administrative-scale Earth-data harmonization and provenance labelling"
)
REQUIRED_HEADINGS = [
    "Abstract",
    "1. Motivation and significance",
    "2. Software description",
    "3. Illustrative examples",
    "4. Impact",
    "5. Conclusions",
    "Declaration of competing interest",
    "Funding",
    "Data and software availability",
    "Declaration of generative AI and AI-assisted technologies in the writing process",
    "References",
    "Current code version",
    "Figure captions",
]
FORBIDDEN_ACTIVE_TERMS = [
    "Earth Science Informatics Software article",
    "Article type: Software article",
    "F1000Research Software Tool Article",
    "submission 188121",
    "pre-DOI release freeze",
    '"version_doi": None',
    "pending reservation",
    "validated flood hazard",
    "validated flood susceptibility",
]
EXPECTED_DOIS = {
    "10.1038/sdata.2015.66",
    "10.5194/essd-13-4349-2021",
    "10.5067/MODIS/MOD13A3.061",
    "10.1016/j.jhydrol.2011.03.051",
    "10.1016/j.rse.2017.06.031",
    "10.1016/j.cageo.2016.08.020",
    "10.32614/CRAN.package.exactextractr",
    "10.1038/sdata.2016.18",
    "10.3233/DS-210053",
}


class AuditError(ValueError):
    """Raised when the manuscript fails editorial preflight."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AuditError(message)
    print(f"[PASS] {message}")


def word_count(text: str) -> int:
    return len(re.findall(r"\b[\w][\w’'\-]*\b", text, flags=re.UNICODE))


def section(text: str, heading: str, next_heading: str | None = None) -> str:
    marker = f"## {heading}"
    start = text.find(marker)
    if start < 0:
        raise AuditError(f"missing section: {heading}")
    start += len(marker)
    if next_heading is None:
        return text[start:]
    end_marker = f"## {next_heading}"
    end = text.find(end_marker, start)
    if end < 0:
        raise AuditError(f"missing end section after {heading}: {next_heading}")
    return text[start:end]


def cited_reference_numbers(narrative: str) -> set[int]:
    """Expand numeric citations such as [1-4], [1–4], and [9,10]."""
    cited: set[int] = set()
    for block in re.findall(r"\[([0-9,;\s\-–]+)\]", narrative):
        normalized = block.replace("–", "-").replace(";", ",")
        for item in normalized.split(","):
            item = item.strip()
            if not item:
                continue
            if "-" in item:
                start_text, end_text = [part.strip() for part in item.split("-", 1)]
                if start_text.isdigit() and end_text.isdigit():
                    start, end = int(start_text), int(end_text)
                    if start <= end:
                        cited.update(range(start, end + 1))
            elif item.isdigit():
                cited.add(int(item))
    return cited


def main() -> None:
    require(MANUSCRIPT.is_file(), "paper/manuscript.md exists")
    text = MANUSCRIPT.read_text(encoding="utf-8")
    require(text.startswith(f"# {EXPECTED_TITLE}\n"), "SoftwareX title is exact")
    require("Article type: Original Software Publication" in text, "article type is Original Software Publication")
    require("Independent Researcher, Kigali, Rwanda" in text, "truthful independent affiliation is present")
    require("0009-0002-0799-3140" in text, "ORCID is present")
    require("priplee@gmail.com" in text, "corresponding and support email is present")

    headings = re.findall(r"^## (.+?)\s*$", text, flags=re.MULTILINE)
    positions: list[int] = []
    for heading in REQUIRED_HEADINGS:
        require(heading in headings, f"required section is present: {heading}")
        positions.append(headings.index(heading))
    require(positions == sorted(positions), "required sections occur in SoftwareX order")

    abstract = section(text, "Abstract", "1. Motivation and significance")
    abstract_words = word_count(abstract.split("**Keywords:**", 1)[0])
    require(150 <= abstract_words <= 250, f"abstract contains 150 to 250 words ({abstract_words})")
    keyword_match = re.search(r"^\*\*Keywords:\*\*\s*(.+)$", abstract, re.MULTILINE)
    require(keyword_match is not None, "keyword line is present")
    keywords = [item.strip() for item in keyword_match.group(1).split(";") if item.strip()]
    require(4 <= len(keywords) <= 6, f"four to six keywords are supplied ({len(keywords)})")
    require(len({item.casefold() for item in keywords}) == len(keywords), "keywords are unique")

    references_start = text.index("## References")
    metadata_start = text.index("## Current code version")
    captions_start = text.index("## Figure captions")
    countable = text[text.index("## Abstract"):references_start] + text[captions_start:]
    countable_words = word_count(countable)
    require(countable_words <= 3000, f"SoftwareX countable text is within 3,000 words ({countable_words})")

    for number in range(1, 6):
        require(f"## {number}." in text, f"numbered main section {number} is present")
    require("### 2.1. Architecture" in text, "architecture subsection is present")
    require("### 2.2. Generic interface" in text, "generic-interface subsection is present")
    require("### 2.3. Rwanda reference builders" in text, "reference-builder subsection is present")

    narrative_citations = cited_reference_numbers(text[:references_start])
    require(narrative_citations == set(range(1, 11)),
            "grouped and ranged narrative citations cover references 1 through 10")
    for number in range(1, 11):
        require(re.search(rf"^\[{number}\]\s", text[references_start:metadata_start], re.MULTILINE) is not None,
                f"reference [{number}] appears in the reference list")

    dois = {
        match.rstrip(".,;)")
        for match in re.findall(r"https://doi\.org/([^\s]+)", text[references_start:metadata_start])
    }
    require(dois == EXPECTED_DOIS, "reference DOI set matches the verified SoftwareX manuscript registry")

    for code in range(1, 10):
        require(re.search(rf"^\| C{code} \|", text[metadata_start:captions_start], re.MULTILINE) is not None,
                f"SoftwareX code metadata row C{code} is present")
    require("MIT License" in text[metadata_start:captions_start], "approved MIT licence is declared")
    require("github.com/PrinceAudre/surt-virtual-rwanda-repro" in text[metadata_start:captions_start],
            "GitHub repository is recorded in the metadata table")

    captions = re.findall(r"^\*\*Fig\. (\d+)\.\*\*", text[captions_start:], re.MULTILINE)
    require(captions == ["1", "2"], "two non-duplicated figure captions are supplied")
    require(len(captions) <= 6, "figure count is within the SoftwareX maximum of six")

    for term in FORBIDDEN_ACTIVE_TERMS:
        require(term.casefold() not in text.casefold(), f"stale or overclaiming phrase is absent: {term}")
    require("TODO" not in text and "TBD" not in text and "[insert" not in text.casefold(),
            "manuscript contains no unresolved editorial placeholder")
    require("48 explicit" in text, "manuscript reports the current 48-outcome suite")
    require("R/harmonize_admin_raster.R" in text, "manuscript identifies the public generic interface")
    require("codex/softwarex-submission-v1.3.0" in text, "candidate source branch is identified")
    require("10.5281/zenodo.21744708" in text and "10.5281/zenodo.21671788" in text,
            "historical version DOI and concept DOI are recorded")

    print("\nSoftwareX manuscript audit passed.")


if __name__ == "__main__":
    try:
        main()
    except AuditError as exc:
        raise SystemExit(f"SoftwareX manuscript audit failed: {exc}") from exc
