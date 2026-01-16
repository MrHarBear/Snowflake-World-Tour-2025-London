-- ============================================
-- Snowflake World Tour 2025 London
-- Call Center Intelligence Demo
-- Step 1: Database and Schema Setup
-- ============================================

-- ============================================
-- CONFIGURATION - Update these for your environment
-- ============================================
SET WAREHOUSE_NAME = 'WH_AISQL_HOL';  -- Change to your warehouse
SET DATABASE_NAME = 'CALL_CENTER_ANALYTICS';
SET SCHEMA_NAME = 'AUDIO_PROCESSING';

-- Set context
USE ROLE ACCOUNTADMIN;  -- Or your appropriate role with CREATE DATABASE privileges
USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

-- ============================================
-- 1. USE EXISTING DATABASE
-- ============================================

-- Your existing database: CALL_CENTER_ANALYTICS
USE DATABASE CALL_CENTER_ANALYTICS;

-- ============================================
-- 2. USE EXISTING SCHEMA
-- ============================================

-- Your existing schema: AUDIO_PROCESSING
USE SCHEMA AUDIO_PROCESSING;

-- ============================================
-- 3. CREATE WAREHOUSE (if needed)
-- ============================================

-- Uncomment if you need to create a dedicated warehouse
-- CREATE WAREHOUSE IF NOT EXISTS CALL_CENTER_WH
--   WAREHOUSE_SIZE = 'XSMALL'
--   AUTO_SUSPEND = 60
--   AUTO_RESUME = TRUE
--   INITIALLY_SUSPENDED = TRUE
--   COMMENT = 'Dedicated warehouse for call center intelligence operations';

-- For demo purposes, XSMALL is sufficient
-- Cortex Search recommendation: Use SMALL or MEDIUM for production

-- ============================================
-- 4. CREATE FILE FORMAT
-- ============================================

CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ESCAPE_UNENCLOSED_FIELD = 'NONE'
  TRIM_SPACE = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  NULL_IF = ('NULL', 'null', '')
  COMMENT = 'CSV file format for loading call center data';

-- ============================================
-- 5. CREATE INTERNAL STAGE
-- ============================================

CREATE OR REPLACE STAGE call_center_stage
  FILE_FORMAT = csv_format
  COMMENT = 'Internal stage for uploading CSV files';

-- ============================================
-- 6. VERIFY SETUP
-- ============================================

-- Show existing objects
SHOW DATABASES LIKE 'CALL_CENTER_ANALYTICS';
SHOW SCHEMAS IN DATABASE CALL_CENTER_ANALYTICS;
SHOW FILE FORMATS IN SCHEMA AUDIO_PROCESSING;
SHOW STAGES IN SCHEMA AUDIO_PROCESSING;

-- Display current context
SELECT 
  CURRENT_ROLE() as current_role,
  CURRENT_DATABASE() as current_database,
  CURRENT_SCHEMA() as current_schema,
  CURRENT_WAREHOUSE() as current_warehouse;

-- ============================================
-- NEXT STEPS
-- ============================================

-- 1. Upload CSV files to the stage:
--    PUT file:///path/to/FINAL_TABLE_COMPLETE.csv @call_center_stage;
--    PUT file:///path/to/CUSTOMER_PROFILE_COMPLETE.csv @call_center_stage;
--
-- 2. Or use Snowsight UI to upload files to the stage
--
-- 3. Then run: 01_create_tables.sql

SELECT '✓ Database setup complete!' as status;

