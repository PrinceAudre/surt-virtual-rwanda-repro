# Final review protocol for SuRT-GeoHarmonizer v1.4.0

**Status:** active Array-transfer hardening gate  
**Branch:** `review/softwarex-resubmission-v1.4.0`  
**Prior peer-reviewed manuscript:** SoftwareX `SOFTX-D-26-01014`  
**Current target:** Array

## Purpose

This protocol is evidence-led and tool-independent. No release or submission decision depends on access to Claude or any other named model. Automated reviewers may be used as adversarial second opinions, but their outputs are findings to adjudicate, not authority.

The prior SoftwareX reviewer report remains an important defect-discovery record because it identified technical and reuse problems that the Array manuscript must not regress. Array adds a second burden: the rebuilt paper must demonstrate a bounded computer-science/software-engineering contribution rather than read as a software-description note.

The published v1.3.0 release remains immutable historical evidence. Nothing in this protocol authorizes retagging or rewriting it.

## Gate 1. Prior reviewer closure audit

Use the original five-page SoftwareX reviewer report as the controlling source for prior technical concerns. `paper/reviewer-response-draft.md` is a response map, not a substitute for the report.

For every distinct concern assign one of:

- `CLOSED WITH DIRECT EVIDENCE`
- `CLOSED WITH BOUNDED CLAIM`
- `PARTIALLY CLOSED`
- `OPEN`

At minimum verify independently:

- partial raster and finite-data coverage;
- true surface-area weighting versus polygon-cell coverage alone;
- HAND denominator and no-data handling;
- independent real-data numerical checks beyond CHIRPS;
- generic-interface edge cases;
- MOD13A3 quality filtering;
- ERA5-Land annual statistic;
- raw-unit no-data thresholds and strict integer parsing;
- operating-system versus geographic portability;
- comparison with existing tools;
- demonstrated reuse beyond Rwanda;
- customizability and extensibility;
- workflow management; and
- value of reuse versus one-off reimplementation.

A technical concern may be called closed only when implementation, tests/evidence and manuscript language use the same semantics.

## Gate 2. Array novelty and related-work audit

`paper/ARRAY_NOVELTY_PRIOR_ART_AUDIT.md` is the active novelty boundary. Before submission repeat a current search of the closest software and literature.

Minimum landscape:

- DART-Pipeline and geoglue;
- DHIS2 Climate App / Climate Tools, Open Climate Service and Rwanda climate-health work;
- AREAdata, stagg, Climate Econometrics Toolkit and Climate-CAFE;
- xagg, spatcovar, exactextract and exactextractr;
- GDAL and terra;
- Google Earth Engine and openEO;
- CDT and other African climate-service precedents;
- Urban Growth Center and GeoBrix coverage/validity interfaces;
- AutoGIS, QFlowCrate, Geospatial Agentic Services, ESDPKI, Snakemake and related contract/provenance/workflow frameworks; and
- current Array framework/software papers, including FairFlow and relevant interdisciplinary health-computing work.

The four October 2026 delta audits are part of this gate and must remain represented in both the claim matrix and manuscript-facing related work.

The paper must not claim a new zonal-statistics algorithm, new cell-area algorithm, first climate-health integration pipeline, first reproducible geospatial workflow, first African/LMIC harmonizer, or superiority over broader systems without direct comparative evidence.

The active contribution is the evaluated **contract-first raster-to-administrative handoff**: mandatory support semantics plus fail-closed configuration, provider decoupling, numerical evidence and release-integrity controls.

## Gate 3. Claim-to-evidence matrix

Every quantitative, comparative, portability, reproducibility, resource-use, release and novelty statement in `paper/array-manuscript.md`, submission materials and release-facing documentation must be traceable through `paper/ARRAY_CLAIM_EVIDENCE_MATRIX.md` to one or more of:

- executable test output;
- a tracked source-pinned evidence record;
- a controlled benchmark;
- an immutable release record;
- an official provider specification;
- a primary publication or official software manual; or
- a documented current CI run on the reviewed commit.

