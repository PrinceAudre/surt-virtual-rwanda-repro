#!/usr/bin/env python3
"""Validate the published district-layer contract and exercise deliberate failures.

This validator uses only the Python standard library. It checks the archived
GeoJSON files independently of the R geospatial stack that produced them. The
checks cover schema, identifiers, feature counts, values, provenance strings,
coordinate bounds, and exact geometry identity across layers.
"""

from __future__ import annotations

from copy import deepcopy
from dataclasses import dataclass
from datetime import datetime, timezone
import argparse
import json
import math
from pathlib import Path
import tempfile
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
EXPECTED_DISTRICTS = 30


class ContractError(ValueError):
    """Raised when a release file violates the declared contract."""


@dataclass(frozen=True)
class LayerSpec:
    filename: str
    value_field: str | None
    minimum: float | None = None
    maximum: float | None = None
    provenance_tokens: tuple[str, ...] = ()

    @property
    def allowed_properties(self) -> set[str]:
        if self.value_field is None:
            return {"district"}
        return {"district", self.value_field, "provenance"}


SPECS = (
    LayerSpec("relief_districts.geojson", None),
    LayerSpec(
        "relief_climate_rainfall.geojson",
        "annual_rainfall_mm",
        300,
        3000,
        ("chirps", "2023"),
    ),
    LayerSpec(
        "relief_climate_temp.geojson",
        "mean_temp_c",
        10,
        30,
        ("era5-land", "2023"),
    ),
    LayerSpec(
        "relief_climate_ndvi.geojson",
        "mean_ndvi",
        0.15,
        0.95,
        ("modis", "mod13a3", "2023"),
    ),
    LayerSpec(
        "relief_low_lying_hand.geojson",
        "low_lying_share_pct",
        0,
        100,
        ("hand", "5 m"),
    ),
)


