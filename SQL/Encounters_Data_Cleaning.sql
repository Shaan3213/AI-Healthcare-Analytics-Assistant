/*==============================================================================
Project     : Healthcare Operations & Financial Performance Analytics Platform

Developer   : Mohd Shaan Saifi

Database    : HEALTHCARE_DB
Source Table: RAW_SCHEMA.ENCOUNTERS
Target Table: CLEAN_SCHEMA.ENCOUNTERS

Description :
This script performs data profiling, data quality assessment,
standardization, and cleaning of the Encounters dataset.
The cleaned dataset is stored in CLEAN_SCHEMA for downstream
analytics in Databricks and visualization in Power BI.

==============================================================================*/


/*==============================================================================
SECTION 1 : DATA PROFILING
==============================================================================*/


-- -----------------------------------------------------------------------------
-- Total number of records
-- -----------------------------------------------------------------------------

SELECT COUNT(*) AS TOTAL_RECORDS
FROM RAW_SCHEMA.ENCOUNTERS;


-- -----------------------------------------------------------------------------
-- Review table structure
-- -----------------------------------------------------------------------------

DESC TABLE RAW_SCHEMA.ENCOUNTERS;



-- -----------------------------------------------------------------------------
-- Preview first 10 records
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.ENCOUNTERS
LIMIT 10;



/*==============================================================================
SECTION 2 : DATA QUALITY ASSESSMENT
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Check Missing Values
-- -----------------------------------------------------------------------------

SELECT
COUNT_IF(ID IS NULL) AS ID_NULLS,
COUNT_IF(START_TIME IS NULL) AS START_TIME_NULLS,
COUNT_IF(STOP_TIME IS NULL) AS STOP_TIME_NULLS,
COUNT_IF(PATIENT IS NULL) AS PATIENT_NULLS,
COUNT_IF(ORGANIZATION IS NULL) AS ORGANIZATION_NULLS,
COUNT_IF(PROVIDER IS NULL) AS PROVIDER_NULLS,
COUNT_IF(PAYER IS NULL) AS PAYER_NULLS,
COUNT_IF(ENCOUNTERCLASS IS NULL) AS ENCOUNTERCLASS_NULLS,
COUNT_IF(CODE IS NULL) AS CODE_NULLS,
COUNT_IF(DESCRIPTION IS NULL) AS DESCRIPTION_NULLS,
COUNT_IF(BASE_ENCOUNTER_COST IS NULL) AS BASE_ENCOUNTER_COST_NULLS,
COUNT_IF(TOTAL_CLAIM_COST IS NULL) AS TOTAL_CLAIM_COST_NULLS,
COUNT_IF(PAYER_COVERAGE IS NULL) AS PAYER_COVERAGE_NULLS,
COUNT_IF(REASONCODE IS NULL) AS REASONCODE_NULLS,
COUNT_IF(REASONDESCRIPTION IS NULL) AS REASONDESCRIPTION_NULLS
FROM RAW_SCHEMA.ENCOUNTERS;


-- -----------------------------------------------------------------------------
-- Check Duplicate Encounter IDs
-- -----------------------------------------------------------------------------

SELECT
ID,
COUNT(*) AS DUPLICATE_COUNT
FROM RAW_SCHEMA.ENCOUNTERS
GROUP BY ID
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- Check Blank Strings
-- -----------------------------------------------------------------------------

SELECT
COUNT_IF(TRIM(DESCRIPTION)='') AS BLANK_DESCRIPTION,
COUNT_IF(TRIM(ENCOUNTERCLASS)='') AS BLANK_ENCOUNTERCLASS
FROM RAW_SCHEMA.ENCOUNTERS;


-- -----------------------------------------------------------------------------
-- Validate Encounter Classes
-- -----------------------------------------------------------------------------

SELECT DISTINCT ENCOUNTERCLASS
FROM RAW_SCHEMA.ENCOUNTERS
ORDER BY ENCOUNTERCLASS;


-- -----------------------------------------------------------------------------
-- Validate Financial Metrics
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.ENCOUNTERS
WHERE BASE_ENCOUNTER_COST < 0
   OR TOTAL_CLAIM_COST < 0
   OR PAYER_COVERAGE < 0;


-- -----------------------------------------------------------------------------
-- Validate Date Range
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.ENCOUNTERS
WHERE TRY_TO_TIMESTAMP_NTZ(STOP_TIME)
    < TRY_TO_TIMESTAMP_NTZ(START_TIME);


-- -----------------------------------------------------------------------------
-- Validate Claim Coverage
-- Payer coverage should not exceed the total claim cost.
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.ENCOUNTERS
WHERE PAYER_COVERAGE > TOTAL_CLAIM_COST;

/*==============================================================================
SECTION 3 : TRANSFORMATION TESTING
==============================================================================*/

