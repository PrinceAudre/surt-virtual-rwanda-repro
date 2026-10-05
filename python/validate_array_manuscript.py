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
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "paper" / "array-manuscript.md"
PRIOR_ART = ROOT / "paper" / "ARRAY_NOVELTY_PRIOR_ART_AUDIT.md"
PRIOR_ART_DELTA = ROOT / "paper" / "ARRAY_PRIOR_ART_UPDATE_2026-10-04.md"
PRIOR_ART_DELTA_B = ROOT / "paper" / "ARRAY_PRIOR_ART_UPDATE_2026-10-04B.md"
PRIOR_ART_DELTA_C = ROOT / "paper" / "ARRAY_PRIOR_ART_UPDATE_2026-10-04C.md"
PRIOR_ART_DELTA_D = ROOT / "paper" / "ARRAY_PRIOR_ART_UPDATE_2026-10-04D.md"
CLAIMS = ROOT / "paper" / "ARRAY_CLAIM_EVIDENCE_MATRIX.md"
COLLISION = ROOT / "evidence" / "array" / "support_semantics_collision.json"
BENCHMARK = ROOT / "evidence" / "array" / "array_contract_benchmark_summary.csv"

AFFILIATION = (
    "School of Public Health, College of Medicine and Health Sciences, "
    "University of Rwanda, Kigali, Rwanda"
)
V13_DOI = "10.5281/zenodo.21840177"
V14_DOI = "10.5281/zenodo.23162055"


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
    delta_b = read(PRIOR_ART_DELTA_B)
    delta_c = read(PRIOR_ART_DELTA_C)
    delta_d = read(PRIOR_ART_DELTA_D)
    claims = read(CLAIMS)
    lower = manuscript.casefold()
    delta_lower = delta.casefold()
    delta_b_lower = delta_b.casefold()
    delta_c_lower = delta_c.casefold()
    delta_d_lower = delta_d.casefold()
    claims_lower = claims.casefold()

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

    # Expanded October 2026 novelty controls.
    require("open climate service" in delta_lower and "chirps" in delta_lower and "health-service" in delta_lower,
            "prior-art delta captures DHIS2 Open Climate Service and administrative health-area processing")
    require("qflowcrate" in delta_lower and "ro-crate" in delta_lower,
            "prior-art delta captures peer-reviewed geospatial provenance packaging")
    require("zonify" in delta_lower and "coverage" in delta_lower and "nodata" in delta_lower,
            "prior-art delta captures current zonal coverage reporting")
    require("model-based geostatistics" in delta_lower and "mbg" in delta_lower,
            "prior-art delta captures health/geostatistical raster-to-polygon aggregation")
    require("machine-readable data contracts" in delta_lower and "not priority claims" in delta_lower,
            "prior-art delta blocks generic data-contract novelty")
    require("he2at" in delta_lower and "sub-saharan african" in delta_lower,
            "prior-art delta treats African climate-health integration as established application context")
    require("fail-closed raster-coverage thresholds" in delta_lower and "check_raster_coverage" in delta_lower,
            "prior-art delta blocks minimum-coverage rejection as a novelty claim")
    require("valid-data footprints" in delta_lower and "valid_percent" in delta_lower,
            "prior-art delta distinguishes grid extent from established valid-data footprint/percent concepts")

    # Second targeted delta: directly challenge coverage and geospatial-assurance novelty.
    require("urban growth center" in delta_b_lower and "valid_coverage_share" in delta_b,
            "second prior-art delta captures metric-specific valid-coverage shares")
    require("geobrix" in delta_b_lower and "coverage=complete" in delta_b and "nodata" in delta_b_lower,
            "second prior-art delta captures extent-versus-valid raster-grid semantics")
    require("geospatial agentic services" in delta_b_lower and "reproducibility bundle" in delta_b_lower,
            "second prior-art delta captures integrated validation/provenance/reproducibility architecture")
    require("enterprise spatial data provenance knowledge infrastructure" in delta_b_lower and "validation-gated" in delta_b_lower,
            "second prior-art delta captures validation-gated geospatial provenance architecture")
    require("not proof of uniqueness" in delta_b_lower,
            "second prior-art delta explicitly blocks exhaustive novelty inference")

    # Third targeted delta: climate/admin preprocessing, African services, public-health use and contracts.
    require("stagg" in delta_c_lower and "climate impacts analysis" in delta_c_lower,
            "third prior-art delta captures dedicated climate-to-administrative preprocessing software")
    require("climate econometrics toolkit" in delta_c_lower and "runtime" in delta_c_lower,
            "third prior-art delta captures integrated climate aggregation and benchmark precedent")
    require("climate data tool" in delta_c_lower and "africa" in delta_c_lower and "20 african countries" in delta_c_lower,
            "third prior-art delta captures operational African climate-service precedent")
    require("geoglue" in delta_c_lower and "epidemiology" in delta_c_lower and "public health" in delta_c_lower,
            "third prior-art delta captures public-health administrative aggregation precedent")
    require("ipums terra" in delta_c_lower and "population-environment" in delta_c_lower,
            "third prior-art delta captures historical population-environment integration")
    require("autogis" in delta_c_lower and "contract-driven" in delta_c_lower,
            "third prior-art delta blocks contract-driven geospatial computing as a priority claim")
    require("not proof of uniqueness" in delta_c_lower,
            "third prior-art delta explicitly blocks exhaustive novelty inference")

    # Fourth targeted delta: the newest direct zonal and epidemiological preprocessing baselines.
    require("gdal 3.12" in delta_d_lower and "coverage arrays" in delta_d_lower and "weighted zonal" in delta_d_lower,
            "fourth prior-art delta captures modern GDAL zonal interface capability")
    require("spatcovar" in delta_d_lower and "geometry repair" in delta_d_lower and "missing-value" in delta_d_lower,
            "fourth prior-art delta captures robust polygon-covariate wrapper precedent")
    require("climate-cafe" in delta_d_lower and "kenya" in delta_d_lower and "epidemiological" in delta_d_lower,
            "fourth prior-art delta captures African epidemiological ERA5 preprocessing precedent")
    require("stagg::overlay_weights()" in delta_d and "administrative polygon" in delta_d_lower,
            "fourth prior-art delta captures explicit polygon-to-grid support weights")
    require("geoglue" in delta_d_lower and "public health" in delta_d_lower and "non-nan" in delta_d_lower,
            "fourth prior-art delta captures missing-data-aware public-health geospatial processing")
    require("not proof of uniqueness" in delta_d_lower,
            "fourth prior-art delta explicitly blocks exhaustive novelty inference")

    # The strongest prior-art findings must not remain only in internal audits.
    for comparator in (
        "Open Climate Service", "QFlowCrate", "mbg", "STAC", "raster-footprint", "SWATbuildR",
        "Urban Growth Center", "GeoBrix", "Geospatial Agentic Services", "ESDPKI",
        "stagg", "Climate-CAFE", "geoglue",
    ):
        require(comparator in manuscript,
                f"expanded prior-art finding is integrated into manuscript: {comparator}")

    # Delta C must at least be represented in the claim matrix even before manuscript compression is finalized.
    for comparator in ("stagg", "Climate Econometrics Toolkit", "CDT", "geoglue", "IPUMS Terra", "AutoGIS"):
        require(comparator.casefold() in claims_lower,
                f"third-delta novelty limit is recorded in claim matrix: {comparator}")

    require("rectangular grid extent" in lower,
            "manuscript defines raster coverage as rectangular grid-extent coverage")
    require("are algebraically independent" in lower and
            "valid_data_fraction = raster_coverage_fraction × valid_within_raster_fraction" in manuscript,
            "manuscript discloses algebraic dependence of the three reported support fields")
    require("produced **one** unique interface signature" in manuscript and
            "produced **three** signatures" in manuscript and
            "produced **four** signatures" in manuscript,
            "manuscript reports the 1/3/4 support-interface signature result")
    require("not a priority claim" in lower and "cannot prove uniqueness" in lower,
            "manuscript states that an unmatched search result is not a priority claim")

    require(V13_DOI in manuscript, "published v1.3.0 DOI is retained")
    require(V14_DOI in manuscript, "reserved v1.4.0 DOI is bound to the Array manuscript")
    require("No v1.4.0 DOI is valid until" not in manuscript,
            "stale pre-reservation v1.4.0 DOI wording is absent")
    require("Declaration of generative AI" in manuscript and "OpenAI ChatGPT and Codex" in manuscript,
            "AI-assistance disclosure is retained")
    unsupported_historical_timing = "19.3 s"
    require(unsupported_historical_timing not in manuscript and unsupported_historical_timing not in claims and unsupported_historical_timing not in prior,
            "unsupported historical before/after timing is absent from active Array evidence claims")
    require("no durable pre-change timing artifact" in manuscript,
            "manuscript explains why only tracked final benchmark timings are reported")
    require("## Declaration of generative AI and AI-assisted technologies in the manuscript preparation process" in manuscript,
            "Elsevier AI declaration uses the current recommended section heading")

    risky_phrases = (
        "the first climate-health",
        "first climate-health data integration",
        "the first environmental-data harmonization",
        "first reusable geospatial pipeline",
        "the first software to aggregate",
        "first to report valid coverage",
        "first to separate raster extent",
        "novel coverage metric",
        "world-first",
        "unprecedented software",
        "scientifically more accurate than",
    )
    for phrase in risky_phrases:
        require(phrase not in lower, f"blocked priority/superiority phrase absent: {phrase}")

    require("fixed integration and assurance contract" in prior.casefold(),
            "main novelty audit retains the bounded integration-contract contribution")
    require("first`, `unique`, `unprecedented`" in claims,
            "claim matrix blocks unverified priority language")
    require("urban growth center" in claims_lower and "geobrix" in claims_lower,
            "claim matrix records the latest direct coverage precedents")
    require("absence of an exact integrated match" in claims_lower,
            "claim matrix blocks novelty inference from an unmatched search")
    require("african/lmic relevance is a deployment rationale only" in claims_lower,
            "claim matrix blocks African/LMIC context from becoming a novelty claim")
    require("contract-first` is descriptive framing" in claims_lower,
            "claim matrix blocks contract-first wording from becoming a priority claim")

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

    mean_only = {(vals[0],) for vals in observed.values()}
    mean_plus_overall = {(vals[0], vals[3]) for vals in observed.values()}
    full_support = {(vals[0], vals[1], vals[2], vals[3]) for vals in observed.values()}
    require(len(mean_only) == 1,
            "mean-only handoff collapses all four controlled support states")
    require(len(mean_plus_overall) == 3,
            "mean plus one overall valid-coverage field leaves one controlled support-state collision")
    require(len(full_support) == 4,
            "mean plus the explicit support tuple identifies all four controlled support states")

    finite_gap = observed["finite_gap"]
    footprint_gap = observed["footprint_gap"]
    require(
        finite_gap[0] == footprint_gap[0]
        and finite_gap[3] == footprint_gap[3]
        and finite_gap[1:3] != footprint_gap[1:3],
        "single overall coverage conflates finite-data loss with raster-grid loss in the controlled fixture",
    )

    collision_meta = collision.get("interface_collision_analysis", {})
    require(int(collision_meta.get("mean_only_unique_signatures", -1)) == len(mean_only),
            "tracked interface analysis records the mean-only signature count")
    require(int(collision_meta.get("mean_plus_overall_valid_coverage_unique_signatures", -1)) == len(mean_plus_overall),
            "tracked interface analysis records the mean-plus-overall signature count")
    require(int(collision_meta.get("mean_plus_three_part_support_unique_signatures", -1)) == len(full_support),
            "tracked interface analysis records the full-support signature count")
    require(collision_meta.get("critical_collision") == ["finite_gap", "footprint_gap"],
            "tracked interface analysis identifies the finite-gap versus footprint-gap collision")
    require("not a claim" in str(collision_meta.get("claim_boundary", "")).casefold(),
            "tracked interface analysis preserves the non-exclusivity claim boundary")

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

    # Citation/reference integrity is part of the manuscript contract. Ignore numeric
    # interval groups containing zero, such as [0,1], because citations start at 1.
    body, sep, refs = manuscript.partition("## References")
    require(bool(sep), "manuscript contains a References section")
    ref_numbers = [int(m.group(1)) for m in re.finditer(r"(?m)^\[(\d+)\]\s", refs)]
    require(bool(ref_numbers), "manuscript contains numbered references")
    require(ref_numbers == list(range(1, max(ref_numbers) + 1)),
            "reference numbering is contiguous from 1")
    cited = set()
    for group in re.findall(r"\[([0-9][0-9,\-– ]*)\]", body):
        values = set()
        for part in group.replace("–", "-").split(","):
            part = part.strip()
            if not part:
                continue
            if "-" in part:
                lo, hi = (int(x.strip()) for x in part.split("-", 1))
                values.update(range(lo, hi + 1))
            else:
                values.add(int(part))
        if 0 in values:
            continue
        cited.update(values)
    require(cited <= set(ref_numbers),
            "every numbered in-text citation resolves to a reference entry")
    require(set(ref_numbers) <= cited,
            "every numbered reference is cited in the manuscript body")

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
