### Code for:
# Copy Number Variant Risk Scores Associated with Cognition, Psychopathology, and Brain Structure in the Philadelphia Neurodevelopmental Cohort

#### Alexander-Bloch et al., 2022.

This repository contains code to perform CNV quality control, filtering, and annotation as described in this paper. These scripts are performed on output after running CNVision and filtering steps described at: https://github.com/MartineauJeanLouis/MIND-GENESPARALLELCNV

## 1. CNV Processing/Exclusions

CNV exclusion scripts with clean raw CNV data.

| Script | Description |
| --- | --- |
| Exclusion_1 | Takes data from CNVision merge format and applies chip quality control and markers criteria (see paper Supplemental Sections S3-4, SFigs. 1-3).|
| Exclusion_2 | Takes data from Exclusion_1 and applies additional CNV cleaning criteria (see paper Supplemental Sections S3-4, SFigs. 1-3).|
  
## 2. CNV Annotations

A list of scripts for implementing different CNV annotations, to be run following CNV Exclusions.

| Script | Description |
| --- | --- |
| Annotation_1 | Annotates CNV for pTS and pHI score, returns subject-level data frame. |
| Annotation_2 | Annotates CNV duplications, e.g., for paper Table 1. |
| Annotation_3 | Annotates CNV deletions, e.g., for paper Table 1. |
| Annotation_4 | Annotates CNV for deletion clusters as shown in Supplemental SFig.4. |
| Annotation_5 | Annotates CNV for duplication clusters as shown in Supplemental SFig.4. |

## Authors

* Nick Huffnagle
* Aaron Alexander-Bloch
