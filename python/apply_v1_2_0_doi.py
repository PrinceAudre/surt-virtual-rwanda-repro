#!/usr/bin/env python3
"""Insert the reserved Zenodo DOI into the final v1.2.0 release files."""

from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DOI = "10.5281/zenodo.21744708"
DOI_URL = f"https://doi.org/{DOI}"
DATE = "2026-08-01"
TAG = "v1.2.0"


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding="utf-8", newline="\n")


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected one occurrence, found {count}: {old[:100]!r}")
    write(path, text.replace(old, new))


def regex_once(path: str, pattern: str, replacement: str, flags: int = 0) -> None:
    text = read(path)
    updated, count = re.subn(pattern, replacement, text, flags=flags)
    if count != 1:
        raise SystemExit(f"{path}: expected one regex match, found {count}: {pattern[:100]!r}")
    write(path, updated)


# CITATION.cff
replace_once(
    "CITATION.cff",
    """message: >-
  This is the version 1.2.0 pre-DOI release freeze. The immutable Zenodo
  version DOI will be inserted after reservation and before tagging, archival,
  citation, or journal submission.""",
    """message: >-
  If you use this software, please cite version 1.2.0 using the metadata below.""",
)
replace_once(
    "CITATION.cff",
    """abstract: >-
  Version 1.2.0 pre-DOI release freeze for an Earth Science Informatics
  Software article.""",
    """abstract: >-
  Version 1.2.0 release for an Earth Science Informatics Software article.""",
)
replace_once(
    "CITATION.cff",
    "version: 1.2.0\nlicense: MIT",
    f"version: 1.2.0\ndoi: {DOI}\ndate-released: '{DATE}'\nlicense: MIT",
)
replace_once(
    "CITATION.cff",
    'url: "https://github.com/PrinceAudre/surt-virtual-rwanda-repro/tree/codex/earth-science-informatics-refinement-v1.3.0"',
    f'url: "{DOI_URL}"',
)

# DESCRIPTION
replace_once(
    "DESCRIPTION",
    """    numerical reproduction. This is the version 1.2.0 pre-DOI release freeze;
    the immutable Zenodo version DOI will be inserted before tagging and submission.""",
    f"""    numerical reproduction. Version 1.2.0 is archived at
    DOI {DOI}.""",
)

# README.md
replace_once(
    "README.md",
    "[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21671788.svg)](https://doi.org/10.5281/zenodo.21671788)",
    f"[![DOI](https://zenodo.org/badge/DOI/{DOI}.svg)]({DOI_URL})",
)
replace_once("README.md", "## Version 1.2.0 release freeze", "## Version 1.2.0 release")
replace_once(
    "README.md",
    """The current branch is the **version 1.2.0 pre-DOI release freeze**. It extends the published version 1.1.1 base archive with additional validators, numerical-validation workflows, figures, evidence summaries, and submission records. Scientific and figure review are closed. The immutable Zenodo version DOI must still be reserved and inserted before the exact Git tag, archival publication, citation, or journal submission.

- **Release-freeze version:** `1.2.0`
- **Published base archive:** version 1.1.1, DOI `10.5281/zenodo.21677162`
- **Concept DOI for all versions:** `10.5281/zenodo.21671788`
- **Version DOI:** not yet reserved; no placeholder DOI is asserted
- **Freeze branch:** `codex/earth-science-informatics-refinement-v1.3.0`

Until the version DOI is published, cite version 1.1.1 only for the historical base archive and do not represent it as containing the version 1.2.0 additions.""",
    f"""Version 1.2.0 extends the published version 1.1.1 base archive with additional validators, numerical-validation workflows, figures, evidence summaries, and submission records. The release is identified by an immutable Zenodo version DOI and the exact Git tag `{TAG}`.

- **Release version:** `1.2.0`
- **Version DOI:** `{DOI}`
- **Release tag:** `{TAG}`
- **Concept DOI for all versions:** `10.5281/zenodo.21671788`
- **Historical base archive:** version 1.1.1, DOI `10.5281/zenodo.21677162`

Version 1.1.1 remains the historical base and must not be represented as containing the version 1.2.0 additions.""",
)
replace_once(
    "README.md",
    "The current candidate records lightweight human-readable provenance.",
    "The current release records lightweight human-readable provenance.",
)
replace_once(
    "README.md",
    """For the published base software, cite version 1.1.1:

> Tuyishime AP (2026). SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.1. Zenodo. https://doi.org/10.5281/zenodo.21677162

Version 1.2.0 is frozen pending DOI reservation. After the reserved version DOI is inserted, the complete manifest will be regenerated and the exact commit will be tagged and archived before journal submission.""",
    f"""Cite version 1.2.0:

> Tuyishime AP (2026). SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.2.0. Zenodo. {DOI_URL}

The complete all-tracked manifest is regenerated for the DOI-bearing release, and the archived source is identified by tag `{TAG}`.""",
)

