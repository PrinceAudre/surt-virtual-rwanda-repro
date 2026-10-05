# Array final pre-release review, 5 October 2026

**Status:** Gates 1 through 11 closed. GO FOR RELEASE FREEZE.  
**Review subject, human source commit:** `059c5173b98625a9aa1a773ddd8453a094264839`  
**Manifest-bearing review head:** `9203be05e8ced02a71752f83368f25c41758ab3d`  
**Target:** Array transfer, SuRT-GeoHarmonizer v1.4.0  
**Prior reviewed manuscript:** SoftwareX `SOFTX-D-26-01014`

## 1. Scope and decision

This record closes the evidence-led review required by `paper/FINAL_REVIEW_PROTOCOL.md` before Gate 12. It does not mint or claim a v1.4.0 DOI, tag, GitHub release, Zenodo publication, or Array submission.

The review used two logically independent passes:

1. **Code and evidence pass.** Exact-tree executable checks, corruption tests, configuration and adapter tests, checksum validation, source-pinned evidence review, benchmark evidence review, and GitHub CI were assessed for internal consistency and fail-closed behavior.
2. **Manuscript and claim pass.** The Array manuscript, claim-to-evidence matrix, four October 2026 prior-art delta audits, submission-facing material, quantitative statements, portability wording, resource-use wording, release identity, and institutional boundaries were checked independently of the code-path review.

No high or medium defect remains that blocks release freeze. The remaining items are Gate 12 release actions and bounded limitations already disclosed in the manuscript.

## 2. Prior SoftwareX reviewer closure

| Item | Final status | Closure basis |
|---|---|---|
| R1.1 partial valid-data coverage | CLOSED WITH DIRECT EVIDENCE | Three-part support semantics, partial-coverage fixtures, output-contract checks |
| R1.2 surface-area weighting | CLOSED WITH DIRECT EVIDENCE | Polygon overlap multiplied by raster-cell surface area; controlled latitude-sensitive comparison |
| R1.3 HAND denominator and no-data semantics | CLOSED WITH DIRECT EVIDENCE | Valid HAND-covered-area denominator, negative-sentinel exclusion, dedicated regression tests |
| R1.4 controlled versus independent validation | CLOSED WITH DIRECT EVIDENCE | Controlled fixtures and source-pinned independent numerical checks are separately labelled |
| R1.5 generic interface branch coverage | CLOSED WITH DIRECT EVIDENCE | Positive and negative generic-interface, schema, parsing, coverage and adapter tests |
| R1.6 comparison with established tools | CLOSED WITH BOUNDED CLAIM | Expanded primary-scope comparison; no superiority or priority claim |
| R1.7 MODIS quality information | CLOSED WITH DIRECT EVIDENCE | Pixel Reliability filtering, completeness rules, negative tests and pinned source evidence |
| R1.8 ERA5-Land annual statistic | CLOSED WITH DIRECT EVIDENCE | Exact calendar-day weighting and leap-year tests |
| R1.9 raw-unit thresholds and integer parsing | CLOSED WITH DIRECT EVIDENCE | Raw-value masking before scale/offset and fail-closed integer parsing tests |
| R1.10 geographic versus operating-system portability | CLOSED WITH BOUNDED CLAIM | Rwanda/Uganda contract reuse plus bounded three-OS core smoke; credentialed acquisition is not generalized |
| R2.1 beyond-Rwanda exercise | CLOSED WITH DIRECT EVIDENCE | Source-derived Uganda CHIRPS case through the same configured generic workflow |
| R2.2 customizability and extensibility | CLOSED WITH DIRECT EVIDENCE | Out-of-tree `module:factory` adapter plus malformed-adapter rejection |
| R2.3 value over tailored reimplementation | CLOSED WITH BOUNDED CLAIM | E1 to E3 evaluate information value, auditability cost and extension boundary without claiming universal superiority |
| R2.4 workflow management | CLOSED WITH DIRECT EVIDENCE | Account-free Snakemake evidence DAG executed in the reproducibility workflow |

## 3. Array research-question and empirical-evidence status

| Evidence item | Status | Evidence |
|---|---|---|
| RQ1 / E1 support semantics | PASS | Four controlled cases retain mean 10 while producing support tuples `1/1/1`, `1/0.5/0.5`, `0.5/1/0.5`, and `0.5/0.5/0.25`; mean-only gives one signature, mean plus overall support three, and the full tuple four |
| RQ2 computational correctness | PASS, bounded | Source-pinned CHIRPS, ERA5-Land, MODIS and HAND cases agree with independent calculations within declared tolerances; this is computational agreement, not source-product observational validation |
| RQ3 / E3 extensibility | PASS | A provider module outside the repository loads through the public adapter boundary without core-registry or generic-harmonizer edits; malformed adapters fail closed |
| RQ4 portability | PASS, bounded | Same generic contract is exercised on Rwanda and Uganda geometry; core smoke runs on Ubuntu, Windows and macOS; credentialed acquisition portability is excluded from the claim |
| RQ5 / E2 cost of auditability | PASS, bounded | Tracked five-repetition benchmark reports identical paired means and documented wall-clock/R-heap measurements on one Windows workstation |
| E4 additional replication | PASS, scoped | Public-data evidence spans CHIRPS, ERA5-Land, MODIS and HAND with source-specific pinning and declared numerical scopes |

