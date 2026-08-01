#!/usr/bin/env python3
"""Audit the active manuscript for structural and citation consistency.

This is a deterministic editorial preflight. It does not validate the scientific
truth of a reference; verified bibliographic metadata are recorded separately in
paper/REFERENCE_AUDIT.md.
"""

from __future__ import annotations

from collections import Counter
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "paper" / "manuscript.md"

REQUIRED_LEVEL2_HEADINGS = [
    "Abstract",
    "Introduction",
    "Design and Implementation",
    "Results",
    "Discussion",
    "Conclusions",
    "Availability and Requirements",
    "Statements and Declarations",
    "References",
    "Tables",
    "Figure captions",
    "Software Files",
]

REQUIRED_DECLARATIONS = [
    "Ethics approval and consent",
    "Funding",
    "Competing interests",
    "Author contributions",
    "Data and software availability",
]

EXPECTED_REFERENCE_KEYS = {
    "Baston 2025": r"\bBaston\s*(?:\(|\s)2025\b",
    "Busetto and Ranghetti 2016": r"\bBusetto and Ranghetti\s*(?:\(|\s)2016\b",
    "Didan 2021": r"\bDidan\s*(?:\(|\s)2021\b",
    "Funk et al. 2015": r"\bFunk et al\.?\s*(?:\(|\s)2015\b",
    "Gorelick et al. 2017": r"\bGorelick et al\.?\s*(?:\(|\s)2017\b",
    "Kale et al. 2023": r"\bKale et al\.?\s*(?:\(|\s)2023\b",
    "Lebo et al. 2013": r"\bLebo et al\.?\s*(?:\(|\s)2013\b",
    "Mitchell et al. 2022": r"\bMitchell et al\.?\s*(?:\(|\s)2022\b",
    "Muñoz-Sabater et al. 2021": r"\bMu(?:ñ|n)oz-Sabater et al\.?\s*(?:\(|\s)2021\b",
    "Nobre et al. 2011": r"\bNobre et al\.?\s*(?:\(|\s)2011\b",
    "Soiland-Reyes et al. 2022": r"\bSoiland-Reyes et al\.?\s*(?:\(|\s)2022\b",
    "Tuyishime 2026": r"\bTuyishime\s*(?:\(|\s)2026\b",
    "Wilkinson et al. 2016": r"\bWilkinson et al\.?\s*(?:\(|\s)2016\b",
    "Zong et al. 2024": r"\bZong et al\.?\s*(?:\(|\s)2024\b",
}

EXPECTED_REFERENCE_STARTS = [
    "Baston D (2025)",
    "Busetto L, Ranghetti L (2016)",
    "Didan K (2021)",
    "Funk C, Peterson P, Landsfeld M et al (2015)",
    "Gorelick N, Hancher M, Dixon M et al (2017)",
    "Kale A, Sun Z, Ma X (2023)",
    "Lebo T, Sahoo S, McGuinness D (eds) (2013)",
    "Mitchell SN, Lahiff A, Cummings N et al (2022)",
    "Muñoz-Sabater J, Dutra E, Agustí-Panareda A et al (2021)",
    "Nobre AD, Cuartas LA, Hodnett M et al (2011)",
    "Soiland-Reyes S, Sefton P, Crosas M et al (2022)",
    "Tuyishime AP (2026)",
    "Wilkinson MD, Dumontier M, Aalbersberg IJ et al (2016)",
    "Zong L, Ngarukiyimana JP, Yang Y et al (2024)",
]

EXPECTED_DOIS = {
    "10.32614/CRAN.package.exactextractr",
    "10.1016/j.cageo.2016.08.020",
    "10.5067/MODIS/MOD13A3.061",
    "10.1038/sdata.2015.66",
    "10.1016/j.rse.2017.06.031",
    "10.1007/s12145-023-01045-0",
    "10.1098/rsta.2021.0300",
    "10.5194/essd-13-4349-2021",
    "10.1016/j.jhydrol.2011.03.051",
    "10.3233/DS-210053",
    "10.5281/zenodo.21677162",
    "10.1038/sdata.2016.18",
    "10.1038/s43247-024-01717-9",
}

FORBIDDEN_ACTIVE_TERMS = [
    "F1000Research Software Tool Article",
    "submission 188121",
    "Cureus Journal of AI-Augmented Research",
    "operational decision support",
    "validated flood hazard",
    "validated flood susceptibility",
]


