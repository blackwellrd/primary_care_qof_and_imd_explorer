# ======================= #
# Load required libraries #
# ======================= #

if(!require(tidyverse)){
  install.packages('tidyverse')
  library(tidyverse)
}

if(!require(readxl)){
  install.packages('readxl')
  library(readxl)
}

# ==================== #
# Input data locations #
# ==================== #

# GP registration data
fil_gp_popn <- 'D:/Data/NHSD/GPREGLSOA/20221001/gp-reg-pat-prac-lsoa-all.csv'
# IMD data
fil_imd <- 'D:/Data/GOV.UK/IMD19/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators_3.csv'
# QOF data
fil_qof_achv <- 'D:/Data/NHSD/QOF/2022/ACHIEVEMENT_2122.csv'
fil_qof_prev <- 'D:/Data/NHSD/QOF/2022/PREVALENCE_2122_V2.csv'
fil_qof_org <- 'D:/Data/NHSD/QOF/2022/MAPPING_NHS_GEOGRAPHIES_2122.csv'
# Lookups
fil_epcn <- 'D:/Data/NHSD/EPCN/20221028/ePCN.xlsx'
sht_epcn <- 'PCNDetails'
fil_prac_pcn_icb <- 'D:/Data/NHSD/ORGMAP/20221001/gp-reg-pat-prac-map.csv'
fil_postcode <- 'D:/Data/OpenGeography/Lookups/PCD/20220831/Data/ONSPD_AUG_2022_UK.csv'

# =============== #
# Load input data #
# =============== #

df_gp_popn <- read.csv(file = fil_gp_popn) %>% 
  select(3, 5, 7) %>% 
  rename_with(.fn = function(x){c('PRACTICE_CODE','LSOA_CODE','POPN')})
df_imd <- read.csv(file = fil_imd) %>% 
  select(1, 5) %>%
  rename_with(.fn = function(x){c('LSOA_CODE','IMD_SCORE')})
df_qof_achv <- read.csv(file = fil_qof_achv) %>% 
  filter(MEASURE %in% c('NUMERATOR','DENOMINATOR','PCAS')) %>%
  pivot_wider(names_from = 'MEASURE', values_from = 'VALUE', values_fill = 0) %>%
  transmute(PRACTICE_CODE, INDICATOR_CODE, NUMERATOR, DENOMINATOR = DENOMINATOR + PCAS)
df_qof_org <- read.csv(file = fil_qof_org) %>% 
  select(15, 16, 13, 14, 10, 12, 7, 9, 4, 6) %>%
  rename_with(.fn = function(x){c(
    'PRACTICE_CODE', 'PRACTICE_NAME',
    'PCN_CODE', 'PCN_NAME',
    'SUB_ICB_CODE', 'SUB_ICB_NAME',
    'ICB_CODE', 'ICB_NAME',
    'REGION_CODE', 'REGION_NAME'
  )})
df_qof_prev <- read.csv(file = fil_qof_prev) %>% 
  select(1, 2, 3, 5) %>%
  rename_with(.fn = function(x){c('PRACTICE_CODE','INDICATOR_CODE','NUMERATOR','DENOMINATOR')})
df_epcn <- read_excel(path = fil_epcn, sheet = sht_epcn) %>% 
  select(1, 2, 3, 12) %>%
  rename_with(.fn = function(x){c('PCN_CODE','PCN_NAME','SUB_ICB_CODE','PCN_POSTCODE')})
df_prac_pcn_icb <- read.csv(file = fil_prac_pcn_icb) %>% 
  select(3, 4, 5, 17, 6, 7, 9, 10, 12, 13, 15, 16) %>%
  rename_with(.fn = function(x){c(
    'PRACTICE_CODE', 'PRACTICE_NAME', 'PRACTICE_POSTCODE', 'PRACTICE_SYSTEM',
    'PCN_CODE', 'PCN_NAME', 
    'SUB_ICB_CODE', 'SUB_ICB_NAME',
    'ICB_CODE', 'ICB_NAME',
    'REGION_CODE', 'REGION_NAME'
    )})
df_postcode <- read.csv(file = fil_postcode) %>% 
  transmute(
    POSTCODE = pcds,
    EASTING = oseast1m, NORTHING = osnrth1m,
    LATITUDE = lat, LONGITUDE = long)

# ======================================== #
# Create the practice and PCN lookup files #
# ======================================== #

# Create the final lookup files for practice and PCN
df_practice_lookup <- df_qof_org %>%
  left_join(
    df_prac_pcn_icb %>% select(PRACTICE_CODE, PRACTICE_POSTCODE, PRACTICE_SYSTEM),
    by = c('PRACTICE_CODE' = 'PRACTICE_CODE')
    ) %>%
  left_join(
    df_postcode,
    by = c('PRACTICE_POSTCODE' = 'POSTCODE')
  ) %>%
  select(1, 2, 11:16, 3:10)

