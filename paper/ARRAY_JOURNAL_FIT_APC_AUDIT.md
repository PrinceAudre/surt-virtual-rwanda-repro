# Array journal-fit and APC audit

**Checked:** 2026-10-04  
**Purpose:** submission planning for SuRT-GeoHarmonizer v1.4.0. This file does not authorize submission or release.

## 1. Journal fit

Array is an Elsevier open-access multidisciplinary computer-science journal. Its stated scope includes Software Engineering, Scientific Computing, Interdisciplinary Applications, and Medical Informatics and Biomedical Engineering. The journal states that submissions must be novel, technically sound, and clearly presented.

For SuRT-GeoHarmonizer, the strongest fit is **software engineering + scientific computing + interdisciplinary application**, with climate-health/public-health use cases providing motivation and evaluation context rather than defining the novelty claim.

The manuscript should therefore be written as a software/systems research paper, not as a public-health methods paper and not as a SoftwareX-style software-description note.

The contribution should be stated as a contract-first, machine-verifiable raster-to-administrative handoff and evaluated through explicit research questions. The Rwanda and Uganda environmental cases should serve as scoped external evaluation of the contract.

Official/current journal entry points:

- Array journal homepage: https://www.sciencedirect.com/journal/array
- Array aims and scope: https://www.sciencedirect.com/journal/array/about/aims-and-scope
- Array guide for authors: https://www.sciencedirect.com/journal/array/publish/guide-for-authors
- Elsevier computer-science journal portfolio: https://www.elsevier.com/subject/computer-science/journals

The founding Array editorial also explicitly describes the journal as spanning the full field of computer science, welcoming interdisciplinary contributions, and requiring novelty, technical soundness, and clear presentation: Thierry Denoeux, *Editorial: Opening up computer science*, Array 1-2 (2019), article 100005, https://doi.org/10.1016/S2590-0056(19)30005-0.

## 2. What `novel` does and does not require

`Novel` does not mean every library primitive must be invented by the paper. SuRT may validly build on exactextractr, terra, sf, Python validation libraries, Snakemake, and established environmental products.

The burden is instead to demonstrate a new and useful systems-level contribution that is not merely a thin reimplementation of existing tools. Current evidence supports the narrower claim that SuRT binds mandatory spatial-support semantics, fail-closed configuration, provider decoupling, independent numerical verification and exact release evidence into one bounded handoff contract.

The manuscript must not claim new zonal-statistics mathematics, first-ever geospatial reproducibility, first climate-health harmonization for Africa/LMICs, or superiority over broader systems.

## 3. Open-access/APC status

Array, ISSN `2590-0056`, is explicitly included in Elsevier's **Geographical Pricing for Open Access (GPOA)** participating-journal list:

- https://www.elsevier.com/en-gb/about/policies-and-standards/pricing/gpoa-journals-list

Elsevier's current pricing policy states that, for participating fully gold open-access journals, the APC is waived when **all authors are based in low-income countries** under the applicable World Bank classification. The same current policy explicitly lists **Rwanda** in the `Low-income (No APC to be paid)` group:

- https://www.elsevier.com/about/policies-and-standards/pricing
- https://service.elsevier.com/app/answers/detail/a_id/37354/supporthub/publishing/~/geographical-pricing-for-open-access-%28gpoa%29/

### Current implication for this manuscript

If the author group at submission consists entirely of authors based in Rwanda or other countries that Elsevier places in the GPOA low-income full-waiver group, the current policy indicates **no APC should be payable for Array**. Elsevier states that the applicable geo-price is calculated automatically during submission.

This is stronger and more directly relevant than relying on a University of Rwanda institutional publishing agreement.

### Conditions and cautions

- APC eligibility must be rechecked in the submission workflow because Elsevier can update journal participation, country classification or pricing policy.
- The all-authors condition matters. Adding an author based outside the full-waiver low-income group can change the calculated APC.
- Affiliation must be truthful and current. The current manuscript affiliation is `School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda`.
- No institutional agreement should be claimed unless independently verified.
- A zero APC does not imply easier peer review or acceptance.

## 4. Decision

**Array remains a rational transfer target.**

Reasons:

1. scope accepts software engineering, scientific computing and interdisciplinary computer-science work;
2. the journal explicitly requires novelty and technical soundness, which matches the evidence-led hardening strategy;
3. the current GPOA policy places Array in the geographical-pricing pilot and Rwanda in the no-APC low-income group, making a full APC waiver likely under the current all-authors condition; and
4. the paper can retain its climate-health motivation while being evaluated on the stronger software-engineering contribution.

The transfer should proceed only after the Array-specific manuscript and exact release artifact pass the final review protocol.
