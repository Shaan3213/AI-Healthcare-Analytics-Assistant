/*==============================================================================
 Project  : Healthcare Operations & Financial Performance Analytics Platform
 File     : 03_Load_Raw_Data.sql

 Purpose  :
    Load raw CSV files from the internal Snowflake stage into the
    RAW_SCHEMA tables.

 Source:
    Internal Stage (HEALTHCARE_STAGE)

 Notes:
    - CSV files are loaded without transformations.
    - Data is stored in the RAW layer exactly as received.
    - Data cleaning and standardization will be performed in CLEAN_SCHEMA.
==============================================================================*/


/*==============================================================================
 Load PATIENTS table from internal stage
==============================================================================*/

COPY INTO RAW_SCHEMA.PATIENTS
FROM @HEALTHCARE_STAGE/patients.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';

/*==============================================================================
 Validate data loading
==============================================================================*/

SELECT 'PATIENTS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM RAW_SCHEMA.PATIENTS;


/*==============================================================================
 Load PROVIDERS table from internal stage
==============================================================================*/

COPY INTO RAW_SCHEMA.PROVIDERS
FROM @HEALTHCARE_STAGE/providers.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';

/*==============================================================================
 Validate data loading
==============================================================================*/

SELECT 'PROVIDERS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM RAW_SCHEMA.PROVIDERS;



/*==============================================================================
 Load ORGANIZATIONS table from internal stage
==============================================================================*/

COPY INTO RAW_SCHEMA.ORGANIZATIONS
FROM @HEALTHCARE_STAGE/organizations.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';

/*==============================================================================
 Validate data loading
==============================================================================*/

SELECT 'ORGANIZATIONS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM RAW_SCHEMA.ORGANIZATIONS;



/*==============================================================================
 Load PAYERS table from internal stage
==============================================================================*/

COPY INTO RAW_SCHEMA.PAYERS
FROM @HEALTHCARE_STAGE/payers.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';

/*==============================================================================
 Validate data loading
==============================================================================*/

SELECT 'PAYERS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM RAW_SCHEMA.PAYERS;



/*==============================================================================
 Load ENCOUNTERS table from internal stage
==============================================================================*/

COPY INTO RAW_SCHEMA.ENCOUNTERS
FROM @HEALTHCARE_STAGE/encounters.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';

/*==============================================================================
 Validate data loading
==============================================================================*/

SELECT 'ENCOUNTERS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM RAW_SCHEMA.ENCOUNTERS;



/*==============================================================================
 Load PROCEDURES table from internal stage
==============================================================================*/

COPY INTO RAW_SCHEMA.PROCEDURES
FROM @HEALTHCARE_STAGE/procedures.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';

/*==============================================================================
 Validate data loading
==============================================================================*/

SELECT 'PROCEDURES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM RAW_SCHEMA.PROCEDURES;



/*==============================================================================
 Load CONDITIONS table from internal stage
==============================================================================*/

COPY INTO RAW_SCHEMA.CONDITIONS
FROM @HEALTHCARE_STAGE/conditions.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';

/*==============================================================================
 Validate data loading
==============================================================================*/

SELECT 'PATIENTS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM RAW_SCHEMA.CONDITIONS;



