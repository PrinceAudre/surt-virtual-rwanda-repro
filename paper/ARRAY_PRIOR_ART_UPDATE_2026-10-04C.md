# Array prior-art delta audit C: climate aggregation, African climate services and contract-driven GIS

**Target journal:** Array  
**Date:** 2026-10-04  
**Status:** active novelty-control record; release not authorized

## Purpose

This third October 2026 delta asks the strongest remaining rejection question: could a skeptical Array reviewer reasonably describe SuRT-GeoHarmonizer as only a wrapper around established raster aggregation, climate-health integration and generic data-contract ideas? The search therefore targeted software that already combines raster-to-administrative aggregation with reproducibility, health/LMIC use, or contract-driven geospatial execution.

The result further narrows the paper. It does not invalidate the bounded SuRT experiment, but it rules out several broad novelty and LMIC-value narratives.

## 1. `stagg`: climate raster preparation for administrative analyses

Peer-reviewed source: Carleton et al., *stagg: A data pre-processing R package for climate impacts analysis*, Environmental Modelling & Software 183 (2025) 106202. https://doi.org/10.1016/j.envsoft.2024.106202

Primary documentation: https://tcarleton.github.io/stagg/

`stagg` streamlines nonlinear transformation, spatial and temporal aggregation, and spatial weighting of high-resolution climate data for statistical analyses. Its polygon overlay step calculates the portion of each administrative region covered by grid cells, can incorporate secondary population/cropland weights, and then aggregates climate data to administrative areas and time scales.

**Consequence for SuRT:** administrative climate-raster aggregation, polygon-cell overlap weighting, temporal aggregation and a research-software package aimed at reducing common preprocessing errors are established. SuRT must not claim that packaging these operations for downstream administrative analyses is new.

## 2. Climate Econometrics Toolkit

Peer-reviewed source: H. Freedman et al., *The climate econometrics toolkit*, Ecological Informatics 92 (2025) 103504. https://doi.org/10.1016/j.ecoinf.2025.103504

The toolkit integrates gridded-climate aggregation, econometric modelling and climate-impact computation in one open-source package. It aggregates gridded climate data to administrative/spatiotemporal levels, supports weighting, provides GUI and programming interfaces, records operations for reproducibility, evaluates runtime on large datasets, and demonstrates value by reproducing published analyses.

**Consequence for SuRT:** integration of established components, workflow standardization, reproducibility support, runtime benchmarking and empirical reproduction can together constitute a publishable software contribution, but none of those ideas is unique to SuRT. For Array, SuRT must make its narrower interface/assurance experiment explicit and quantitatively evaluated rather than relying on 'integrated workflow' language alone.

## 3. Climate Data Tool (CDT): direct African/LMIC prior art

Peer-reviewed source: T. Dinku, R. Faniriantsoa, S. Islam, G. Nsengiyumva, A. Grossi, *The Climate Data Tool: Enhancing Climate Services Across Africa*, Frontiers in Climate 3 (2022) 787519. https://doi.org/10.3389/fclim.2021.787519

Current project page: https://www.sei.org/tools/climate-data-tool/

CDT is open-source R software developed under ENACTS for National Meteorological and Hydrological Services, especially in Africa and other developing-country settings. It supports organization and quality control of station data, satellite/reanalysis processing, ancillary administrative boundaries, data-availability diagnostics, merging station and proxy data, and extraction of gridded products for selected boxes, points or administrative boundaries. The peer-reviewed article reported operational use in more than 20 African countries.

**Consequence for SuRT:** SuRT cannot claim novelty or special value merely because it is open source, handles climate/environmental grids by administrative boundary, supports public-sector/health use, or is relevant to African/LMIC infrastructure. Those are established and much more operationally demonstrated in CDT. Any LMIC/Africa statement in the Array paper must be framed as a bounded deployment rationale, not a differentiator.

## 4. `geoglue`: epidemiology/public-health administrative aggregation

Primary documentation: https://geoglue.readthedocs.io/  
Repository: https://github.com/kraemer-lab/geoglue

The University of Oxford Kraemer Lab describes `geoglue` as open-source software to fetch and aggregate geospatial data to administrative levels, with intended use in epidemiology, climate science and public health. Its modules include ECMWF/CDS access, administrative boundaries from GADM/geoBoundaries, raster resampling and zonal statistics using `exactextract`. The active repository contains tests and CI and is also used by DART-Pipeline.

**Consequence for SuRT:** fetch-and-aggregate geospatial software for epidemiology/public health, including exact polygon overlap and administrative-boundary support, is direct adjacent prior art. `geoglue` is currently marked under development/not for production, but maturity differences do not create algorithmic novelty for SuRT.

