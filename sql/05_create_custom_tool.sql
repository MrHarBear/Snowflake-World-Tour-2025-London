-- ============================================
-- Snowflake World Tour 2025 London
-- Custom Tool: Schedule Customer Callback
-- ============================================
-- Purpose: Demonstrate WRITE actions with Cortex Agents
-- Shows the agent can take action, not just provide insights
-- This is a stored procedure that schedules customer callbacks

-- ============================================
-- CONFIGURATION - Update these for your environment
-- ============================================
SET WAREHOUSE_NAME = 'WH_AISQL_HOL';  -- Change to your warehouse

USE DATABASE CALL_CENTER_ANALYTICS;
USE SCHEMA AUDIO_PROCESSING;
USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

-- ============================================
-- 1. CREATE CALLBACK QUEUE TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS CALLBACK_QUEUE (
    CALLBACK_ID NUMBER AUTOINCREMENT PRIMARY KEY,
    CUSTOMER_NAME VARCHAR(200) NOT NULL,
    CALLBACK_REASON VARCHAR(500),
    PRIORITY VARCHAR(20) DEFAULT 'MEDIUM',
    SCHEDULED_DATE DATE,
    SCHEDULED_TIME TIME,
    ASSIGNED_AGENT VARCHAR(200),
    CUSTOMER_SEGMENT VARCHAR(50),
    MONTHLY_PLAN_VALUE NUMBER(10,2),
    STATUS VARCHAR(20) DEFAULT 'PENDING',
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CREATED_BY VARCHAR(100) DEFAULT CURRENT_USER(),
    NOTES VARCHAR(1000)
) COMMENT = 'Queue for scheduled customer callbacks. Populated by Cortex Agent or call center staff.';

-- ============================================
-- 2. CREATE CALLBACK SCHEDULING PROCEDURE
-- ============================================

CREATE OR REPLACE PROCEDURE schedule_customer_callback(
    CUSTOMER_NAME_INPUT VARCHAR,
    CALLBACK_REASON_INPUT VARCHAR,
    SCHEDULED_DATE_INPUT VARCHAR,
    PRIORITY_INPUT VARCHAR DEFAULT 'MEDIUM'
)
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = 'Schedules a customer callback by inserting into CALLBACK_QUEUE table. Returns confirmation message. Used by Cortex Agent to take action on customer issues.'
AS
$$
BEGIN
    -- Insert callback directly using subqueries for intelligent assignment
    INSERT INTO CALLBACK_QUEUE (
        CUSTOMER_NAME,
        CALLBACK_REASON,
        PRIORITY,
        SCHEDULED_DATE,
        SCHEDULED_TIME,
        ASSIGNED_AGENT,
        CUSTOMER_SEGMENT,
        MONTHLY_PLAN_VALUE,
        STATUS,
        NOTES
    )
    SELECT 
        :CUSTOMER_NAME_INPUT as CUSTOMER_NAME,
        :CALLBACK_REASON_INPUT as CALLBACK_REASON,
        :PRIORITY_INPUT as PRIORITY,
        TO_DATE(:SCHEDULED_DATE_INPUT) as SCHEDULED_DATE,
        -- Smart time assignment based on priority
        CASE :PRIORITY_INPUT
            WHEN 'HIGH' THEN '10:00:00'::TIME
            WHEN 'LOW' THEN '16:00:00'::TIME
            ELSE '14:00:00'::TIME
        END as SCHEDULED_TIME,
        -- Smart agent assignment: High priority gets senior agents (score >= 9)
        (SELECT AGENT_NAME 
         FROM AI_TRANSCRIBED_CALLS_AI_GENERATED 
         WHERE AGENT_PERFORMANCE_SCORE >= CASE WHEN :PRIORITY_INPUT = 'HIGH' THEN 9 ELSE 7 END
         ORDER BY RANDOM() 
         LIMIT 1
        ) as ASSIGNED_AGENT,
        cp.CUSTOMER_SEGMENT,
        cp.MONTHLY_PLAN_VALUE,
        'PENDING' as STATUS,
        'Auto-scheduled by Cortex Agent based on customer interaction analysis' as NOTES
    FROM AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE cp
    WHERE cp.CUSTOMER_NAME = :CUSTOMER_NAME_INPUT
    LIMIT 1;
    
    -- Return confirmation message with callback details
    RETURN (
        SELECT 
            'Callback scheduled successfully! ' ||
            'Callback ID: ' || CALLBACK_ID || ' | ' ||
            'Customer: ' || CUSTOMER_NAME || ' (' || COALESCE(CUSTOMER_SEGMENT, 'Unknown') || ') | ' ||
            'Priority: ' || PRIORITY || ' | ' ||
            'Scheduled: ' || TO_VARCHAR(SCHEDULED_DATE, 'YYYY-MM-DD') || ' at ' || TO_VARCHAR(SCHEDULED_TIME, 'HH24:MI') || ' | ' ||
            'Assigned to: ' || COALESCE(ASSIGNED_AGENT, 'TBD') || ' | ' ||
            'Reason: ' || CALLBACK_REASON
        FROM CALLBACK_QUEUE
        WHERE CUSTOMER_NAME = :CUSTOMER_NAME_INPUT
        ORDER BY CALLBACK_ID DESC
        LIMIT 1
    );