# CHANGELOG.md
replace_once(
    "CHANGELOG.md",
    """- Froze the release-facing package metadata at version 1.2.0 pending reservation and insertion of the immutable Zenodo version DOI.
- Retained version 1.1.1 and DOI `10.5281/zenodo.21677162` as the historical published base archive only.
- Replaced the interim checksum scope with a complete all-tracked SHA-256 manifest; DOI insertion will require one final manifest regeneration and exact-head CI run before tagging and archival.""",
    f"""- Finalized release-facing metadata at version 1.2.0 with immutable Zenodo version DOI `{DOI}` and release date {DATE}.
- Retained version 1.1.1 and DOI `10.5281/zenodo.21677162` as the historical published base archive only.
- Regenerated the complete all-tracked SHA-256 manifest after DOI insertion and required exact-head CI before tagging and archival.""",
)

# REPRODUCIBILITY.md
replace_once(
    "REPRODUCIBILITY.md",
    "## Version 1.2.0 freeze and archive boundary",
    "## Version 1.2.0 release and archive boundary",
)
replace_once(
    "REPRODUCIBILITY.md",
    """The current branch is the version 1.2.0 pre-DOI release freeze. It extends the published version 1.1.1 base archive, DOI `10.5281/zenodo.21677162`, with additional validators, figures, evidence summaries, and submission records. The immutable Zenodo version DOI must be reserved and inserted before the exact Git tag and archival publication.""",
    f"""Version 1.2.0 extends the published version 1.1.1 base archive, DOI `10.5281/zenodo.21677162`, with additional validators, figures, evidence summaries, and submission records. The release is archived under version DOI `{DOI}` and identified in Git by tag `{TAG}`.""",
)
replace_once(
    "REPRODUCIBILITY.md",
    """For the version 1.2.0 freeze, `CHECKSUMS.sha256` is generated with `python python/build_checksum_manifest.py --all-tracked --write` and covers every tracked file except the manifest itself. Verify it with `python python/build_checksum_manifest.py --all-tracked --check`. `CHECKSUMS.scope` is retained as a historical development-scope record and is not the release verification scope.

A successful checksum verification establishes byte-level integrity of tracked files. It does not establish scientific validity. The manifest must be regenerated after the reserved DOI is inserted.""",
    """For version 1.2.0, `CHECKSUMS.sha256` is generated with `python python/build_checksum_manifest.py --all-tracked --write` and covers every tracked file except the manifest itself. Verify it with `python python/build_checksum_manifest.py --all-tracked --check`. `CHECKSUMS.scope` is retained as a historical development-scope record and is not the release verification scope.

A successful checksum verification establishes byte-level integrity of tracked files. It does not establish scientific validity. The committed manifest corresponds to the DOI-bearing release tree.""",
)

