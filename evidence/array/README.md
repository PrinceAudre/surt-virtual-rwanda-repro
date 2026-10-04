# Array empirical value evidence

This directory records Array-specific evidence for the SuRT-GeoHarmonizer v1.4 development branch. It supplements the SoftwareX reviewer-remediation evidence and does not authorize a release.

## E1: support-semantics collision

`R/test_zonal_area_summary.R` contains a controlled experiment in which four cases all return a zonal mean of `10` while representing different evidence support:

| case | raster coverage | valid within raster | overall valid data |
|---|---:|---:|---:|
| complete | 1.0 | 1.0 | 1.00 |
| finite_gap | 1.0 | 0.5 | 0.50 |
| footprint_gap | 0.5 | 1.0 | 0.50 |
| combined_gap | 0.5 | 0.5 | 0.25 |

The local regression suite returned 18 passed and 0 failed on 2026-10-04. The experiment supports the narrower claim that SuRT's mandatory support fields expose materially different reasons for incomplete evidence that a zonal mean alone does not reveal. It does not claim that other geospatial libraries are unable to calculate comparable diagnostics when explicitly programmed.

## E2: cost of the support contract

`R/benchmark_array_contract.R` compares a direct area-weighted mean using the same `terra` and `exactextractr` primitives against `surt_area_weighted_summary()`, which additionally returns the mandatory support semantics. The benchmark deliberately does not test or claim performance superiority.

Final run environment:

- Date: 2026-10-04
- Operating system: Microsoft Windows 11 Pro
- CPU: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
- Installed RAM: approximately 15.76 GB
- R: 4.6.0 (2026-04-24 ucrt)
- Repetitions: 5 per workload and mode

Median elapsed times and measured R-heap peak deltas:

| workload | direct mean | SuRT support contract | absolute time overhead | direct heap delta | SuRT heap delta |
|---|---:|---:|---:|---:|---:|
| 10,000 cells / 16 polygons | 0.11 s | 0.14 s | +0.03 s | 22.7 MB | 26.8 MB |
| 90,000 cells / 64 polygons | 0.20 s | 0.24 s | +0.04 s | 88.9 MB | 97.6 MB |
| 360,000 cells / 144 polygons | 0.50 s | 0.57 s | +0.07 s | 144.7 MB | 150.7 MB |

All paired mean outputs were numerically identical at the benchmark tolerance (`max_value_difference_vs_peer = 0`). The memory quantities come from R's `gc()` heap indicators and are **not total process resident-set size (RSS)**. Results are machine- and workload-specific and must not be generalized into universal speed or memory claims.

Files:

- `array_contract_benchmark.csv`: all 30 timed observations.
- `array_contract_benchmark_summary.csv`: workload/mode summaries.

## E3: out-of-tree provider extension

`python/test_config_contract.py` now creates a temporary Python adapter module physically outside the repository, loads it through the public `module:factory` mechanism, verifies that it preserves the prepared artifact and provenance boundary, and exercises fail-closed behaviour. The local suite returned 21 passed and 0 failed on 2026-10-04.

The experiment supports the claim that a provider implementation can be loaded out of tree without modifying the built-in provider registry or generic R harmonizer. Plugin architectures themselves are prior art and are not claimed as novel.

## Interpretation boundary

These experiments support a contract-level software-engineering contribution. They do not establish first-ever priority, environmental-product accuracy, universal computational efficiency, or superiority over DART/geoglue, Google Earth Engine, xagg, exactextract(r), GDAL, terra, DHIS2 Climate tooling, or other prior systems.