class AuditError(ValueError):
    """Raised when the manuscript fails editorial preflight."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AuditError(message)
    print(f"[PASS] {message}")


def section(text: str, start: str, end: str | None = None) -> str:
    start_marker = f"## {start}"
    start_index = text.find(start_marker)
    if start_index < 0:
        raise AuditError(f"missing section: {start}")
    start_index += len(start_marker)
    if end is None:
        return text[start_index:]
    end_marker = f"## {end}"
    end_index = text.find(end_marker, start_index)
    if end_index < 0:
        raise AuditError(f"missing end section after {start}: {end}")
    return text[start_index:end_index]


def reference_paragraphs(reference_text: str) -> list[str]:
    return [
        re.sub(r"\s+", " ", paragraph).strip()
        for paragraph in re.split(r"\n\s*\n", reference_text)
        if paragraph.strip()
    ]


def normalize_doi(value: str) -> str:
    return value.rstrip(".,;)").strip()


def main() -> None:
    if not MANUSCRIPT.is_file():
        raise AuditError("paper/manuscript.md is missing")
    text = MANUSCRIPT.read_text(encoding="utf-8")

    level2 = re.findall(r"^## (.+?)\s*$", text, flags=re.MULTILINE)
    positions = []
    for heading in REQUIRED_LEVEL2_HEADINGS:
        require(heading in level2, f"required level-two heading is present: {heading}")
        positions.append(level2.index(heading))
    require(
        positions == sorted(positions) and len(set(positions)) == len(positions),
        "required level-two headings occur once in the designated order",
    )

    declaration_text = section(text, "Statements and Declarations", "References")
    for heading in REQUIRED_DECLARATIONS:
        require(
            re.search(rf"^### {re.escape(heading)}\s*$", declaration_text, re.MULTILINE)
            is not None,
            f"required declaration is present: {heading}",
        )

    body = text[: text.index("## References")]
    for key, pattern in EXPECTED_REFERENCE_KEYS.items():
        require(
            re.search(pattern, body, flags=re.IGNORECASE) is not None,
            f"reference is cited in the narrative: {key}",
        )

    refs = reference_paragraphs(section(text, "References", "Tables"))
    require(
        len(refs) == len(EXPECTED_REFERENCE_STARTS),
        f"reference list contains the expected {len(EXPECTED_REFERENCE_STARTS)} entries",
    )
    # The length check above makes plain zip() equivalent to strict zip while
    # retaining compatibility with the Python 3.9 runtime used by CI.
    actual_starts = []
    for expected, paragraph in zip(EXPECTED_REFERENCE_STARTS, refs):
        require(
            paragraph.startswith(expected),
            f"reference begins with verified author-year metadata: {expected}",
        )
        actual_starts.append(expected)
    surnames = [start.split()[0].casefold() for start in actual_starts]
    require(surnames == sorted(surnames), "references are alphabetized by first author")

    dois = [
        normalize_doi(match)
        for match in re.findall(r"https://doi\.org/([^\s]+)", "\n".join(refs))
    ]
    require(
        len(dois) == len(set(dois)),
        "reference-list DOI values are unique",
    )
    require(
        set(dois) == EXPECTED_DOIS,
        "reference-list DOI set matches the verified audit registry",
    )

    for number in range(1, 5):
        require(
            re.search(rf"\bTable {number}\b", body) is not None,
            f"Table {number} is mentioned before the table block",
        )
        require(
            re.search(rf"^### Table {number}\b", text, re.MULTILINE) is not None,
            f"Table {number} has one numbered table heading",
        )

    for number in range(1, 4):
        require(
            re.search(rf"\bFigure {number}\b", body) is not None,
            f"Figure {number} is mentioned before the caption block",
        )
        require(
            re.search(rf"^\*\*Fig\. {number}\*\*", text, re.MULTILINE) is not None,
            f"Figure {number} has one numbered caption",
        )

    table_headings = re.findall(r"^### Table (\d+)\b", text, re.MULTILINE)
    figure_captions = re.findall(r"^\*\*Fig\. (\d+)\*\*", text, re.MULTILINE)
    require(
        Counter(table_headings) == Counter({"1": 1, "2": 1, "3": 1, "4": 1}),
        "table numbers are complete and non-duplicated",
    )
    require(
        Counter(figure_captions) == Counter({"1": 1, "2": 1, "3": 1}),
        "figure numbers are complete and non-duplicated",
    )

    for term in FORBIDDEN_ACTIVE_TERMS:
        require(
            term.casefold() not in text.casefold(),
            f"forbidden stale or overclaiming phrase is absent: {term}",
        )

    require(
        "TODO" not in text and "TBD" not in text and "[insert" not in text.casefold(),
        "manuscript contains no unresolved editorial placeholder",
    )
    require(
    "version 1.2.0" in text.casefold()
    and "reserved version doi" in text.casefold()
    and "before submission" in text.casefold()
    and "tagged and archived" in text.casefold(),
    "v1.2.0 DOI, tag, and archive dependency is explicit",
)

    print("\nManuscript structure and citation audit passed.")


if __name__ == "__main__":
    try:
        main()
    except AuditError as exc:
        raise SystemExit(f"Manuscript audit failed: {exc}") from exc
