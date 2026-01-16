# 🚀 Complete Setup Guide - From Zero to Demo

## Snowflake World Tour 2025 London - Call Center Intelligence

**Estimated Time:** 90 minutes  
**Outcome:** Fully functional Snowflake Intelligence Agent ready for demo

---

## 📋 WHAT YOU'LL BUILD

- **500 call center interactions** loaded to Snowflake
- **418 customer profiles** with demographics and revenue data
- **3 Cortex Search services** for semantic transcript search
- **Enhanced semantic model** with metrics, filters, verified queries
- **1 custom tool** that schedules callbacks (takes action!)
- **Snowflake Intelligence Agent** with planning + response instructions

---

## 🎯 YOUR SNOWFLAKE ENVIRONMENT

```
Database: CALL_CENTER_ANALYTICS
Schema: AUDIO_PROCESSING
Warehouse: WH_AISQL_HOL
```

---

## 📂 FILES YOU NEED

**Required (in `data/final/`):**
1. `FINAL_TABLE_COMPLETE.csv` (500 calls - pre-transcribed)
2. `CUSTOMER_PROFILE_COMPLETE.csv` (418 customers)
3. `call_center_semantic_model_ENHANCED.yaml` (semantic model)

**Optional (in `audio/`):**
- 52 MP3 audio files for demonstrating `AI_TRANSCRIBE` function
- Use these if you want to show the full audio-to-insight pipeline

---

## ⚡ SETUP STEPS

### **Step 1: Create File Format and Stage** (5 min)

```bash
snow sql -c snowflake_cursor_conn -f sql/01_setup_database.sql
```

**Creates:**
- CSV file format
- Internal stage: `call_center_stage`

---

### **Step 2: Upload CSV Files to Stage** (5 min)

```bash
cd data/final/

snow stage copy FINAL_TABLE_COMPLETE.csv \
  @CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.call_center_stage --overwrite

snow stage copy CUSTOMER_PROFILE_COMPLETE.csv \
  @CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.call_center_stage --overwrite
```

---

### **Step 3: Create Tables and Load Data** (10 min)

```bash
cd ../..
snow sql -c snowflake_cursor_conn -f sql/02_create_tables_and_load.sql
```

**Creates and loads:**
- `AI_TRANSCRIBED_CALLS_AI_GENERATED` (500 rows)
- `AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE` (418 rows)

**Verify:**
```sql
SELECT COUNT(*) FROM AI_TRANSCRIBED_CALLS_AI_GENERATED;  -- Should be 500
```

---

### **Step 4: Create Cortex Search Services** (15 min - includes indexing)

```bash
snow sql -c snowflake_cursor_conn -f sql/03_create_cortex_search.sql
```

**Creates:**
- `SWT2025_call_transcript_search` (main transcript search)
- `SWT2025_customer_name_search` (fuzzy name matching)
- `SWT2025_agent_name_search` (fuzzy agent matching)

**Wait ~10 minutes for indexing to complete**

---

### **Step 5: Upload Semantic Model** (5 min)

**Via Snowsight UI:**
1. Navigate: Data → CALL_CENTER_ANALYTICS → AUDIO_PROCESSING
2. Click: "+ Create" → "Semantic Model"
3. Upload: `data/final/call_center_semantic_model_ENHANCED.yaml`
4. Name it: `SWT2025_CALL_CENTER_SEMANTIC_MODEL_ENHANCED`

**Should upload successfully** ✅

---

### **Step 6: Create Custom Tool** (5 min)

```bash
snow sql -c snowflake_cursor_conn -f sql/05_create_custom_tool.sql
```

**Creates:**
- `CALLBACK_QUEUE` table
- `schedule_customer_callback` procedure
- Test callbacks (3 examples)

**Verify:**
```sql
SELECT * FROM CALLBACK_QUEUE;  -- Should show test callbacks
```

---

### **Step 7: Create Snowflake Intelligence Agent** (5 min)

**Option A: Via SQL (Recommended)**
```bash
snow sql -c snowflake_cursor_conn -f sql/07_create_agent.sql
```

**Option B: Via Snowsight UI → AI & ML → Agents:**

#### **Basic Info:**
- Name: `CALL_CENTRE_AGENT_SWT2025`
- Display Name: "Call Center Intelligence"

