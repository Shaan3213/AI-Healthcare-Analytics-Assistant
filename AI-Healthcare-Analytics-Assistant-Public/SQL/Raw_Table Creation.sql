/*==============================================================================
 Project  : Healthcare Operations & Financial Performance Analytics Platform
 File     : 02_Create_Raw_Tables.sql
 Purpose  : Create Raw Tables
==============================================================================*/

USE DATABASE HEALTHCARE_DB;
USE SCHEMA RAW_SCHEMA;

-- ============================================================================
-- PATIENTS
-- ============================================================================

CREATE OR REPLACE TABLE PATIENTS
(
    ID                     VARCHAR(50),
    BIRTHDATE              VARCHAR,
    DEATHDATE              VARCHAR,

    SSN                    VARCHAR(20),
    DRIVERS                VARCHAR(30),
    PASSPORT               VARCHAR(30),

    PREFIX                 VARCHAR(10),
    FIRST                  VARCHAR(100),
    LAST                   VARCHAR(100),
    SUFFIX                 VARCHAR(20),
    MAIDEN                 VARCHAR(100),

    MARITAL                VARCHAR(20),
    RACE                   VARCHAR(50),
    ETHNICITY              VARCHAR(100),
    GENDER                 VARCHAR(10),

    BIRTHPLACE             VARCHAR(255),

    ADDRESS                VARCHAR(255),
    CITY                   VARCHAR(100),
    STATE                  VARCHAR(50),
    COUNTY                 VARCHAR(100),
    ZIP                    VARCHAR(15),

    LAT                    FLOAT,
    LON                    FLOAT,

    HEALTHCARE_EXPENSES    NUMBER(12,2),
    HEALTHCARE_COVERAGE    NUMBER(12,2)
);

-- ============================================================================
-- PROVIDERS
-- ============================================================================

CREATE OR REPLACE TABLE PROVIDERS
(
    ID                VARCHAR(50),

    ORGANIZATION      VARCHAR(50),

    NAME              VARCHAR(255),

    GENDER            VARCHAR(20),

    SPECIALITY        VARCHAR(255),

    ADDRESS           VARCHAR(255),
    CITY              VARCHAR(100),
    STATE             VARCHAR(50),
    ZIP               VARCHAR(15),

    LAT               FLOAT,
    LON               FLOAT,

    UTILIZATION       NUMBER
);

/*==============================================================================
    ORGANIZATIONS
==============================================================================*/

CREATE OR REPLACE TABLE ORGANIZATIONS
(
    ID                  VARCHAR(50),

    NAME                VARCHAR(255),

    ADDRESS             VARCHAR(255),
    CITY                VARCHAR(100),
    STATE               VARCHAR(50),
    ZIP                 VARCHAR(15),

    LAT                 FLOAT,
    LON                 FLOAT,

    PHONE               VARCHAR(30),

    REVENUE             NUMBER(15,2),

    UTILIZATION         NUMBER
);



/*==============================================================================
    PAYERS
==============================================================================*/

CREATE OR REPLACE TABLE PAYERS
(
    ID                              VARCHAR(50),

    NAME                            VARCHAR(255),

    ADDRESS                         VARCHAR(255),
    CITY                            VARCHAR(100),
    STATE_HEADQUARTER               VARCHAR(100),
    ZIP                             VARCHAR(15),

    PHONE                           VARCHAR(30),

    AMOUNT_COVERED                  NUMBER(15,2),
    AMOUNT_UNCOVERED                NUMBER(15,2),

    REVENUE                         NUMBER(15,2),

    COVERED_ENCOUNTERS              NUMBER,
    UNCOVERED_ENCOUNTERS            NUMBER,

    COVERED_MEDICATIONS             NUMBER,
    UNCOVERED_MEDICATIONS           NUMBER,

    COVERED_PROCEDURES              NUMBER,
    UNCOVERED_PROCEDURES            NUMBER,

    COVERED_IMMUNIZATIONS           NUMBER,
    UNCOVERED_IMMUNIZATIONS         NUMBER,

    UNIQUE_CUSTOMERS                NUMBER,

    QOLS_AVG                        FLOAT,

    MEMBER_MONTHS                   NUMBER
);

/*==============================================================================
    ENCOUNTERS
==============================================================================*/

CREATE OR REPLACE TABLE RAW_SCHEMA.ENCOUNTERS
(
    ID                      VARCHAR(50),
    START_TIME              VARCHAR,
    STOP_TIME               VARCHAR,

    PATIENT                 VARCHAR(50),
    ORGANIZATION            VARCHAR(50),
    PROVIDER                VARCHAR(50),
    PAYER                   VARCHAR(50),

    ENCOUNTERCLASS          VARCHAR(100),
    CODE                    VARCHAR(30),
    DESCRIPTION             VARCHAR(255),

    BASE_ENCOUNTER_COST     NUMBER(15,2),
    TOTAL_CLAIM_COST        NUMBER(15,2),
    PAYER_COVERAGE          NUMBER(15,2),

    REASONCODE              VARCHAR(30),
    REASONDESCRIPTION       VARCHAR(255)
);



/*==============================================================================
    PROCEDURES
==============================================================================*/

CREATE TABLE RAW_SCHEMA.PROCEDURES
(
    DATE                DATE,
    PATIENT             VARCHAR(50),
    ENCOUNTER           VARCHAR(50),
    CODE                VARCHAR(30),
    DESCRIPTION         VARCHAR(255),
    BASE_COST           NUMBER(15,2),
    REASONCODE          VARCHAR(30),
    REASONDESCRIPTION   VARCHAR(255)
);


/*==============================================================================
    CONDITIONS
==============================================================================*/

CREATE OR REPLACE TABLE RAW_SCHEMA.CONDITIONS
(
    START_TIME              VARCHAR,
    STOP_TIME               VARCHAR,

    PATIENT                 VARCHAR(50),

    ENCOUNTER               VARCHAR(50),

    CODE                    VARCHAR(30),

    DESCRIPTION             VARCHAR(255)
);


SELECT 'PATIENTS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM RAW_SCHEMA.PATIENTS
UNION ALL
SELECT 'PROVIDERS', COUNT(*) FROM RAW_SCHEMA.PROVIDERS
UNION ALL
SELECT 'ORGANIZATIONS', COUNT(*) FROM RAW_SCHEMA.ORGANIZATIONS
UNION ALL
SELECT 'PAYERS', COUNT(*) FROM RAW_SCHEMA.PAYERS
UNION ALL
SELECT 'ENCOUNTERS', COUNT(*) FROM RAW_SCHEMA.ENCOUNTERS
UNION ALL
SELECT 'PROCEDURES', COUNT(*) FROM RAW_SCHEMA.PROCEDURES
UNION ALL
SELECT 'CONDITIONS', COUNT(*) FROM RAW_SCHEMA.CONDITIONS;