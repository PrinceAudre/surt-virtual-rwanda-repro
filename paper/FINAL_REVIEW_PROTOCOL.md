# Final review protocol for SuRT-GeoHarmonizer v1.4.0

**Status:** active reviewer-remediation gate  
**Branch:** `review/softwarex-resubmission-v1.4.0`  
**Manuscript:** SoftwareX `SOFTX-D-26-01014`

## Purpose

This protocol replaces the former dependency on a named external AI reviewer. Final review is evidence-led and tool-independent. No release decision depends on access to Claude or any other specific model.

The protocol is designed to prevent four failure modes before v1.4.0 is frozen:

1. a reviewer concern is declared closed without executable or documentary evidence;
2. a manuscript claim is broader than the code, tests, data, or external source supports;
3. genuine reuse or scientific value is understated because the evidence is not connected to the claim; or
4. stale submission, affiliation, release, DOI, or journal-targeting metadata survives into the final package.

The published v1.3.0 release remains immutable historical evidence. Nothing in this protocol authorizes retagging or rewriting it.

## Gate 1. Reviewer-comment closure audit

Use the verbatim five-page reviewer report as the controlling source. `paper/reviewer-response-draft.md` is a response map, not a substitute for the report.

For every distinct reviewer concern, assign exactly one status:

- `CLOSED WITH DIRECT EVIDENCE`
- `CLOSED WITH BOUNDED CLAIM`
- `PARTIALLY CLOSED`
- `OPEN`

A concern may be called closed only when its response identifies the relevant implementation, test or evidence artifact and the manuscript text uses the same semantics.

At minimum, verify the following concerns independently:

- partial raster and finite-data coverage;
- true surface-area weighting versus polygon-cell coverage weighting;
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
- value of reuse versus a one-off reimplementation.

## Gate 2. Claim-to-evidence matrix

Every quantitative, comparative, portability, validation, reproducibility, release, and novelty claim in `paper/manuscript.md`, `paper/reviewer-response-draft.md`, `README.md`, and `paper/submission/` must be traceable to one or more of:

- executable test output;
- a tracked source-pinned evidence record;
- an immutable release record;
- an official provider specification;
- a primary publication or official software manual; or
- a documented current CI run on the reviewed commit.

Classify each claim as one of:

- **software verification:** controlled behaviour and failure handling;
- **computational cross-validation:** agreement between independently implemented calculations for a specified case;
- **source/product validity:** evidence about the underlying environmental product itself;
- **portability:** tested reuse across geometry, geography, configuration, provider boundary, or operating system; or
- **release integrity:** evidence about exact files, version identity, metadata, and checksums.

Do not allow evidence in one class to silently support a claim in another. In particular, computational agreement does not establish observational accuracy, and a three-platform core smoke matrix does not establish full cross-platform provider acquisition.

## Gate 3. Spatial and scientific semantics

Re-read the implementation rather than relying on prose. Confirm that:

- zonal contributions are weighted by polygon-cell overlap fraction multiplied by raster-cell surface area;
- `raster_coverage_fraction`, `valid_within_raster_fraction`, and `valid_data_fraction` have distinct and algebraically consistent meanings;
- incomplete coverage can be reported and can optionally fail closed through a minimum-valid-fraction gate;
- near-global longitude normalization cannot inflate coverage;
- HAND is the percentage of valid HAND-covered area at or below the threshold and negative sentinels are excluded;
- ERA5-Land annual temperature uses exact calendar-day weighting of the 12 monthly means before Kelvin-to-Celsius conversion;
- MOD13A3 uses the declared v061 subdataset, scale, pixel-reliability rule, and temporal-completeness policy; and
- every interpretation remains descriptive unless a separate validation study supports a stronger interpretation.

Run the controlled and corruption tests on the exact review commit. Any change to these semantics reopens the relevant reviewer item.

## Gate 4. Reuse and extension audit

The reviewer challenged whether reuse offers value over reimplementation. Test the reuse claim directly rather than rhetorically.

Required evidence:

- the generic raster/polygon interface accepts arbitrary valid identifiers and polygon geometry;
- the Uganda source-derived CHIRPS case uses the same configuration-driven harmonizer without Rwanda-specific edits to the generic engine;
- an external `module:factory` adapter can be loaded and exercised by a positive test without editing `python/provider_adapters.py` or the generic R harmonizer;
- malformed adapters and configurations fail closed;
- provider-specific QA remains owned by the provider layer instead of being silently generalized; and
- documentation shows the minimum work a new user must supply: scientifically appropriate prepared raster or provider adapter, polygon boundaries, configuration, provenance, and interpretation.

The manuscript should describe the demonstrated reuse boundary exactly. It must not claim universal provider support or no-code scientific interchangeability.

## Gate 5. Related-software and novelty audit

Before release, repeat a current literature and software search. The comparison must include both reviewer-named tools and the closest newly identified adjacent systems.

Minimum landscape:

