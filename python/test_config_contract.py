#!/usr/bin/env python3
"""Account-free regression tests for declarative configuration and adapter loading."""

from __future__ import annotations

from copy import deepcopy
import importlib
import json
from pathlib import Path
import sys
import tempfile

from config_contract import ConfigError, load_job_config, validate_job_config
from provider_adapters import AdapterError, LocalRasterAdapter, load_adapter
from run_configured_harmonization import build_harmonizer_command


ROOT = Path(__file__).resolve().parents[1]
DEMO_CONFIG = ROOT / "config" / "demo-harmonization.json"
passed = 0


def check(label: str, condition: bool) -> None:
    global passed
    if not condition:
        raise SystemExit(f"[FAIL] {label}")
    passed += 1
    print(f"[PASS] {label}")


def expect_error(label: str, function, expected: str) -> None:
    try:
        function()
    except (ConfigError, AdapterError) as exc:
        check(label, expected.casefold() in str(exc).casefold())
        return
    raise SystemExit(f"[FAIL] {label}: invalid configuration was accepted")


def main() -> None:
    config = load_job_config(DEMO_CONFIG)
    check("bundled declarative demo config validates", config["schema_version"] == "1.0")

    mutated = deepcopy(config)
    mutated["unexpected"] = True
    expect_error(
        "unknown top-level configuration key fails closed",
        lambda: validate_job_config(mutated),
        "unknown key",
    )

    mutated = deepcopy(config)
    mutated["transform"]["mystery"] = 1
    expect_error(
        "unknown nested transform key fails closed",
        lambda: validate_job_config(mutated),
        "unknown key",
    )

    mutated = deepcopy(config)
    mutated["variable"]["name"] = "9invalid"
    expect_error(
        "invalid output variable name fails closed",
        lambda: validate_job_config(mutated),
        "must begin with a letter",
    )

    mutated = deepcopy(config)
    mutated["aggregation"]["min_valid_fraction"] = 1.1
    expect_error(
        "coverage threshold outside zero-to-one fails closed",
        lambda: validate_job_config(mutated),
        "between 0 and 1",
    )

    mutated = deepcopy(config)
    mutated["output"]["crs"] = "EPSG:3857"
    expect_error(
        "unsupported configured output CRS fails closed",
        lambda: validate_job_config(mutated),
        "EPSG:4326",
    )

    adapter = LocalRasterAdapter()
    mutated = deepcopy(config)
    mutated["qa"] = {"mode": "cloud_mask", "options": {}}
    expect_error(
        "local raster adapter rejects undeclared provider QA",
        lambda: adapter.validate_options(mutated["provider"]["options"], mutated["qa"]),
        "qa.mode='none'",
    )

    mutated = deepcopy(config)
    mutated["provider"]["options"]["extra"] = "not-allowed"
    expect_error(
        "local raster adapter rejects unknown provider options",
        lambda: adapter.validate_options(mutated["provider"]["options"], mutated["qa"]),
        "unknown",
    )

    expect_error(
        "unknown adapter fails closed with plugin guidance",
        lambda: load_adapter("not_registered"),
        "module:factory",
    )

    # Repository fixture proves the normal module:factory path while remaining
    # absent from the built-in registry.
    external = load_adapter("fixture_external_adapter:make_adapter")
    check(
        "external module factory loads a provider without core-registry edits",
        external.name == "fixture_external",
    )
    expect_error(
        "malformed external adapter object fails closed at the plugin boundary",
        lambda: load_adapter("fixture_external_adapter:make_invalid_adapter"),
        "non-empty string 'name'",
    )

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        missing = temp_path / "missing.tif"
        expect_error(
            "local raster adapter fails closed on missing prepared artifact",
            lambda: adapter.prepare({"path": str(missing)}, {"mode": "none", "options": {}}, ROOT),
            "artifact not found",
        )

        dummy = temp_path / "prepared.tif"
        dummy.write_bytes(b"fixture")
        artifact = adapter.prepare({"path": str(dummy)}, {"mode": "none", "options": {}}, ROOT)
        check("local raster adapter resolves an existing prepared artifact", artifact.path == dummy)

        external_artifact = external.prepare(
            {"path": str(dummy), "label": "account-free plugin proof"},
            {"mode": "none", "options": {}},
            ROOT,
        )
        check(
            "external adapter prepares the same declared artifact through the plugin contract",
            external_artifact.path == dummy
            and external_artifact.provenance_suffix == "External adapter fixture: account-free plugin proof",
        )
        expect_error(
            "external adapter rejects undeclared options",
            lambda: external.prepare(
                {"path": str(dummy), "label": "fixture", "extra": True},
                {"mode": "none", "options": {}},
                ROOT,
            ),
            "only 'path' and 'label'",
        )

        # Array E3: construct a provider module outside the repository at runtime.
        # Loading and execution must require no edit to _BUILTINS, provider_adapters.py,
        # or the generic R harmonizer.
        module_name = "array_out_of_tree_adapter"
        module_path = temp_path / f"{module_name}.py"
        module_path.write_text(
            "from pathlib import Path\n"
            "from provider_adapters import PreparedRaster\n\n"
            "class TempAdapter:\n"
            "    name = 'array_out_of_tree'\n"
            "    def validate_options(self, options, qa):\n"
            "        if set(options) != {'path'}:\n"
            "            raise ValueError('path only')\n"
            "        if qa != {'mode': 'none', 'options': {}}:\n"
            "            raise ValueError('qa none only')\n"
            "    def prepare(self, options, qa, root):\n"
            "        self.validate_options(options, qa)\n"
            "        p = Path(options['path'])\n"
            "        if not p.is_file():\n"
            "            raise ValueError('missing artifact')\n"
            "        return PreparedRaster(path=p, provenance_suffix='Temporary out-of-tree adapter')\n\n"
            "def make_adapter():\n"
            "    return TempAdapter()\n",
            encoding="utf-8",
        )
        check(
            "out-of-tree adapter fixture is physically outside the repository",
            ROOT.resolve() not in module_path.resolve().parents,
        )
        sys.path.insert(0, str(temp_path))
        importlib.invalidate_caches()
        try:
            temp_adapter = load_adapter(f"{module_name}:make_adapter")
            check(
                "out-of-tree module factory loads without built-in registry edits",
                temp_adapter.name == "array_out_of_tree",
            )
            temp_artifact = temp_adapter.prepare(
                {"path": str(dummy)},
                {"mode": "none", "options": {}},
                ROOT,
            )
            check(
                "out-of-tree adapter preserves the declared artifact and provenance boundary",
                temp_artifact.path == dummy
                and temp_artifact.provenance_suffix == "Temporary out-of-tree adapter",
            )
        finally:
            sys.modules.pop(module_name, None)
            try:
                sys.path.remove(str(temp_path))
            except ValueError:
                pass

    command = build_harmonizer_command(config, Path("/tmp/prepared.tif"), ROOT)
    joined = "\n".join(command)
    check(
        "config runner maps raw masking, scale, offset, and coverage controls to generic CLI",
        all(flag in command for flag in (
            "--na-below", "--scale", "--offset", "--min-valid-fraction", "--round-digits"
        )),
    )
    check(
        "config runner preserves configured value name and provenance",
        config["variable"]["name"] in joined and config["provenance"]["text"] in joined,
    )

    schema = json.loads((ROOT / "config" / "harmonization-job.schema.json").read_text(encoding="utf-8"))
    check(
        "machine-readable schema declares the same configuration version",
        schema["properties"]["schema_version"]["const"] == config["schema_version"],
    )

    print(f"\n=== declarative configuration and adapter contract: {passed} passed, 0 failed ===")


if __name__ == "__main__":
    main()
