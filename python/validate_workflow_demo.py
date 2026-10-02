#!/usr/bin/env python3
"""Validate the deterministic Snakemake demo output without geospatial Python dependencies."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


EXPECTED = {
    "ALPHA-01": {"value": 16.0, "valid": 1.0},
    "BETA-02": {"value": 36.0, "valid": 1.0},
    "GAMMA-03": {"value": 51.0, "valid": 0.5},
}
VALUE_NAME = "demo_environment_mean"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, help="Configured harmonizer GeoJSON output")
    parser.add_argument("--output", required=True, help="Validation evidence JSON")
    return parser.parse_args()


def check(label: str, condition: bool) -> None:
    if not condition:
        raise SystemExit(f"[FAIL] {label}")
    print(f"[PASS] {label}")


def finite_number(value: Any) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise TypeError
    number = float(value)
    if number != number or number in (float("inf"), float("-inf")):
        raise TypeError
    return number


def main() -> None:
    args = parse_args()
    source = Path(args.input)
    output = Path(args.output)
    try:
        payload = json.loads(source.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"[FAIL] could not read workflow GeoJSON: {exc}") from exc

    features = payload.get("features") if isinstance(payload, dict) else None
    check("workflow output is a GeoJSON FeatureCollection", payload.get("type") == "FeatureCollection")
    check("workflow output contains exactly three administrative units", isinstance(features, list) and len(features) == 3)

    observed: dict[str, dict[str, float]] = {}
    provenance_values: set[str] = set()
    for feature in features:
        props = feature.get("properties", {})
        unit_id = props.get("unit_id")
        if unit_id not in EXPECTED:
            raise SystemExit(f"[FAIL] unexpected workflow unit_id: {unit_id!r}")
        try:
            value = finite_number(props.get(VALUE_NAME))
            raster = finite_number(props.get("raster_coverage_fraction"))
            within = finite_number(props.get("valid_within_raster_fraction"))
            valid = finite_number(props.get("valid_data_fraction"))
        except TypeError as exc:
            raise SystemExit(f"[FAIL] non-finite workflow property for {unit_id}") from exc
        observed[unit_id] = {
            "value": value,
            "raster_coverage_fraction": raster,
            "valid_within_raster_fraction": within,
            "valid_data_fraction": valid,
        }
        provenance_values.add(str(props.get("provenance", "")))

    check("workflow output preserves all expected identifiers", set(observed) == set(EXPECTED))
    check(
        "workflow output reproduces raw-mask then scale-offset fixture means",
        all(abs(observed[key]["value"] - expected["value"]) < 1e-9 for key, expected in EXPECTED.items()),
    )
    check(
        "workflow output reports complete raster-footprint coverage",
        all(abs(row["raster_coverage_fraction"] - 1.0) < 1e-9 for row in observed.values()),
    )
    check(
        "workflow output reports finite-data support including the half-covered unit",
        all(abs(observed[key]["valid_data_fraction"] - expected["valid"]) < 1e-9 for key, expected in EXPECTED.items()),
    )
    check(
        "workflow output keeps within-raster and overall valid fractions aligned for full footprint coverage",
        all(abs(row["valid_within_raster_fraction"] - row["valid_data_fraction"]) < 1e-9 for row in observed.values()),
    )
    check(
        "workflow output carries one non-empty provenance statement",
        len(provenance_values) == 1 and bool(next(iter(provenance_values)).strip()),
    )

    output.parent.mkdir(parents=True, exist_ok=True)
    evidence = {
        "schema_version": "1.0",
        "status": "passed",
        "evidence_class": "controlled-software-verification",
        "input": source.as_posix(),
        "value_name": VALUE_NAME,
        "expected": EXPECTED,
        "observed": observed,
        "limitation": "Synthetic fixture verification only; not independent validation of any Earth-observation product.",
    }
    output.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"[WRITE] {output}")


if __name__ == "__main__":
    main()