#### **Add Tool #1: Cortex Analyst**
- Semantic View: `SWT2025_CALL_CENTER_SEMANTIC_MODEL_ENHANCED`
- Warehouse: User's default
- Query Timeout: 60 seconds
- Description: "Analyzes structured call center data including customer satisfaction rates, agent performance scores, resolution rates, escalation rates, and revenue metrics. Use for quantitative questions requiring calculations, aggregations, or comparisons."

#### **Add Tool #2: Cortex Search**
- Search Service: `SWT2025_call_transcript_search`
- Max Results: 10
- ID Column: `CALL_ID`
- Title Column: `CALL_SUMMARY`
- Filters: `SENTIMENT_CATEGORY`, `PRIMARY_INTENT`, `CUSTOMER_SATISFACTION`
- Description: "Searches through 500 customer service call transcripts using semantic search. Use when you need to find what customers said, specific issues mentioned, or conversation patterns."

#### **Add Tool #3: Custom Tool**
- Procedure: `schedule_customer_callback`
- Warehouse: User's default
- Query Timeout: 60 seconds
- Parameters:
  1. `customer_name_input` (string, REQUIRED) - Customer's full name
  2. `callback_reason_input` (string, REQUIRED) - Reason for callback
  3. `scheduled_date_input` (string, REQUIRED) - Date in YYYY-MM-DD
  4. `priority_input` (string, OPTIONAL) - HIGH/MEDIUM/LOW
- Description: "Schedules customer callbacks by writing to CALLBACK_QUEUE table. Takes action by creating callback tasks with intelligent agent assignment based on customer segment and priority."

---

### **Step 8: Add Orchestration Instructions** (5 min)

**Copy from:** `docs/PLANNING_AND_RESPONSE_INSTRUCTIONS.md`

#### **Planning Instructions:**
Paste the full planning instructions (teaches agent which tool to use)

#### **Response Instructions:**
Paste the full response instructions (teaches agent how to communicate)

---

### **Step 9: Test the Agent** (15 min)

Test all 3 demo questions:

```
1. "Compare customer satisfaction rates across all regions and show me which region needs attention"
2. "Why is the West region underperforming in customer satisfaction? Give me a detailed investigation."
3. "Schedule a high-priority callback for David Thompson tomorrow regarding his unresolved billing issue"
```

**Verify:**
- Q1: Shows chart, identifies West region
- Q2: Multi-step reasoning visible, uses both tools
- Q3: Callback scheduled, check `SELECT * FROM CALLBACK_QUEUE`

---

### **Step 10: Prepare for Demo** (15 min)

- [ ] Clear test callbacks: `DELETE FROM CALLBACK_QUEUE WHERE NOTES LIKE '%test%'`
- [ ] Take screenshots as backup
- [ ] Open browser tabs: Agent UI, SQL worksheet
- [ ] Disable browser notifications
- [ ] Increase font size for audience viewing
- [ ] Practice the 3 questions
- [ ] Have SQL query ready: `SELECT * FROM CALLBACK_QUEUE WHERE STATUS = 'PENDING'`

---

## ✅ TROUBLESHOOTING

### "YAML won't upload"
- Check: No `verified_at` fields (should be removed)
- Check: No `cortex_search_service` references (should be removed)

### "Cortex Search creation fails"
- Check: ESCALATION_REQUIRED not in ATTRIBUTES (BOOLEAN not supported)
- Check: Warehouse exists: `WH_AISQL_HOL`

### "Custom tool doesn't execute"
- Check: Procedure created: `SHOW PROCEDURES LIKE 'schedule_customer_callback'`
- Check: Test manually: `CALL schedule_customer_callback('Test', 'Test', '2025-10-10', 'HIGH')`

---

## 🎯 SUCCESS CRITERIA

When setup is complete, you should have:
- ✅ 500 calls + 418 customers in Snowflake
- ✅ 3 Cortex Search services (RUNNING status)
- ✅ 1 semantic model uploaded
- ✅ 1 custom tool working
- ✅ 1 Intelligence Agent created
- ✅ All 3 demo questions tested and working

---

**Setup complete? Time to rehearse your demo!** 🎬



