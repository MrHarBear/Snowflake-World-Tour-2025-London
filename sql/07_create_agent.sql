-- ============================================
-- Snowflake World Tour 2025 London
-- Step 7: Create Snowflake Intelligence Agent
-- ============================================
-- Prerequisites:
--   1. Run scripts 01-05 first (tables, search, semantic model, custom tool)
--   2. Ensure SNOWFLAKE_INTELLIGENCE database exists (auto-created by Snowflake)
--   3. Role must have CREATE AGENT privilege on SNOWFLAKE_INTELLIGENCE.AGENTS
--
-- Documentation: https://docs.snowflake.com/en/sql-reference/sql/create-agent
-- ============================================

-- ============================================
-- CONFIGURATION - Update these for your environment
-- ============================================
SET WAREHOUSE_NAME = 'WH_AISQL_HOL';  -- Change to your warehouse

USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

-- ============================================
-- 1. VERIFY PREREQUISITES EXIST
-- ============================================

SELECT '🔍 Checking prerequisites...' AS status;

-- Check semantic view exists
SELECT 'Semantic Model:' as check_type, 
       CASE WHEN COUNT(*) > 0 THEN '✅ Found' ELSE '❌ Missing' END as status
FROM CALL_CENTER_ANALYTICS.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'AUDIO_PROCESSING' 
  AND TABLE_NAME LIKE '%SEMANTIC_MODEL%';

-- Check Cortex Search service exists
DESC CORTEX SEARCH SERVICE CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.SWT2025_CALL_TRANSCRIPT_SEARCH;

-- Check procedure exists
SHOW PROCEDURES LIKE 'SCHEDULE_CUSTOMER_CALLBACK' IN SCHEMA CALL_CENTER_ANALYTICS.AUDIO_PROCESSING;

-- ============================================
-- 2. CREATE THE AGENT
-- ============================================