SELECT

START_TIME,
TRY_TO_TIMESTAMP_NTZ(START_TIME) AS CLEAN_START_TIME,

STOP_TIME,
TRY_TO_TIMESTAMP_NTZ(STOP_TIME) AS CLEAN_STOP_TIME,

DESCRIPTION,
INITCAP(TRIM(DESCRIPTION)) AS CLEAN_DESCRIPTION,

ENCOUNTERCLASS,
LOWER(TRIM(ENCOUNTERCLASS)) AS CLEAN_ENCOUNTERCLASS,

REASONDESCRIPTION,
INITCAP(TRIM(REASONDESCRIPTION)) AS CLEAN_REASONDESCRIPTION

FROM RAW_SCHEMA.ENCOUNTERS
LIMIT 10;



/*==============================================================================
SECTION 4 : DATA QUALITY SUMMARY

Total Records : 53,346

Observations

• No duplicate Encounter IDs found.
• No missing values in key fields.
• REASONCODE and REASONDESCRIPTION contain 39,569 NULL values
  representing encounters without an associated diagnosis.
  These are valid business scenarios and require no cleaning.
• No blank string values detected.
• Encounter Class contains six valid categories.
• Financial metrics contain no negative values.
• No invalid date ranges identified.
• Payer Coverage values are valid and do not exceed Total Claim Cost.

Cleaning Required

✓ Convert START_TIME from VARCHAR to TIMESTAMP
✓ Convert STOP_TIME from VARCHAR to TIMESTAMP
✓ Standardize Encounter Description
✓ Standardize Reason Description
✓ Standardize Encounter Class

No Cleaning Required

✓ Encounter ID
✓ Patient ID
✓ Organization ID
✓ Provider ID
✓ Payer ID
✓ Encounter Code
✓ Base Encounter Cost
✓ Total Claim Cost
✓ Payer Coverage
✓ Reason Code

==============================================================================*/



/*==============================================================================
SECTION 5 : CREATE CLEAN TABLE
==============================================================================*/

CREATE OR REPLACE TABLE CLEAN_SCHEMA.ENCOUNTERS AS

SELECT

ID,

TRY_TO_TIMESTAMP_NTZ(START_TIME) AS START_TIME,

TRY_TO_TIMESTAMP_NTZ(STOP_TIME) AS STOP_TIME,

PATIENT,

ORGANIZATION,

PROVIDER,

PAYER,

LOWER(TRIM(ENCOUNTERCLASS)) AS ENCOUNTERCLASS,

CODE,

INITCAP(TRIM(DESCRIPTION)) AS DESCRIPTION,

BASE_ENCOUNTER_COST,

TOTAL_CLAIM_COST,

PAYER_COVERAGE,

REASONCODE,

INITCAP(TRIM(REASONDESCRIPTION)) AS REASONDESCRIPTION

FROM RAW_SCHEMA.ENCOUNTERS;



/*==============================================================================
SECTION 6 : VALIDATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Validate Record Count
-- -----------------------------------------------------------------------------

SELECT COUNT(*) AS RAW_RECORDS
FROM RAW_SCHEMA.ENCOUNTERS;

SELECT COUNT(*) AS CLEAN_RECORDS
FROM CLEAN_SCHEMA.ENCOUNTERS;


-- -----------------------------------------------------------------------------
-- Preview Clean Table
-- -----------------------------------------------------------------------------

SELECT *
FROM CLEAN_SCHEMA.ENCOUNTERS
LIMIT 10;

