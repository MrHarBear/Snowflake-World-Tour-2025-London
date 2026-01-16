# 🎯 Snowflake World Tour 2025 London - Call Center Intelligence Demo

## "What's New: Snowflake Intelligence and No-Code Agentic AI"

> **Transform unstructured call center data into conversational insights—no code required, fully governed, instantly accessible.**

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [High-Level Architecture](#high-level-architecture)
4. [Data Flow & Script Relationships](#data-flow--script-relationships)
5. [Audio Files (Optional Transcription)](#audio-files-optional-transcription)
6. [Data Assets](#data-assets)
7. [Setup Instructions](#setup-instructions)
8. [Utility Scripts](#utility-scripts)
9. [Demo Guide](#demo-guide)
10. [Key Features Demonstrated](#key-features-demonstrated)
11. [Business Value](#business-value)

---

## 🎯 OVERVIEW

### Session Abstract
*"What if you could turn all of your company's data into a single, intelligent conversation? That's the promise of agentic AI. In this session, you'll see how to create and deploy a no-code agentic AI solution directly within Snowflake Intelligence. Get ready for a live demo that proves you can make critical insights instantly accessible to everyone, with a simple, conversational interface. No more sifting through dashboards. Just ask your data a question and get an answer you could trust with Snowflake Intelligence."*

### Demo Scenario
**Call Center Analytics**: 500 customer service calls with transcripts, parsed and analyzed with AI, combined with 418 customer demographic profiles. Business users can ask natural language questions to uncover insights about:
- Customer satisfaction trends by region
- Agent performance and coaching opportunities
- Churn risk identification
- Issue resolution effectiveness
- Revenue impact analysis

### Key Technologies
- **Cortex Analyst**: Text-to-SQL for structured data analysis
- **Cortex Search**: Semantic search over unstructured call transcripts
- **Snowflake Intelligence**: No-code AI agent interface
- **Semantic Model**: Business context and verified queries
- **RBAC & Governance**: Built-in access controls

---

## 📁 PROJECT STRUCTURE

```
Snowflake World Tour 2025 London/
│
├── 📋 README.md                          ← This file - start here
├── 📋 START_HERE.md                      ← Quick setup checklist
│
├── 📂 audio/  🎵                         ← Original call recordings
│   └── CALL_20250728_*.mp3              (52 audio files for AI_TRANSCRIBE)
│
├── 📂 data/                              ← All data files
│   ├── raw/                              ← Original source data (archive)
│   ├── generated/                        ← Generated data (backup)
│   └── final/  ⭐                        ← USE THESE FILES
│       ├── FINAL_TABLE_COMPLETE.csv      (500 calls - LOAD TO SNOWFLAKE)
│       ├── CUSTOMER_PROFILE_COMPLETE.csv (418 customers - LOAD TO SNOWFLAKE)
│       └── call_center_semantic_model_ENHANCED.yaml (Semantic model)
│
├── 📂 docs/                              ← Documentation & guides
│   ├── 01_SETUP_GUIDE.md                 (Complete setup instructions)
│   ├── 02_PROJECT_PLAN.md                (Project overview & components)
│   ├── 03_DEMO_SCRIPT_FINAL.md           (7-8 min presentation script)
│   └── PLANNING_AND_RESPONSE_INSTRUCTIONS.md (Agent configuration)
│
├── 📂 notebooks/  📓                     ← Snowflake Notebooks (interactive demos)
│   ├── 01_AI_TRANSCRIBE_DEMO.ipynb       (Audio → Text → Insights demo)
│   └── 02_CORTEX_ANALYST_SETUP.ipynb     (Semantic model & search setup)
│
├── 📂 scripts/                           ← Python utilities
│   ├── generate_call_data.py             (Created 448 calls)
│   ├── generate_customer_profiles.py     (Created 418 profiles)
│   └── verify_data_alignment.py          (Verify data quality)
│
├── 📂 sql/                               ← Snowflake setup scripts
│   ├── 01_setup_database.sql             (Run 1st: Database setup)
│   ├── 02_create_tables_and_load.sql     (Run 2nd: Tables & data)
│   ├── 03_create_cortex_search.sql       (Run 3rd: Search services)
│   ├── 04_verify_and_test.sql            (Run 4th: Verification)
│   ├── 05_create_custom_tool.sql         (Run 5th: Custom callback tool)
│   ├── 06_cleanup.sql                    (Optional: Remove all assets)
│   └── 07_create_agent.sql               (Run 7th: Create Intelligence Agent)
│
├── 📂 Streamlit App/  📊                 ← Visual analytics dashboard
│   └── CALL_CENTER_ANALYTICS_APP.py      (Streamlit in Snowflake app)
│
└── 📂 Reference/                         ← Original materials
    ├── Original call data                (Original 52 transcribed calls)
    └── Presentation materials            (Jeff's slides & transcript)
```

**See [`START_HERE.md`](START_HERE.md) for a quick setup checklist.**

---

## 🏗️ HIGH-LEVEL ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                  SNOWFLAKE INTELLIGENCE                     │
│                  (No-Code AI Agent UI)                      │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
┌───────▼───────┐        ┌────────▼──────────┐
│ CORTEX        │        │ CORTEX SEARCH     │
│ ANALYST       │        │ (Unstructured)    │
│ (Structured)  │        │                   │
└───────┬───────┘        └────────┬──────────┘
        │                         │
┌───────▼─────────────────────────▼──────────┐
│         SEMANTIC MODEL (YAML)              │
│  • Business synonyms                       │
│  • Metrics & Filters                       │
│  • Verified Queries                        │
│  • Custom Instructions                     │
└───────┬────────────────────────────────────┘
        │
┌───────▼──────────────────────────────────────┐
│              DATA LAYER                      │
│                                              │
│  ┌─────────────────┐   ┌──────────────────┐ │
│  │ CALL_CENTER     │   │ CUSTOMER         │ │
│  │ DATA            │   │ PROFILE          │ │
│  │ • 500 calls     │◄──┤ • Demographics   │ │
│  │ • Transcripts   │   │ • Geography      │ │
│  │ • Sentiment     │   │ • Account info   │ │
│  │ • Agent metrics │   │ • LTV            │ │
│  └─────────────────┘   └──────────────────┘ │
└──────────────────────────────────────────────┘
```

---

## 🔄 DATA FLOW & SCRIPT RELATIONSHIPS

### End-to-End Pipeline

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        AUDIO TRANSCRIPTION (Optional)                         │
│                   📓 See: notebooks/01_AI_TRANSCRIBE_DEMO.ipynb               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📂 audio/                                                                   │
│  └── 52 MP3 files ─────────► Upload to Snowflake Stage                       │
│      (CALL_20250728_*.mp3)        │                                          │
│                                   ▼                                          │
│                           SNOWFLAKE_CORTEX.AI_TRANSCRIBE()                   │
│                                   │  • Converts audio → text transcripts     │
│                                   │  • Extracts sentiment, intent, summary   │
│                                   ▼                                          │
│                           AI_COMPLETE(), SENTIMENT(), AI_CLASSIFY()          │
│                                   │  • Structures unstructured data          │
│                                   ▼                                          │
│                           comprehensive_call_analysis table                  │
│                                                                              │
│  ⚠️  Note: This step is OPTIONAL. Pre-transcribed data is in data/final/    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                           DATA PREPARATION (Local)                            │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📂 Reference/                    📂 scripts/                                │
│  └── Original 52 calls    ──────► generate_call_data.py                      │
│      (transcribed)                │  • Adds 448 synthetic calls              │
│                                   │  • Maintains data distribution           │
│                                   ▼                                          │
│                           generate_customer_profiles.py                      │
│                                   │  • Creates 418 customer profiles         │
│                                   │  • Links to CUSTOMER_NAME                │
│                                   ▼                                          │
│                           verify_data_alignment.py                           │
│                                   │  • Validates referential integrity       │
│                                   ▼                                          │
│  📂 data/final/                                                              │
│  ├── FINAL_TABLE_COMPLETE.csv          (500 rows)                            │
│  ├── CUSTOMER_PROFILE_COMPLETE.csv     (418 rows)                            │
│  └── call_center_semantic_model_ENHANCED.yaml                                │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE DEPLOYMENT (Cloud)                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  SQL SCRIPT EXECUTION ORDER:                                                 │
│                                                                              │
│  ┌─────────────────────────┐                                                 │
│  │ 01_setup_database.sql   │ Creates: DATABASE, SCHEMA, FILE_FORMAT, STAGE   │
│  └───────────┬─────────────┘                                                 │
│              ▼                                                               │
│  ┌─────────────────────────────┐                                             │
│  │ 02_create_tables_and_load   │ Creates: AI_TRANSCRIBED_CALLS_AI_GENERATED  │
│  │          .sql               │          AI_TRANSCRIBED_..._CUSTOMER_PROFILE │
│  └───────────┬─────────────────┘          (Loads data from stage)            │
│              ▼                                                               │
│  ┌─────────────────────────────┐                                             │
│  │ 03_create_cortex_search.sql │ Creates: SWT2025_call_transcript_search     │
│  │                             │          SWT2025_customer_name_search       │
│  └───────────┬─────────────────┘          SWT2025_agent_name_search          │
│              ▼                                                               │
│  ┌─────────────────────────────┐                                             │
│  │ 04_verify_and_test.sql      │ Validates: Object existence, row counts,    │
│  │                             │            search functionality             │
│  └───────────┬─────────────────┘                                             │
│              ▼                                                               │
│  ┌─────────────────────────────┐                                             │
│  │ 05_create_custom_tool.sql   │ Creates: CALLBACK_QUEUE table               │
│  │                             │          schedule_customer_callback proc    │
│  └───────────┬─────────────────┘                                             │
│              ▼                                                               │
│  ┌─────────────────────────────┐                                             │
│  │ 07_create_agent.sql         │ Creates: CALL_CENTRE_AGENT_SWT2025          │
│  │                             │          (with tools & instructions)        │
│  └─────────────────────────────┘                                             │
│                                                                              │
│  ┌─────────────────────────────┐                                             │
│  │ 06_cleanup.sql              │ OPTIONAL: Drops all created assets          │
│  └─────────────────────────────┘                                             │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Object Dependency Graph

```
CALL_CENTRE_AGENT_SWT2025 (Snowflake Intelligence Agent)
├── Tool: Cortex Analyst
│   └── SWT2025_CALL_CENTER_SEMANTIC_MODEL_ENHANCED (Semantic View)
│       └── AI_TRANSCRIBED_CALLS_AI_GENERATED (Table, 500 rows)
│       └── AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE (Table, 418 rows)
│
├── Tool: Cortex Search
│   └── SWT2025_call_transcript_search (Search Service)
│       └── AI_TRANSCRIBED_CALLS_AI_GENERATED (Source Table)
│
└── Tool: Custom Procedure
    └── schedule_customer_callback (Stored Procedure)
        └── CALLBACK_QUEUE (Table for callback requests)
        └── AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE (Lookup table)
```

### Data Relationships

```
AI_TRANSCRIBED_CALLS_AI_GENERATED        AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE
┌────────────────────────────────┐       ┌──────────────────────────────────────────────┐
│ CALL_ID (PK)                   │       │ CUSTOMER_ID (PK)                             │
│ CUSTOMER_NAME ─────────────────┼──────►│ CUSTOMER_NAME (Unique, FK)                   │
│ AGENT_NAME                     │       │ EMAIL, PHONE, STATE, REGION                  │
│ TRANSCRIPT_TEXT                │       │ CUSTOMER_SEGMENT (Basic/Premium/Enterprise)  │
│ SENTIMENT_SCORE/CATEGORY       │       │ MONTHLY_PLAN_VALUE, LIFETIME_VALUE           │
│ CALL_SUMMARY, CALL_CLASSIFICATION      │ CUSTOMER_SINCE, ACCOUNT_STATUS               │
│ AGENT_PERFORMANCE_SCORE        │       └──────────────────────────────────────────────┘
│ PRIMARY_INTENT, URGENCY_LEVEL  │
│ ISSUE_RESOLVED, ESCALATION_REQUIRED    CALLBACK_QUEUE
│ CUSTOMER_SATISFACTION          │       ┌──────────────────────────────────────────────┐
└────────────────────────────────┘       │ CALLBACK_ID (PK, Auto)                       │
                                         │ CUSTOMER_NAME ───────────────────────────────┘
                                         │ ASSIGNED_AGENT
                                         │ PRIORITY, SCHEDULED_DATE/TIME
                                         │ CUSTOMER_SEGMENT, STATUS
                                         └──────────────────────────────────────────────┘
```

---

## 🎵 AUDIO FILES (Optional Transcription)

The `audio/` folder contains **52 original MP3 call recordings** that can be transcribed using Snowflake's `AI_TRANSCRIBE` function.

### Files Included

| Pattern | Count | Size | Description |
|---------|-------|------|-------------|
| `CALL_20250728_*.mp3` | 52 files | ~42MB total | Original call center recordings |

### Using AI_TRANSCRIBE (Optional)

If you want to run the full transcription pipeline yourself instead of using the pre-transcribed data:

**Step 1: Upload Audio Files to Stage**

```bash
# Upload all audio files to Snowflake stage
cd audio/
for file in *.mp3; do
  snow stage copy "$file" @CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.call_center_stage -c snowflake_cursor_conn
done
```

**Step 2: Create Transcription Table**

```sql
-- Create table for raw transcriptions
CREATE TABLE IF NOT EXISTS AI_TRANSCRIBED_CALLS (
    FILENAME VARCHAR(500),
    TRANSCRIPT VARIANT,
    TRANSCRIPTION_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Transcribe audio files using AI_TRANSCRIBE
INSERT INTO AI_TRANSCRIBED_CALLS (FILENAME, TRANSCRIPT)
SELECT 
    RELATIVE_PATH as FILENAME,
    SNOWFLAKE.CORTEX.AI_TRANSCRIBE(
        BUILD_SCOPED_FILE_URL(@call_center_stage, RELATIVE_PATH)
    ) as TRANSCRIPT
FROM DIRECTORY(@call_center_stage)
WHERE RELATIVE_PATH LIKE '%.mp3';
```

**Step 3: Extract Transcript Text**

```sql
-- Extract the text from the VARIANT column
SELECT 
    FILENAME,
    TRANSCRIPT:text::VARCHAR as TRANSCRIPT_TEXT,
    TRANSCRIPT:language::VARCHAR as DETECTED_LANGUAGE
FROM AI_TRANSCRIBED_CALLS;
```

> **Note:** The `data/final/FINAL_TABLE_COMPLETE.csv` already contains the transcribed and analyzed data from these 52 audio files plus 448 generated calls. You only need to run transcription if you want to demonstrate the full audio-to-insight pipeline.

---

## 📊 DATA ASSETS

### 1. **AI_TRANSCRIBED_CALLS_AI_GENERATED** (Call Center Data)
**500 rows** (52 original + 448 generated)

| Column | Type | Description |
|--------|------|-------------|
| `CALL_ID` | VARCHAR | Unique call identifier (e.g., CALL_20250728_10050) |
| `TRANSCRIPT_TEXT` | VARCHAR | Full call transcript (unstructured) |
| `WORD_COUNT` | NUMBER | Length of transcript |
| `SENTIMENT_SCORE` | FLOAT | AI sentiment (-1 to +1) |
| `SENTIMENT_CATEGORY` | VARCHAR | POSITIVE, NEGATIVE, NEUTRAL |
| `CUSTOMER_SATISFACTION` | VARCHAR | satisfied, neutral, dissatisfied |
| `AGENT_PERFORMANCE_SCORE` | NUMBER | 0-10 rating |
| `PRIMARY_INTENT` | VARCHAR | billing, technical_support, cancellation, etc. |
| `ISSUE_RESOLVED` | VARCHAR | yes/no |
| `ESCALATION_REQUIRED` | VARCHAR | yes/no |
| `URGENCY_LEVEL` | VARCHAR | low, medium, high |
| `CALL_TYPE` | VARCHAR | inbound, outbound |
| `CUSTOMER_NAME` | VARCHAR | Customer name (joins to customer profile table) |
| `AGENT_NAME` | VARCHAR | Agent handling the call |
| `ANALYSIS_TIMESTAMP` | TIMESTAMP | Call date/time |

**Key Statistics:**
- **Sentiment Distribution**: 35% Positive, 42% Neutral, 23% Negative
- **Intent Distribution**: Billing (16%), Technical (15%), Cancellation (20%), Information (17%), Complaint (14%), Compliment (18%)
- **Resolution Rate**: ~68% of calls resolved
- **Escalation Rate**: ~18% require escalation

### 2. **AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE** (Customer Demographics)
**418 unique customers** (matched to calls)

| Column | Type | Description |
|--------|------|-------------|
| `CUSTOMER_ID` | NUMBER | Unique customer ID |
| `CUSTOMER_NAME` | VARCHAR | Full name (joins to call data table) |
| `REGION` | VARCHAR | West, South, Northeast, Southeast, Midwest |
| `STATE` | VARCHAR | US state |
| `CITY` | VARCHAR | City |
| `ACCOUNT_TYPE` | VARCHAR | Residential, Business |
| `CUSTOMER_SEGMENT` | VARCHAR | Individual, Premium, Enterprise, Mid-Market, Senior |
| `ACCOUNT_STATUS` | VARCHAR | Active, Cancelled, Churned |
| `MONTHLY_PLAN_VALUE` | FLOAT | Monthly recurring revenue (MRR) |
| `LIFETIME_VALUE` | FLOAT | Total customer lifetime value |
| `CUSTOMER_SINCE` | DATE | Account creation date |
| `AGE_GROUP` | VARCHAR | Age bracket |
| `INDUSTRY` | VARCHAR | For business customers |

**Key Statistics:**
- **Geographic Distribution**: West (40%), South (15%), Northeast (20%), Southeast (15%), Midwest (10%)
- **Customer Segments**: Individual (50%), Premium (30%), Enterprise (10%), Mid-Market (7%), Senior (3%)
- **Average LTV**: $4,200
- **Average Tenure**: 2.3 years

### 3. **CORTEX SEARCH SERVICES**

Three search services enable semantic queries:

1. **call_transcript_search**: Main transcript search with 12 filterable attributes
2. **customer_name_search**: Fuzzy name matching
3. **agent_name_search**: Fuzzy agent name matching

---

## 🚀 SETUP INSTRUCTIONS

### Prerequisites
- Snowflake account with Cortex features enabled
- Role with privileges:
  - `CREATE DATABASE`, `CREATE SCHEMA`
  - `CREATE CORTEX SEARCH SERVICE`
  - `USAGE` on warehouse
  - Cortex LLM function privileges
- Snowflake Intelligence access (currently in preview)

### Step 1: Prepare Your Environment

```bash
# Clone or download the project
cd "Snowflake World Tour 2025 London"

# Verify data files exist
ls data/final/FINAL_TABLE_COMPLETE.csv      # 500 call records
ls data/final/CUSTOMER_PROFILE_COMPLETE.csv # 418 customer profiles
ls data/final/call_center_semantic_model_ENHANCED.yaml
```

### Step 2: Execute SQL Scripts (In Order)

**Edit the warehouse name in each script to match your environment:**

```sql
SET WAREHOUSE_NAME = 'COMPUTE_WH';  -- Change to your warehouse
```

**Execute scripts in numbered order via Snowsight or SnowCLI:**

```bash
# Using SnowCLI
snow sql -c your_connection -f sql/01_setup_database.sql
snow sql -c your_connection -f sql/02_create_tables_and_load.sql
snow sql -c your_connection -f sql/03_create_cortex_search.sql
snow sql -c your_connection -f sql/04_verify_and_test.sql
snow sql -c your_connection -f sql/05_create_custom_tool.sql
snow sql -c your_connection -f sql/07_create_agent.sql
```

### Step 3: Upload Data to Stage

```bash
# Upload CSV files to the internal stage
snow stage copy data/final/FINAL_TABLE_COMPLETE.csv @CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.call_center_stage
snow stage copy data/final/CUSTOMER_PROFILE_COMPLETE.csv @CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.call_center_stage
```

### Step 4: Upload Semantic Model

```bash
# Upload semantic model YAML
snow stage copy data/final/call_center_semantic_model_ENHANCED.yaml @CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.call_center_stage
```

Then in Snowsight:
1. Navigate to **Data → Databases → CALL_CENTER_ANALYTICS → AUDIO_PROCESSING**
2. Click **"+ Create"** → **"Semantic View"**
3. Reference the uploaded YAML file

### Step 5: Verify Agent Creation

The `07_create_agent.sql` script creates the agent automatically. Verify:

```sql
SHOW AGENTS IN DATABASE SNOWFLAKE_INTELLIGENCE LIKE 'CALL_CENTRE_AGENT_SWT2025';
DESCRIBE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.CALL_CENTRE_AGENT_SWT2025;
```

**Test the agent** by asking: "What's our customer satisfaction rate?"

### Step 6: Pre-Demo Testing

Run these test queries to ensure everything works:

```
✓ "What's our overall customer satisfaction rate?"
✓ "Compare satisfaction across all regions"
✓ "Why is the West region underperforming?"
✓ "Show me high-value customers at risk"
✓ "Which agents need coaching?"
✓ "Find calls mentioning billing errors"
```

---

## 🔧 UTILITY SCRIPTS

The `scripts/` folder contains Python utilities used during data preparation:

### Python Scripts (Already Run)

| Script | Purpose | Output |
|--------|---------|--------|
| `generate_call_data.py` | Generates 448 synthetic call records from the original 52 | `FINAL_TABLE_COMPLETE.csv` |
| `generate_customer_profiles.py` | Creates 418 customer profiles matching call data | `CUSTOMER_PROFILE_COMPLETE.csv` |
| `verify_data_alignment.py` | Validates referential integrity between calls and customers | Console output |
| `test_sql_scripts.py` | Validates SQL scripts syntax before deployment | Test results |

**Note:** These scripts have already been run. The output files are in `data/final/`. You only need to run these if regenerating data.

### SQL Scripts

| Script | What It Creates | Dependencies |
|--------|-----------------|--------------|
| `01_setup_database.sql` | Database, Schema, File Format, Stage | None |
| `02_create_tables_and_load.sql` | Tables: `AI_TRANSCRIBED_CALLS_AI_GENERATED`, Customer Profile | Script 01 |
| `03_create_cortex_search.sql` | 3 Cortex Search services | Script 02 |
| `04_verify_and_test.sql` | Verification queries (no new objects) | Scripts 01-03 |
| `05_create_custom_tool.sql` | `CALLBACK_QUEUE` table, `schedule_customer_callback` procedure | Script 02 |
| `06_cleanup.sql` | Drops all demo assets | None (run to tear down) |
| `07_create_agent.sql` | `CALL_CENTRE_AGENT_SWT2025` agent | Scripts 01-05, Semantic Model |

### Snowflake Notebooks (Interactive Demos)

| Notebook | Purpose | When to Use |
|----------|---------|-------------|
| `01_AI_TRANSCRIBE_DEMO.ipynb` | Shows audio → text → insights pipeline | Live demos showing "how it works" |
| `02_CORTEX_ANALYST_SETUP.ipynb` | Builds semantic model & search service | Technical deep-dives |

**To use:** Upload to Snowflake Notebooks via Snowsight → Projects → Notebooks → Import.

### Streamlit Dashboard

| App | Purpose |
|-----|---------|
| `CALL_CENTER_ANALYTICS_APP.py` | Visual analytics dashboard for call center KPIs |

**To deploy:** Snowsight → Streamlit → Create App → Upload file → Select `CALL_CENTER_ANALYTICS` database.

---

## 🎬 DEMO GUIDE

See **[docs/03_DEMO_SCRIPT_FINAL.md](docs/03_DEMO_SCRIPT_FINAL.md)** for the complete 7-8 minute demo walkthrough.

### Quick Demo Flow:
1. **Context** (1 min): Show the data challenge
2. **Agent Demo** (4 min): Live natural language queries
3. **Trust & Governance** (1.5 min): Verified queries, data sources
4. **Setup Tour** (1.5 min): Show semantic model, Cortex Search

### Key Questions to Demo:
- ✅ Simple: "What's our customer satisfaction rate?"
- ✅ Cross-dimensional: "Compare satisfaction across regions"
- ⭐ **WOW Moment**: "Why is West region underperforming?"
- ✅ Actionable: "Show me customers at risk of churning"

---

## ✨ KEY FEATURES DEMONSTRATED

### 1. **Cortex Analyst** (Structured Data)
- Text-to-SQL generation with 90%+ accuracy
- Automatic joins across tables (calls ← customer profiles)
- Business synonym understanding ("csat" = "customer satisfaction")
- Complex metric calculations (resolution rate, escalation rate)

### 2. **Cortex Search** (Unstructured Data)
- Semantic search over 500 call transcripts
- Context-aware filtering (sentiment + intent + region)
- Fuzzy name matching
- Vector embeddings with `snowflake-arctic-embed-l-v2.0`

### 3. **Agentic Reasoning**
- Multi-step investigation (autonomous breakdown of "why" questions)
- Tool orchestration (Analyst + Search + reasoning)
- Planning and reflection
- Synthesized insights from multiple sources

### 4. **Semantic Model**
- Business-friendly synonyms and definitions
- 8 pre-defined metrics (resolution_rate, escalation_rate, etc.)
- 7 common filters (negative_sentiment, west_region, etc.)
- 7 verified queries approved by data team

### 5. **Trust & Governance**
- Verified query badges (green shields)
- Data source transparency
- RBAC integration
- Row-level security support
- Explainable AI (show SQL, show reasoning)

### 6. **No-Code Setup**
- Semantic model via YAML
- Agent creation via UI
- Minutes to deploy, not months

---

## 💼 BUSINESS VALUE

### Metrics That Matter

| Traditional Approach | Snowflake Intelligence |
|---------------------|------------------------|
| **Time to Insight**: Days-weeks | **Seconds** |
| **Technical Skill**: SQL, BI tools | **Natural language** |
| **Setup Time**: 3-6 months | **<30 minutes** |
| **User Adoption**: 10-20% | **80%+** (conversational) |
| **Data Coverage**: Structured only | **Structured + Unstructured** |

### ROI Drivers

1. **Democratize Data**: Business users get self-service analytics
2. **Unlock Dark Data**: 500 call transcripts → actionable insights
3. **Reduce Data Team Bottleneck**: Ad-hoc questions answered instantly
4. **Faster Decisions**: From question to action in seconds
5. **Trust & Compliance**: Governed access, verified answers

### Use Case Extensions

Beyond call centers, this pattern applies to:
- **Patient interactions** (healthcare)
- **Support tickets** (IT, SaaS)
- **Sales conversations** (CRM notes)
- **Compliance monitoring** (financial services)
- **Customer feedback** (surveys, reviews)

---

## 🎯 SUCCESS CRITERIA

**Audience should leave thinking:**
1. ✅ "We have similar unstructured data we could unlock"
2. ✅ "This doesn't require an army of data engineers"
3. ✅ "The AI is actually reasoning, not just searching"
4. ✅ "Snowflake takes governance seriously"
5. ✅ "I want to try this with our data"

---

## 📚 RESOURCES

### Documentation
- [Cortex Analyst Semantic Model Spec](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model-spec)
- [Cortex Search Service](https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search)
- [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-intelligence)

### Reference Materials
- Original presentation: `Reference/WN214B_SnowflakeIntelligence_V1.docx.md`
- Session notes: `Reference/[SWT 25] - WN214B – What's New_ Snowflake Intelligence.txt`

### Support
- Snowflake Community: [community.snowflake.com](https://community.snowflake.com)
- Snowflake University: [learn.snowflake.com](https://learn.snowflake.com)

---

## 🎉 NEXT STEPS

1. **Test the demo** with your team
2. **Customize questions** for your audience
3. **Practice the flow** (timing is key!)
4. **Prepare backup slides** (in case of demo gremlins)
5. **Have fun!** This is genuinely cool technology

---

## 📝 NOTES & TIPS

### Demo Tips
- ⏱️ **Timing**: Practice to stay within 7-8 minutes
- 🎯 **Focus**: Spend most time on the "WOW" question (#3)
- 🛡️ **Safety**: Test everything 30 mins before presentation
- 📸 **Backup**: Screenshots in case of connectivity issues
- 🎤 **Energy**: Be enthusiastic—this is genuinely impressive!

### Common Pitfalls to Avoid
- ❌ Don't rush the autonomous reasoning moment (let it show)
- ❌ Don't get lost in technical details (audience is business-focused)
- ❌ Don't skip the governance piece (trust matters)
- ❌ Don't forget to pre-warm the agent (run test query beforehand)

### Customization Ideas
- Replace "call center" with your industry terminology
- Add industry-specific questions
- Show integration with Slack/Teams (if available)
- Demonstrate mobile access via ai.snowflake.com

---

## 🏆 THE BIG IDEA

> **"What if every person in your organization could ask any question of any data, and get trusted answers in seconds? That's not the future. That's Snowflake Intelligence today."**

---

**Questions? Issues? Need help?**  
Contact the Snowflake team or your account representative.

**Good luck with your presentation! 🚀**

---

*Last updated: October 2, 2025*  
*Prepared for: Snowflake World Tour 2025 - London*

