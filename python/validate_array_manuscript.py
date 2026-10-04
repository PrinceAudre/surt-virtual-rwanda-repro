#!/usr/bin/env python3
"""Fail-closed checks for the Array development manuscript and its evidence.

This validator is intentionally independent of the older SoftwareX submission gate.
It checks only claims that can be verified from tracked manuscript/evidence files and
does not imply peer-review acceptance or authorize a v1.4.0 release.
"""

from __future__ import annotations

import csv
import io
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "paper" / "array-manuscript.md"
PRIOR_ART = ROOT / "paper" / "ARRAY_NOVELTY_PRIOR_ART_AUDIT.md"
PRIOR_ART_DELTA = ROOT / "paper" / "ARRAY_PRIOR_ART_UPDATE_2026-10-04.md"
CLAIMS = ROOT / "paper" / "ARRAY_CLAIM_EVIDENCE_MATRIX.md"
COLLISION = ROOT / "evidence" / "array" / "support_semantics_collision.json"
BENCHMARK = ROOT / "evidence" / "array" / "array_contract_benchmark_summary.csv"

AFFILIATION = (
    "School of Public Health, College of Medicine and Health Sciences, "
    "University of Rwanda, Kigali, Rwanda"
)
V13_DOI = "10.5281/zenodo.21840177"


class ArrayValidationError(ValueError):
    pass


def read(path: Path) -> str:
    if not path.is_file():
        raise ArrayValidationError(f"missing required file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ArrayValidationError(message)
    print(f"[PASS] {message}")


def main() -> None:
    manuscript = read(MANUSCRIPT)
    prior = read(PRIOR_ART)
    delta = read(PRIOR_ART_DELTA)
    claims = read(CLAIMS)
    lower = manuscript.casefold()

    require(manuscript.startswith("# SuRT-GeoHarmonizer: A contract-first workflow"),
            "Array manuscript uses the contract-first title")
    require("**Target journal:** Array" in manuscript,
            "Array is the explicit target journal")
    require(AFFILIATION in manuscript,
            "current University of Rwanda affiliation is present")
    require("Original Software Publication" not in manuscript,
            "SoftwareX article-type wording is absent from the Array manuscript")
    require("## 7. Threats to validity and limitations" in manuscript,
            "Array manuscript contains an explicit threats-to-validity section")

    for rq in range(1, 6):
        require(f"RQ{rq}" in manuscript, f"Array research question RQ{rq} is present")

    require("does not introduce a new zonal-statistics algorithm" in lower,
            "manuscript explicitly disclaims a new zonal-statistics algorithm")
    for comparator in ("exactextractr", "GDAL", "DART-Pipeline", "DHIS2 Climate"):
        require(comparator in manuscript, f"manuscript acknowledges comparator/context: {comparator}")

    require("GDAL 3.12" in delta and "fractional" in delta and "coverage" in delta,
            "latest prior-art delta captures GDAL 3.12 fractional coverage capability")
    require("spatcovar" in delta and "0.1.0" in delta and "2026-09-08" in delta,
            "latest prior-art delta captures spatcovar 0.1.0")
    require("spatcovar" in prior and "spatcovar" in manuscript,
            "spatcovar prior-art finding is integrated into audit and manuscript")

    require(V13_DOI in manuscript, "published v1.3.0 DOI is retained")
    require("No v1.4.0 DOI is valid until" in manuscript,
            "v1.4.0 remains explicitly unreleased")
    require("Declaration of generative AI" in manuscript and "OpenAI ChatGPT and Codex" in manuscript,
            "AI-assistance disclosure is retained")

    risky_phrases = (
        "the first climate-health",
        "first climate-health data integration",
        "the first environmental-data harmonization",
        "first reusable geospatial pipeline",
        "the first software to aggregate",
        "world-first",
        "unprecedented software",
        "scientifically more accurate than",
    )
    for phrase in risky_phrases:
        require(phrase not in lower, f"blocked priority/superiority phrase absent: {phrase}")

    require("mandatory three-part spatial-support semantics" in prior.casefold(),
            "main novelty audit retains the mandatory support-semantic boundary")
    require("first`, `unique`, `unprecedented`" in claims,
            "claim matrix blocks unverified priority language")

    collision = json.loads(read(COLLISION))
    cases = collision.get("cases", [])
    require(len(cases) == 4, "support-semantics evidence contains four collision cases")
    expected = {
        "complete": (10.0, 1.0, 1.0, 1.0),
        "finite_gap": (10.0, 1.0, 0.5, 0.5),
        "footprint_gap": (10.0, 0.5, 1.0, 0.5),
        "combined_gap": (10.0, 0.5, 0.5, 0.25),
    }
    observed = {
        c["case"]: (
            float(c["value"]),
            float(c["raster_coverage_fraction"]),
            float(c["valid_within_raster_fraction"]),
            float(c["valid_data_fraction"]),
        )
        for c in cases
    }
    require(observed == expected, "collision evidence matches the frozen four-case support tuples")
    require("| Complete | 10 | 1.0 | 1.0 | 1.00 |" in manuscript,
            "manuscript collision table matches complete-support evidence")
    require("| Combined gap | 10 | 0.5 | 0.5 | 0.25 |" in manuscript,
            "manuscript collision table matches combined-gap evidence")

    rows = list(csv.DictReader(io.StringIO(read(BENCHMARK))))
    require(len(rows) == 6, "benchmark summary contains the expected six mode/workload rows")
    by_key = {(r["scenario"], r["mode"]): r for r in rows}
    expected_keys = {
        ("small", "direct_mean"), ("small", "surt_support_contract"),
        ("medium", "direct_mean"), ("medium", "surt_support_contract"),
        ("large", "direct_mean"), ("large", "surt_support_contract"),
    }
    require(set(by_key) == expected_keys, "benchmark modes and scenarios are complete")
    require(all(float(r["max_value_difference_vs_peer"]) == 0.0 for r in rows),
            "benchmark evidence reports identical paired means")

    for scenario, cells, polygons in (("small", 10000, 16), ("medium", 90000, 64), ("large", 360000, 144)):
        direct = by_key[(scenario, "direct_mean")]
        surt = by_key[(scenario, "surt_support_contract")]
        require(int(direct["raster_cells"]) == cells and int(direct["polygon_count"]) == polygons,
                f"benchmark dimensions match for {scenario}")
        direct_s = round(float(direct["median_elapsed_s"]), 2)
        surt_s = round(float(surt["median_elapsed_s"]), 2)
        fragment = f"| {cells:,} cells / {polygons} polygons | {direct_s:.2f} s | {surt_s:.2f} s |"
        require(fragment in manuscript, f"manuscript benchmark timing matches evidence for {scenario}")

    require("not operating-system rss" in lower or "not process rss" in lower,
            "benchmark memory limitation explicitly distinguishes R heap from RSS")
    require("does not establish" in lower and "universal" in lower,
            "performance/portability conclusions remain bounded")

    print("\nArray manuscript and evidence validation passed.")


if __name__ == "__main__":
    try:
        main()
    except (ArrayValidationError, json.JSONDecodeError, KeyError, ValueError) as exc:
        raise SystemExit(f"Array manuscript validation failed: {exc}") from exc