END;
$$;

-- ============================================
-- 3. TEST THE PROCEDURE
-- ============================================

-- Test 1: Schedule a high-priority callback
CALL schedule_customer_callback(
    'David Thompson',
    'Unresolved billing dispute - customer called 3 times',
    '2025-10-08',
    'HIGH'
);

-- Test 2: Schedule a medium-priority callback
CALL schedule_customer_callback(
    'Ashley Brown',
    'Follow up on technical support issue',
    '2025-10-07',
    'MEDIUM'
);

-- Test 3: Schedule a low-priority callback
CALL schedule_customer_callback(
    'Emily Davis',
    'General account review',
    '2025-10-09',
    'LOW'
);

-- ============================================
-- 4. VIEW SCHEDULED CALLBACKS
-- ============================================

-- View all pending callbacks
SELECT 
    CALLBACK_ID,
    CUSTOMER_NAME,
    CUSTOMER_SEGMENT,
    PRIORITY,
    SCHEDULED_DATE,
    TO_VARCHAR(SCHEDULED_TIME, 'HH24:MI') as scheduled_time,
    ASSIGNED_AGENT,
    CALLBACK_REASON,
    STATUS,
    CREATED_AT
FROM CALLBACK_QUEUE
WHERE STATUS = 'PENDING'
ORDER BY 
    CASE PRIORITY 
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        ELSE 3
    END,
    SCHEDULED_DATE,
    SCHEDULED_TIME;

-- ============================================
-- 5. ANALYTICS ON CALLBACK QUEUE
-- ============================================

-- Callback summary by priority
SELECT 
    PRIORITY,
    COUNT(*) as callback_count,
    SUM(MONTHLY_PLAN_VALUE) as total_revenue_in_queue,
    MIN(SCHEDULED_DATE) as earliest_callback,
    COUNT(DISTINCT ASSIGNED_AGENT) as agents_assigned
FROM CALLBACK_QUEUE
WHERE STATUS = 'PENDING'
GROUP BY PRIORITY
ORDER BY 
    CASE PRIORITY 
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        ELSE 3
    END;

-- Callbacks by customer segment
SELECT 
    CUSTOMER_SEGMENT,
    COUNT(*) as callback_count,
    AVG(MONTHLY_PLAN_VALUE) as avg_customer_value
FROM CALLBACK_QUEUE
WHERE STATUS = 'PENDING'
GROUP BY CUSTOMER_SEGMENT
ORDER BY avg_customer_value DESC;

-- ============================================
-- 6. HELPER PROCEDURE: Bulk Schedule from Query
-- ============================================

