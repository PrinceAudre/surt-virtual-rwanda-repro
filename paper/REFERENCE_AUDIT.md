# Reference verification record

**Scope:** active Earth Science Informatics manuscript  
**Verification date:** 31 July 2026  
**Rule:** article and dataset metadata are checked against publisher, repository, standards-body, or official product pages. Search-engine snippets and model memory are not treated as final bibliographic evidence.

The active manuscript uses Springer-style author-year citations. Long author lists are shortened after the first three authors with `et al`. The W3C recommendation identifies its three editors explicitly. Final Word formatting remains subject to the journal's reference style at submission.

## Verified references

| Key | Verified manuscript entry | Primary or official source | Audit note |
|---|---|---|---|
| Baston 2025 | Baston D (2025) exactextractr: fast extraction from raster datasets using polygons. R package version 0.10.1. https://doi.org/10.32614/CRAN.package.exactextractr | CRAN package record and DOI landing page | Software package; version 0.10.1 retained because it is the locked candidate dependency |
| Busetto and Ranghetti 2016 | Busetto L, Ranghetti L (2016) MODIStsp: an R package for automatic preprocessing of MODIS Land Products time series. Comput Geosci 97:40–48. https://doi.org/10.1016/j.cageo.2016.08.020 | Elsevier DOI record | Title, journal, volume, pages, year, and DOI verified |
| Didan 2021 | Didan K (2021) MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid V061 [Dataset]. NASA EOSDIS Land Processes Distributed Active Archive Center. https://doi.org/10.5067/MODIS/MOD13A3.061 | NASA Earthdata / LP DAAC DOI record | Dataset citation, not a journal article; product identifier and version must remain `MOD13A3.061` |
| Funk et al. 2015 | Funk C, Peterson P, Landsfeld M et al (2015) The climate hazards infrared precipitation with stations – a new environmental record for monitoring extremes. Sci Data 2:150066. https://doi.org/10.1038/sdata.2015.66 | Scientific Data article page | Article number 150066, not a page range |
| Gorelick et al. 2017 | Gorelick N, Hancher M, Dixon M et al (2017) Google Earth Engine: planetary-scale geospatial analysis for everyone. Remote Sens Environ 202:18–27. https://doi.org/10.1016/j.rse.2017.06.031 | Elsevier DOI record | Volume and pages verified |
| Kale et al. 2023 | Kale A, Sun Z, Ma X (2023) Utility of the Python package Geoweaver_cwl for improving workflow reusability: an illustration with multidisciplinary use cases. Earth Sci Inform 16:2955–2961. https://doi.org/10.1007/s12145-023-01045-0 | Springer article page | All three authors are listed; no `et al` is needed in the reference entry |
| Lebo et al. 2013 | Lebo T, Sahoo S, McGuinness D (eds) (2013) PROV-O: The PROV Ontology. W3C Recommendation, 30 April 2013. https://www.w3.org/TR/prov-o/ | W3C Recommendation | The three named people are editors. The entry must not add `et al` |
| Mitchell et al. 2022 | Mitchell SN, Lahiff A, Cummings N et al (2022) FAIR data pipeline: provenance-driven data management for traceable scientific workflows. Philos Trans R Soc A 380(2233):20210300. https://doi.org/10.1098/rsta.2021.0300 | Royal Society / PubMed record | First three authors, issue 2233, and article number 20210300 verified |
| Muñoz-Sabater et al. 2021 | Muñoz-Sabater J, Dutra E, Agustí-Panareda A et al (2021) ERA5-Land: a state-of-the-art global reanalysis dataset for land applications. Earth Syst Sci Data 13:4349–4383. https://doi.org/10.5194/essd-13-4349-2021 | Copernicus / ESSD article page | Preserve diacritics in author names |
| Nobre et al. 2011 | Nobre AD, Cuartas LA, Hodnett M et al (2011) Height Above the Nearest Drainage – a hydrologically relevant new terrain model. J Hydrol 404:13–29. https://doi.org/10.1016/j.jhydrol.2011.03.051 | Elsevier DOI record | Volume, pages, year, and DOI verified |
| Soiland-Reyes et al. 2022 | Soiland-Reyes S, Sefton P, Crosas M et al (2022) Packaging research artefacts with RO-Crate. Data Sci 5(2):97–138. https://doi.org/10.3233/DS-210053 | Publisher article page | First three authors, issue 2, pages, year, and DOI verified; Silvio Peroni is the editor shown by the publisher, not the first article author |
| Tuyishime 2026 | Tuyishime AP (2026) SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.1. Zenodo [Software]. https://doi.org/10.5281/zenodo.21677162 | Zenodo version record | Published base archive only; replace or supplement with the new candidate release DOI before submission |
| Wilkinson et al. 2016 | Wilkinson MD, Dumontier M, Aalbersberg IJ et al (2016) The FAIR Guiding Principles for scientific data management and stewardship. Sci Data 3:160018. https://doi.org/10.1038/sdata.2016.18 | Scientific Data article page | Article number 160018 verified |
| Zong et al. 2024 | Zong L, Ngarukiyimana JP, Yang Y et al (2024) Malaria transmission risk is projected to increase in the highlands of Western and Northern Rwanda. Commun Earth Environ 5:559. https://doi.org/10.1038/s43247-024-01717-9 | Communications Earth & Environment article page | Article number 559 verified |

## Citation-consistency decisions

- In-text citations use `Author et al. year` for works with more than two authors, regardless of whether the reference entry prints the first three authors.
- `Busetto and Ranghetti (2016)` is the only two-author narrative form in the current manuscript.
- Dataset and software citations remain in the same alphabetical reference list because both are material research objects used by the workflow.
- The published version 1.1.1 software citation is retained to describe the base archive. The candidate additions cannot be attributed to that DOI.
- No reference is included solely to increase citation count. Each must support a specific design, product, workflow, provenance, or interpretation statement.

## Final-release checks

1. Re-run the manuscript audit after the final candidate DOI is inserted.
2. Confirm whether the journal requires all authors or permits first three plus `et al` in the reference list; conform the Word file accordingly.
3. Validate every DOI and standards URL in the final DOCX/PDF.
4. Ensure every reference is cited and every citation has one reference entry.
5. Replace branch references with the immutable GitHub/Zenodo release.
6. Confirm that the final archived software title and version exactly match the reference entry.