# SECURITY_REVIEW.md
replace_once(
    "SECURITY_REVIEW.md",
    "This record documents the security, privacy, credential, and publication-scope review for the Earth Science Informatics journal candidate. It supplements automated checks and does not replace the author's final pre-release inspection.",
    "This record documents the security, privacy, credential, and publication-scope review for the Earth Science Informatics software release and journal package. It supplements automated checks and does not replace the author's final submission inspection.",
)
replace_once(
    "SECURITY_REVIEW.md",
    """## Version 1.2.0 freeze status

The current branch is the version 1.2.0 pre-DOI release freeze based on published version 1.1.1. Historical F1000Research submission artifacts were removed from the active tree without rewriting Git history. No version DOI, Git tag, GitHub release, Zenodo publication, or journal submission is claimed yet.""",
    f"""## Version 1.2.0 release status

Version 1.2.0 is the DOI-bearing release based on published version 1.1.1. Its immutable Zenodo version DOI is `{DOI}`, and its Git release identifier is `{TAG}`. Historical F1000Research submission artifacts were removed from the active tree without rewriting Git history. Journal submission remains a separate author-controlled action.""",
)
replace_once(
    "SECURITY_REVIEW.md",
    "| The pre-DOI freeze may be mistaken for a published release | `CITATION.cff`, `DESCRIPTION`, README, manuscript, and readiness records state that DOI reservation, exact tagging, and archival publication remain pending |",
    f"| Release metadata may be separated from the wrong source tree | `CITATION.cff`, README, manuscript, tag `{TAG}`, DOI `{DOI}`, and the complete manifest must identify the same release |",
)
replace_once(
    "SECURITY_REVIEW.md",
    "## Final release security gate\n\nBefore the candidate is tagged or deposited:",
    "## Final release security gate\n\nThe following controls were required on the DOI-bearing release tree before tagging and deposit:",
)
replace_once(
    "SECURITY_REVIEW.md",
    "The candidate remains a reduced, descriptive, non-operational artifact intended to make the environmental-data preparation and provenance discipline independently inspectable.",
    "Version 1.2.0 remains a reduced, descriptive, non-operational artifact intended to make the environmental-data preparation and provenance discipline independently inspectable.",
)