-- This procedure can schedule callbacks for multiple customers at once
CREATE OR REPLACE PROCEDURE bulk_schedule_callbacks_for_at_risk_customers(
    DAYS_TO_LOOKBACK NUMBER DEFAULT 30,
    PRIORITY_INPUT VARCHAR DEFAULT 'HIGH'
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    customers_scheduled NUMBER := 0;
BEGIN
    -- Schedule callbacks for customers with negative sentiment and unresolved issues
    INSERT INTO CALLBACK_QUEUE (
        CUSTOMER_NAME,
        CALLBACK_REASON,
        PRIORITY,
        SCHEDULED_DATE,
        SCHEDULED_TIME,
        ASSIGNED_AGENT,
        CUSTOMER_SEGMENT,
        MONTHLY_PLAN_VALUE,
        STATUS,
        NOTES
    )
    SELECT DISTINCT
        cp.CUSTOMER_NAME,
        'Multiple negative interactions detected - retention risk' as CALLBACK_REASON,
        :PRIORITY_INPUT as PRIORITY,
        DATEADD(day, 1, CURRENT_DATE()) as SCHEDULED_DATE,
        '10:00:00'::TIME as SCHEDULED_TIME,
        (SELECT AGENT_NAME FROM AI_TRANSCRIBED_CALLS_AI_GENERATED 
         WHERE AGENT_PERFORMANCE_SCORE >= 9 
         ORDER BY RANDOM() LIMIT 1) as ASSIGNED_AGENT,
        cp.CUSTOMER_SEGMENT,
        cp.MONTHLY_PLAN_VALUE,
        'PENDING' as STATUS,
        'Bulk scheduled by Cortex Agent - retention campaign'
    FROM AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE cp
    JOIN AI_TRANSCRIBED_CALLS_AI_GENERATED cc ON cp.CUSTOMER_NAME = cc.CUSTOMER_NAME
    WHERE cc.SENTIMENT_CATEGORY = 'NEGATIVE'
        AND cc.ANALYSIS_TIMESTAMP >= DATEADD(day, -:DAYS_TO_LOOKBACK, CURRENT_DATE())
        AND cp.ACCOUNT_STATUS = 'Active'
        AND cp.CUSTOMER_NAME NOT IN (SELECT CUSTOMER_NAME FROM CALLBACK_QUEUE WHERE STATUS = 'PENDING')
    GROUP BY cp.CUSTOMER_NAME, cp.CUSTOMER_SEGMENT, cp.MONTHLY_PLAN_VALUE
    HAVING COUNT(cc.CALL_ID) >= 2;
    
    SET customers_scheduled = SQLROWCOUNT;
    
    RETURN 'Successfully scheduled ' || :customers_scheduled || 
           ' callbacks for at-risk customers with priority: ' || :PRIORITY_INPUT;
END;
$$;

-- Test bulk scheduling
-- CALL bulk_schedule_callbacks_for_at_risk_customers(30, 'HIGH');

-- ============================================
-- 7. GRANT PERMISSIONS
-- ============================================

-- Grant execute permission to agent role (replace with your actual role)
-- GRANT USAGE ON PROCEDURE schedule_customer_callback(VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO ROLE AGENT_ROLE;
-- GRANT USAGE ON PROCEDURE bulk_schedule_callbacks_for_at_risk_customers(NUMBER, VARCHAR) TO ROLE AGENT_ROLE;

-- ============================================
-- 8. VERIFICATION
-- ============================================

-- Show created objects
SHOW TABLES LIKE 'CALLBACK_QUEUE';
SHOW PROCEDURES LIKE 'schedule_customer_callback';

-- Check callback queue
SELECT 
    COUNT(*) as total_callbacks,
    SUM(CASE WHEN STATUS = 'PENDING' THEN 1 ELSE 0 END) as pending_callbacks,
    SUM(CASE WHEN PRIORITY = 'HIGH' THEN 1 ELSE 0 END) as high_priority_callbacks
FROM CALLBACK_QUEUE;

SELECT '✓ Custom tool created successfully!' as status,
       '  → Table: CALLBACK_QUEUE' as detail1,
       '  → Procedure: schedule_customer_callback' as detail2,
       '  → Bulk procedure: bulk_schedule_callbacks_for_at_risk_customers' as detail3,
       '  → Ready to add to Cortex Agent!' as next_step;

-- ============================================
-- EXAMPLE AGENT QUERIES (After Adding to Agent)
-- ============================================

-- Single callback:
-- "Schedule a callback for David Thompson tomorrow at 2pm regarding his billing issue"
-- "Schedule a high-priority callback for Robert Kim about his unresolved technical problem"

-- Bulk callbacks:
-- "Schedule callbacks for all customers with multiple negative calls in the last 30 days"
-- "Create callback tasks for Premium customers who had escalations this week"

-- Query callbacks:
-- "Show me all pending high-priority callbacks"
-- "Who is scheduled for callbacks tomorrow?"
-- "How many callbacks do we have queued by priority?"