- Google Earth Engine;
- MODIStsp;
- `exactextractr`;
- GDAL zonal statistics and weighting capabilities;
- `terra` as an independent geospatial implementation used for cross-checking;
- DART-Pipeline and its `geoglue` work for climate-sensitive-disease data integration and administrative aggregation;
- Snakemake as workflow infrastructure; and
- relevant recent SoftwareX geospatial/reproducibility software.

The novelty claim is **not** a new zonal-statistics algorithm, a new raster-area algorithm, or the first climate/environmental data integration pipeline. Mature tools already provide these capabilities in different forms.

The defensible contribution is narrower: a small administrative-raster harmonization and release-evidence contract that combines explicit surface-area and coverage semantics, fail-closed declarative jobs, a provider extension boundary, restricted provenance-labelled GeoJSON outputs, controlled negative tests, independent output-contract validation, source-pinned numerical cross-checks, and exact release-integrity gates.

For adjacent systems with broader capabilities, state the difference in scope rather than asserting that they lack a feature unless a primary source proves that absence.

## Gate 6. Research-software practice audit

Check the project against current research-software practice without claiming formal certification:

- persistent version-specific archive and DOI;
- clear software licence and third-party data terms;
- citation metadata;
- machine-readable metadata;
- dependency capture;
- installation and quick-start instructions;
- contribution guidance;
- deterministic positive and negative tests;
- CI;
- workflow orchestration;
- release checksums;
- documentation of provenance and limitations; and
- issue/release history.

FAIR4RS and the FORCE11 Software Citation Principles may be used as reference frameworks, but the manuscript must say "aligned with" or describe concrete practices unless a formal conformance assessment has been completed.

## Gate 7. Submission and affiliation audit

The current manuscript is a rebuilt submission after external SoftwareX peer review. Submission-facing files must therefore:

- identify prior manuscript `SOFTX-D-26-01014` accurately;
- never state that the work has not undergone external peer review;
- distinguish immutable v1.3.0 from unreleased v1.4.0;
- retain a do-not-submit guard until the exact v1.4.0 DOI-bearing release exists; and
- use the author's current truthful affiliation for the revised work while avoiding any implication of institutional endorsement.

Current author affiliation for the rebuilt manuscript is:

`School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda`

Because the original software predates this enrolment, the cover letter should state that the affiliation changed during the reviewer-remediation period if needed for editorial clarity. Historical v1.3.0 metadata must not be rewritten retroactively. Release-facing v1.4.0 metadata should adopt the current affiliation at the release freeze.

## Gate 8. Journal-fit and APC audit

Journal choice is a separate decision from technical correctness. Before final submission:

1. verify the active journal's current aims, article type, and software expectations from official sources;
2. compare any Elsevier transfer offer against the rebuilt v1.4.0 manuscript rather than the older v1.3 abstract used to generate the transfer suggestions;
3. distinguish a guaranteed-peer-review transfer offer from guaranteed acceptance;
4. verify the author's current country- and institution-based APC eligibility in the publisher system; and
5. do not change scientific framing merely to fit a journal whose scope is weaker.

A transfer should be chosen only when it improves scope fit or editorial pathway, not merely because its list APC or impact metric looks attractive.

## Gate 9. Exact-commit execution

On the intended pre-release commit run, without weakening any gate:

```text
python python/run_all_checks.py
python python/validate_resubmission_metadata.py
python python/audit_manuscript.py
python python/validate_release_contract.py
python python/build_checksum_manifest.py --all-tracked --check
```

CI must also execute the account-free Snakemake DAG and the declared multi-platform core smoke matrix. Credentialed/provider-source checks must be rerun when their source access is available; otherwise retain the source-pinned evidence and disclose the execution limitation.

## Gate 10. Release freeze

Only after Gates 1 through 9 are closed:

1. reserve the v1.4.0 version-specific Zenodo DOI without publishing the archive;
2. insert that DOI and the v1.4.0 identity into all release-facing metadata;
3. update the v1.4.0 affiliation metadata without changing immutable v1.3.0 historical records;
4. freeze the exact source tree;
5. rebuild the complete tracked-file manifest;
6. run `python python/run_all_checks.py --verify-manifest` on that exact tree;
7. verify all listed SHA-256 digests;
8. render and visually inspect the manuscript, reviewer response, cover letter, figures, tables, and highlights;
9. tag that exact commit `v1.4.0`;
10. create the matching GitHub release and Zenodo archive from the same content; and
11. confirm that the published version DOI resolves to the tagged release before journal submission.

No model-generated statement can substitute for these release gates.

## Final verdict format

The final pre-release review must report:

- exact commit reviewed;
- reviewer-item closure table;
- high, medium, and low findings;
- claims narrowed or strengthened;
- related-work sources checked;
- commands and CI runs actually executed;
- unresolved limitations;
- journal/APC decision basis; and
- one of: `GO FOR RELEASE FREEZE`, `GO AFTER CORRECTIONS`, or `HOLD`.
