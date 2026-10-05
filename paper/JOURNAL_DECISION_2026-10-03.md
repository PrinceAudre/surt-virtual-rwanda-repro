# Journal strategy after SoftwareX peer review

**Assessment updated:** 4 October 2026  
**Prior manuscript:** SoftwareX `SOFTX-D-26-01014`  
**Current target:** Array  
**Purpose:** internal decision record for the reviewer-remediated v1.4.0 manuscript

## Current editorial state

SoftwareX rejected the earlier submission after external peer review. The reviewer reports remain valuable technical evidence and have been used to drive the v1.4.0 remediation. Elsevier subsequently offered a transfer pathway that permits the author to choose another journal rather than treating the earlier decision as a revision round in the original journal.

The owner has now selected **Array** as the transfer target and intends to stop before final submission until the software and manuscript have been hardened for Array. No additional presubmission query to SoftwareX is required for the active strategy.

A transfer is an editorial pathway, not an acceptance guarantee. The Array submission must therefore stand on its own as a novel, technically sound computer-science/software-engineering paper.

## Why Array is the active target

Array is an open-access multidisciplinary computer-science journal. Its broad scope can accommodate software engineering, scientific computing, interdisciplinary applications and biomedical/medical-informatics work. The climate-health and public-health use case does not create a scope problem so long as the paper's research contribution is clearly computational and software-engineering based.

Array also has direct precedent for health-related computer-science work, including medical imaging, wearable-health systems, medical-information security, and the 2026 FairFlow reproducibility framework in bioinformatics. Therefore the manuscript does not need to conceal its public-health motivation. It must, however, avoid presenting domain relevance as a substitute for computer-science novelty.

The revised manuscript should be a systems/evaluation paper rather than a SoftwareX-style software-description note. The contribution is the tested raster-to-administrative handoff contract, not the existence of the Rwanda reference dataset.

## Novelty position

The prior-art audit and four October 2026 delta audits find substantial overlap at the feature level with DART-Pipeline/geoglue, DHIS2 Climate Tools/Open Climate Service, AREAdata, stagg, Climate Econometrics Toolkit, Climate-CAFE, xagg, spatcovar, exactextract(r), GDAL, terra, Google Earth Engine, openEO, CDT and general contract/provenance/reproducibility systems.

Accordingly, SuRT-GeoHarmonizer does **not** claim to invent:

- zonal statistics or polygon-cell intersection;
- surface-area weighting;
- raster-to-administrative aggregation;
- climate-health or environmental-data integration;
- declarative geospatial workflows;
- provider/plugin architectures;
- provenance, checksums or workflow reproducibility; or
- local/open climate-health tooling for Africa or LMICs.

The surviving contribution is narrower and now empirically evaluated: a **contract-first raster-to-administrative handoff** that binds mandatory three-part spatial-support semantics, fail-closed job/output rules, an out-of-tree provider boundary, independent computational cross-checks and exact release-evidence gates.

Array-specific E1-E3 experiments are complete and tracked in `evidence/array/` and `paper/ARRAY_NOVELTY_PRIOR_ART_AUDIT.md`.

## APC position

Array, ISSN 2590-0056, is explicitly listed in Elsevier's Geographical Pricing for Open Access programme. Elsevier's current pricing policy lists Rwanda in the **Low-income (No APC to be paid)** group and states that the APC is waived for participating journals when all authors are based in low-income countries.

Therefore, if the final author group remains entirely based in Rwanda or other countries in Elsevier's full-waiver low-income group, the current policy indicates an expected payable APC of **USD 0**. Elsevier calculates the applicable geo-price in the submission process.

This eligibility must be rechecked at submission time. Adding an author based outside the full-waiver group may change the APC. No University of Rwanda institutional Elsevier agreement is claimed or required for the current zero-APC expectation.

Official policy sources are recorded in `paper/ARRAY_JOURNAL_FIT_APC_AUDIT.md`.

## Affiliation

The author's current truthful affiliation for the rebuilt manuscript is:

`School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda`

This affiliation identifies the author's current academic institution. It does not imply University of Rwanda sponsorship, ownership or endorsement of the software. Published v1.3.0 historical metadata must not be rewritten retroactively.

## Current strategy

1. Preserve the SoftwareX reviews as a technical defect-discovery record and retain the completed remediation evidence.
2. Use `paper/array-manuscript.md` as the new active manuscript rather than reshaping the SoftwareX article in place.
3. Review every Array claim against `paper/ARRAY_CLAIM_EVIDENCE_MATRIX.md` and the prior-art audit.
4. Keep Rwanda and Uganda as evaluation contexts, not as the definition of the software contribution.
5. Retain the no-priority/no-superiority rule unless new direct evidence changes it.
6. Run exact-tree local and CI validation after the Array manuscript and supporting controls are stabilized.
7. Reserve and insert the v1.4.0 DOI only after technical and manuscript gates are closed.
8. Do not create a v1.4.0 tag, GitHub release or Zenodo publication without explicit owner authorization.
9. Recheck Array scope/APC information at final submission time.
10. Submit through the Elsevier transfer pathway only after the exact released artifact and manuscript package agree.

## Decision

**Proceed with Array hardening.**

The target is justified by scope, the software-engineering direction of the rebuilt study, direct Array precedent for interdisciplinary and health-related computer-science papers, and the current Rwanda no-APC policy. Acceptance is not assumed. The manuscript must earn novelty through the bounded contract and its empirical evaluation rather than through inflated claims.
