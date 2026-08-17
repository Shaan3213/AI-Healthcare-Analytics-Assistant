/*==============================================================================
Project     : Healthcare Operations & Financial Performance Analytics Platform

Developer   : Mohd Shaan Saifi

Database    : HEALTHCARE_DB
Source Table: RAW_SCHEMA.PROVIDERS
Target Table: CLEAN_SCHEMA.PROVIDERS

Description :
This script performs data profiling, data quality assessment,
standardization, and cleaning of the Providers dataset.
The cleaned data is stored in CLEAN_SCHEMA for downstream
analytics in Databricks and visualization in Power BI.

==============================================================================*/


/*==============================================================================
SECTION 1 : DATA PROFILING
==============================================================================*/

-- Total number of records
SELECT COUNT(*) AS TOTAL_RECORDS
FROM RAW_SCHEMA.PROVIDERS;


-- Review table structure
DESCRIBE TABLE RAW_SCHEMA.PROVIDERS;


-- Preview first 10 records
SELECT *
FROM RAW_SCHEMA.PROVIDERS
LIMIT 10;


-- Check missing values

SELECT
COUNT_IF(ID IS NULL) AS ID_NULLS,
COUNT_IF(ORGANIZATION IS NULL) AS ORGANIZATION_NULL,
COUNT_IF(NAME IS NULL) AS NAME_NULL,
COUNT_IF(GENDER IS NULL) AS GENDER_NULL,
COUNT_IF(SPECIALITY IS NULL) AS SPECIALTY_NULL,
COUNT_IF(ADDRESS IS NULL) AS ADDRESS_NULL,
COUNT_IF(CITY IS NULL) AS CITY_NULL,
COUNT_IF(STATE IS NULL) AS STATE_NULL,
COUNT_IF(ZIP IS NULL) AS ZIP_NULL,
COUNT_IF(LAT IS NULL) AS LAT_NULL,
COUNT_IF(LON IS NULL) AS LON_NULL,
COUNT_IF(UTILIZATION IS NULL) AS UTILIZATION_NULL
FROM RAW_SCHEMA.PROVIDERS;



-- Check duplicate Provider IDs
SELECT
ID,
COUNT(*)
FROM RAW_SCHEMA.PROVIDERS
GROUP BY ID
HAVING COUNT(*)>1;


/*------------------------------------------------------------------------------
Check Blank Strings
------------------------------------------------------------------------------*/

SELECT
COUNT_IF(TRIM(NAME)='') AS BLANK_NAME,
COUNT_IF(TRIM(SPECIALITY)='') AS BLANK_SPECIALITY,
COUNT_IF(TRIM(ADDRESS)='') AS BLANK_ADDRESS,
COUNT_IF(TRIM(CITY)='') AS BLANK_CITY,
COUNT_IF(TRIM(STATE)='') AS BLANK_STATE
FROM RAW_SCHEMA.PROVIDERS;



--Gender Validation
SELECT DISTINCT GENDER
FROM RAW_SCHEMA.PROVIDERS;



/*------------------------------------------------------------------------------
Validate Provider Specialties
------------------------------------------------------------------------------*/

SELECT DISTINCT SPECIALITY
FROM RAW_SCHEMA.PROVIDERS
ORDER BY SPECIALITY;



/*------------------------------------------------------------------------------
Validate State Values
------------------------------------------------------------------------------*/

SELECT DISTINCT STATE
FROM RAW_SCHEMA.PROVIDERS;



/*------------------------------------------------------------------------------
Validate Provider Utilization
------------------------------------------------------------------------------*/

-- Check for negative utilization values

SELECT *
FROM RAW_SCHEMA.PROVIDERS
WHERE UTILIZATION < 0;



/*==============================================================================

Total Records           : 5855
Duplicate Records       : 0
Missing Values          : 0
Blank Strings           : 0

Cleaning Required

✓ Remove numeric suffixes from Provider Name
✓ Standardize text formatting

No Cleaning Required

✓ Provider ID
✓ Organization ID
✓ Gender
✓ Specialty Values
✓ Address Completeness
✓ State
✓ ZIP
✓ Latitude & Longitude
✓ Utilization

*==============================================================================/



/*==============================================================================
SECTION 5 : CREATE CLEAN TABLE
==============================================================================*/

CREATE OR REPLACE TABLE CLEAN_SCHEMA.PROVIDERS AS

SELECT

    ID,

    ORGANIZATION,

    INITCAP(
    TRIM(
        REGEXP_REPLACE(NAME, '[0-9]+', '')
    )
) AS NAME,

    UPPER(TRIM(GENDER)) AS GENDER,

    INITCAP(TRIM(SPECIALITY)) AS SPECIALITY,

    INITCAP(TRIM(ADDRESS)) AS ADDRESS,

    INITCAP(TRIM(CITY)) AS CITY,

    UPPER(TRIM(STATE)) AS STATE,

    ZIP,

    LAT,

    LON,

    UTILIZATION

FROM RAW_SCHEMA.PROVIDERS;


/*------------------------------------------------------------------------------
Validate Row Count
------------------------------------------------------------------------------*/

SELECT COUNT(*) AS RAW_RECORDS
FROM RAW_SCHEMA.PROVIDERS;

SELECT COUNT(*) AS CLEAN_RECORDS
FROM CLEAN_SCHEMA.PROVIDERS;


/*------------------------------------------------------------------------------
Preview Clean Table
------------------------------------------------------------------------------*/

SELECT *
FROM CLEAN_SCHEMA.PROVIDERS
LIMIT 10;


/*------------------------------------------------------------------------------
Verify Name Standardization
------------------------------------------------------------------------------*/

SELECT
    NAME
FROM CLEAN_SCHEMA.PROVIDERS
LIMIT 20;