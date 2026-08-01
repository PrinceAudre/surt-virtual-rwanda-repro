#!/usr/bin/env python3
"""One-time exact-base integration of the reviewed manuscript changes."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "paper" / "manuscript.md"
EXPECTED_BASE_GIT_BLOB = "54619a4ba4e6e7815909aa4237dc5bab46270913"
EXPECTED_RESULT_SHA256 = "300a01ce116e0421553f069527531ec9268afe9023d73b4d01cb7585f2c9e50f"


def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()


def replace_once(text: str, old: str, new: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected one manuscript anchor, found {count}: {old[:100]!r}")
    return text.replace(old, new)


def main() -> None:
    data = PATH.read_bytes()
    actual_base = git_blob_sha(data)
    if actual_base != EXPECTED_BASE_GIT_BLOB:
        raise SystemExit(
            f"Refusing stale manuscript update: expected Git blob {EXPECTED_BASE_GIT_BLOB}, "
            f"found {actual_base}"
        )
    text = data.decode("utf-8")

    text = text.replace("Munoz-Sabater", "Muñoz-Sabater")
    text = text.replace("Agusti-Panareda", "Agustí-Panareda")

    text = replace_once(
        text,
        "Rwanda is the real-data reference implementation. The artifact excludes",
        "Rwanda is the real-data reference implementation. Portability is claimed only at the function-interface level demonstrated with arbitrary identifiers and projected synthetic geometry; end-to-end deployment in a second country has not been evaluated. The artifact excludes",
    )
    text = replace_once(
        text,
        "fixed integrity values, and an archived version.",
        "fixed integrity values, and an archived version. Table 2 summarizes the relationship between these adjacent tools or standards and the present workflow.",
    )
    text = replace_once(
        text,
        "The rule is fail closed: incomplete declarations are not promoted to source-derived status. The module validates declarations and presentation behaviour. It does not independently establish that a citation is correct, that every external application routes values through the module, or that a declared method was implemented faithfully outside the released repository. Provenance is recorded as human-readable file and feature metadata; the current candidate does not claim PROV-O or RO-Crate conformance.",
        "Figure 3 separates the implementation into three independent controls. First, `surt_method_register_ok()` validates the required register structure, legal vocabularies, and the prohibition on combining `source-derived` evidence with a `placeholder` method. Second, `surt_output_is_illustrative()` applies the fail-closed display rule independently: an output remains illustrative unless its identifier is present and its `evidence_class` is exactly `source-derived`; this function does not inspect `method_class` or independently verify that real or public data were used. Third, `surt_illustrative_note()` selects one wording for a documented method on synthetic data and another for synthetic, placeholder, unknown, or incomplete material. The module validates declarations and presentation behaviour. It does not independently establish that a citation is correct, that every external application routes values through the module, or that a declared method was implemented faithfully outside the released repository. Provenance is recorded as human-readable file and feature metadata; the current candidate does not claim PROV-O or RO-Crate conformance.",
    )
    text = replace_once(
        text,
        "- five deliberate release-corruption rejections.\n\nThe environmental fixture",
        "- five deliberate release-corruption rejections.\n\nTable 3 maps the principal software claims to the corresponding candidate evidence and verification mechanism.\n\nThe environmental fixture",
    )
    text = replace_once(
        text,
        "Figure 3 standardizes values within each layer to compare district profiles despite different units.",
        "Supplementary Figure S1 standardizes values within each layer to compare district profiles despite different units.",
    )
    text = replace_once(
        text,
        "The candidate branch also extends the published v1.1.1 base archive; therefore a new immutable release and version DOI are required before journal submission.",
        "The candidate branch also extends the published v1.1.1 base archive; therefore a new immutable release and version DOI are required before journal submission. Table 4 consolidates these limitations and their interpretation consequences.",
    )

    text = replace_once(
        text,
        "Lebo T, Sahoo S, McGuinness D et al (2013)",
        "Lebo T, Sahoo S, McGuinness D (eds) (2013)",
    )
    text = replace_once(
        text,
        "Mitchell SN et al (2022) FAIR data pipeline: provenance-driven data management for traceable scientific workflows. Philos Trans R Soc A 380:20210300.",
        "Mitchell SN, Lahiff A, Cummings N et al (2022) FAIR data pipeline: provenance-driven data management for traceable scientific workflows. Philos Trans R Soc A 380(2233):20210300.",
    )
    text = replace_once(
        text,
        "Soiland-Reyes S, Sefton P, Crosas M et al (2022) Packaging research artefacts with RO-Crate. Data Sci 5:97–138.",
        "Soiland-Reyes S, Sefton P, Crosas M et al (2022) Packaging research artefacts with RO-Crate. Data Sci 5(2):97–138.",
    )
    text = replace_once(
        text,
        "**Fig. 3** Standardized district profiles across the four environmental layers. Values are expressed as within-layer z scores to permit comparison despite different physical units. District ordering is based on the first principal component of the four standardized layers. The plot is descriptive and does not represent an epidemiological risk score, hazard index, or causal model",
        "**Fig. 3** Three independent provenance controls implemented in `R/provenance_value_class.R`. Register validation checks required fields and legal vocabularies and rejects `source-derived` combined with `placeholder`. Display classification is fail closed: an output is illustrative unless its identifier is present and its `evidence_class` is exactly `source-derived`; this step does not inspect `method_class` or independently verify real-data use. Illustrative-note selection uses one wording for a documented method on synthetic data and another for synthetic, placeholder, unknown, or incomplete material. Register validity is not shown as a prerequisite for the display or note functions because the functions can be called independently.\n\n**Supplementary Fig. S1** Standardized district profiles across the four environmental layers. Values are expressed as within-layer z scores to permit comparison despite different physical units. District ordering is based on the first principal component of the four standardized layers. The plot is descriptive and does not represent an epidemiological risk score, hazard index, or causal model",
    )

    result = text.encode("utf-8")
    digest = hashlib.sha256(result).hexdigest()
    if digest != EXPECTED_RESULT_SHA256:
        raise SystemExit(
            f"Integrated manuscript digest mismatch: expected {EXPECTED_RESULT_SHA256}, found {digest}"
        )
    PATH.write_bytes(result)
    print(f"Integrated paper/manuscript.md ({digest})")


if __name__ == "__main__":
    main()
