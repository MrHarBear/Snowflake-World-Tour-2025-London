# 📊 Project Plan - What We Built and Why

## Snowflake World Tour 2025 London Demo

**Goal:** Demonstrate how Snowflake Intelligence transforms unstructured call center data into conversational insights with no code.

---

## 🎯 HIGH-LEVEL OBJECTIVE

**Turn complex call center data into a conversational AI experience that:**
- ✅ Answers questions in natural language
- ✅ Reasons across structured + unstructured data
- ✅ Takes action (schedules callbacks)
- ✅ Requires zero custom code
- ✅ Is fully governed and trustworthy

**Key Message:** From unstructured data to actionable insights through conversation—no dashboards, no SQL, no coding.

---

## 📊 WHAT WE BUILT

### **1. Data Assets** (500 calls, 418 customers)

**Call Center Data:**
- 52 original call transcripts
- 448 AI-generated realistic calls
- Total: 500 customer interactions
- Includes: Transcripts, sentiment, agent performance, resolution status

**Customer Profiles:**
- 418 unique customers (100% join coverage)
- Demographics: Region, state, city, age group
- Account data: Segment, status, tenure
- Revenue: Monthly plan value, lifetime value

**Why this data:**
- Shows enterprise scale (500 calls)
- Realistic scenarios (mix of positive/negative)
- Geographic patterns (West region underperforms)
- Revenue context (quantify business impact)

---

### **2. Cortex Search Services** (3 services)

**Main Service: `SWT2025_call_transcript_search`**
- Indexes 500 call transcripts
- Semantic search with `snowflake-arctic-embed-l-v2.0`
- 11 filterable attributes (sentiment, intent, agent, etc.)
- Enables: "Find calls mentioning billing errors"

**Supporting Services:**
- `SWT2025_customer_name_search` - Fuzzy name matching
- `SWT2025_agent_name_search` - Fuzzy agent matching

**Why:** Unlock unstructured data (call transcripts) for natural language queries

---

### **3. Semantic Model** (ENHANCED)

**File:** `call_center_semantic_model_ENHANCED.yaml`

**Components:**
- 2 logical tables (call_center_data, customer_profile)
- 1 relationship (join on CUSTOMER_NAME)
- 90+ business synonyms ("csat" → "customer satisfaction")
- 15 metrics (resolution_rate, escalation_rate, churn_rate, etc.)
- 10 filters (negative_sentiment, west_region, high_priority, etc.)
- 7 verified queries (pre-approved questions with green shields)
- Custom instructions (business context for AI)

**Why:** Bridges business language and technical schema, enables accurate text-to-SQL

---

### **4. Custom Tool** (Action!)

**Procedure:** `schedule_customer_callback`

**What it does:**
- Writes to CALLBACK_QUEUE table
- Intelligent agent assignment (Premium → senior agents)
- Priority-based scheduling (HIGH → 10am, MEDIUM → 2pm, LOW → 4pm)
- Captures customer context (segment, revenue)

**Why:** Demonstrates agent can take ACTION, not just analyze. Shows infinite extensibility.

---

### **5. Snowflake Intelligence Agent**

**Name:** `CALL_CENTRE_AGENT_SWT2025`

**3 Tools:**
1. Cortex Analyst (structured data queries)
2. Cortex Search (transcript search)
3. Custom callback scheduler (takes action)

**Planning Instructions:** Teaches agent which tool to use when  
**Response Instructions:** Shapes how agent communicates

**Why:** No-code configuration of intelligent, business-ready AI agent

---

## 🎬 THE DEMO STORY

### **Act 1: The Problem**
"500 customer calls. Buried insights. Manual analysis takes weeks."

### **Act 2: The Solution**
"What if you could just ask? [Demo natural language queries]"

### **Act 3: The Magic**
"Watch autonomous investigation" [Why is West underperforming?]

### **Act 4: The Action**
"Not just insights—execution" [Schedule callback demo]

### **Act 5: The Setup**
"Built in 30 minutes with YAML and UI—no code"

---

## 🎯 KEY TECHNOLOGIES DEMONSTRATED

| Technology | Purpose | Demo Moment |
|------------|---------|-------------|
| **Cortex Analyst** | Text-to-SQL for structured data | Q1: Regional comparison |
| **Cortex Search** | Semantic search over transcripts | Q2: Why West underperforming |
| **Agentic Reasoning** | Multi-step autonomous investigation | Q2: Agent breaks down question |
| **Semantic Model** | Business context & verified queries | Green shield badges shown |
| **Custom Tools** | Extend with your business logic | Q3: Schedule callback |
| **Planning Instructions** | Guide tool selection | Q2: Uses multiple tools automatically |
| **Response Instructions** | Shape communication style | Charts auto-generated |
| **No-Code Setup** | YAML + UI configuration | Show semantic model + agent config |

---

## 💼 BUSINESS VALUE

**Traditional Approach:**
- Time to insight: Days/weeks
- Requires: SQL skills, BI tools, data team
- Coverage: Structured data only
- Action: Manual follow-up

**Snowflake Intelligence:**
- Time to insight: Seconds
- Requires: Natural language only
- Coverage: Structured + unstructured
- Action: Automated (via custom tools)

**ROI:** Democratize data, unlock dark data, reduce bottlenecks, faster decisions

---

## 📁 PROJECT STRUCTURE

```
data/
├── final/           ← Load these 3 files to Snowflake
├── generated/       ← Backup of generated data
└── raw/             ← Archive

docs/
├── 01_SETUP_GUIDE.md        ← This file
├── 02_PROJECT_PLAN.md       ← What we built
├── 03_DEMO_SCRIPT_FINAL.md  ← Stage presentation script
└── PLANNING_AND_RESPONSE_INSTRUCTIONS.md ← Copy-paste for agent

sql/
├── 01_setup_database.sql
├── 02_create_tables_and_load.sql
├── 03_create_cortex_search.sql
├── 04_verify_and_test.sql
├── 05_create_custom_tool.sql
├── 06_cleanup.sql              (Optional: removes all assets)
└── 07_create_agent.sql         (Creates Intelligence Agent via SQL)

scripts/
└── [Python data generation scripts - already run]

Reference/
└── [Original presentation materials]
```

---

## ✅ PRE-DEMO CHECKLIST

**Data:**
- [ ] Tables loaded (500 + 418 rows verified)
- [ ] 100% join coverage confirmed

**Services:**
- [ ] 3 Cortex Search services RUNNING
- [ ] Semantic model uploaded
- [ ] Custom tool procedure created

**Agent:**
- [ ] Agent created with 3 tools
- [ ] Planning instructions pasted
- [ ] Response instructions pasted
- [ ] 3 demo questions tested

**Presentation:**
- [ ] Demo script reviewed
- [ ] Screenshots taken as backup
- [ ] Browser tabs organized
- [ ] Font size comfortable for audience

---

**Follow this guide and you'll be demo-ready in 90 minutes!** 🚀



