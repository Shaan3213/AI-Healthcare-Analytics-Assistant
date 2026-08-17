/*==============================================================================
Project     : Healthcare Operations & Financial Performance Analytics Platform

Developer   : Mohd Shaan Saifi

Database    : HEALTHCARE_DB
Source Table: RAW_SCHEMA.PAYERS
Target Table: CLEAN_SCHEMA.PAYERS

Description :
This script performs data profiling, data quality assessment,
standardization, and cleaning of the Payers dataset.
The cleaned dataset is stored in CLEAN_SCHEMA for downstream
analytics in Databricks and visualization in Power BI.

==============================================================================*/


--Record Count
SELECT COUNT(*) AS TOTAL_RECORDS
FROM RAW_SCHEMA.PAYERS;

-- Table Structure
DESC TABLE RAW_SCHEMA.PAYERS;

-- SampleData
SELECT *
FROM RAW_SCHEMA.PAYERS
LIMIT 10;


/*------------------------------------------------------------------------------
Check Missing Values
------------------------------------------------------------------------------*/

SELECT
COUNT_IF(ID IS NULL) AS ID_NULLS,
COUNT_IF(NAME IS NULL) AS NAME_NULLS,
COUNT_IF(ADDRESS IS NULL) AS ADDRESS_NULLS,
COUNT_IF(CITY IS NULL) AS CITY_NULLS,
COUNT_IF(STATE_HEADQUARTER IS NULL) AS STATE_NULLS,
COUNT_IF(ZIP IS NULL) AS ZIP_NULLS,
COUNT_IF(PHONE IS NULL) AS PHONE_NULLS
FROM RAW_SCHEMA.PAYERS;


/*------------------------------------------------------------------------------
Duplicate IDs
------------------------------------------------------------------------------*/

SELECT
ID,
COUNT(*)
FROM RAW_SCHEMA.PAYERS
GROUP BY ID
HAVING COUNT(*)>1;



/*------------------------------------------------------------------------------
Blank Strings
------------------------------------------------------------------------------*/

SELECT
COUNT_IF(TRIM(NAME)='') AS BLANK_NAME,
COUNT_IF(TRIM(ADDRESS)='') AS BLANK_ADDRESS,
COUNT_IF(TRIM(CITY)='') AS BLANK_CITY
FROM RAW_SCHEMA.PAYERS;


/*------------------------------------------------------------------------------
State Values
------------------------------------------------------------------------------*/

SELECT DISTINCT STATE_HEADQUARTER
FROM RAW_SCHEMA.PAYERS;



/*------------------------------------------------------------------------------
Negative Financial Values
------------------------------------------------------------------------------*/

SELECT *
FROM RAW_SCHEMA.PAYERS
WHERE AMOUNT_COVERED < 0
   OR AMOUNT_UNCOVERED < 0
   OR REVENUE < 0;



   /*==============================================================================
SECTION 3 : TRANSFORMATION TESTING
==============================================================================*/

SELECT

NAME,
INITCAP(TRIM(NAME)) AS CLEAN_NAME,

ADDRESS,
INITCAP(TRIM(ADDRESS)) AS CLEAN_ADDRESS,

CITY,
INITCAP(TRIM(CITY)) AS CLEAN_CITY,

STATE_HEADQUARTER,
UPPER(TRIM(STATE_HEADQUARTER)) AS CLEAN_STATE

FROM RAW_SCHEMA.PAYERS
LIMIT 10;



/*==============================================================================
SECTION 4 : DATA QUALITY SUMMARY

Total Records : 10

Observations

• No duplicate Payer IDs found.
• No missing values identified.
• No blank string values detected.
• State Headquarters values are valid.
• Financial metrics contain no negative values.

Cleaning Required

✓ Standardize Payer Name
✓ Standardize Address
✓ Standardize City
✓ Standardize State Headquarters

No Cleaning Required

✓ Payer ID
✓ ZIP
✓ Phone
✓ Amount Covered
✓ Amount Uncovered
✓ Revenue
✓ Covered Encounters
✓ Uncovered Encounters
✓ Covered Medications
✓ Uncovered Medications
✓ Covered Procedures
✓ Uncovered Procedures
✓ Covered Immunizations
✓ Uncovered Immunizations
✓ Covered Unique Customers
✓ Uncovered Unique Customers

==============================================================================*/



/*==============================================================================
SECTION 5 : CREATE CLEAN TABLE
==============================================================================*/

CREATE OR REPLACE TABLE CLEAN_SCHEMA.PAYERS AS

SELECT

ID,

INITCAP(TRIM(NAME)) AS NAME,

INITCAP(TRIM(ADDRESS)) AS ADDRESS,

INITCAP(TRIM(CITY)) AS CITY,

UPPER(TRIM(STATE_HEADQUARTER)) AS STATE_HEADQUARTER,

ZIP,

PHONE,

AMOUNT_COVERED,

AMOUNT_UNCOVERED,

REVENUE,

COVERED_ENCOUNTERS,

UNCOVERED_ENCOUNTERS,

COVERED_MEDICATIONS,

UNCOVERED_MEDICATIONS,

COVERED_PROCEDURES,

UNCOVERED_PROCEDURES,

COVERED_IMMUNIZATIONS,

UNCOVERED_IMMUNIZATIONS,

UNIQUE_CUSTOMERS,

QOLS_AVG,

MEMBER_MONTHS

FROM RAW_SCHEMA.PAYERS;



/*==============================================================================
SECTION 6 : VALIDATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Validate Record Count
-- -----------------------------------------------------------------------------

SELECT COUNT(*) AS RAW_RECORDS
FROM RAW_SCHEMA.PAYERS;

SELECT COUNT(*) AS CLEAN_RECORDS
FROM CLEAN_SCHEMA.PAYERS;


-- -----------------------------------------------------------------------------
-- Preview Clean Table
-- -----------------------------------------------------------------------------

SELECT *
FROM CLEAN_SCHEMA.PAYERS
LIMIT 10;