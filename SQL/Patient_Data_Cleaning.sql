/*==============================================================================
 Project      : Healthcare Operations & Financial Performance Analytics Platform
 File         : 04_Patients_Data_Cleaning.sql
 Author       : Mohd Shaan Saifi

 Source Table : RAW_SCHEMA.PATIENTS
 Target Table : CLEAN_SCHEMA.PATIENTS

 Purpose:
    Clean and standardize patient master data for downstream
    Python EDA and Power BI reporting.

 Business Rules:
    - Preserve all valid patient records
    - Convert data types
    - Standardize text fields
    - Handle NULL values
    - Remove invalid formatting
==============================================================================*/

USE DATABASE HEALTHCARE_DB;
USE SCHEMA RAW_SCHEMA;

/*==============================================================================
DATA PROFILING
==============================================================================*/

-- Total Records
SELECT COUNT(*) AS TOTAL_RECORDS
FROM RAW_SCHEMA.PATIENTS;


-- Table Structure
DESCRIBE TABLE RAW_SCHEMA.PATIENTS;


-- Preview Data
SELECT *
FROM RAW_SCHEMA.PATIENTS
LIMIT 10;



-- 4.1 Missing Values
SELECT
    COUNT_IF(ID IS NULL)                    AS NULL_ID,
    COUNT_IF(BIRTHDATE IS NULL)             AS NULL_BIRTHDATE,
    COUNT_IF(DEATHDATE IS NULL)             AS NULL_DEATHDATE,
    COUNT_IF(FIRST IS NULL)                 AS NULL_FIRST_NAME,
    COUNT_IF(LAST IS NULL)                  AS NULL_LAST_NAME,
    COUNT_IF(GENDER IS NULL)                AS NULL_GENDER,
    COUNT_IF(ADDRESS IS NULL)               AS NULL_ADDRESS,
    COUNT_IF(CITY IS NULL)                  AS NULL_CITY,
    COUNT_IF(STATE IS NULL)                 AS NULL_STATE
FROM RAW_SCHEMA.PATIENTS;


-- 4.2 Duplicate Check
SELECT
    ID,
    COUNT(*) AS RECORD_COUNT
FROM RAW_SCHEMA.PATIENTS
GROUP BY ID
HAVING COUNT(*) > 1;

--4.3 Blank Strings
SELECT
COUNT_IF(TRIM(FIRST)='') AS BLANK_FIRST_NAME,
COUNT_IF(TRIM(LAST)='')  AS BLANK_LAST_NAME,
COUNT_IF(TRIM(CITY)='')  AS BLANK_CITY,
COUNT_IF(TRIM(STATE)='') AS BLANK_STATE
FROM RAW_SCHEMA.PATIENTS;


--4.4 Gender Validation
SELECT DISTINCT GENDER
FROM RAW_SCHEMA.PATIENTS;


--4.5 Standardizing Names
Select
REGEXP_REPLACE(INITCAP(TRIM(FIRST)), '[0-9]+$', '') AS FIRST,
REGEXP_REPLACE(INITCAP(TRIM(LAST)), '[0-9]+$', '') AS LAST,
REGEXP_REPLACE(INITCAP(TRIM(MAIDEN)), '[0-9]+$', '') AS MAIDEN
from raw_schema.patients;


--4.5 Birthdate range
SELECT
    MIN(TRY_TO_DATE(BIRTHDATE,'DD-MM-YYYY')) AS EARLIEST_BIRTHDATE,
    MAX(TRY_TO_DATE(BIRTHDATE,'DD-MM-YYYY')) AS LATEST_BIRTHDATE
FROM RAW_SCHEMA.PATIENTS;


-- 4.6 Validating negative expense amount
SELECT
COUNT_IF(HEALTHCARE_EXPENSES < 0) AS NEGATIVE_EXPENSES,
COUNT_IF(HEALTHCARE_EXPENSES IS NULL) AS NULL_EXPENSES
FROM RAW_SCHEMA.PATIENTS;


-- 4.7 Validating negative coverage amount
SELECT
COUNT_IF(HEALTHCARE_COVERAGE < 0) AS NEGATIVE_COVERAGE,
COUNT_IF(HEALTHCARE_COVERAGE IS NULL) AS NULL_COVERAGE
FROM RAW_SCHEMA.PATIENTS;


-- 4.8 Marital Status Validation
SELECT DISTINCT MARITAL
FROM RAW_SCHEMA.PATIENTS;


-- 4.8 Prefix Validation
SELECT DISTINCT PREFIX
FROM RAW_SCHEMA.PATIENTS;


-- 4.9 Race Validation
SELECT DISTINCT RACE
FROM RAW_SCHEMA.PATIENTS;


-- 4.9 Ethnicity Validation
SELECT DISTINCT ETHNICITY
FROM RAW_SCHEMA.PATIENTS;


-- 4.10 State Validation
SELECT DISTINCT STATE
FROM RAW_SCHEMA.PATIENTS;



/*==============================================================================
DATA QUALITY SUMMARY

Total Records              : 1171
Duplicate IDs              : 0
Missing Birth Dates        : 0
Missing Death Dates        : 1000 (Expected - Living Patients)
Blank First Names          : 0
Blank Last Names           : 0
Invalid Gender Values      : 0
Negative Expenses          : 0
Negative Coverage          : 0

Cleaning Required

✓ Convert Birthdate to DATE
✓ Convert Deathdate to DATE
✓ Remove numeric suffixes from names
✓ Standardize text formatting

No Cleaning Required

✓ Gender
✓ Marital Status
✓ Prefix
✓ Race
✓ Ethnicity
✓ State
✓ Healthcare Expenses
✓ Healthcare Coverage

==============================================================================*/

-- Creating the cleaned Patient Table

CREATE OR REPLACE TABLE CLEAN_SCHEMA.PATIENTS AS

SELECT
    ID,

    TRY_TO_DATE(BIRTHDATE, 'DD-MM-YYYY') AS BIRTHDATE,

    TRY_TO_DATE(DEATHDATE, 'DD-MM-YYYY') AS DEATHDATE,

    REGEXP_REPLACE(INITCAP(TRIM(FIRST)), '[0-9]+$', '') AS FIRST,

    REGEXP_REPLACE(INITCAP(TRIM(LAST)), '[0-9]+$', '') AS LAST,

    REGEXP_REPLACE(INITCAP(TRIM(MAIDEN)), '[0-9]+$', '') AS MAIDEN,

    UPPER(TRIM(MARITAL)) AS MARITAL,

    UPPER(TRIM(GENDER)) AS GENDER,

    INITCAP(TRIM(RACE)) AS RACE,

    INITCAP(TRIM(ETHNICITY)) AS ETHNICITY,

    INITCAP(TRIM(ADDRESS)) AS ADDRESS,

    INITCAP(TRIM(CITY)) AS CITY,

    INITCAP(TRIM(COUNTY)) AS COUNTY,

    UPPER(TRIM(STATE)) AS STATE,

    PREFIX,

    SUFFIX,

    BIRTHPLACE,

    ZIP,

    LAT,

    LON,

    HEALTHCARE_EXPENSES,

    HEALTHCARE_COVERAGE,

    SSN,

    DRIVERS,

    PASSPORT

FROM RAW_SCHEMA.PATIENTS;


Select * from clean_schema.patients;