# paper/manuscript.md
replace_once(
    "paper/manuscript.md",
    "Provenance is recorded as human-readable file and feature metadata; the current candidate does not claim PROV-O or RO-Crate conformance.",
    "Provenance is recorded as human-readable file and feature metadata; the current release does not claim PROV-O or RO-Crate conformance.",
)
replace_once(
    "paper/manuscript.md",
    "Table 3 maps the principal software claims to the corresponding candidate evidence and verification mechanism.",
    "Table 3 maps the principal software claims to the corresponding release evidence and verification mechanism.",
)
replace_once(
    "paper/manuscript.md",
    """For the version 1.2.0 freeze, `CHECKSUMS.sha256` is generated with `python/build_checksum_manifest.py --all-tracked --write` and covers every tracked file except the manifest itself. The runner requires `--all-tracked --check` to reproduce that exact scope and then verifies every listed digest. `CHECKSUMS.scope` is retained as a historical development-scope record. The manifest must be regenerated after the reserved DOI is inserted. A checksum establishes byte integrity, not scientific validity.""",
    """For version 1.2.0, `CHECKSUMS.sha256` is generated with `python/build_checksum_manifest.py --all-tracked --write` and covers every tracked file except the manifest itself. The runner requires `--all-tracked --check` to reproduce that exact scope and then verifies every listed digest. `CHECKSUMS.scope` is retained as a historical development-scope record. The committed manifest corresponds to the DOI-bearing release tree. A checksum establishes byte integrity, not scientific validity.""",
)
replace_once(
    "paper/manuscript.md",
    """The release has further limitations. Annual district summaries suppress seasonality, extremes, and within-district heterogeneity. MODIS quality flags are not applied. Environmental values are point estimates without uncertainty or quality fields. Provider-dependent rebuilds require accounts and network access. The real-data implementation covers one country and one reference year. Only the CHIRPS layer currently has independent public-data computational validation. Version 1.2.0 extends the published v1.1.1 base archive; its immutable version DOI must be reserved, inserted, and archived on the exact tagged commit before journal submission. Table 4 consolidates these limitations and their interpretation consequences.""",
    f"""The release has further limitations. Annual district summaries suppress seasonality, extremes, and within-district heterogeneity. MODIS quality flags are not applied. Environmental values are point estimates without uncertainty or quality fields. Provider-dependent rebuilds require accounts and network access. The real-data implementation covers one country and one reference year. Only the CHIRPS layer currently has independent public-data computational validation. Version 1.2.0 extends the published v1.1.1 base archive and is archived at DOI {DOI} under Git tag `{TAG}`. Table 4 consolidates these limitations and their interpretation consequences.""",
)
replace_once(
    "paper/manuscript.md",
    "- **Release freeze:** version 1.2.0 on `codex/earth-science-informatics-refinement-v1.3.0`; the immutable Zenodo version DOI will be inserted after reservation and before exact tagging, archival publication, citation, or submission",
    f"- **Release archive:** version 1.2.0, {DOI_URL}, Git tag `{TAG}`",
)
replace_once(
    "paper/manuscript.md",
    """The version 1.2.0 source tree, manuscript, metadata, and figures are frozen in a pre-DOI state, and the complete tracked-file checksum manifest is generated. Before submission, the reserved version DOI will be inserted, the manifest regenerated, and the exact commit tagged and archived. The final submitted manuscript will replace the branch reference above with that immutable version DOI.""",
    f"""The version 1.2.0 source tree, manuscript, metadata, figures, and complete tracked-file checksum manifest are synchronized to the immutable archive DOI {DOI} and Git tag `{TAG}`. Journal submission uses this exact archived version.""",
)
replace_once(
    "paper/manuscript.md",
    """The published base outputs and software remain archived in Zenodo version 1.1.1 (Tuyishime 2026). Version 1.2.0 includes the additional verification, numerical-validation, figure, integrity, and journal-packaging files described here. Its immutable Zenodo version DOI is pending reservation and will be inserted before the exact commit is tagged, archived, cited, or submitted.""",
    f"""The complete version 1.2.0 outputs, software, validators, numerical-validation workflow, figures, integrity metadata, and journal-packaging files are archived at Zenodo DOI {DOI} (Tuyishime 2026). The earlier version 1.1.1 archive remains the historical base at DOI 10.5281/zenodo.21677162.""",
)
replace_once(
    "paper/manuscript.md",
    "Tuyishime AP (2026) SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.1. Zenodo [Software]. https://doi.org/10.5281/zenodo.21677162",
    f"Tuyishime AP (2026) SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.2.0. Zenodo [Software]. {DOI_URL}",
)
replace_once("paper/manuscript.md", "| Software claim | Candidate evidence | Verification |", "| Software claim | Release evidence | Verification |")
replace_once(
    "paper/manuscript.md",
    """| Interim integrity manifest matches its declared scope | `CHECKSUMS.scope`, `CHECKSUMS.sha256`, and manifest builder | `python/build_checksum_manifest.py --check` |
| Every interim listed file has its recorded digest | `CHECKSUMS.sha256` | SHA-256 verification in `python/run_all_checks.py` |""",
    """| Complete release manifest matches the tracked-file scope | `CHECKSUMS.sha256` and manifest builder | `python/build_checksum_manifest.py --all-tracked --check` |
| Every release file has its recorded digest | `CHECKSUMS.sha256` | SHA-256 verification in `python/run_all_checks.py` |""",
)
replace_once(
    "paper/manuscript.md",
    "| Version 1.2.0 extends the published v1.1.1 base | The reserved version DOI, regenerated complete manifest, exact tag, and immutable archive are required before submission |",
    f"| Version 1.2.0 extends the published v1.1.1 base | Reuse and submission must cite the immutable version DOI {DOI} and exact tag `{TAG}` |",
)
replace_once(
    "paper/manuscript.md",
    """Version 1.2.0 contains the base software and district outputs together with the validators, numerical-validation workflow, figure pipeline, machine-readable evidence summaries, manifest builder, and submission records described in this manuscript. Its immutable version DOI must be inserted and the exact commit tagged and archived before submission.""",
    f"""Version 1.2.0 contains the base software and district outputs together with the validators, numerical-validation workflow, figure pipeline, machine-readable evidence summaries, manifest builder, and submission records described in this manuscript. The release is archived at {DOI_URL} and identified by Git tag `{TAG}`.""",
)
replace_once(
    "paper/manuscript.md",
    "- `CHECKSUMS.scope` and `CHECKSUMS.sha256`: interim stable-file scope and corresponding integrity manifest;",
    "- `CHECKSUMS.sha256`: complete all-tracked integrity manifest; `CHECKSUMS.scope`: historical development-scope record;",
)