Classify evidence explicitly as:

- **software verification**;
- **controlled experiment**;
- **computational cross-validation**;
- **source/product validity**;
- **portability**;
- **performance/resource benchmark**; or
- **release integrity**.

Do not allow one class to silently support another. Computational agreement does not establish observational accuracy. Three-platform core smoke does not establish credentialed acquisition on every operating system. R `gc()` heap indicators are not process RSS.

## Gate 4. Spatial and scientific semantics

Re-read the implementation, not just prose. Confirm that:

- zonal contributions use polygon-cell overlap multiplied by raster-cell surface area;
- `raster_coverage_fraction`, `valid_within_raster_fraction` and `valid_data_fraction` remain distinct and algebraically consistent;
- incomplete support can be reported and optionally fail closed through `min_valid_fraction`;
- footprint calculation cannot inflate geographic coverage through longitude wrapping;
- HAND is the percentage of valid HAND-covered area at or below threshold and negative sentinels are excluded;
- ERA5-Land annual temperature uses calendar-day weighting across all 12 monthly means before Celsius conversion;
- MOD13A3 uses the declared v061 subdataset, scale, Pixel Reliability policy and temporal-completeness rule; and
- interpretations remain descriptive unless a separate validation study supports stronger language.

Run controlled and corruption tests on the exact review commit. Any change to these semantics reopens the associated reviewer and Array evidence items.

## Gate 5. Array empirical-value audit

The paper's systems contribution must be demonstrated, not merely described.

Required experiments:

### E1. Support-semantics collision

Four controlled cases must retain identical means while differentiating complete support, finite-data loss, footprint loss and combined loss. The intended support tuples are tracked in `evidence/array/` and tested by `R/test_zonal_area_summary.R`.

### E2. Cost of auditability

`R/benchmark_array_contract.R` must compare the support contract against a direct area-weighted mean using the same underlying primitives. Report wall-clock and R-heap metrics honestly, preserve all repetitions, and disclose that heap metrics are not RSS. The purpose is to quantify cost, not to prove superiority.

### E3. Out-of-tree extension

`python/test_config_contract.py` must load a temporary provider module physically outside the repository through `module:factory`, preserve artifact/provenance and fail closed for malformed adapters, without changes to the built-in registry or generic R harmonizer.

### E4. Additional replication

Additional countries/products are optional and should be added only when they exercise a genuinely different boundary condition. Do not inflate a case count for appearance.

If E1-E3 no longer pass on the intended source tree, the Array novelty/value claim reopens.

## Gate 6. Reuse and portability audit

Required evidence:

- generic valid raster/polygon input and arbitrary identifiers;
- source-derived Uganda boundary portability;
- source-derived Uganda CHIRPS configured case;
- tested out-of-tree provider boundary;
- fail-closed malformed configuration and adapter paths;
- documentation of the user-supplied scientific responsibilities; and
- precise separation of geographic portability, provider portability and operating-system portability.

The manuscript must not claim universal provider support, no-code interchangeability, or cross-platform credentialed acquisition unless directly tested.

## Gate 7. Research-software and reproducibility audit

Check, without claiming formal certification:

- version-specific archive and DOI strategy;
- software licence and third-party data terms;
- citation and machine-readable metadata;
- dependency capture;
- installation and quick-start instructions;
- contribution guidance;
- deterministic positive and negative tests;
- CI;
- workflow orchestration;
- release checksums;
- provenance/limitations documentation; and
- issue/release history.

FAIR4RS, FAIR and software-citation principles may be used as reference frameworks, but do not claim formal conformance without an actual conformance assessment.

## Gate 8. Submission, affiliation and disclosure audit

The current Array manuscript is a rebuilt paper following external SoftwareX peer review. Submission-facing files must:

- never state or imply that the work has not undergone prior external peer review;
- distinguish immutable v1.3.0 from unreleased v1.4.0;
- retain a do-not-submit guard until the exact v1.4.0 release exists;
- use the current truthful affiliation;
- avoid implying University of Rwanda sponsorship or endorsement; and
- make AI-assistance disclosure truthful to the actual development history while making clear that no named model is a scientific/release authority.

Current affiliation:

`School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda`

Historical v1.3.0 metadata must not be rewritten retroactively. Release-facing v1.4.0 metadata should adopt the current affiliation at release freeze.

## Gate 9. Array journal-fit and APC audit

Before final transfer submission:

1. verify Array's current aims/scope and author guide from official publisher sources;
2. verify that the paper is framed as software engineering/scientific computing with interdisciplinary application rather than as a domain-only methods paper;
3. recheck `paper/ARRAY_JOURNAL_FIT_APC_AUDIT.md` against the live Elsevier GPOA policy;
4. confirm the actual final author-country configuration used by Elsevier's APC calculation; and
5. do not treat transfer, peer review or a zero APC as an acceptance signal.

Current policy evidence places Array in GPOA and Rwanda in the no-APC low-income group when all authors satisfy the full-waiver condition. This is a time-sensitive administrative claim and must be rechecked at submission.

## Gate 10. Exact-commit execution

On the intended pre-release commit, run without weakening any gate:

```text
python python/run_all_checks.py
python python/validate_resubmission_metadata.py
python python/audit_manuscript.py
python python/validate_release_contract.py
python python/build_checksum_manifest.py --all-tracked --check
```

Also rerun:

```text
Rscript R/test_zonal_area_summary.R
python python/test_config_contract.py
Rscript R/benchmark_array_contract.R --repetitions 5 --output <review-output.csv>
```

Compare the benchmark output with the manuscript rather than assuming timings are invariant.

CI must execute the account-free Snakemake DAG and the declared multi-platform core smoke matrix. Credentialed/source checks must be rerun when source access is available; otherwise retain source-pinned evidence and disclose the limitation.

## Gate 11. Adversarial review

Before release freeze, perform at least two logically independent review passes:

1. **code/evidence adversarial pass:** search for hidden assumptions, untested branches, numerical-semantic mismatches, stale checksums, brittle provider logic and benchmark artefacts;
2. **manuscript adversarial pass:** search for unsupported priority, causal, validation, portability, resource-use, health-impact or institutional claims, and verify every number against tracked evidence.

A coding/review agent such as Codex may assist one pass, but another pass must be evidence-based and independently adjudicated. No automated reviewer can waive a failed test or missing source.

## Gate 12. Release freeze

Only after Gates 1-11 are closed:

1. reserve the v1.4.0 version-specific Zenodo DOI without publishing the archive;
2. insert that DOI and v1.4.0 identity into all release-facing metadata;
3. update v1.4.0 affiliation metadata without altering historical releases;
4. freeze the exact source tree;
5. rebuild the complete tracked-file manifest;
6. run `python python/run_all_checks.py --verify-manifest` on that exact tree;
7. verify all SHA-256 digests;
8. render and visually inspect the Array manuscript, cover letter, figures, tables, highlights and transfer package;
9. tag that exact commit `v1.4.0`;
10. create the matching GitHub release and Zenodo archive from the same content; and
11. confirm that the published version DOI resolves to the tagged release before final journal submission.

Steps 1 and 9-11 are owner-authorized release actions. No DOI, tag, GitHub release or Zenodo publication is to be created without explicit owner authorization.

## Final verdict format

The final pre-release review must report:

- exact commit reviewed;
- prior-reviewer closure table;
- Array RQ/E1-E3 evidence status;
- high, medium and low findings;
- claims narrowed or strengthened;
- related-work sources checked;
- commands and CI runs actually executed;
- unresolved limitations;
- current journal/APC basis; and
- one of `GO FOR RELEASE FREEZE`, `GO AFTER CORRECTIONS`, or `HOLD`.