## 5. IPUMS Terra / TerraPop

Primary sources:

- https://www.ipums.org/projects/ipums-terra
- https://terra.ipums.org/integration
- S. Manson et al., *Terra Populus' Architecture for Integrated Big Geospatial Services* (2017), available via PubMed Central: https://pmc.ncbi.nlm.nih.gov/articles/PMC6764783/

IPUMS Terra integrated population microdata, area-level data and environmental rasters through location-based transformations. It could summarize rasters to geographic units, attach resulting contextual variables to population microdata, and was used in health research at district level. The interactive Terra service has since been decommissioned, but the architecture and published work remain prior art.

**Consequence for SuRT:** global population-environment integration and raster-to-area transformations for health/demographic research long predate SuRT. 'Joining environmental raster data to district health/population analysis' cannot support a novelty claim.

## 6. AutoGIS: explicit contract-driven geospatial prior art

Peer-reviewed source: *AutoGIS: an agent framework for automated geospatial data management and analysis*, International Journal of Digital Earth (2026). https://doi.org/10.1080/17538947.2026.2704301

AutoGIS describes geospatial analysis as program synthesis governed by explicit, verifiable data and algorithm contracts plus environmental feedback. Its data side performs discovery/acquisition/processing and writes contracts containing spatial extent, CRS, geometry modality and schema; its code side executes PyQGIS workflows under contract constraints and runtime feedback.

**Consequence for SuRT:** 'contract-driven' or 'contract-first geospatial software' is not itself a priority claim. AutoGIS is solving a different problem, autonomous GIS program synthesis rather than a raster-to-administrative support handoff, but it is sufficient to prohibit any suggestion that SuRT introduced contract-governed geospatial computation.

## 7. Search result for an exact match

Across the three October delta audits, the strongest collisions now include:

- mature zonal-statistics primitives and weighted extraction;
- published climate-to-administrative preprocessing packages;
- climate-health/domain pipelines;
- operational African climate services;
- value-plus-validity-share products;
- raster extent versus valid/NoData distinctions at other processing layers;
- geospatial provenance/reproducibility bundles;
- generic and geospatial data-contract systems; and
- contract-driven autonomous GIS.

The reviewed sources did **not** establish an exact published implementation of the complete SuRT experiment in which the following are simultaneously mandatory at the administrative output boundary:

1. rectangular raster-grid support per polygon;
2. finite/QA-accepted support conditional on grid-covered area;
3. their explicit overall product with an enforced invariant;
4. fail-closed job/output semantics;
5. an out-of-tree provider boundary;
6. independent numerical cross-checks of scoped public-data outputs;
7. executable negative paths; and
8. exact release-integrity gates.

This remains **evidence of a search outcome, not proof of uniqueness**. Each component is established or readily implementable using existing software. The paper's defensible research contribution is therefore the evaluation of this particular integrated interface and its information/cost properties, not the absence of equivalent implementations elsewhere.

## 8. Updated LMIC/Africa boundary

The deep dive weakens any attempt to sell SuRT as uniquely valuable because it comes from or can run in Africa. CDT, DHIS2 Climate & Health/Open Climate Service, DART, IPUMS/TerraPop-derived health work and related systems already demonstrate the domain need.

Allowed statement:

> The workflow can run on prepared local inputs without requiring a proprietary cloud account, uses open-source core dependencies, emits inspectable/checksum-verifiable artifacts, and has one documented workstation benchmark. These properties may be useful where local control, auditability or limited access to proprietary infrastructure matters.

Blocked statements without new comparative deployment evidence:

- designed uniquely for LMICs;
- first such system for Africa;
- low-resource or lightweight in general;
- easier to deploy than CDT/DHIS2/DART/geoglue;
- proven to improve African public-health decision-making;
- uniquely suitable for tropical settings.

## 9. Decision

**GO FOR ARRAY HARDENING remains justified, with an even narrower contribution boundary.**

The search did not collapse RQ1-RQ5. It did remove any defensible novelty claim based on climate-raster aggregation, African relevance, health context, reproducibility, workflow integration, contracts or local/open-source execution by themselves.

The submission should therefore live or die on empirical evidence for the bounded interface:

- whether separating the two causal support factors preserves information that one overall support share loses;
- whether scoped outputs independently reproduce;
- whether the provider boundary is demonstrably decoupled;
- whether portability claims remain bounded to what is tested; and
- what computational cost the added assurance contract imposes.

If those results remain correct under adversarial review, the contribution is publishable as evaluated software-engineering integration without claiming a new geospatial primitive.