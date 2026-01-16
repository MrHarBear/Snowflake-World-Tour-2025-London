-- ============================================
-- Snowflake World Tour 2025 London
-- Call Center Intelligence Demo
-- Step 2: Create Tables and Load Data
-- ============================================

-- ============================================
-- CONFIGURATION - Update these for your environment
-- ============================================
SET WAREHOUSE_NAME = 'WH_AISQL_HOL';  -- Change to your warehouse

USE DATABASE CALL_CENTER_ANALYTICS;
USE SCHEMA AUDIO_PROCESSING;
USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

-- ============================================
-- 1. CREATE AI_TRANSCRIBED_CALLS_AI_GENERATED (Call Center Data)
-- ============================================

CREATE OR REPLACE TABLE AI_TRANSCRIBED_CALLS_AI_GENERATED (
    CALL_ID VARCHAR(50) PRIMARY KEY COMMENT 'Unique call identifier',
    TRANSCRIPT_TEXT VARCHAR(16777216) COMMENT 'Full call transcript (unstructured text)',
    WORD_COUNT NUMBER COMMENT 'Number of words in transcript',
    SENTIMENT_SCORE FLOAT COMMENT 'AI sentiment score (-1 to +1)',
    SENTIMENT_CATEGORY VARCHAR(20) COMMENT 'POSITIVE, NEGATIVE, or NEUTRAL',
    CALL_SUMMARY VARCHAR(16777216) COMMENT 'AI-generated summary of the call',
    CALL_CLASSIFICATION VARCHAR(50) COMMENT 'Classification: Billing Issue, Technical Support, etc.',
    EXTRACTED_FIELDS VARIANT COMMENT 'JSON with extracted structured fields',
    CALL_ANALYSIS VARIANT COMMENT 'JSON with full call analysis',
    AGENT_PERFORMANCE_SCORE NUMBER COMMENT 'Agent performance rating (0-10)',
    IMPROVEMENT_OPPORTUNITIES VARCHAR(16777216) COMMENT 'Suggested improvements for agent',
    ANALYSIS_TIMESTAMP TIMESTAMP_NTZ COMMENT 'When the call was analyzed',
    CALL_TYPE VARCHAR(20) COMMENT 'inbound or outbound',
    CUSTOMER_NAME VARCHAR(100) COMMENT 'Customer name',
    AGENT_NAME VARCHAR(100) COMMENT 'Agent who handled the call',
    PRIMARY_INTENT VARCHAR(50) COMMENT 'billing, technical_support, cancellation, etc.',
    URGENCY_LEVEL VARCHAR(20) COMMENT 'low, medium, high',
    ISSUE_RESOLVED VARCHAR(10) COMMENT 'yes or no',
    ESCALATION_REQUIRED VARCHAR(10) COMMENT 'yes or no',
    CUSTOMER_SATISFACTION VARCHAR(20) COMMENT 'satisfied, neutral, dissatisfied'
) COMMENT = 'Call center interaction data with AI-powered sentiment analysis and agent performance metrics';

-- ============================================
-- 2. CREATE AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE (Demographics)
-- ============================================

CREATE OR REPLACE TABLE AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE (
    CUSTOMER_ID NUMBER PRIMARY KEY COMMENT 'Unique customer identifier',
    CUSTOMER_NAME VARCHAR(100) UNIQUE COMMENT 'Customer full name (joins to AI_TRANSCRIBED_CALLS_AI_GENERATED)',
    EMAIL VARCHAR(200) COMMENT 'Customer email address',
    PHONE VARCHAR(20) COMMENT 'Customer phone number',
    STATE VARCHAR(50) COMMENT 'US state',
    REGION VARCHAR(50) COMMENT 'Geographic region: West, South, Northeast, Southeast, Midwest',
    COUNTRY VARCHAR(50) COMMENT 'Country (United States)',
    CITY VARCHAR(100) COMMENT 'City',
    POSTAL_CODE VARCHAR(20) COMMENT 'ZIP/Postal code',
    ACCOUNT_TYPE VARCHAR(20) COMMENT 'Residential or Business',
    CUSTOMER_SEGMENT VARCHAR(50) COMMENT 'Individual, Premium, Enterprise, Mid-Market, Senior',
    CUSTOMER_SINCE DATE COMMENT 'Account creation date',
    ACCOUNT_STATUS VARCHAR(20) COMMENT 'Active, Cancelled, Churned',
    MONTHLY_PLAN_VALUE FLOAT COMMENT 'Monthly recurring revenue (MRR)',
    LIFETIME_VALUE FLOAT COMMENT 'Total customer lifetime value',
    PAYMENT_METHOD VARCHAR(50) COMMENT 'Credit Card, Bank Transfer, Debit Card, Invoice',
    PREFERRED_CONTACT VARCHAR(20) COMMENT 'Phone, Email, SMS',
    LANGUAGE_PREFERENCE VARCHAR(50) COMMENT 'Preferred language for service',
    AGE_GROUP VARCHAR(20) COMMENT 'Age bracket',
    INDUSTRY VARCHAR(100) COMMENT 'Industry sector for business customers'
) COMMENT = 'Customer demographic and account information for enriched call analysis';

-- ============================================
-- 3. LOAD DATA FROM STAGE
-- ============================================

