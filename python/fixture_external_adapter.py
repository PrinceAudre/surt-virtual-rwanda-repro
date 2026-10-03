#!/usr/bin/env python3
"""Account-free external adapter fixture for the v1.4 plugin contract tests."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Mapping

from provider_adapters import AdapterError, PreparedRaster, resolve_path


class FixtureExternalAdapter:
    """Minimal external adapter used only to prove the module:factory extension path."""

    name = "fixture_external"

    def validate_options(
        self,
        options: Mapping[str, Any],
        qa: Mapping[str, Any],
    ) -> None:
        if set(options) != {"path", "label"}:
            raise AdapterError("fixture_external options must contain only 'path' and 'label'")
        if not isinstance(options["path"], str) or not options["path"].strip():
            raise AdapterError("fixture_external options.path must be a non-empty string")
        if not isinstance(options["label"], str) or not options["label"].strip():
            raise AdapterError("fixture_external options.label must be a non-empty string")
        if qa.get("mode") != "none" or qa.get("options") != {}:
            raise AdapterError("fixture_external accepts qa.mode='none' with empty qa.options only")

    def prepare(
        self,
        options: Mapping[str, Any],
        qa: Mapping[str, Any],
        root: Path,
    ) -> PreparedRaster:
        self.validate_options(options, qa)
        path = resolve_path(root, str(options["path"]))
        if not path.is_file():
            raise AdapterError(f"fixture_external artifact not found: {path}")
        return PreparedRaster(
            path=path,
            provenance_suffix=f"External adapter fixture: {options['label'].strip()}",
        )


def make_adapter() -> FixtureExternalAdapter:
    """Return a valid external adapter without editing the core registry."""
    return FixtureExternalAdapter()


def make_invalid_adapter() -> object:
    """Return a deliberately invalid object for fail-closed shape testing."""
    return object()
