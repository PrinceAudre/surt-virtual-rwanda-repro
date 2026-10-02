#!/usr/bin/env python3
"""Stable provider-adapter contract for SuRT-GeoHarmonizer v1.4 development."""

from __future__ import annotations

from dataclasses import dataclass
import importlib
from pathlib import Path
from typing import Any, Mapping, Protocol


class AdapterError(ValueError):
    """Raised when a provider adapter cannot validate or prepare its raster artifact."""


@dataclass(frozen=True)
class PreparedRaster:
    """Raster artifact returned by an adapter before generic harmonization."""

    path: Path
    provenance_suffix: str = ""


class ProviderAdapter(Protocol):
    """Protocol implemented by built-in or externally loaded provider adapters."""

    name: str

    def validate_options(
        self,
        options: Mapping[str, Any],
        qa: Mapping[str, Any],
    ) -> None:
        """Validate provider and QA configuration without requiring generated files."""

    def prepare(
        self,
        options: Mapping[str, Any],
        qa: Mapping[str, Any],
        root: Path,
    ) -> PreparedRaster:
        """Return a prepared raster suitable for the generic harmonizer."""


def resolve_path(root: Path, value: str) -> Path:
    """Resolve repository-relative paths while preserving explicit absolute paths."""
    path = Path(value).expanduser()
    return path if path.is_absolute() else (root / path).resolve()


class LocalRasterAdapter:
    """Pass an already prepared local raster into the generic harmonizer."""

    name = "local_raster"

    def validate_options(
        self,
        options: Mapping[str, Any],
        qa: Mapping[str, Any],
    ) -> None:
        if set(options) != {"path"}:
            extra = sorted(set(options) - {"path"})
            missing = sorted({"path"} - set(options))
            details = []
            if missing:
                details.append(f"missing: {', '.join(missing)}")
            if extra:
                details.append(f"unknown: {', '.join(extra)}")
            raise AdapterError("local_raster options must contain only 'path' (" + "; ".join(details) + ")")
        if not isinstance(options["path"], str) or not options["path"].strip():
            raise AdapterError("local_raster options.path must be a non-empty string")
        if qa.get("mode") != "none" or qa.get("options") != {}:
            raise AdapterError(
                "local_raster accepts qa.mode='none' with empty qa.options only; "
                "provider-specific QA belongs in a provider adapter"
            )

    def prepare(
        self,
        options: Mapping[str, Any],
        qa: Mapping[str, Any],
        root: Path,
    ) -> PreparedRaster:
        self.validate_options(options, qa)
        path = resolve_path(root, str(options["path"]))
        if not path.is_file():
            raise AdapterError(f"local_raster artifact not found: {path}")
        return PreparedRaster(path=path)


_BUILTINS = {
    "local_raster": LocalRasterAdapter,
}


def _validate_adapter_shape(adapter: Any, spec: str) -> ProviderAdapter:
    name = getattr(adapter, "name", None)
    if not isinstance(name, str) or not name.strip():
        raise AdapterError(f"adapter {spec!r} must expose a non-empty string 'name'")
    for method in ("validate_options", "prepare"):
        if not callable(getattr(adapter, method, None)):
            raise AdapterError(f"adapter {spec!r} must implement {method}()")
    return adapter


def load_adapter(spec: str) -> ProviderAdapter:
    """Load a built-in adapter or an external `module:factory` plugin.

    External factories are zero-argument callables returning an object that follows
    ProviderAdapter. This extension mechanism lets a new provider live outside the
    core harmonization code and avoids editing the generic R engine.
    """
    if spec in _BUILTINS:
        return _BUILTINS[spec]()
    if ":" not in spec:
        raise AdapterError(
            f"unknown provider adapter {spec!r}; use a built-in adapter or 'module:factory'"
        )
    module_name, factory_name = spec.split(":", 1)
    if not module_name or not factory_name:
        raise AdapterError("external adapter spec must be 'module:factory'")
    try:
        module = importlib.import_module(module_name)
    except Exception as exc:
        raise AdapterError(f"could not import adapter module {module_name!r}: {exc}") from exc
    factory = getattr(module, factory_name, None)
    if not callable(factory):
        raise AdapterError(f"adapter factory {factory_name!r} was not found in {module_name!r}")
    try:
        adapter = factory()
    except Exception as exc:
        raise AdapterError(f"adapter factory {spec!r} failed: {exc}") from exc
    return _validate_adapter_shape(adapter, spec)


def validate_adapter_config(config: Mapping[str, Any]) -> ProviderAdapter:
    """Load the configured adapter and validate its provider and QA sections."""
    provider = config["provider"]
    qa = config["qa"]
    adapter = load_adapter(str(provider["adapter"]))
    adapter.validate_options(provider["options"], qa)
    return adapter
