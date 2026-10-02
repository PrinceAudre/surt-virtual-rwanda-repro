#!/usr/bin/env python3
"""Strict standard-library validation for declarative harmonization jobs."""

from __future__ import annotations

import json
from pathlib import Path
import re
from typing import Any, Mapping


SCHEMA_VERSION = "1.0"
NAME_PATTERN = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")
JOB_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]*$")
RESERVED_VALUE_NAMES = {
    "unit_id",
    "provenance",
    "geometry",
    "raster_coverage_fraction",
    "valid_within_raster_fraction",
    "valid_data_fraction",
}


class ConfigError(ValueError):
    """Raised when a declarative harmonization job violates the public contract."""


def _fail(path: str, message: str) -> None:
    raise ConfigError(f"{path}: {message}")


def _mapping(value: Any, path: str) -> Mapping[str, Any]:
    if not isinstance(value, dict):
        _fail(path, "must be an object")
    return value


def _exact_keys(value: Mapping[str, Any], path: str, required: set[str]) -> None:
    actual = set(value)
    missing = sorted(required - actual)
    extra = sorted(actual - required)
    if missing:
        _fail(path, f"missing required key(s): {', '.join(missing)}")
    if extra:
        _fail(path, f"unknown key(s): {', '.join(extra)}")


def _nonempty_string(value: Any, path: str) -> str:
    if not isinstance(value, str) or not value.strip():
        _fail(path, "must be a non-empty string")
    return value.strip()


def _number(value: Any, path: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        _fail(path, "must be a finite number")
    numeric = float(value)
    if numeric != numeric or numeric in (float("inf"), float("-inf")):
        _fail(path, "must be a finite number")
    return numeric


def _optional_number(value: Any, path: str) -> float | None:
    if value is None:
        return None
    return _number(value, path)


def load_job_config(path: str | Path) -> dict[str, Any]:
    """Load UTF-8 JSON and validate the common v1.4 configuration contract."""
    config_path = Path(path)
    try:
        value = json.loads(config_path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ConfigError(f"config file not found: {config_path}") from exc
    except json.JSONDecodeError as exc:
        raise ConfigError(
            f"invalid JSON in {config_path}: line {exc.lineno}, column {exc.colno}: {exc.msg}"
        ) from exc
    if not isinstance(value, dict):
        raise ConfigError("configuration root must be an object")
    validate_job_config(value)
    return value


def validate_job_config(config: Mapping[str, Any]) -> None:
    """Validate the provider-independent portion of one harmonization job."""
    root = _mapping(config, "config")
    top_keys = {
        "schema_version",
        "job_id",
        "provider",
        "boundaries",
        "variable",
        "transform",
        "aggregation",
        "qa",
        "output",
        "provenance",
    }
    _exact_keys(root, "config", top_keys)

    if root["schema_version"] != SCHEMA_VERSION:
        _fail("schema_version", f"must equal {SCHEMA_VERSION!r}")
    job_id = _nonempty_string(root["job_id"], "job_id")
    if not JOB_PATTERN.fullmatch(job_id):
        _fail("job_id", "may contain only letters, digits, dot, underscore, and hyphen")

    provider = _mapping(root["provider"], "provider")
    _exact_keys(provider, "provider", {"adapter", "options"})
    _nonempty_string(provider["adapter"], "provider.adapter")
    _mapping(provider["options"], "provider.options")

    boundaries = _mapping(root["boundaries"], "boundaries")
    _exact_keys(boundaries, "boundaries", {"path", "id_field"})
    _nonempty_string(boundaries["path"], "boundaries.path")
    id_field = _nonempty_string(boundaries["id_field"], "boundaries.id_field")
    if not NAME_PATTERN.fullmatch(id_field):
        _fail("boundaries.id_field", "must begin with a letter and contain only letters, digits, and underscores")

    variable = _mapping(root["variable"], "variable")
    _exact_keys(variable, "variable", {"name", "layer"})
    value_name = _nonempty_string(variable["name"], "variable.name")
    if not NAME_PATTERN.fullmatch(value_name):
        _fail("variable.name", "must begin with a letter and contain only letters, digits, and underscores")
    if value_name in RESERVED_VALUE_NAMES:
        _fail("variable.name", f"{value_name!r} is reserved by the output contract")
    layer = variable["layer"]
    if isinstance(layer, bool) or not isinstance(layer, (int, str)):
        _fail("variable.layer", "must be a positive integer index or non-empty layer name")
    if isinstance(layer, int) and layer < 1:
        _fail("variable.layer", "integer layer index must be at least 1")
    if isinstance(layer, str) and not layer.strip():
        _fail("variable.layer", "layer name must be non-empty")

    transform = _mapping(root["transform"], "transform")
    _exact_keys(transform, "transform", {"scale", "offset", "na_below", "na_above"})
    _number(transform["scale"], "transform.scale")
    _number(transform["offset"], "transform.offset")
    na_below = _optional_number(transform["na_below"], "transform.na_below")
    na_above = _optional_number(transform["na_above"], "transform.na_above")
    if na_below is not None and na_above is not None and na_below > na_above:
        _fail("transform", "na_below must not exceed na_above")

    aggregation = _mapping(root["aggregation"], "aggregation")
    _exact_keys(aggregation, "aggregation", {"method", "min_valid_fraction"})
    if aggregation["method"] != "surface_area_weighted_mean":
        _fail("aggregation.method", "must equal 'surface_area_weighted_mean'")
    min_valid = _number(aggregation["min_valid_fraction"], "aggregation.min_valid_fraction")
    if not 0 <= min_valid <= 1:
        _fail("aggregation.min_valid_fraction", "must be between 0 and 1")

    qa = _mapping(root["qa"], "qa")
    _exact_keys(qa, "qa", {"mode", "options"})
    _nonempty_string(qa["mode"], "qa.mode")
    _mapping(qa["options"], "qa.options")

    output = _mapping(root["output"], "output")
    _exact_keys(output, "output", {"path", "crs", "round_digits", "min_value", "max_value"})
    _nonempty_string(output["path"], "output.path")
    if output["crs"] != "EPSG:4326":
        _fail("output.crs", "the current public output contract requires 'EPSG:4326'")
    round_digits = output["round_digits"]
    if round_digits is not None and (isinstance(round_digits, bool) or not isinstance(round_digits, int)):
        _fail("output.round_digits", "must be an integer or null")
    min_value = _optional_number(output["min_value"], "output.min_value")
    max_value = _optional_number(output["max_value"], "output.max_value")
    if min_value is not None and max_value is not None and min_value > max_value:
        _fail("output", "min_value must not exceed max_value")

    provenance = _mapping(root["provenance"], "provenance")
    _exact_keys(provenance, "provenance", {"text"})
    _nonempty_string(provenance["text"], "provenance.text")


def schema_path(root: str | Path) -> Path:
    """Return the machine-readable JSON Schema distributed with the repository."""
    return Path(root) / "config" / "harmonization-job.schema.json"
