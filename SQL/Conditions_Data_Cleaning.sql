/*==============================================================================
Project     : Healthcare Operations & Financial Performance Analytics Platform

Developer   : Mohd Shaan Saifi

Database    : HEALTHCARE_DB
Source Table: RAW_SCHEMA.CONDITIONS
Target Table: CLEAN_SCHEMA.CONDITIONS

Description :
This script performs data profiling, data quality assessment,
standardization, and cleaning of the Conditions dataset.
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
FROM RAW_SCHEMA.CONDITIONS;


-- -----------------------------------------------------------------------------
-- Review table structure
-- -----------------------------------------------------------------------------

DESC TABLE RAW_SCHEMA.CONDITIONS;



-- -----------------------------------------------------------------------------
-- Preview first 10 records
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.CONDITIONS
LIMIT 10;


/*------------------------------------------------------------------------------
Check Missing Values
------------------------------------------------------------------------------*/

SELECT
COUNT_IF(START_TIME IS NULL) AS START_NULLS,
COUNT_IF(STOP_TIME IS NULL) AS STOP_NULLS,
COUNT_IF(PATIENT IS NULL) AS PATIENT_NULLS,
COUNT_IF(ENCOUNTER IS NULL) AS ENCOUNTER_NULLS,
COUNT_IF(CODE IS NULL) AS CODE_NULLS,
COUNT_IF(DESCRIPTION IS NULL) AS DESCRIPTION_NULLS
FROM RAW_SCHEMA.CONDITIONS;



/*------------------------------------------------------------------------------
Duplicate Records
------------------------------------------------------------------------------*/

SELECT
START_TIME,
PATIENT,
ENCOUNTER,
CODE,
COUNT(*)
FROM RAW_SCHEMA.CONDITIONS
GROUP BY
START_TIME,
PATIENT,
ENCOUNTER,
CODE
HAVING COUNT(*) > 1;


/*------------------------------------------------------------------------------
Blank Descriptions
------------------------------------------------------------------------------*/

SELECT
COUNT_IF(TRIM(DESCRIPTION)='') AS BLANK_DESCRIPTION
FROM RAW_SCHEMA.CONDITIONS;



/*------------------------------------------------------------------------------
Invalid Date Range
------------------------------------------------------------------------------*/

SELECT *
FROM RAW_SCHEMA.CONDITIONS
WHERE TRY_TO_DATE(STOP_TIME) < TRY_TO_DATE(START_TIME);



/*==============================================================================
SECTION 3 : TRANSFORMATION TESTING
==============================================================================*/

SELECT

START_TIME,
TRY_TO_DATE(START_TIME) AS CLEAN_START_TIME,

STOP_TIME,
TRY_TO_DATE(STOP_TIME) AS CLEAN_STOP_TIME,

DESCRIPTION,
INITCAP(TRIM(DESCRIPTION)) AS CLEAN_DESCRIPTION

FROM RAW_SCHEMA.CONDITIONS
LIMIT 10;



/*==============================================================================
SECTION 4 : DATA QUALITY SUMMARY

Total Records : 8,376

Observations

• No duplicate condition records found.
• No missing values in key fields.
• STOP_TIME contains 3,811 NULL values representing active or
  ongoing medical conditions. These are valid business scenarios
  and require no cleaning.
• No blank descriptions detected.
• No invalid date ranges identified.

Cleaning Required

✓ Convert START_TIME from VARCHAR to DATE
✓ Convert STOP_TIME from VARCHAR to DATE
✓ Standardize Condition Description

No Cleaning Required

✓ Patient ID
✓ Encounter ID
✓ Condition Code

==============================================================================*/


/*==============================================================================
SECTION 5 : CREATE CLEAN TABLE
==============================================================================*/

CREATE OR REPLACE TABLE CLEAN_SCHEMA.CONDITIONS AS

SELECT

TRY_TO_DATE(START_TIME) AS START_TIME,

TRY_TO_DATE(STOP_TIME) AS STOP_TIME,

PATIENT,

ENCOUNTER,

CODE,

INITCAP(TRIM(DESCRIPTION)) AS DESCRIPTION

FROM RAW_SCHEMA.CONDITIONS;



/*==============================================================================
SECTION 6 : VALIDATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Validate Record Count
-- -----------------------------------------------------------------------------

SELECT COUNT(*) AS RAW_RECORDS
FROM RAW_SCHEMA.CONDITIONS;

SELECT COUNT(*) AS CLEAN_RECORDS
FROM CLEAN_SCHEMA.CONDITIONS;


-- -----------------------------------------------------------------------------
-- Preview Clean Table
-- -----------------------------------------------------------------------------

SELECT *
FROM CLEAN_SCHEMA.CONDITIONS
LIMIT 10;