# paper/EDITORIAL_READINESS.md
replace_once(
    "paper/EDITORIAL_READINESS.md",
    """**Release-gated, not ready for submission.** The scientific, manuscript, reference, software-verification, public-CHIRPS-validation, and figure-review gates are closed. The candidate must still receive a frozen semantic version, complete tracked-file checksum manifest, exact Git tag, immutable Zenodo version DOI, final Springer DOCX/PDF package, and author-only sign-offs before submission.""",
    f"""**DOI-bearing release prepared; not yet ready for journal submission.** The scientific, manuscript, reference, software-verification, public-CHIRPS-validation, figure-review, semantic-version, DOI-insertion, and complete-manifest gates are closed for version 1.2.0. Remaining gates are exact-head CI confirmation, Git tag `{TAG}`, GitHub release, Zenodo publication under DOI `{DOI}`, final Springer DOCX/PDF inspection, and author-only sign-offs.""",
)
replace_once(
    "paper/EDITORIAL_READINESS.md",
    "- **Closed review baseline:** `952fda78611358416706202ec15f811072961c4b`",
    f"- **Closed review baseline:** `952fda78611358416706202ec15f811072961c4b`\n- **Release version:** `1.2.0`\n- **Version DOI:** `{DOI}`\n- **Release tag:** `{TAG}`",
)
regex_once(
    "paper/EDITORIAL_READINESS.md",
    r"## Candidate-release gates\n.*?\n## Submission-package cleanup",
    f"""## Release gates

The published v1.1.1 archive, DOI `10.5281/zenodo.21677162`, predates the journal-release validators, figures, timing metadata, and public-data validation. It remains the historical base only.

Completed for version 1.2.0:

1. Author authorization to freeze version 1.2.0.
2. Synchronized `DESCRIPTION`, `CITATION.cff`, `CHANGELOG.md`, README, manuscript, and release-facing documentation.
3. Reserved and inserted immutable Zenodo version DOI `{DOI}`.
4. Regenerated the complete all-tracked checksum manifest after DOI insertion.
5. Re-ran release-metadata and manuscript audits on the DOI-bearing tree.

Remaining before journal submission:

1. Confirm all exact-head CI workflows pass on the final DOI-bearing commit.
2. Create Git tag `{TAG}` and the corresponding GitHub release from that exact commit.
3. Upload the exact tagged source archive to the Zenodo new-version draft and publish it under DOI `{DOI}`.
4. Confirm that the published DOI resolves and that the archive contains every cited software, data, figure-source, validation, and supplementary file.
5. Record the exact commit, tag, GitHub release, Zenodo version, checksum manifest, and CI run identifiers.
6. Build and inspect the final Springer DOCX and PDF.
7. Complete author-only sign-offs on the exact submission package.

No placeholder DOI or development version may appear in the submission.

## Submission-package cleanup""",
    flags=re.DOTALL,
)
replace_once(
    "paper/EDITORIAL_READINESS.md",
    "The final Word file is built only after the release and DOI gates close.",
    "The final Word file is built after the DOI-bearing release commit passes exact-head CI and the GitHub and Zenodo archives are published.",
)

