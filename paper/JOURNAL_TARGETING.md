# Journal targeting decision for SuRT-Virtual Rwanda

**Assessment date:** 31 July 2026  
**Artifact assessed:** Zenodo v1.1.1 (`10.5281/zenodo.21677162`) and the manuscript on this branch

## Decision

### Primary target: Earth Science Informatics

**Publisher:** Springer Nature  
**Publishing model:** Hybrid  
**Recommended article type:** Software article  
**Cost route:** Subscription publication, for which Springer Nature does not charge an article-processing charge. Open access remains optional and would normally carry an APC unless an agreement or funder covers it.

Official sources:

- Journal home and metrics: https://link.springer.com/journal/12145
- Aims and scope: https://link.springer.com/journal/12145/aims-and-scope
- Submission guidelines: https://link.springer.com/journal/12145/submission-guidelines
- Springer Nature APC policy for hybrid journals: https://support.springernature.com/en/support/solutions/articles/6000211135-article-processing-charges-apc-

### Why it fits

Earth Science Informatics explicitly publishes research, methodology, and software articles on formal and computational methods and computer applications for acquiring, processing, interchanging, and visualising Earth-system data. The released software combines four Earth-observation and terrain products, product-specific transformations, administrative aggregation, provenance classification, reproducibility tests, and archived release integrity.

The journal is established and currently reports a 2025 Journal Impact Factor of 4.2, a five-year Journal Impact Factor of 3.8, and indexing in Scopus and the Science Citation Index Expanded.

### Main scope risk

The journal warns that manuscripts whose principal contribution is a conventional GIS, remote-sensing, geography, or application-domain study may be out of scope. The manuscript must therefore establish that the central contribution is an Earth-science informatics method and release contract, not a Rwanda map product or a climate-health application.

The submission should foreground:

1. cross-provider Earth-data harmonisation;
2. a common administrative-output contract;
3. fail-closed provenance classification;
4. hermetic and provider-independent verification;
5. release integrity and reproducible archival; and
6. portability of the design beyond Rwanda.

The Rwanda implementation should be framed as the evaluated reference implementation.

### Required journal structure

The software-article instructions require:

- a **Design and Implementation** section between Introduction and Results;
- an **Availability and Requirements** section after Conclusions;
- a **Software Files** section after tables and captions;
- operating-system and hardware requirements;
- editable source files;
- an abstract of 150–250 words;
- four to six keywords; and
- author–year citations with an alphabetised reference list.

The guidelines explicitly accommodate temporarily unaffiliated authors by recording city and country of residence. The article can therefore use `Kigali, Rwanda` truthfully without inventing an institutional affiliation.

## Backup target: Discover Informatics

**Publisher:** Springer Nature  
**Publishing model:** Fully open access  
**Recommended article type:** Methodology or Research  
**Current APC:** £0 / US$0 / €0 for articles accepted through 31 December 2027

Official sources:

- Journal home and fee sponsorship: https://link.springer.com/journal/44564
- Aims and scope: https://link.springer.com/journal/44564/aims-and-scope
- Submission guidelines: https://link.springer.com/journal/44564/submission-guidelines

The scope is an excellent substantive fit because it includes environmental and geospatial informatics, scientific workflows, metadata standards, data curation, auditability, accountability, FAIR data, and reproducibility. The trade-off is maturity: the journal launched in June 2026 and is not currently listed in Scopus or Web of Science. It is therefore the strongest free-open-access policy fit, but not yet the strongest indexing or track-record option.

## Not recommended for the current manuscript

### Cureus Journal of AI-Augmented Research

Official scope: https://www.cureusjournals.com/scope/ai-augmented-research

CJAI requires AI to be central to the research. It explicitly excludes traditional algorithms without AI and manuscripts where AI was used only for writing, editing, or formatting. In the present study, the reported workflow is deterministic R/Python geospatial software; generative AI assisted development and editing but did not constitute the method or intervention. Recasting the existing manuscript as AI research would be inaccurate.

CJAI would become relevant only for a separate study with a prespecified AI research question and new evidence, for example a benchmark of an LLM-assisted provenance auditor against the deterministic fail-closed contract, with blinded reference labels, performance metrics, error analysis, and reproducible prompts/models.

### Cureus Journal of Medical Science

The present artifact contains no patient, surveillance, clinical, epidemiological, or healthcare-delivery evaluation. Its central contribution is Earth-data informatics rather than medical science. Journal fit would be weak despite the possibility of low-cost publication.

### Systematic Reviews

The Springer Nature marketing email is a general journal alert, not a manuscript-specific recommendation. Systematic Reviews publishes evidence syntheses and review methodology; this software article is outside its article type and scope.

### Journal of Medical Systems

The current manuscript does not evaluate a clinical information system in a healthcare-delivery setting. Submission would require a materially different study involving a deployed or evaluated health-system use case.

## Secondary established fallback

### SN Computer Science

SN Computer Science is a broad, hybrid Springer Nature journal. The subscription route can be used without an APC. It is a possible fallback if the paper is expanded into a stronger software-engineering evaluation, including runtime and memory benchmarks, failure-injection tests, portability across operating systems, and comparative evaluation against alternative workflow assemblies. Its broad scope is less exact than Earth Science Informatics.

## Submission gate

Do not submit until all of the following are complete:

- journal-specific software-article structure;
- at least one architecture/workflow figure;
- maps or distributions of all four released layers;
- quantitative verification and performance reporting;
- independent numerical spot checks or a clearly defined validation study;
- portability analysis beyond Rwanda;
- author–year reference conversion;
- exact AI-use disclosure consistent with Springer Nature policy;
- truthful affiliation recorded as city and country unless a verifiable institutional affiliation applies to the work; and
- a final clean-environment CI run on the exact submission commit.
