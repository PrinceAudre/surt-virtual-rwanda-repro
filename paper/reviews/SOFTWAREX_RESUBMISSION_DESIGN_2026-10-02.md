# SoftwareX resubmission design

Date: 2026-10-02
Prior manuscript: SOFTX-D-26-01014
Development target: SuRT-GeoHarmonizer v1.4.0
Branch: `review/softwarex-resubmission-v1.4.0`

## Status

SoftwareX rejected v1.3.0 after external review. The reviews nevertheless identify a viable rebuild path. Reviewer 1 accepts the verification discipline and release structure but requires tighter spatial definitions and broader direct tests. Reviewer 2 challenges the central reuse claim and requires evidence of customizability, extensibility, and real reuse beyond the Rwanda case.

The published v1.3.0 tag and Zenodo archive are historical records and must not be rewritten. All revisions belong to a new v1.4.0 release.

## Design principle

The resubmission must answer reviewer criticism with executable evidence. Manuscript wording alone is insufficient where a code, test, portability, or validation change can resolve the concern.

## Spatial aggregation contract

The generic continuous-raster summary will be redefined as a cell-area-weighted polygon mean. Polygon-cell overlap and cell area are both part of the weight. For geographic rasters this prevents equal-degree cells at different latitudes from being treated as equal-area observations.

Every generic output will report valid-data coverage. A finite mean will no longer be the only coverage criterion. The public interface will expose a configurable minimum valid-data fraction. Partial valid coverage remains reportable even when the threshold is set to zero.

The implementation and manuscript must distinguish:

1. raster footprint coverage of the polygon;
2. finite-value coverage within the raster footprint;
3. the resulting overall valid-data fraction; and
4. the value summary calculated from finite cells only.

A controlled latitude-sensitive fixture and a controlled partial-NA fixture are mandatory.

## HAND definition

The HAND statistic will be defined as the area-weighted share of valid HAND-covered area at or below the selected threshold. Valid HAND coverage will be reported separately. No-data cells are unknown and are not silently placed in either the numerator or denominator of the valid-area threshold share.

A mixed valid/NA fixture must verify numerator, denominator, valid coverage, and threshold share exactly. The output remains a terrain descriptor and must not be labelled as flood extent, flood probability, or validated hazard.

## ERA5-Land definition

Version 1.3.0 calculates an arithmetic mean of the 12 monthly mean layers. For v1.4.0 the preferred annual statistic is a calendar-day-weighted mean of the 12 monthly means so the result corresponds more closely to an annual mean over days. Leap years must be handled explicitly and tested.

A small real-data numerical check will independently verify Kelvin-to-Celsius conversion and the annual aggregation for selected locations or administrative units.

## MODIS NDVI quality policy

Version 1.3.0 masks fill/out-of-range values but does not use MOD13A3 quality layers. Version 1.4.0 will implement an explicit, documented QA policy using the product quality information, with a deliberate configuration option if unfiltered NDVI is requested.

The default must be scientifically defensible, quality filtering must be tested, and post-QA valid-data coverage must be reported. A limited real-data check must verify selected subdataset, raw scaling, QA handling, and resulting values.

## Generic interface test contract

Direct generic-interface tests must cover all documented controls and failure paths, including layer index/name selection, scale, offset, raw-value masking thresholds, strict integer parsing of rounding digits, identifier failures, CRS failures, invalid geometry, unsupported geometry types, min/max failures, full no-data, partial coverage, schema collisions, output schema, and output CRS.

The test runner should derive assertion totals from machine-readable results rather than preserving a manually maintained total such as 48.

## Reuse architecture

Reviewer 2's concern is architectural. Version 1.4.0 must therefore add a stable configuration and extension layer rather than simply adding more examples to ad hoc scripts.

The target architecture is:

- core raster/polygon aggregation functions;
- provider adapters with explicit contracts;
- declarative validated configuration for variables, transformations, QA, aggregation, coverage thresholds, provenance, and outputs;
- provider acquisition separated from deterministic transformation;
- independently callable R/Python CLIs;
- Snakemake orchestration above those CLIs for reproducible multi-step execution;
- release evidence and validation as explicit workflow rules rather than only an imperative check runner.

Adding a new provider should be documented and testable without editing core aggregation logic.

## Independent real-world reuse case

A second real administrative context is mandatory. It must use public, redistributable boundaries and an account-free raster where possible. The case must execute through the same configuration-driven workflow, with no country-specific edits to core code.

The case should be selected to provide a stronger test than the current synthetic portability fixture, including different identifiers, geometry, administrative structure, and sufficient latitude span to exercise the area-weighting rationale. The evidence package will record source terms, checksums, commands, coverage metrics, outputs, and claim boundaries.

## Workflow management

A Snakemake layer will orchestrate account-free acquisition/demo inputs, transformations, harmonization, validation, and release evidence. Existing R and Python entry points remain usable independently. Provider credentials remain optional and external to the repository.

CI must execute the account-free workflow and validate its DAG outputs. Platform claims remain separate from geographic portability claims.

## Comparative value proposition

The revised manuscript will include an evidence-based matrix comparing SuRT-GeoHarmonizer with Google Earth Engine, MODIStsp, and exactextractr. Dimensions will include acquisition, raster/polygon processing, zonal statistics, area weighting, valid-data coverage reporting, per-feature provenance, negative tests, release-contract validation, checksums, CI, account-free verification, provider extension, and workflow orchestration.

The comparison must state complementarity accurately. The contribution is integration and auditable release behavior, not a claim that established tools lack their own strengths.

## Real-data validation hierarchy

The manuscript will preserve an explicit evidence hierarchy:

1. controlled unit/fixture tests;
2. generic-interface contract tests;
3. failure injection and corruption rejection;
4. end-to-end second-context execution;
5. independent numerical real-data checks by provider;
6. release integrity and archive identity.

CHIRPS retains its existing full Rwanda reproduction. ERA5-Land, MODIS, and HAND gain limited independent real-data numerical checks. These categories must not be collapsed into a single claim of scientific validation.

## Software engineering hardening

Version 1.4.0 should also improve function documentation, configuration-schema validation, lint/static checks, multi-platform CI where geospatial dependencies permit, and regression tests for every reviewer-identified failure mode. Existing fail-closed behavior, negative tests, checksums, licensing controls, and provenance boundaries must be preserved.

## Manuscript rebuild

The revised paper will not be a cosmetic revision of v1.3.0. It will be rewritten around demonstrated reuse. Required additions include the second real-world case, the comparison matrix, exact area/coverage definitions, QA policy, expanded tests, real-data validation results, configuration/adapter architecture, and workflow-management layer.

The Impact section must rely on demonstrated reusable behavior rather than prospective claims. Limitations must identify any remaining provider, operating-system, validation, or data-quality boundaries.

## Resubmission package

Prepare a point-by-point response for both reviewers. Every substantive response should name the exact manuscript section, code file, test, commit, and evidence artifact that resolves it. The cover letter should disclose prior manuscript SOFTX-D-26-01014 and explain that the software and manuscript were substantively rebuilt following peer review.

Because the editorial decision is rejection rather than a formal revision decision, the exact Editorial Manager route must be confirmed before submission. Do not submit an unchanged automatic transfer package.

## Release gate

No v1.4.0 tag, Zenodo version, or journal resubmission until:

- all reviewer items in issue #10 are closed;
- account-free and real-data validation gates are green on the exact commit;
- second-context execution is reproducible;
- manuscript and code claims match exactly;
- checksums and metadata identify the same frozen release;
- independent code and manuscript review is complete; and
- the final rendered submission package has been inspected page by page.
