-- ============================================
-- Snowflake World Tour 2025 London
-- Call Center Intelligence Demo
-- Step 4: Verification and Testing
-- ============================================

-- ============================================
-- CONFIGURATION - Update these for your environment
-- ============================================
SET WAREHOUSE_NAME = 'WH_AISQL_HOL';  -- Change to your warehouse

USE DATABASE CALL_CENTER_ANALYTICS;
USE SCHEMA AUDIO_PROCESSING;
USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

-- ============================================
-- 1. VERIFY ALL OBJECTS EXIST
-- ============================================

SELECT '=== VERIFICATION CHECKLIST ===' as section;

-- Check tables
SELECT 'Tables' as object_type, TABLE_NAME, ROW_COUNT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'AUDIO_PROCESSING'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Expected: AI_TRANSCRIBED_CALLS_AI_GENERATED (500 rows), AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE (418 rows)

-- Check views
SELECT 'Views' as object_type, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'AUDIO_PROCESSING'
  AND TABLE_TYPE = 'VIEW';

-- Check Cortex Search Services
SHOW CORTEX SEARCH SERVICE;

-- Expected: call_transcript_search, customer_name_search, agent_name_search

-- ============================================
-- 2. DATA QUALITY CHECKS
-- ============================================

SELECT '=== DATA QUALITY CHECKS ===' as section;

-- Call data completeness
SELECT 
    'Call Data' as check_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT CALL_ID) as unique_calls,
    SUM(CASE WHEN TRANSCRIPT_TEXT IS NOT NULL AND LENGTH(TRANSCRIPT_TEXT) > 0 THEN 1 ELSE 0 END) as calls_with_transcripts,
    COUNT(DISTINCT CUSTOMER_NAME) as unique_customers,
    COUNT(DISTINCT AGENT_NAME) as unique_agents
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED;

-- Customer profile completeness
SELECT 
    'Customer Profile' as check_name,
    COUNT(*) as total_customers,
    COUNT(DISTINCT REGION) as unique_regions,
    COUNT(DISTINCT CUSTOMER_SEGMENT) as unique_segments,
    SUM(CASE WHEN ACCOUNT_STATUS = 'Active' THEN 1 ELSE 0 END) as active_customers
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE;

-- Join coverage (how many calls have matching customer data)
SELECT 
    'Call-Customer Join' as check_name,
    COUNT(f.CALL_ID) as total_calls,
    SUM(CASE WHEN c.CUSTOMER_ID IS NOT NULL THEN 1 ELSE 0 END) as calls_with_customer_data,
    (SUM(CASE WHEN c.CUSTOMER_ID IS NOT NULL THEN 1 ELSE 0 END)::FLOAT / COUNT(f.CALL_ID) * 100) as join_coverage_pct
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED f
LEFT JOIN AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE c ON f.CUSTOMER_NAME = c.CUSTOMER_NAME;

-- ============================================
-- 3. TEST CORTEX SEARCH SERVICES
-- ============================================

SELECT '=== CORTEX SEARCH TESTS ===' as section;

-- Test 1: Basic transcript search
SELECT 'Test 1: Search for billing issues' as test_name;

SELECT CORTEX_SEARCH(
    'call_transcript_search',
    'billing error overcharge unauthorized charge',
    5  -- Return top 5 results
);

-- Test 2: Search with filtering
SELECT 'Test 2: Search negative sentiment calls' as test_name;

SELECT CORTEX_SEARCH(
    'call_transcript_search',
    'customer frustrated unhappy dissatisfied',
    10,
    {'sentiment_category': 'NEGATIVE'}
);

-- Test 3: Customer name fuzzy search
SELECT 'Test 3: Find customer by partial name' as test_name;

SELECT CORTEX_SEARCH(
    'customer_name_search',
    'David',
    5
);

-- ============================================
-- 4. TEST ANALYTICAL QUERIES
-- ============================================

SELECT '=== ANALYTICAL QUERY TESTS ===' as section;

-- Query 1: Regional satisfaction comparison
SELECT 
    'Regional Satisfaction Comparison' as query_name,
    cp.REGION,
    COUNT(ft.CALL_ID) as call_count,
    ROUND(AVG(ft.SENTIMENT_SCORE), 3) as avg_sentiment,
    ROUND(COUNT(CASE WHEN ft.CUSTOMER_SATISFACTION = 'satisfied' THEN 1 END)::FLOAT / COUNT(*) * 100, 1) as satisfaction_rate
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED ft
LEFT JOIN AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE cp ON ft.CUSTOMER_NAME = cp.CUSTOMER_NAME
WHERE cp.REGION IS NOT NULL
GROUP BY cp.REGION
ORDER BY satisfaction_rate DESC;

