/*==============================================================================
Project     : Healthcare Operations & Financial Performance Analytics Platform

Developer   : Mohd Shaan Saifi

Database    : HEALTHCARE_DB
Source Table: RAW_SCHEMA.ORGANIZATIONS
Target Table: CLEAN_SCHEMA.ORGANIZATIONS

Description :
This script performs data profiling, data quality assessment,
standardization, and cleaning of the Organizations dataset.
The cleaned dataset is stored in CLEAN_SCHEMA for downstream
analytics in Databricks and visualization in Power BI.

==============================================================================*/

/*==============================================================================
SECTION 1 : DATA PROFILING
==============================================================================*/

-- Total number of records
SELECT COUNT(*) AS TOTAL_RECORDS
FROM RAW_SCHEMA.ORGANIZATIONS;


-- Review table structure
DESC TABLE RAW_SCHEMA.ORGANIZATIONS;


-- Preview first 10 records
SELECT *
FROM RAW_SCHEMA.ORGANIZATIONS
LIMIT 10;


/*==============================================================================
SECTION 2 : DATA QUALITY ASSESSMENT
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Check Missing Values
-- -----------------------------------------------------------------------------

SELECT
COUNT_IF(ID IS NULL)           AS ID_NULLS,
COUNT_IF(NAME IS NULL)         AS NAME_NULLS,
COUNT_IF(ADDRESS IS NULL)      AS ADDRESS_NULLS,
COUNT_IF(CITY IS NULL)         AS CITY_NULLS,
COUNT_IF(STATE IS NULL)        AS STATE_NULLS,
COUNT_IF(ZIP IS NULL)          AS ZIP_NULLS,
COUNT_IF(LAT IS NULL)          AS LAT_NULLS,
COUNT_IF(LON IS NULL)          AS LON_NULLS,
COUNT_IF(PHONE IS NULL)        AS PHONE_NULLS,
COUNT_IF(REVENUE IS NULL)      AS REVENUE_NULLS,
COUNT_IF(UTILIZATION IS NULL)  AS UTILIZATION_NULLS
FROM RAW_SCHEMA.ORGANIZATIONS;


-- -----------------------------------------------------------------------------
-- Check Duplicate Organization IDs
-- -----------------------------------------------------------------------------

SELECT
ID,
COUNT(*) AS DUPLICATE_COUNT
FROM RAW_SCHEMA.ORGANIZATIONS
GROUP BY ID
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- Check Blank Strings
-- -----------------------------------------------------------------------------

SELECT
COUNT_IF(TRIM(NAME)='')      AS BLANK_NAME,
COUNT_IF(TRIM(ADDRESS)='')   AS BLANK_ADDRESS,
COUNT_IF(TRIM(CITY)='')      AS BLANK_CITY,
COUNT_IF(TRIM(STATE)='')     AS BLANK_STATE
FROM RAW_SCHEMA.ORGANIZATIONS;


-- -----------------------------------------------------------------------------
-- Validate State Values
-- -----------------------------------------------------------------------------

SELECT DISTINCT STATE
FROM RAW_SCHEMA.ORGANIZATIONS;


-- -----------------------------------------------------------------------------
-- Validate Revenue
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.ORGANIZATIONS
WHERE REVENUE < 0;


-- -----------------------------------------------------------------------------
-- Validate Utilization
-- -----------------------------------------------------------------------------

SELECT *
FROM RAW_SCHEMA.ORGANIZATIONS
WHERE UTILIZATION < 0;


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

STATE,
UPPER(TRIM(STATE)) AS CLEAN_STATE

FROM RAW_SCHEMA.ORGANIZATIONS
LIMIT 10;



/*==============================================================================
SECTION 4 : DATA QUALITY SUMMARY

Total Records          : 1119

Observations

• No duplicate Organization IDs found.
• No missing values identified.
• No blank string values detected.
• State values are standardized (MA).
• Revenue contains no negative values.
• Utilization contains no negative values.

Cleaning Required

✓ Standardize Organization Name
✓ Standardize Address
✓ Standardize City
✓ Standardize State

No Cleaning Required

✓ Organization ID
✓ ZIP
✓ Latitude
✓ Longitude
✓ Phone
✓ Revenue
✓ Utilization

==============================================================================*/



/*==============================================================================
SECTION 5 : CREATE CLEAN TABLE
==============================================================================*/

CREATE OR REPLACE TABLE CLEAN_SCHEMA.ORGANIZATIONS AS

SELECT

ID,

INITCAP(TRIM(NAME)) AS NAME,

INITCAP(TRIM(ADDRESS)) AS ADDRESS,

INITCAP(TRIM(CITY)) AS CITY,

UPPER(TRIM(STATE)) AS STATE,

ZIP,

LAT,

LON,

PHONE,

REVENUE,

UTILIZATION

FROM RAW_SCHEMA.ORGANIZATIONS;



/*==============================================================================
SECTION 6 : VALIDATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Validate Record Count
-- -----------------------------------------------------------------------------

SELECT COUNT(*) AS RAW_RECORDS
FROM RAW_SCHEMA.ORGANIZATIONS;

SELECT COUNT(*) AS CLEAN_RECORDS
FROM CLEAN_SCHEMA.ORGANIZATIONS;


-- -----------------------------------------------------------------------------
-- Preview Clean Table
-- -----------------------------------------------------------------------------

SELECT *
FROM CLEAN_SCHEMA.ORGANIZATIONS
LIMIT 10;