SELECT '🤖 Creating Snowflake Intelligence Agent...' AS status;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.CALL_CENTRE_AGENT_SWT2025
  COMMENT = 'Call Center Intelligence Agent for SWT 2025 London Demo'
  PROFILE = '{"display_name": "CALL_CENTRE_AGENT_SWT2025"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration: {}

  instructions:
    response: |
      You are a professional call center intelligence assistant helping business users make data-driven decisions.

      TONE & COMMUNICATION:
      - Professional, helpful, concise and succinct
      - Use business-friendly language, avoid technical jargon
      - Be constructive when discussing performance issues
      - Acknowledge both successes and areas for improvement

      ANSWER STRUCTURE:
      - Start with the direct answer to the question
      - Provide context and comparisons (e.g., "68%, down from 72% last month")
      - Include actionable insights, not just data points
      - For regional/segment comparisons, include all categories for fairness

      VISUALIZATIONS (Important):
      - Create charts for comparisons, trends, and distributions
      - Use bar charts for regional or segment comparisons
      - Use line charts for time-series trends
      - Use tables when showing detailed multi-column breakdowns
      - Always create a chart when comparing more than 2 values

      SPECIFIC BEHAVIORS:
      - Revenue questions: Show both dollar amount AND customer count
      - Problem identification: Suggest 2-3 potential root causes
      - Agent performance: Balance performance scores with improvement opportunities
      - At-risk customers: Rank by revenue impact (highest value first)
      - Callback confirmations: Include customer segment, assigned agent, and priority

      ACTION CONFIRMATIONS:
      - When taking actions (callbacks, tasks), confirm what was done
      - Include relevant context (who, when, why, assigned to whom)
      - Provide follow-up suggestions

      TRANSPARENCY:
      - Cite which data sources were used (metrics from Analyst, patterns from Search)
      - If a question cannot be fully answered, explain what data is missing
      - When making recommendations, explain the reasoning

      BUSINESS CONTEXT:
      - First Call Resolution (FCR) = calls where ISSUE_RESOLVED = 'yes'
      - Premium customers (Premium, Enterprise) receive priority treatment
      - West region = California, Washington, Oregon, Montana, Nevada, Hawaii, Colorado
      - Default to last 30 days for trend analysis unless specified otherwise

    orchestration: |
      PRIORITY RULES:
      - For questions about specific customers: Always check their profile first
      - For revenue questions: Prioritize Premium and Enterprise segments
      - For agent performance: Be constructive, focus on improvement opportunities
      - When in doubt: Use Cortex Analyst for data, Cortex Search for context

      Always prefer using tools over general knowledge.
      Combine multiple tools when needed to provide comprehensive answers.

    sample_questions:
      - question: "What was the most common reason customers called us last week?"
      - question: "Show me the calls where customers exhibited the most negative sentiment and tell me the single biggest issue they were calling about"
      - question: "Across all agents, what is the most frequently mentioned area of improvement?"

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: CALL_CENTER_SEMANTIC_MODEL_ENHANCED
        description: |
          Analyzes structured call center data including customer satisfaction rates, 
          agent performance scores, resolution rates, escalation rates, and revenue metrics. 
          Use this tool for quantitative questions requiring calculations, aggregations, 
          comparisons, or metrics across customer segments, regions, call types, and time periods.

          Can answer: "What's our satisfaction rate?", "Compare regions", "Show top performing agents", 
          "What's our resolution rate?", "Which customers have the highest lifetime value?", 
          "How many escalations this month?"

          Verified queries include regional satisfaction comparisons, agent performance rankings, 
          billing issue analysis, churn risk identification, and revenue impact calculations.

    - tool_spec:
        type: cortex_search
        name: SWT2025_call_transcript_search
        description: |
          Searches through 500 actual customer service call transcripts using semantic search. 
          Use this tool when you need to find what customers said, specific issues mentioned, 
          conversation patterns, or qualitative feedback.

          Best for questions like: "Find calls mentioning billing errors", 
          "What did frustrated customers say about West region?", 
          "Show me calls where customers asked for supervisor", 
          "What complaints did we receive about technical support?"

          Returns relevant transcript excerpts with call metadata (sentiment, agent, resolution status). 
          Can filter by sentiment category, call intent, customer satisfaction, urgency level, and agent name.

    - tool_spec:
        type: generic
        name: schedule_customer_callback
        description: |
          Schedules customer callbacks by writing to the CALLBACK_QUEUE table. 
          Takes action by creating callback tasks with intelligent agent assignment 
          based on customer segment and priority level.

          Use this tool when users ask to:
          - Schedule a callback for a specific customer
          - Create a follow-up task
          - Take action on unresolved issues

          The procedure automatically:
          - Assigns senior agents (score >=9) for HIGH priority or Premium/Enterprise customers
          - Assigns qualified agents (score >=7) for standard requests
          - Sets callback time based on priority (HIGH=10am, MEDIUM=2pm, LOW=4pm)
          - Captures customer segment and revenue data
          - Returns confirmation with all callback details
        input_schema:
          type: object
          properties:
            customer_name_input:
              type: string
              description: "The full name of the customer to schedule a callback for. Must match a customer name in the database exactly. Example: David Thompson"
            callback_reason_input:
              type: string
              description: "The reason for the callback. Describe the issue or purpose clearly. Example: Unresolved billing dispute"
            scheduled_date_input:
              type: string
              description: "The date to schedule the callback in YYYY-MM-DD format. Example: 2025-10-08"
            priority_input:
              type: string
              description: "Priority level: HIGH, MEDIUM, or LOW. HIGH priority schedules at 10am with senior agents, MEDIUM at 2pm, LOW at 4pm."
          required:
            - customer_name_input
            - callback_reason_input
            - scheduled_date_input
            - priority_input

  tool_resources:
    CALL_CENTER_SEMANTIC_MODEL_ENHANCED:
      semantic_view: CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.SWT2025_CALL_CENTER_SEMANTIC_MODEL_ENHANCED
      execution_environment:
        type: warehouse
        warehouse: ""

    SWT2025_call_transcript_search:
      name: CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.SWT2025_CALL_TRANSCRIPT_SEARCH
      max_results: 10
      title_column: CALL_CLASSIFICATION
      id_column: CALL_ID

    schedule_customer_callback:
      identifier: CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.SCHEDULE_CUSTOMER_CALLBACK
      name: "SCHEDULE_CUSTOMER_CALLBACK(VARCHAR, VARCHAR, VARCHAR, DEFAULT VARCHAR)"
      type: procedure
      execution_environment:
        type: warehouse
        warehouse: ""
        query_timeout: 60
  $$;

-- ============================================
-- 3. VERIFY AGENT CREATION
-- ============================================

SELECT '✅ Agent created successfully!' AS status;

-- Show agent details
SHOW AGENTS LIKE 'CALL_CENTRE_AGENT_SWT2025' IN DATABASE SNOWFLAKE_INTELLIGENCE;

-- Describe agent configuration
DESCRIBE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.CALL_CENTRE_AGENT_SWT2025;

-- ============================================
-- NEXT STEPS
-- ============================================

SELECT 
    '🎉 Agent ready!' AS status,
    'Open Snowsight → AI & ML → Agents → CALL_CENTRE_AGENT_SWT2025' AS next_step1,
    'Test with: "Compare customer satisfaction rates across all regions"' AS next_step2,
    'Test with: "Why is the West region underperforming?"' AS next_step3,
    'Test with: "Schedule a callback for David Thompson tomorrow"' AS next_step4;

-- ============================================
-- TO DROP THE AGENT (if needed)
-- ============================================
-- DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.CALL_CENTRE_AGENT_SWT2025;
