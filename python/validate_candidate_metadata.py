#!/usr/bin/env python3
"""Compatibility entry point for the superseded v1.3 candidate validator.

The active peer-review remediation target is v1.4.0 on
``review/softwarex-resubmission-v1.4.0``. Historical v1.3.0 release metadata are
immutable and are validated only as historical baselines by the active
``validate_resubmission_metadata.py`` gate.

This file remains at its historical path so old documentation or local scripts do
not silently execute stale v1.3 submission assumptions. Running it delegates to
the current v1.4 remediation validator.
"""

from __future__ import annotations

import runpy
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ACTIVE_VALIDATOR = ROOT / "python" / "validate_resubmission_metadata.py"


def main() -> None:
    if not ACTIVE_VALIDATOR.is_file():
        raise SystemExit(
            "Active v1.4 metadata validator is missing: "
            f"{ACTIVE_VALIDATOR.relative_to(ROOT)}"
        )
    print(
        "[DEPRECATED] python/validate_candidate_metadata.py was the v1.3 candidate "
        "validator; delegating to python/validate_resubmission_metadata.py."
    )
    runpy.run_path(str(ACTIVE_VALIDATOR), run_name="__main__")


if __name__ == "__main__":
    main()
