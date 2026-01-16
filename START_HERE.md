# 👋 START HERE - Snowflake World Tour London 2025

## Your 3-Document Guide to Success

---

## 📚 READ THESE IN ORDER:

### **1. Setup Guide** → [docs/01_SETUP_GUIDE.md](docs/01_SETUP_GUIDE.md)
**When:** Before building anything  
**Time:** 90 minutes to complete setup  
**What:** Step-by-step instructions to build the entire demo from scratch

---

### **2. Project Plan** → [docs/02_PROJECT_PLAN.md](docs/02_PROJECT_PLAN.md)
**When:** To understand what you built and why  
**Time:** 10 minute read  
**What:** Overview of all components, technologies, and business value

---

### **3. Demo Script** → [docs/03_DEMO_SCRIPT_FINAL.md](docs/03_DEMO_SCRIPT_FINAL.md)
**When:** Day of presentation  
**Time:** 7-8 minute performance  
**What:** Your complete stage presentation script with timing and delivery tips

---

## ⚡ THE 3 DEMO QUESTIONS

Copy these for your presentation:

```
1. "Compare customer satisfaction rates across all regions and show me which region needs attention"

2. "Why is the West region underperforming in customer satisfaction? Give me a detailed investigation."

3. "Schedule a high-priority callback for David Thompson tomorrow regarding his unresolved billing issue. Make sure we assign our best agent."
```

---

## 📁 PROJECT FILES

```
Snowflake World Tour 2025 London/
│
├── README.md                    ← Project overview
├── START_HERE.md                ← This file
│
├── data/final/                  ← Load these to Snowflake
│   ├── FINAL_TABLE_COMPLETE.csv
│   ├── CUSTOMER_PROFILE_COMPLETE.csv
│   └── call_center_semantic_model_ENHANCED.yaml
│
├── sql/                         ← Run in order (01 → 02 → 03 → 04 → 05 → 07)
│   ├── 01_setup_database.sql
│   ├── 02_create_tables_and_load.sql
│   ├── 03_create_cortex_search.sql
│   ├── 04_verify_and_test.sql
│   ├── 05_create_custom_tool.sql
│   ├── 06_cleanup.sql           (Optional: removes all assets)
│   └── 07_create_agent.sql      (Creates Intelligence Agent via SQL)
│
└── docs/                        ← Documentation
    ├── 01_SETUP_GUIDE.md                    (How to build)
    ├── 02_PROJECT_PLAN.md                   (What we built)
    ├── 03_DEMO_SCRIPT_FINAL.md              (Stage script)
    └── PLANNING_AND_RESPONSE_INSTRUCTIONS.md (Agent config)
```

---

## ✅ QUICK CHECKLIST

**Setup Complete When:**
- [ ] 500 calls + 418 customers loaded to Snowflake
- [ ] 3 Cortex Search services created and RUNNING
- [ ] Semantic model uploaded
- [ ] Custom callback tool created
- [ ] Intelligence Agent configured with 3 tools
- [ ] Planning and response instructions pasted
- [ ] All 3 demo questions tested

**Demo Ready When:**
- [ ] Demo script reviewed and practiced
- [ ] Backup screenshots taken
- [ ] Browser tabs organized
- [ ] SQL query ready to show CALLBACK_QUEUE table

---

## 🎯 YOUR DEMO IN 3 SENTENCES

1. **Q1** shows instant insights from structured data with auto-generated charts
2. **Q2** shows autonomous multi-step reasoning across structured + unstructured data (the WOW moment)
3. **Q3** shows the agent taking action by scheduling a real callback (proves extensibility)

---

## 🏆 EXPECTED OUTCOME

**Audience leaves thinking:**
- "We have similar data we could unlock"
- "This doesn't require months of work"
- "AI can actually reason and take action"
- "I want to build this for our business"

---

**Everything you need is in this repository. Go build and amaze London!** 🇬🇧🚀