def load_geojson(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ContractError(f"missing release file: {path.relative_to(ROOT)}") from exc
    except json.JSONDecodeError as exc:
        raise ContractError(f"invalid JSON in {path.relative_to(ROOT)}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ContractError(f"top-level JSON must be an object: {path.relative_to(ROOT)}")
    return payload


def coordinate_pairs(node: Any) -> Iterable[tuple[float, float]]:
    """Yield coordinate pairs from arbitrarily nested Polygon coordinates."""
    if not isinstance(node, list):
        raise ContractError("geometry coordinates must be nested arrays")
    if len(node) >= 2 and all(isinstance(v, (int, float)) and not isinstance(v, bool) for v in node[:2]):
        yield float(node[0]), float(node[1])
        return
    for child in node:
        yield from coordinate_pairs(child)


def geometry_fingerprint(geometry: dict[str, Any]) -> str:
    return json.dumps(geometry, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def check_crs(payload: dict[str, Any], label: str) -> None:
    crs = payload.get("crs")
    if crs is None:
        return  # RFC 7946 GeoJSON may omit CRS and is then WGS84 longitude/latitude.
    text = json.dumps(crs, sort_keys=True).lower()
    if "crs84" not in text and "4326" not in text:
        raise ContractError(f"{label}: declared CRS is not CRS84/EPSG:4326")


def validate_payload(
    payload: dict[str, Any],
    spec: LayerSpec,
    *,
    reference_order: list[str] | None = None,
    reference_geometry: dict[str, str] | None = None,
) -> dict[str, Any]:
    label = spec.filename
    if payload.get("type") != "FeatureCollection":
        raise ContractError(f"{label}: type must be FeatureCollection")
    check_crs(payload, label)
    features = payload.get("features")
    if not isinstance(features, list):
        raise ContractError(f"{label}: features must be an array")
    if len(features) != EXPECTED_DISTRICTS:
        raise ContractError(
            f"{label}: expected {EXPECTED_DISTRICTS} features; found {len(features)}"
        )

    order: list[str] = []
    geometries: dict[str, str] = {}
    values: list[float] = []

    for index, feature in enumerate(features, start=1):
        if not isinstance(feature, dict) or feature.get("type") != "Feature":
            raise ContractError(f"{label}: feature {index} is not a GeoJSON Feature")
        properties = feature.get("properties")
        if not isinstance(properties, dict):
            raise ContractError(f"{label}: feature {index} properties must be an object")
        keys = set(properties)
        if keys != spec.allowed_properties:
            missing = sorted(spec.allowed_properties - keys)
            extra = sorted(keys - spec.allowed_properties)
            raise ContractError(
                f"{label}: feature {index} property contract violated; "
                f"missing={missing}, extra={extra}"
            )

        district = properties.get("district")
        if not isinstance(district, str) or not district.strip():
            raise ContractError(f"{label}: feature {index} has an empty district identifier")
        district = district.strip()
        if district in geometries:
            raise ContractError(f"{label}: duplicate district identifier: {district}")

        geometry = feature.get("geometry")
        if not isinstance(geometry, dict) or geometry.get("type") not in {"Polygon", "MultiPolygon"}:
            raise ContractError(f"{label}: {district} geometry must be Polygon or MultiPolygon")
        coordinates = geometry.get("coordinates")
        pairs = list(coordinate_pairs(coordinates))
        if not pairs:
            raise ContractError(f"{label}: {district} geometry has no coordinates")
        for longitude, latitude in pairs:
            if not math.isfinite(longitude) or not math.isfinite(latitude):
                raise ContractError(f"{label}: {district} has a non-finite coordinate")
            if not (-180 <= longitude <= 180 and -90 <= latitude <= 90):
                raise ContractError(
                    f"{label}: {district} coordinate outside longitude/latitude bounds"
                )

        order.append(district)
        geometries[district] = geometry_fingerprint(geometry)

        if spec.value_field is not None:
            raw_value = properties.get(spec.value_field)
            if not isinstance(raw_value, (int, float)) or isinstance(raw_value, bool):
                raise ContractError(f"{label}: {district} value is not numeric")
            value = float(raw_value)
            if not math.isfinite(value):
                raise ContractError(f"{label}: {district} value is not finite")
            assert spec.minimum is not None and spec.maximum is not None
            if not spec.minimum <= value <= spec.maximum:
                raise ContractError(
                    f"{label}: {district} value {value} outside "
                    f"[{spec.minimum}, {spec.maximum}]"
                )
            values.append(value)

            provenance = properties.get("provenance")
            if not isinstance(provenance, str) or not provenance.strip():
                raise ContractError(f"{label}: {district} has empty provenance")
            provenance_lower = provenance.lower()
            missing_tokens = [
                token for token in spec.provenance_tokens if token.lower() not in provenance_lower
            ]
            if missing_tokens:
                raise ContractError(
                    f"{label}: {district} provenance lacks tokens {missing_tokens}"
                )

    if len(set(order)) != EXPECTED_DISTRICTS:
        raise ContractError(f"{label}: district identifiers are not unique")
    if reference_order is not None and order != reference_order:
        raise ContractError(f"{label}: district order differs from relief_districts.geojson")
    if reference_geometry is not None:
        if set(geometries) != set(reference_geometry):
            raise ContractError(f"{label}: district set differs from relief_districts.geojson")
        mismatched = [
            district
            for district in order
            if geometries[district] != reference_geometry[district]
        ]
        if mismatched:
            raise ContractError(
                f"{label}: geometry differs from relief_districts.geojson for "
                + ", ".join(mismatched)
            )

    result: dict[str, Any] = {
        "filename": spec.filename,
        "features": len(features),
        "districts_unique": True,
        "properties_exact": True,
        "coordinate_bounds_valid": True,
        "geometry_matches_reference": reference_geometry is not None or spec.value_field is None,
    }
    if values:
        result.update(
            {
                "value_field": spec.value_field,
                "minimum": min(values),
                "maximum": max(values),
                "mean": sum(values) / len(values),
                "provenance_tokens_present": True,
            }
        )
    return {"order": order, "geometries": geometries, "summary": result}


def validate_release() -> list[dict[str, Any]]:
    district_spec = SPECS[0]
    district_result = validate_payload(load_geojson(DATA / district_spec.filename), district_spec)
    order = district_result["order"]
    geometry = district_result["geometries"]
    summaries = [district_result["summary"]]
    print(f"[PASS] {district_spec.filename}: 30 unique districts and valid geometry")

    for spec in SPECS[1:]:
        result = validate_payload(
            load_geojson(DATA / spec.filename),
            spec,
            reference_order=order,
            reference_geometry=geometry,
        )
        summaries.append(result["summary"])
        print(
            f"[PASS] {spec.filename}: schema, values, provenance, order, and geometry"
        )
    return summaries


def expect_contract_failure(label: str, payload: dict[str, Any], spec: LayerSpec, contains: str) -> None:
    try:
        validate_payload(payload, spec)
    except ContractError as exc:
        if contains.lower() not in str(exc).lower():
            raise AssertionError(
                f"{label}: failed for the wrong reason: {exc!s}"
            ) from exc
        print(f"[PASS] deliberate corruption rejected: {label}")
        return
    raise AssertionError(f"{label}: malformed payload was incorrectly accepted")


def run_failure_injection_tests() -> list[str]:
    spec = SPECS[1]
    original = load_geojson(DATA / spec.filename)
    labels: list[str] = []

    duplicate = deepcopy(original)
    duplicate["features"][1]["properties"]["district"] = duplicate["features"][0]["properties"]["district"]
    expect_contract_failure("duplicate district", duplicate, spec, "duplicate district")
    labels.append("duplicate district")

    missing_provenance = deepcopy(original)
    del missing_provenance["features"][0]["properties"]["provenance"]
    expect_contract_failure("missing provenance", missing_provenance, spec, "property contract")
    labels.append("missing provenance")

    out_of_range = deepcopy(original)
    out_of_range["features"][0]["properties"][spec.value_field] = 99999
    expect_contract_failure("out-of-range value", out_of_range, spec, "outside")
    labels.append("out-of-range value")

    geometry_mismatch = deepcopy(original)
    geometry_mismatch["features"][0]["geometry"] = deepcopy(
        geometry_mismatch["features"][1]["geometry"]
    )
    district_result = validate_payload(
        load_geojson(DATA / SPECS[0].filename), SPECS[0]
    )
    try:
        validate_payload(
            geometry_mismatch,
            spec,
            reference_order=district_result["order"],
            reference_geometry=district_result["geometries"],
        )
    except ContractError as exc:
        if "geometry differs" not in str(exc).lower():
            raise AssertionError(
                f"geometry mismatch: failed for the wrong reason: {exc!s}"
            ) from exc
        print("[PASS] deliberate corruption rejected: geometry mismatch")
        labels.append("geometry mismatch")
    else:
        raise AssertionError("geometry mismatch: malformed payload was incorrectly accepted")

    extra_property = deepcopy(original)
    extra_property["features"][0]["properties"]["unreviewed_field"] = "unexpected"
    expect_contract_failure("unexpected property", extra_property, spec, "property contract")
    labels.append("unexpected property")

    return labels


def write_summary(
    layer_summaries: list[dict[str, Any]], failure_tests: list[str]
) -> Path:
    output_dir = ROOT / "generated"
    output_dir.mkdir(parents=True, exist_ok=True)
    output = output_dir / "release_contract_summary.json"
    document = {
        "schema_version": "1.0",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "status": "passed",
        "scope": "five archived GeoJSON files",
        "layer_contracts_passed": len(layer_summaries),
        "deliberate_corruptions_rejected": len(failure_tests),
        "layers": layer_summaries,
        "failure_injection_tests": failure_tests,
    }
    output.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    print(f"[WRITE] {output.relative_to(ROOT)}")
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--skip-failure-tests",
        action="store_true",
        help="Validate release files without exercising deliberate corruptions.",
    )
    args = parser.parse_args()

    summaries = validate_release()
    failure_tests = [] if args.skip_failure_tests else run_failure_injection_tests()
    write_summary(summaries, failure_tests)
    print(
        f"\nRelease contract passed: {len(summaries)} layer contracts; "
        f"{len(failure_tests)} deliberate corruptions rejected."
    )


if __name__ == "__main__":
    main()
