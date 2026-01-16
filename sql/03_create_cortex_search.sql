-- ============================================
-- Snowflake World Tour 2025 London
-- Call Center Intelligence Demo
-- Step 3: Cortex Search Services
-- ============================================
-- Purpose: Enable semantic search over call center transcripts
-- This allows natural language queries like:
--   "Find calls where customers mentioned billing errors"
--   "Show me frustrated customers talking about cancellations"
--   "What did customers say about West region service issues?"

-- Prerequisites:
-- 1. Tables must exist: AI_TRANSCRIBED_CALLS_AI_GENERATED
-- 2. Warehouse must exist
-- 3. Role must have CORTEX LLM privileges

-- ============================================
-- CONFIGURATION - Update these for your environment
-- ============================================
SET WAREHOUSE_NAME = 'WH_AISQL_HOL';  -- Change to your warehouse

USE DATABASE CALL_CENTER_ANALYTICS;
USE SCHEMA AUDIO_PROCESSING;
USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

-- Create Cortex Search Service on transcript text
-- Using larger embedding model (arctic-embed-l) for better semantic understanding
CREATE OR REPLACE CORTEX SEARCH SERVICE SWT2025_call_transcript_search
  ON TRANSCRIPT_TEXT                    -- Column containing unstructured call transcripts
  ATTRIBUTES 
    CALL_ID,                            -- Unique call identifier for filtering
    CUSTOMER_NAME,                      -- Filter by specific customers
    AGENT_NAME,                         -- Filter by specific agents
    CALL_TYPE,                          -- Filter: inbound vs outbound
    PRIMARY_INTENT,                     -- Filter: billing, technical_support, cancellation, etc.
    SENTIMENT_CATEGORY,                 -- Filter: POSITIVE, NEGATIVE, NEUTRAL
    CUSTOMER_SATISFACTION,              -- Filter: satisfied, neutral, dissatisfied
    URGENCY_LEVEL,                      -- Filter: low, medium, high
    ISSUE_RESOLVED,                     -- Filter: yes, no
    CALL_CLASSIFICATION,                -- Filter: Billing Issue, Technical Support, etc.
    ANALYSIS_TIMESTAMP                  -- Filter by date/time
    -- Note: ESCALATION_REQUIRED removed (BOOLEAN type not supported in Cortex Search)
  WAREHOUSE = WH_AISQL_HOL            -- Dedicated warehouse for search operations
  TARGET_LAG = '30 day'             -- Keep index fresh within 30 minutes of data updates
  EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'  -- Large model for best accuracy
  INITIALIZE = ON_CREATE                -- Build index immediately (not on schedule)
  COMMENT = 'Semantic search service for call center transcripts. Enables natural language queries over customer conversations with contextual filtering by agent, sentiment, intent, and resolution status.'
AS 
  SELECT 
    CALL_ID,
    TRANSCRIPT_TEXT,
    CUSTOMER_NAME,
    AGENT_NAME,
    CALL_TYPE,
    PRIMARY_INTENT,
    SENTIMENT_CATEGORY,
    CUSTOMER_SATISFACTION,
    URGENCY_LEVEL,
    ISSUE_RESOLVED,
    -- ESCALATION_REQUIRED excluded (BOOLEAN not supported in Cortex Search)
    CALL_CLASSIFICATION,
    ANALYSIS_TIMESTAMP
  FROM AI_TRANSCRIBED_CALLS_AI_GENERATED
  WHERE TRANSCRIPT_TEXT IS NOT NULL     -- Only index calls with transcripts
    AND LENGTH(TRANSCRIPT_TEXT) > 0;    -- Skip empty transcripts


-- ============================================
-- Verify Search Service Creation
-- ============================================

-- Check service status
DESCRIBE CORTEX SEARCH SERVICE SWT2025_call_transcript_search;

-- Expected output should show:
--   indexing_state: RUNNING
--   serving_state: RUNNING
--   embedding_model: snowflake-arctic-embed-l-v2.0
--   source_data_num_rows: 500 (52 original + 448 generated calls)


-- ============================================
-- Example Search Queries
-- ============================================

-- Example 1: Find calls mentioning specific issues
-- SELECT CORTEX_SEARCH_SERVICE(
--   'call_transcript_search',
--   'billing error overcharge',
--   5  -- Return top 5 results
-- );

-- Example 2: Search with filtering for negative sentiment
-- SELECT CORTEX_SEARCH_SERVICE(
--   'call_transcript_search',
--   'customer frustrated unable to resolve',
--   10,
--   {'sentiment_category': 'NEGATIVE', 'issue_resolved': 'no'}
-- );

-- Example 3: Find technical support escalations
-- SELECT CORTEX_SEARCH_SERVICE(
--   'call_transcript_search',
--   'technical problem internet connection',
--   5,
--   {'primary_intent': 'technical_support', 'escalation_required': 'yes'}
-- );


-- ============================================
-- Alternative: Smaller Model for Cost Savings
-- ============================================
-- If you prefer faster indexing and lower costs, use the medium model:
--
-- CREATE OR REPLACE CORTEX SEARCH SERVICE call_transcript_search
--   ON transcript_text
--   ATTRIBUTES call_id, customer_name, agent_name, call_type, primary_intent, 
--              sentiment_category, customer_satisfaction, urgency_level,
--              issue_resolved, escalation_required, analysis_timestamp
--   WAREHOUSE = call_center_wh
--   TARGET_LAG = '30 minutes'
--   EMBEDDING_MODEL = 'snowflake-arctic-embed-m-v1.5'  -- Medium model (default)
--   INITIALIZE = ON_CREATE
-- AS SELECT ... (same query as above)


-- ============================================
-- Search Service for Agent/Customer Names (Fuzzy Matching)
-- ============================================
-- These services support fuzzy matching in semantic model for names

CREATE OR REPLACE CORTEX SEARCH SERVICE SWT2025_customer_name_search
  ON CUSTOMER_NAME
  ATTRIBUTES CALL_ID
  WAREHOUSE = WH_AISQL_HOL
  TARGET_LAG = '1 hour'
  INITIALIZE = ON_CREATE
AS 
  SELECT DISTINCT 
    CUSTOMER_NAME,
    CALL_ID
  FROM AI_TRANSCRIBED_CALLS_AI_GENERATED
  WHERE CUSTOMER_NAME IS NOT NULL;

CREATE OR REPLACE CORTEX SEARCH SERVICE SWT2025_agent_name_search
  ON AGENT_NAME
  ATTRIBUTES CALL_ID
  WAREHOUSE = WH_AISQL_HOL
  TARGET_LAG = '1 hour'
  INITIALIZE = ON_CREATE
AS 
  SELECT DISTINCT 
    AGENT_NAME,
    CALL_ID
  FROM AI_TRANSCRIBED_CALLS_AI_GENERATED
  WHERE AGENT_NAME IS NOT NULL;