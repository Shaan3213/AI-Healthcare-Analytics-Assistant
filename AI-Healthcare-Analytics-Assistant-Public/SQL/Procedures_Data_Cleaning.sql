/*==============================================================================
Project     : Healthcare Operations & Financial Performance Analytics Platform

Developer   : Mohd Shaan Saifi

Database    : HEALTHCARE_DB
Source Table: RAW_SCHEMA.PROCEDURES
Target Table: CLEAN_SCHEMA.PROCEDURES

Description :
This script performs data profiling, data quality assessment,
standardization, and cleaning of the Procedures dataset.
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
FROM RAW_SCHEMA.PROCEDURES;


-- -----------------------------------------------------------------------------
-- Review table structure
-- -----------------------------------------------------------------------------

DESC TABLE RAW_SCHEMA.PROCEDURES;


-- -----------------------------------------------------------------------------
-- Preview first 10 records
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.PROCEDURES
LIMIT 10;


/*------------------------------------------------------------------------------
Check Missing Values
------------------------------------------------------------------------------*/

SELECT
COUNT_IF(DATE IS NULL) AS DATE_NULLS,
COUNT_IF(PATIENT IS NULL) AS PATIENT_NULLS,
COUNT_IF(ENCOUNTER IS NULL) AS ENCOUNTER_NULLS,
COUNT_IF(CODE IS NULL) AS CODE_NULLS,
COUNT_IF(DESCRIPTION IS NULL) AS DESCRIPTION_NULLS,
COUNT_IF(BASE_COST IS NULL) AS BASE_COST_NULLS,
COUNT_IF(REASONCODE IS NULL) AS REASONCODE_NULLS,
COUNT_IF(REASONDESCRIPTION IS NULL) AS REASONDESCRIPTION_NULLS
FROM RAW_SCHEMA.PROCEDURES;


/*------------------------------------------------------------------------------
Duplicate Records
------------------------------------------------------------------------------*/

SELECT
DATE,
PATIENT,
ENCOUNTER,
CODE,
COUNT(*)
FROM RAW_SCHEMA.PROCEDURES
GROUP BY
DATE,
PATIENT,
ENCOUNTER,
CODE
HAVING COUNT(*)>1;


/*------------------------------------------------------------------------------
Blank Strings
------------------------------------------------------------------------------*/

SELECT
COUNT_IF(TRIM(DESCRIPTION)='') AS BLANK_DESCRIPTION
FROM RAW_SCHEMA.PROCEDURES;


/*------------------------------------------------------------------------------
Negative Base Cost
------------------------------------------------------------------------------*/

SELECT *
FROM RAW_SCHEMA.PROCEDURES
WHERE BASE_COST < 0;



/*==============================================================================
SECTION 3 : TRANSFORMATION TESTING
==============================================================================*/

SELECT

DESCRIPTION,
INITCAP(TRIM(DESCRIPTION)) AS CLEAN_DESCRIPTION,

REASONDESCRIPTION,
INITCAP(TRIM(REASONDESCRIPTION)) AS CLEAN_REASONDESCRIPTION

FROM RAW_SCHEMA.PROCEDURES
LIMIT 10;


/*==============================================================================
SECTION 4 : DATA QUALITY SUMMARY

Total Records : 34,981

Observations

• No duplicate procedure records found.
• No missing values in key fields.
• REASONCODE and REASONDESCRIPTION contain NULL values
  representing procedures without an associated diagnosis.
  These are valid business scenarios and require no cleaning.
• No blank descriptions detected.
• Base Cost contains no negative values.

Cleaning Required

✓ Standardize Procedure Description
✓ Standardize Reason Description

No Cleaning Required

✓ Date
✓ Patient ID
✓ Encounter ID
✓ Procedure Code
✓ Base Cost
✓ Reason Code

==============================================================================*/


/*==============================================================================
SECTION 5 : CREATE CLEAN TABLE
==============================================================================*/

CREATE OR REPLACE TABLE CLEAN_SCHEMA.PROCEDURES AS

SELECT

DATE,

PATIENT,

ENCOUNTER,

CODE,

INITCAP(TRIM(DESCRIPTION)) AS DESCRIPTION,

BASE_COST,

REASONCODE,

INITCAP(TRIM(REASONDESCRIPTION)) AS REASONDESCRIPTION

FROM RAW_SCHEMA.PROCEDURES;


/*==============================================================================
SECTION 6 : VALIDATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Validate Record Count
-- -----------------------------------------------------------------------------

SELECT COUNT(*) AS RAW_RECORDS
FROM RAW_SCHEMA.PROCEDURES;

SELECT COUNT(*) AS CLEAN_RECORDS
FROM CLEAN_SCHEMA.PROCEDURES;



-- -----------------------------------------------------------------------------
-- Preview Clean Table
-- -----------------------------------------------------------------------------

SELECT *
FROM CLEAN_SCHEMA.PROCEDURES
LIMIT 10;