# Create the final lookup files for practice and PCN
df_pcn_lookup <- df_epcn %>% 
  left_join(
    df_prac_pcn_icb %>% 
      distinct(SUB_ICB_CODE, SUB_ICB_NAME,
        ICB_CODE, ICB_NAME, REGION_CODE, REGION_NAME),
    by = c('SUB_ICB_CODE' = 'SUB_ICB_CODE')
  ) %>% 
  left_join(
    df_postcode,
    by = c('PCN_POSTCODE' = 'POSTCODE')
  ) %>% 
  select(1, 2, 4, 10:13, 3, 5:9)

# ========================================== #
# Create the practice and PCN level IMD data #
# ========================================== #

df_tmp <- df_imd %>% 
  left_join(
    df_gp_popn,
    by = c('LSOA_CODE' = 'LSOA_CODE')
  ) %>% 
  left_join(
    df_practice_lookup %>% select(PRACTICE_CODE, PCN_CODE),
    by = c('PRACTICE_CODE' = 'PRACTICE_CODE')    
  ) %>%
  mutate(IMD_SCORE = IMD_SCORE * POPN)

df_practice_imd <- df_tmp %>%
  group_by(PRACTICE_CODE) %>%
  summarise(
    POPN = sum(POPN, na.rm = TRUE),
    IMD_SCORE = sum(IMD_SCORE, na.rm = TRUE)
  ) %>%
  transmute(
    PRACTICE_CODE,
    POPN,
    IMD_SCORE = IMD_SCORE / POPN
  ) %>% 
  ungroup() %>%
  mutate(IMD_DECILE = ntile(desc(IMD_SCORE), n = 10))

df_pcn_imd <- df_tmp %>%
  filter(!is.na(PCN_CODE) & PCN_CODE!='U') %>%
  group_by(PCN_CODE) %>%
  summarise(
    POPN = sum(POPN, na.rm = TRUE),
    IMD_SCORE = sum(IMD_SCORE, na.rm = TRUE)
  ) %>%
  transmute(
    PCN_CODE,
    POPN,
    IMD_SCORE = IMD_SCORE / POPN
  ) %>% 
  ungroup() %>%
  mutate(IMD_DECILE = ntile(desc(IMD_SCORE), n = 10))

rm(df_tmp)
  
# ========================================== #
# Create the practice and PCN level QOF data #
# ========================================== #

# --------------- #
# QOF Achievement #
# --------------- #

df_tmp <- df_qof_achv %>% 
  left_join(
    df_practice_lookup %>% select(PRACTICE_CODE, PCN_CODE),
    by = c('PRACTICE_CODE' = 'PRACTICE_CODE')    
  ) %>%
  pivot_wider(
    names_from = INDICATOR_CODE, 
    values_from = c(NUMERATOR, DENOMINATOR), 
    names_glue = "QOF_ACHV_{INDICATOR_CODE}_{.value}")

df_practice_qof_achv <- df_tmp %>% select(-PCN_CODE)

df_pcn_qof_achv <- df_tmp %>%
  group_by(PCN_CODE) %>% 
  summarise(across(3:NCOL(df_tmp)-1, .fns = sum)) %>%
  ungroup()

# -------------- #
# QOF Prevalence #
# -------------- #

df_tmp <- df_qof_prev %>% 
  left_join(
    df_practice_lookup %>% select(PRACTICE_CODE, PCN_CODE),
    by = c('PRACTICE_CODE' = 'PRACTICE_CODE')    
  ) %>% 
  pivot_wider(
    names_from = INDICATOR_CODE, 
    values_from = c(NUMERATOR, DENOMINATOR), 
    names_glue = "QOF_PREV_{INDICATOR_CODE}_{.value}")

df_practice_qof_prev <- df_tmp %>% select(-PCN_CODE)

df_pcn_qof_prev <- df_tmp %>%
  group_by(PCN_CODE) %>% 
  summarise(across(3:NCOL(df_tmp)-1, .fns = sum)) %>%
  ungroup()

# ============================================================================== #
# Create practice and PCN level data matrix with Sub-ICB, ICB and Region details #
# ============================================================================== #

df_practice_data_matrix <- df_practice_imd %>%
  left_join(
    df_practice_lookup,
    by = c('PRACTICE_CODE' = 'PRACTICE_CODE')
  ) %>% 
  filter(!is.na(PRACTICE_NAME)) %>%
  select(1, 5:19, 2:4) %>%
  left_join(
    df_practice_qof_achv,
    by = c('PRACTICE_CODE' = 'PRACTICE_CODE')
  ) %>%
  left_join(
    df_practice_qof_prev,
    by = c('PRACTICE_CODE' = 'PRACTICE_CODE')
  )

df_pcn_data_matrix <- df_pcn_imd %>%
  left_join(
    df_pcn_lookup,
    by = c('PCN_CODE' = 'PCN_CODE')
  ) %>%
  select(1, 5:16, 2:4) %>%
  left_join(
    df_pcn_qof_achv,
    by = c('PCN_CODE' = 'PCN_CODE')
  ) %>%
  left_join(
    df_pcn_qof_prev,
    by = c('PCN_CODE' = 'PCN_CODE')
  )

dir.create('./outputs', showWarnings = FALSE, recursive = TRUE)
write.csv(df_practice_data_matrix, './outputs/practice_data_matrix.csv', row.names = FALSE)
write.csv(df_pcn_data_matrix, './outputs/pcn_data_matrix.csv', row.names = FALSE)

