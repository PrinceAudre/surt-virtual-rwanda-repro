# Journal strategy after SoftwareX peer review

**Assessment date:** 3 October 2026  
**Manuscript:** `SOFTX-D-26-01014`  
**Purpose:** internal decision record for the reviewer-remediated v1.4.0 manuscript

## Current editorial state

SoftwareX formally rejected the v1.3.0 submission on 2 October 2026. The same decision letter states that both reviewers recognized the verification and reproducibility strengths, identifies specific technical and reuse deficiencies, and instructs the author that a revised submission should provide a comprehensive point-by-point response. It explicitly says the final evaluation will depend on how convincingly the spatial refinements, broader applicability, and distinct value proposition are demonstrated.

Elsevier subsequently offered transfer destinations. A transfer is optional, and the destination journal makes its own editorial decision. The transfer page was generated from the earlier manuscript state, not the rebuilt v1.4 evidence base.

## APC position

APC cost is not currently a reason to leave SoftwareX.

Elsevier states that all fully open-access Elsevier journals participate in Research4Life APC eligibility, with a 100% waiver for Group A author groups. Current Research4Life eligibility places Rwanda in Group A. Therefore a sole-author SoftwareX paper with the author's current Rwanda institutional affiliation should be eligible for a 100% APC waiver, subject to Elsevier's final automated eligibility determination after acceptance.

The five offered transfer journals are also listed in Elsevier's Geographical Pricing for Open Access program. Elsevier's current policy states that papers for which all authors are based in World Bank low-income countries pay no APC in participating journals, and Rwanda is explicitly in the current `Low-income (No APC to be paid)` group. The expected payable APC for the offered journals is therefore also USD 0, subject to final publisher eligibility checks.

Official policy sources:

- Elsevier pricing and country groups: https://www.elsevier.com/about/policies-and-standards/pricing
- GPOA participating journals: https://www.elsevier.com/about/policies-and-standards/pricing/gpoa-journals-list
- Elsevier open-access waiver policy: https://www.elsevier.com/researcher/author/open-access/choice
- Research4Life eligibility: https://www.research4life.org/access/eligibility/
- World Bank current income groups: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups

## Option 1. Fresh SoftwareX submission referencing the prior manuscript

### Advantages

- Best article-type fit: SoftwareX explicitly publishes detailed research-software articles and emphasizes open science and reproducibility.
- The two reviews already define the exact acceptance risk, and v1.4 has been engineered around those concerns rather than around a new editorial target.
- Recent SoftwareX publications include generalized geospatial software, reproducible Snakemake workflows, environmental-data systems, raster/vector toolkits, GIS workflows, and software demonstrated in more than one geographic context.
- The current point-by-point response can remain central rather than being discarded or hidden.
- Expected APC is zero under Research4Life if eligibility is confirmed.

### Risk

The earlier submission is formally rejected, so renewed consideration cannot be assumed. Before final submission, ask SoftwareX whether a substantially rebuilt new submission that references `SOFTX-D-26-01014` is welcome and how they want the prior reviewer response supplied. The editor's decision letter supports asking this question but does not guarantee that a new submission will be accepted or sent to the same reviewers.

## Option 2. Transfer to Array

### Advantages

- Broad computer-science scope can accommodate software architecture and reusable research tooling.
- The current Elsevier transfer offer marks Array for guaranteed peer review, which is an editorial-process advantage, not a guarantee of acceptance.
- It is a GPOA journal, so the expected APC for a Rwanda-only author group is USD 0.
- Transfer can carry files and, where configured, prior reviewer material, reducing administrative friction.

### Risks

- The manuscript would need stronger computer-science/software-engineering framing than SoftwareX requires.
- A transfer generated from the older manuscript is not evidence that the rebuilt v1.4 is a better thematic fit there than in SoftwareX.
- The paper should not be distorted into a new-algorithm claim merely to fit a general computer-science journal.

**Role:** strongest transfer fallback if SoftwareX declines a fresh rebuilt submission.

## Option 3. Transfer to Results in Engineering

The offer marks this journal for guaranteed peer review, and it participates in GPOA. However, its core audience is engineering, and the manuscript does not presently revolve around an engineering system, device, process, or quantified engineering outcome. Reframing the work as engineering would be less natural than the SoftwareX or Array routes.

**Role:** secondary fallback only if the editor confirms the software/data-infrastructure contribution fits its interdisciplinary engineering remit.

## Option 4. Transfer to Ecological Informatics

Ecological Informatics is a credible computational-environmental journal and participates in GPOA. Its scope centers on computational ecology, ecological data science, biogeography, ecosystem analysis, and ecosystem management. SuRT uses environmental data, but the current manuscript does not test an ecological hypothesis, perform ecosystem analysis, or evaluate ecological decision support.

**Role:** do not transfer the current manuscript there merely for journal metrics. Consider it only if a separate ecological use case becomes a substantive part of the study.

## Option 5. Systems and Soft Computing

The journal focuses on soft-computing and computational-intelligence methods such as fuzzy logic, neural networks, evolutionary and bio-inspired computation, and related applications. SuRT is a deterministic geospatial harmonization and reproducibility workflow, not a soft-computing method.

**Role:** scope mismatch; do not transfer.

## Option 6. Natural Language Processing Journal

The journal is focused on analysis, processing, and modelling of human language. SuRT does not contain an NLP research contribution.

**Role:** scope mismatch; do not transfer.

## Current strategy

1. Complete the v1.4 evidence-led final review without depending on Claude or another named model.
2. Close the remaining software-reuse gap with an executable external-adapter plugin test.
3. Add the closest adjacent pipeline, DART-Pipeline, to the related-work boundary and narrow the novelty claim accordingly.
4. Keep the SoftwareX manuscript structure while the technical review is completed.
5. Before release freeze, send a short presubmission query to the SoftwareX editorial office asking whether they will consider a substantially rebuilt new submission referencing `SOFTX-D-26-01014` and its reviewer response.
6. If SoftwareX confirms that route, freeze and release v1.4.0 for SoftwareX.
7. If SoftwareX declines or advises transfer, use Array as the first transfer candidate and re-audit the manuscript against Array's current guide before transfer.
8. Do not select a journal merely on APC, impact metric, or transfer convenience. Under the current Rwanda eligibility, APC is expected to be zero across the realistic Elsevier options.

This strategy does not assume acceptance at any destination.
