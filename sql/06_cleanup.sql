-- ============================================
-- Snowflake World Tour 2025 London
-- Cleanup Script: Remove All Demo Assets
-- ============================================
-- WARNING: This script will DELETE all objects created by this demo!
-- Only run this when you want to completely remove the demo setup.
-- ============================================

-- ============================================
-- CONFIGURATION - Update these for your environment
-- ============================================
SET WAREHOUSE_NAME = 'WH_AISQL_HOL';  -- Change to your warehouse

USE DATABASE CALL_CENTER_ANALYTICS;
USE SCHEMA AUDIO_PROCESSING;
USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

-- ============================================
-- 1. DROP CORTEX SEARCH SERVICES
-- ============================================

SELECT '🗑️ Dropping Cortex Search Services...' AS status;

DROP CORTEX SEARCH SERVICE IF EXISTS SWT2025_call_transcript_search;
DROP CORTEX SEARCH SERVICE IF EXISTS SWT2025_customer_name_search;
DROP CORTEX SEARCH SERVICE IF EXISTS SWT2025_agent_name_search;

-- ============================================
-- 2. DROP TABLES
-- ============================================

SELECT '🗑️ Dropping Tables...' AS status;

DROP TABLE IF EXISTS AI_TRANSCRIBED_CALLS_AI_GENERATED;
DROP TABLE IF EXISTS AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE;
DROP TABLE IF EXISTS CALLBACK_QUEUE;

-- ============================================
-- 3. DROP VIEWS
-- ============================================

SELECT '🗑️ Dropping Views...' AS status;

DROP VIEW IF EXISTS call_metrics_by_region;

-- ============================================
-- 4. DROP PROCEDURES
-- ============================================

SELECT '🗑️ Dropping Procedures...' AS status;

DROP PROCEDURE IF EXISTS schedule_customer_callback(VARCHAR, VARCHAR, VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS bulk_schedule_callbacks_for_at_risk_customers(NUMBER, VARCHAR);

-- ============================================
-- 5. DROP STAGE AND FILE FORMAT
-- ============================================

SELECT '🗑️ Dropping Stage and File Format...' AS status;

DROP STAGE IF EXISTS call_center_stage;
DROP FILE FORMAT IF EXISTS csv_format;

-- ============================================
-- 6. DROP SEMANTIC MODEL (Manual Step Required)
-- ============================================

-- NOTE: Semantic models must be deleted via Snowsight UI:
--   1. Navigate to: Data → CALL_CENTER_ANALYTICS → AUDIO_PROCESSING
--   2. Find: SWT2025_CALL_CENTER_SEMANTIC_MODEL_ENHANCED
--   3. Click the "..." menu → Delete

SELECT '⚠️ MANUAL STEP: Delete semantic model via Snowsight UI' AS reminder;

-- ============================================
-- 7. DROP AGENT (if applicable)
-- ============================================

-- Uncomment to drop the agent:
-- DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.CALL_CENTRE_AGENT_SWT2025;

SELECT '⚠️ OPTIONAL: Run DROP AGENT command if you want to remove the agent' AS reminder;

-- ============================================
-- VERIFICATION
-- ============================================

SELECT '🔍 Verifying cleanup...' AS status;

-- Check remaining tables
SELECT 'Remaining Tables:' as check_type, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'AUDIO_PROCESSING' 
  AND TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME IN (
    'AI_TRANSCRIBED_CALLS_AI_GENERATED',
    'AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE',
    'CALLBACK_QUEUE'
  );

-- Check remaining views
SELECT 'Remaining Views:' as check_type, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'AUDIO_PROCESSING' 
  AND TABLE_TYPE = 'VIEW'
  AND TABLE_NAME = 'CALL_METRICS_BY_REGION';

-- ============================================
-- CLEANUP COMPLETE
-- ============================================

SELECT 
    '✅ Cleanup complete!' AS status,
    'All demo assets have been removed from CALL_CENTER_ANALYTICS.AUDIO_PROCESSING' AS message,
    'Remember to manually delete the semantic model and agent via Snowsight UI' AS reminder;