## 4. Adversarial findings and corrections

### High

None open.

### Medium

None open.

### Low and bounded limitations

- Credentialed provider acquisition is not claimed to have been exercised on every operating system.
- Source-pinned numerical checks establish computational agreement for the stated cases, not observational accuracy of the environmental products.
- The performance benchmark is one documented Windows workstation and does not establish universal speed or scalability.
- Memory evidence is R-heap instrumentation, not process RSS or total machine memory.
- Annual administrative summaries do not preserve temporal extremes or within-unit heterogeneity.
- The development branch name retains `softwarex-resubmission-v1.4.0` for continuity with the peer-review history; active submission-facing sources and validation now target Array.

One substantive claim defect was corrected during this pass. The manuscript and audits previously repeated an exact historical optimization anecdote of approximately 19.3 s to 0.64 s. The optimization itself is supported by commits `5a465e8` and `88b1544`, but no durable pre-change timing artifact with a defined environment and repetition protocol was preserved. The exact speedup has therefore been removed. Quantitative performance claims are now limited to the tracked final benchmark, and the Array validator rejects reintroduction of the unsupported historical timing.

## 5. Novelty and prior-art boundary

The four October 2026 delta audits and the claim matrix were retained. The review confirms that the manuscript does not claim novelty for zonal statistics, polygon-cell intersection, fractional coverage, valid-data percentages, raster footprints, generic polygon-covariate wrappers, climate-to-administrative preprocessing, African climate-health integration, workflow orchestration, provenance, or contract-driven geospatial computing as standalone concepts.

The remaining contribution is deliberately bounded to the evaluated integration and assurance contract: explicit per-polygon grid support and finite/QA support with an invariant-checked overall product, fail-closed declarative jobs, an out-of-tree provider boundary, provenance-labelled administrative output, independent numerical checks, negative and corruption tests, and exact release-integrity controls.

Comparator coverage includes exactextract/exactextractr, terra, GDAL 3.12, xagg, spatcovar, Google Earth Engine, openEO, DART-Pipeline/geoglue, DHIS2 Climate Tools/Open Climate Service, AREAdata, stagg, Climate-CAFE, mbg, Urban Growth Center, GeoBrix, QFlowCrate, Geospatial Agentic Services, ESDPKI, STAC validity metadata, raster-footprint tooling, SWATbuildR, IPUMS Terra, CDT, Climate Econometrics Toolkit and AutoGIS. The audit does not treat an unmatched search as proof of uniqueness.

## 6. Exact-tree execution

On manifest-bearing head `9203be05e8ced02a71752f83368f25c41758ab3d`:

- `python python/build_checksum_manifest.py --all-tracked --check`: PASS, 123 tracked files.
- `python python/validate_array_manuscript.py`: PASS.
- `python python/validate_resubmission_metadata.py`: PASS.
- `git diff --check`: PASS.
- `python python/run_all_checks.py --verify-manifest`: PASS in 141.184 seconds.
- strict runner result: all account-free checks passed, complete tracked-file manifest passed, and 123 listed SHA-256 digests verified.
- working tree was clean before this review record was added.

GitHub Actions on source commit `059c5173b98625a9aa1a773ddd8453a094264839`:

| Workflow | Run | Result |
|---|---:|---|
| Reproducibility checks | `37303861507` | SUCCESS |
| Array manuscript validation | `37303861562` | SUCCESS |
| Metadata/manuscript validation | `37303861564` | SUCCESS |
| Core platform smoke | `37303861566` | SUCCESS |
| Manifest refresh | `37303861597` | SUCCESS |

The successful manifest workflow produced `9203be05e8ced02a71752f83368f25c41758ab3d` as a checksum-only child of `059c5173b98625a9aa1a773ddd8453a094264839`.

## 7. Release-freeze boundary

**Verdict: GO FOR RELEASE FREEZE.**

Gates 1 through 11 are closed. Gate 12 remains deliberately sequential:

1. reserve a v1.4.0 Zenodo version DOI without publishing;
2. insert the DOI and v1.4.0 release identity into release-facing metadata while preserving historical releases;
3. freeze that exact source tree and rebuild the all-tracked manifest;
4. rerun strict exact-tree verification and SHA-256 checks;
5. render and visually inspect the manuscript, cover letter, tables, figures, highlights and transfer package;
6. tag the exact approved commit `v1.4.0`;
7. create the matching GitHub release and publish the exact Zenodo version archive;
8. confirm that the version DOI resolves to the tagged release before final Array submission.

This review record itself changes the tracked tree. It must therefore be followed by the normal manifest refresh and a clean exact-tree check before DOI-bearing freeze work proceeds.