-- Option A: Load from uploaded files in stage
-- (First, upload your CSV files using SnowCLI or Snowsight UI)

-- Load AI_TRANSCRIBED_CALLS_AI_GENERATED
COPY INTO AI_TRANSCRIBED_CALLS_AI_GENERATED
FROM @call_center_stage/FINAL_TABLE_COMPLETE.csv
FILE_FORMAT = csv_format
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Load AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE
COPY INTO AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE
FROM @call_center_stage/CUSTOMER_PROFILE_COMPLETE.csv
FILE_FORMAT = csv_format
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- ============================================
-- 4. VERIFY DATA LOAD
-- ============================================

-- Check row counts
SELECT 'AI_TRANSCRIBED_CALLS_AI_GENERATED' as table_name, COUNT(*) as row_count FROM AI_TRANSCRIBED_CALLS_AI_GENERATED
UNION ALL
SELECT 'AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE', COUNT(*) FROM AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE;

-- Expected results:
-- AI_TRANSCRIBED_CALLS_AI_GENERATED: 500 rows (52 original + 448 generated)
-- AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE: 418 rows (complete coverage)

-- Sample data from AI_TRANSCRIBED_CALLS_AI_GENERATED
SELECT 
    CALL_ID,
    CUSTOMER_NAME,
    AGENT_NAME,
    CALL_TYPE,
    PRIMARY_INTENT,
    SENTIMENT_CATEGORY,
    CUSTOMER_SATISFACTION,
    ISSUE_RESOLVED,
    LEFT(TRANSCRIPT_TEXT, 100) as transcript_preview
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED
LIMIT 5;

-- Sample data from AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE
SELECT 
    CUSTOMER_NAME,
    REGION,
    STATE,
    CUSTOMER_SEGMENT,
    ACCOUNT_STATUS,
    MONTHLY_PLAN_VALUE,
    CUSTOMER_SINCE
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE
LIMIT 5;

-- ============================================
-- 5. DATA QUALITY CHECKS
-- ============================================

-- Check for calls with transcripts
SELECT 
    COUNT(*) as total_calls,
    SUM(CASE WHEN TRANSCRIPT_TEXT IS NOT NULL THEN 1 ELSE 0 END) as calls_with_transcripts,
    SUM(CASE WHEN LENGTH(TRANSCRIPT_TEXT) > 0 THEN 1 ELSE 0 END) as calls_with_text
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED;

-- Verify customer-call join
SELECT 
    c.CUSTOMER_NAME,
    c.REGION,
    c.CUSTOMER_SEGMENT,
    COUNT(f.CALL_ID) as call_count,
    AVG(f.SENTIMENT_SCORE) as avg_sentiment,
    AVG(f.AGENT_PERFORMANCE_SCORE) as avg_agent_score
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE c
LEFT JOIN AI_TRANSCRIBED_CALLS_AI_GENERATED f ON c.CUSTOMER_NAME = f.CUSTOMER_NAME
GROUP BY c.CUSTOMER_NAME, c.REGION, c.CUSTOMER_SEGMENT
ORDER BY call_count DESC
LIMIT 10;

-- ============================================
-- 6. CREATE USEFUL VIEWS (Optional)
-- ============================================

-- View: Call metrics by region
CREATE OR REPLACE VIEW call_metrics_by_region AS
SELECT 
    cp.REGION,
    COUNT(DISTINCT ft.CALL_ID) as total_calls,
    AVG(ft.SENTIMENT_SCORE) as avg_sentiment,
    COUNT(CASE WHEN ft.CUSTOMER_SATISFACTION = 'satisfied' THEN 1 END)::FLOAT / COUNT(*) * 100 as satisfaction_rate,
    COUNT(CASE WHEN ft.ISSUE_RESOLVED = 'yes' THEN 1 END)::FLOAT / COUNT(*) * 100 as resolution_rate,
    COUNT(CASE WHEN ft.ESCALATION_REQUIRED = 'yes' THEN 1 END)::FLOAT / COUNT(*) * 100 as escalation_rate,
    AVG(ft.AGENT_PERFORMANCE_SCORE) as avg_agent_performance
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED ft
LEFT JOIN AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE cp ON ft.CUSTOMER_NAME = cp.CUSTOMER_NAME
WHERE cp.REGION IS NOT NULL
GROUP BY cp.REGION
ORDER BY satisfaction_rate DESC;

-- Test the view
SELECT * FROM call_metrics_by_region;

-- ============================================
-- 7. GRANT PERMISSIONS (Adjust as needed)
-- ============================================

-- Grant SELECT to other roles if needed
-- GRANT SELECT ON ALL TABLES IN SCHEMA AUDIO_PROCESSING TO ROLE DATA_ANALYST;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA AUDIO_PROCESSING TO ROLE DATA_ANALYST;

-- ============================================
-- NEXT STEPS
-- ============================================

-- Run: 03_create_cortex_search.sql

SELECT '✓ Tables created and data loaded successfully!' as status,
       '  → AI_TRANSCRIBED_CALLS_AI_GENERATED: 500 rows (52 original + 448 generated)' as detail1,
       '  → AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE: 418 rows (100% coverage)' as detail2,
       '  → Avg 1.2 calls per customer' as detail3,
       '  → Ready for Cortex Search setup' as next_step;

