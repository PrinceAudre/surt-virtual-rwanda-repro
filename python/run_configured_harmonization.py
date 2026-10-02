#!/usr/bin/env python3
"""Execute one validated declarative harmonization job through the generic R core."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
from typing import Any, Mapping

from config_contract import ConfigError, load_job_config
from provider_adapters import AdapterError, resolve_path, validate_adapter_config


ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", required=True, help="Path to a harmonization-job JSON file")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Validate schema and adapter options without requiring prepared input files",
    )
    return parser.parse_args()


def _append_optional(command: list[str], flag: str, value: Any) -> None:
    if value is not None:
        command.extend([flag, str(value)])


def build_harmonizer_command(
    config: Mapping[str, Any],
    raster_path: Path,
    root: Path = ROOT,
) -> list[str]:
    """Translate the declarative contract into the existing provider-agnostic R CLI."""
    rscript = shutil.which("Rscript") or "Rscript"
    boundaries = resolve_path(root, str(config["boundaries"]["path"]))
    output = resolve_path(root, str(config["output"]["path"]))
    provenance = str(config["provenance"]["text"])

    command = [
        rscript,
        str(root / "R" / "harmonize_admin_raster.R"),
        "--raster",
        str(raster_path),
        "--boundaries",
        str(boundaries),
        "--id-field",
        str(config["boundaries"]["id_field"]),
        "--value-name",
        str(config["variable"]["name"]),
        "--output",
        str(output),
        "--provenance",
        provenance,
        "--layer",
        str(config["variable"]["layer"]),
        "--scale",
        str(config["transform"]["scale"]),
        "--offset",
        str(config["transform"]["offset"]),
        "--min-valid-fraction",
        str(config["aggregation"]["min_valid_fraction"]),
    ]
    _append_optional(command, "--na-below", config["transform"]["na_below"])
    _append_optional(command, "--na-above", config["transform"]["na_above"])
    _append_optional(command, "--round-digits", config["output"]["round_digits"])
    _append_optional(command, "--min-value", config["output"]["min_value"])
    _append_optional(command, "--max-value", config["output"]["max_value"])
    return command


def validate_config_and_adapter(config_path: str | Path) -> tuple[dict[str, Any], Any]:
    config = load_job_config(config_path)
    adapter = validate_adapter_config(config)
    return config, adapter


def main() -> None:
    args = parse_args()
    try:
        config, adapter = validate_config_and_adapter(args.config)
        if args.validate_only:
            print(json.dumps({
                "status": "valid",
                "schema_version": config["schema_version"],
                "job_id": config["job_id"],
                "adapter": config["provider"]["adapter"],
                "output": config["output"]["path"],
            }, sort_keys=True))
            return

        artifact = adapter.prepare(config["provider"]["options"], config["qa"], ROOT)
        boundaries = resolve_path(ROOT, str(config["boundaries"]["path"]))
        if not boundaries.is_file():
            raise ConfigError(f"boundary artifact not found: {boundaries}")
        command = build_harmonizer_command(config, artifact.path, ROOT)
        if artifact.provenance_suffix:
            provenance_index = command.index("--provenance") + 1
            command[provenance_index] = (
                command[provenance_index].rstrip("; ") + "; " + artifact.provenance_suffix.strip()
            )
        if shutil.which(command[0]) is None:
            raise ConfigError("Rscript is required but was not found on PATH")

        completed = subprocess.run(command, cwd=ROOT, check=False)
        if completed.returncode:
            raise SystemExit(completed.returncode)
        output = resolve_path(ROOT, str(config["output"]["path"]))
        if not output.is_file() or output.stat().st_size == 0:
            raise ConfigError(f"configured output was not written: {output}")
        print(f"[WRITE] {output.relative_to(ROOT) if output.is_relative_to(ROOT) else output}")
    except (ConfigError, AdapterError) as exc:
        raise SystemExit(f"FAIL-CLOSED: {exc}") from exc


if __name__ == "__main__":
    main()