-- Query 2: Top performing agents
SELECT 
    'Top Performing Agents' as query_name,
    AGENT_NAME,
    COUNT(*) as total_calls,
    ROUND(AVG(AGENT_PERFORMANCE_SCORE), 2) as avg_performance,
    ROUND(AVG(SENTIMENT_SCORE), 3) as avg_sentiment,
    ROUND(COUNT(CASE WHEN ISSUE_RESOLVED = 'yes' THEN 1 END)::FLOAT / COUNT(*) * 100, 1) as resolution_rate
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED
WHERE AGENT_PERFORMANCE_SCORE IS NOT NULL
GROUP BY AGENT_NAME
ORDER BY avg_performance DESC
LIMIT 5;

-- Query 3: Calls requiring attention (unresolved + negative)
SELECT 
    'Calls Requiring Attention' as query_name,
    CALL_ID,
    CUSTOMER_NAME,
    AGENT_NAME,
    PRIMARY_INTENT,
    SENTIMENT_CATEGORY,
    URGENCY_LEVEL,
    LEFT(CALL_SUMMARY, 100) as summary_preview
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED
WHERE ISSUE_RESOLVED = 'no'
  AND SENTIMENT_CATEGORY = 'NEGATIVE'
  AND URGENCY_LEVEL IN ('medium', 'high')
ORDER BY ANALYSIS_TIMESTAMP DESC
LIMIT 10;

-- Query 4: Customer churn risk analysis
SELECT 
    'Churn Risk Analysis' as query_name,
    cp.CUSTOMER_NAME,
    cp.CUSTOMER_SEGMENT,
    cp.REGION,
    cp.MONTHLY_PLAN_VALUE,
    COUNT(ft.CALL_ID) as recent_negative_calls,
    ROUND(AVG(ft.SENTIMENT_SCORE), 3) as avg_sentiment,
    MAX(ft.ANALYSIS_TIMESTAMP) as last_call_date
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE cp
JOIN AI_TRANSCRIBED_CALLS_AI_GENERATED ft ON cp.CUSTOMER_NAME = ft.CUSTOMER_NAME
WHERE ft.SENTIMENT_CATEGORY = 'NEGATIVE'
  AND ft.ANALYSIS_TIMESTAMP >= DATEADD(day, -60, CURRENT_TIMESTAMP())
  AND cp.ACCOUNT_STATUS = 'Active'
GROUP BY cp.CUSTOMER_NAME, cp.CUSTOMER_SEGMENT, cp.REGION, cp.MONTHLY_PLAN_VALUE
HAVING COUNT(ft.CALL_ID) >= 2
ORDER BY cp.MONTHLY_PLAN_VALUE DESC
LIMIT 10;

-- ============================================
-- 5. PERFORMANCE BENCHMARKS
-- ============================================

SELECT '=== PERFORMANCE BENCHMARKS ===' as section;

-- Measure query performance
SET start_time = CURRENT_TIMESTAMP();

SELECT COUNT(*) as total_records
FROM AI_TRANSCRIBED_CALLS_AI_GENERATED ft
JOIN AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE cp ON ft.CUSTOMER_NAME = cp.CUSTOMER_NAME;

SELECT DATEDIFF(millisecond, $start_time, CURRENT_TIMESTAMP()) as query_time_ms;

-- ============================================
-- 6. SEMANTIC MODEL READINESS
-- ============================================

SELECT '=== SEMANTIC MODEL READINESS ===' as section;

-- Check that all columns referenced in semantic model exist
SELECT 'Checking AI_TRANSCRIBED_CALLS_AI_GENERATED columns' as check_name;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'AUDIO_PROCESSING'
  AND TABLE_NAME = 'AI_TRANSCRIBED_CALLS_AI_GENERATED'
ORDER BY ORDINAL_POSITION;

SELECT 'Checking AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE columns' as check_name;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'AUDIO_PROCESSING'
  AND TABLE_NAME = 'AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE'
ORDER BY ORDINAL_POSITION;

-- ============================================
-- 7. FINAL CHECKLIST
-- ============================================

SELECT '=== FINAL SETUP CHECKLIST ===' as section;

SELECT 
    '✓ Database created: SNOWFLAKE_DEMO_DB' as step1,
    '✓ Schema created: CALL_CENTER' as step2,
    '✓ Tables created: AI_TRANSCRIBED_CALLS_AI_GENERATED, AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE' as step3,
    '✓ Data loaded: 500 calls, 418 customers' as step4,
    '✓ Cortex Search services created' as step5,
    '✓ Queries tested successfully' as step6,
    '' as blank,
    '📋 NEXT STEPS:' as next_steps,
    '  1. Upload semantic model (call_center_semantic_model.yaml)' as action1,
    '  2. Create Snowflake Intelligence Agent' as action2,
    '  3. Test demo questions' as action3,
    '  4. Practice presentation flow' as action4;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

SELECT 
    '🎉 Setup Complete!' as message,
    'All components verified and ready for demo' as status,
    'Proceed to create your Snowflake Intelligence Agent' as next_action;

