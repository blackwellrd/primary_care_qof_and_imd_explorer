# Primary Care QOF and IMD Explorer
Create practice and PCN level datasets for Quality and Outcomes Framework (QOF) Achievement and Prevalence and Indices of Multiple Deprivation (IMD)

### Methodology
Convert the Indices of Multiple Deprivation (IMD) 2019 data from Lower-layer Super Output Area (LSOA) geographical area into practice and PCN by using a population weighted score.

The overall IMD score for that LSOA is multiplied by the number of patients registered at the practice who live in that LSOA, this population weighted score is summed for each practice and the resulting figure is divided by the number of patients registered at the practice to create the practice overall IMD score. These scores are arranged descending and the decile assigned to each practice is the IMD decile (1 - most deprived to 10 - least deprived). For PCN the weighted scores are the sum of all the weighted population scores for the member practices of the PCN and as divided by the PCN population to create the PCN IMD score, this is then ranked descending and the decile assigned to each PCN.

The QOF achievement for each indicator is given by the numerator value for that indicator divided by the sum of the denominator and Personalised Care Adjustment (PCA) value. This calculation give the 'true' achievement ignoring any exclusions.

The QOF prevalance for each indicator group is given by the register size for the that indicator group divided by the practice list size relevant for that indicator (this might be the entire practice, or over 6, 16, 17, 18, and 50 year olds).

For both the QOF achievement and prevalence the PCN calculation is to simply sum the values (numerator, denominator, register etc) used in the calculation for member practices of the PCN.

Practices that are present in the practice registration but not in QOF data are ignored and removed from the practice level data and do not form part of the PCN level calculation. Unallocated practices are also ignored in for the PCN level calculation but are still present in the practice level data.

***

### Datasets used and their locations

##### General Practice Registration at LSOA
* Description: Number of people registered with practice in each Lower-layer Super Output Area (LSOA)
* Links:
  + [Landing page](https://digital.nhs.uk/data-and-information/publications/statistical/patients-registered-at-a-gp-practice/october-2022)
  + [Current download link](https://files.digital.nhs.uk/AA/AE3EDC/gp-reg-pat-prac-lsoa-male-female-oct-22..zip)
  + File: gp-reg-pat-prac-lsoa-all.csv


##### Indices of Multiple Deprivation Domain Scores
* Description: Indices of Multiple Deprivation (IMD) 2019 Domain Scores by Lower-layer Super Output Area
* Links
  + [Landing page](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019)
  + [Current download link](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/845345/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators_3.csv)
  + File: File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators_3.csv

##### QOF Achievement and Prevalence Data
* Description: Quality and Outcomes Framework (QOF) 2021/22 Achievement and Prevalence by Practice and Organisation Mapping from Practice to PCN to Sub-ICB Location to ICB to Region
* Links
  + [Landing page](https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2021-22)
  + [Current download link](https://files.digital.nhs.uk/90/6F833F/QOF_2122_V2.zip)
  + Files: 
      + ACHIEVEMENT_2122.csv 
      + PREVALENCE_2122_V2.csv
      + MAPPING_NHS_GEOGRAPHIES_2122.csv
      
##### PCN Details
* Description: England Primary Care Networks (PCN) details including postcode and Sub-ICB Location
* Links:
  + [Landing page](https://digital.nhs.uk/services/organisation-data-service/file-downloads/gp-and-gp-practice-related-data)
  + [Current download link](https://nhs-prod.global.ssl.fastly.net/binaries/content/assets/website-assets/services/ods/data-downloads-other-nhs-organisations/epcn.zip)
  + File: ePCN.xlsx
  + Worksheet: PCNDetails
  
##### Practice to PCN to Sub-ICB Location to ICB to NHS Region
* Description: Practice (with postcode) to Primary Care Network (PCN) to Sub-Integrated Care Board (Sub-ICB) Location (previously CCG) to Integrated Care Board (ICB) to NHS England Region
* Links:
  + [Landing page](https://digital.nhs.uk/data-and-information/publications/statistical/patients-registered-at-a-gp-practice/october-2022)
  + [Current download link](https://files.digital.nhs.uk/1F/9ACF6B/gp-reg-pat-prac-map.csv)
  + File: gp-reg-pat-prac-map.csv

##### Postcode data
Description: Office of National Statistics Postcode file used to geocode postcode to longitude, latitude and easting and northing
* Links:
  + [Landing page](https://geoportal.statistics.gov.uk/datasets/ons-postcode-directory-august-2022/about)
  + [Current download link](https://www.arcgis.com/sharing/rest/content/items/8e0d123a946240288c3c84cf9f9cba28/data)
  + File: ONSPD_AUG_2022_UK.csv