# python/validate_candidate_metadata.py: replace the whole validator with final-release rules.
validator = f'''#!/usr/bin/env python3
"""Validate the final version 1.2.0 DOI-bearing release metadata."""

from __future__ import annotations

import re
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_TITLE = (
    "An auditable cross-provider workflow for district-scale Earth-data "
    "harmonization and provenance labelling: software design and a Rwanda "
    "implementation"
)
VERSION = "1.2.0"
RELEASE_DOI = "{DOI}"
RELEASE_DATE = "{DATE}"
RELEASE_TAG = "{TAG}"
BASE_VERSION = "1.1.1"
BASE_DOI = "10.5281/zenodo.21677162"
ORCID = "0009-0002-0799-3140"

class MetadataError(ValueError):
    """Raised when release metadata are incomplete or inconsistent."""

def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        raise MetadataError(f"missing required metadata file: {{relative}}")
    return path.read_text(encoding="utf-8")

def require(condition: bool, message: str) -> None:
    if not condition:
        raise MetadataError(message)
    print(f"[PASS] {{message}}")

def top_level_yaml_value(text: str, key: str) -> str | None:
    match = re.search(rf"^{{re.escape(key)}}:\\s*(.*?)\\s*$", text, re.MULTILINE)
    return match.group(1).strip().strip("\\\"'") if match else None

def description_value(text: str, key: str) -> str | None:
    match = re.search(rf"^{{re.escape(key)}}:\\s*(.*?)\\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else None

def manuscript_abstract(manuscript: str) -> str:
    match = re.search(
        r"^## Abstract\\s*\\n+(.*?)\\n+\\*\\*Keywords:\\*\\*",
        manuscript,
        flags=re.MULTILINE | re.DOTALL,
    )
    if not match:
        raise MetadataError("manuscript abstract or keyword boundary is missing")
    return re.sub(r"\\s+", " ", match.group(1)).strip()

def manuscript_keywords(manuscript: str) -> list[str]:
    match = re.search(r"^\\*\\*Keywords:\\*\\*\\s*(.+)$", manuscript, re.MULTILINE)
    if not match:
        raise MetadataError("manuscript keyword line is missing")
    return [item.strip() for item in match.group(1).split(";") if item.strip()]

def word_count(text: str) -> int:
    return len(re.findall(r"\\b[\\w][\\w’'\\-]*\\b", text, flags=re.UNICODE))

def tracked_paths() -> list[str]:
    completed = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if completed.returncode:
        raise MetadataError(
            "git ls-files failed: "
            + completed.stderr.decode("utf-8", errors="replace").strip()
        )
    return [
        item.decode("utf-8").replace("\\\\", "/")
        for item in completed.stdout.split(b"\\0")
        if item
    ]

def main() -> None:
    manuscript = read("paper/manuscript.md")
    readme = read("README.md")
    citation = read("CITATION.cff")
    description = read("DESCRIPTION")
    changelog = read("CHANGELOG.md")

    require(manuscript.startswith(f"# {{EXPECTED_TITLE}}\\n"), "manuscript title matches the designated release title")
    require(EXPECTED_TITLE in readme, "README names the same manuscript")
    require(description_value(description, "Version") == VERSION, f"DESCRIPTION version is {{VERSION}}")
    require(top_level_yaml_value(citation, "version") == VERSION, f"CITATION.cff version is {{VERSION}}")
    require(top_level_yaml_value(citation, "cff-version") == "1.2.0", "CITATION.cff declares schema version 1.2.0")
    require(top_level_yaml_value(citation, "doi") == RELEASE_DOI, f"CITATION.cff DOI is {{RELEASE_DOI}}")
    require(top_level_yaml_value(citation, "date-released") == RELEASE_DATE, f"CITATION.cff release date is {{RELEASE_DATE}}")

    for label, text in {{
        "README": readme,
        "manuscript": manuscript,
        "CITATION.cff": citation,
        "CHANGELOG": changelog,
    }}.items():
        require(VERSION in text and RELEASE_DOI in text, f"{{label}} identifies version {{VERSION}} and its DOI")
        require(BASE_VERSION in text and BASE_DOI in text, f"{{label}} preserves the historical base version and DOI")

    require(RELEASE_TAG in readme, "README identifies the exact release tag")
    require(RELEASE_TAG in manuscript, "manuscript identifies the exact release tag")
    require(ORCID in manuscript, "manuscript contains the designated ORCID")
    require(ORCID in citation, "CITATION.cff contains the designated ORCID")

    abstract_words = word_count(manuscript_abstract(manuscript))
    require(150 <= abstract_words <= 250, f"abstract length is within 150 to 250 words ({{abstract_words}})")
    keywords = manuscript_keywords(manuscript)
    require(4 <= len(keywords) <= 6, f"manuscript contains four to six keywords ({{len(keywords)}})")
    require(len({{keyword.casefold() for keyword in keywords}}) == len(keywords), "manuscript keywords are unique")

    paths = tracked_paths()
    forbidden_active_paths = [
        path for path in paths
        if "f1000" in path.casefold() and not path.startswith("paper/archive/")
    ]
    require(not forbidden_active_paths, "no active tracked path is specific to the historical F1000 submission")
    active_submission_files = [path for path in paths if path.startswith("paper/submission/")]
    require(not active_submission_files, "active submission directory is empty until the Earth Science Informatics build")

    release_facing = "\\n".join([citation, description, readme, changelog, manuscript])
    for stale in ("pre-DOI", "pending DOI reservation", "not yet reserved", "1.2.0-dev", "1.2.0.9000"):
        require(stale.casefold() not in release_facing.casefold(), f"stale release token is absent: {{stale}}")

    doi_url = f"https://doi.org/{{RELEASE_DOI}}"
    require(doi_url in readme and doi_url in manuscript, "README and manuscript use the release DOI URL")
    require("archived" in manuscript.casefold() and RELEASE_DOI in manuscript, "manuscript identifies the immutable release archive")

    print("\\nVersion 1.2.0 DOI-bearing release metadata validation passed.")

if __name__ == "__main__":
    try:
        main()
    except MetadataError as exc:
        raise SystemExit(f"Release metadata validation failed: {{exc}}") from exc
'''
write("python/validate_candidate_metadata.py", validator)

# python/audit_manuscript.py
replace_once(
    "python/audit_manuscript.py",
    '    "10.5281/zenodo.21677162",',
    f'    "{DOI}",',
)
replace_once(
    "python/audit_manuscript.py",
    '''    "validated flood susceptibility",
]''',
    '''    "validated flood susceptibility",
    "pre-DOI",
    "pending reservation",
    "reserved version DOI",
]''',
)
regex_once(
    "python/audit_manuscript.py",
    r'''    require\(
\s*"version 1\.2\.0" in text\.casefold\(\)
\s*and "reserved version doi" in text\.casefold\(\)
\s*and "before submission" in text\.casefold\(\)
\s*and "tagged and archived" in text\.casefold\(\),
\s*"v1\.2\.0 DOI, tag, and archive dependency is explicit",
\s*\)''',
    f'''    require(
        "version 1.2.0" in text.casefold()
        and "{DOI}" in text
        and "{TAG}" in text
        and "archived" in text.casefold(),
        "v1.2.0 DOI, tag, and immutable archive identity is explicit",
    )''',
    flags=re.MULTILINE,
)

# Final cross-file assertions before the helper is removed.
for path in (
    "CITATION.cff",
    "DESCRIPTION",
    "README.md",
    "CHANGELOG.md",
    "REPRODUCIBILITY.md",
    "SECURITY_REVIEW.md",
    "paper/manuscript.md",
    "paper/EDITORIAL_READINESS.md",
    "python/validate_candidate_metadata.py",
    "python/audit_manuscript.py",
):
    text = read(path)
    if "1.2.0.9000" in text or "1.2.0-dev" in text:
        raise SystemExit(f"{path}: development version token remains")

print(f"Inserted release DOI {DOI} and release date {DATE}.")
