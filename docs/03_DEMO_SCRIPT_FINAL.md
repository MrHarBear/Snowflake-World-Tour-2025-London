# 🎬 FINAL DEMO SCRIPT - Snowflake World Tour London 2025

## "What's New: Snowflake Intelligence and No-Code Agentic AI"

**Duration:** 7-8 minutes  
**Audience:** Business leaders, data practitioners

---

## 🎯 THE 3 QUESTIONS (Your Demo Backbone)

### **Q1:** Compare customer satisfaction rates across all regions
### **Q2:** Why is the West region underperforming in customer satisfaction?
### **Q3:** Schedule a high-priority callback for David Thompson tomorrow regarding his unresolved billing issue

---

## 🎬 COMPLETE DEMO SCRIPT

### **INTRO: The Problem** (45 seconds)

> "Imagine you're a call center director. You have **500 customer service calls**. Rich insights buried in transcripts, sentiment data, customer demographics.
>
> Traditional approach? You'd need:
> - SQL queries for metrics
> - Manual review of transcripts  
> - Data team for every question
> - Days or weeks to get answers
>
> [PAUSE]
>
> What if you could just... **ask**?"

[Open Snowflake Intelligence Agent]

---

### **QUESTION 1: The Warm-Up** (45 seconds)

> "Let me start with a simple question."

[TYPE]
```
Compare customer satisfaction rates across all regions and show me which region needs attention
```

[WAIT - Let agent respond ~5 seconds]

[POINT TO CHART]

> "There's our answer. Bar chart automatically generated. West region is clearly underperforming—**45% satisfaction versus 68-72% in other regions.**
>
> Notice what just happened:
> - No SQL
> - No dashboard navigation  
> - Just a question, instant answer with a chart
>
> But we need to know **why**. Let's dig deeper."

---

### **QUESTION 2: The WOW Moment** ⭐ (2.5-3 minutes)

> "Here's where it gets interesting."

[TYPE]
```
Why is the West region underperforming in customer satisfaction? Give me a detailed investigation.
```

[WAIT - Agent starts multi-step reasoning]

[POINT TO THINKING PANEL - SLOW DOWN HERE]

> "**Watch the agent work.**
>
> [READ FROM SCREEN]
> It's breaking down the question... creating an investigation plan...
>
> [AS STEPS EXECUTE]
> Step 1: Querying metrics with Cortex Analyst—call volumes, resolution rates, escalations
>
> Step 2: Searching transcripts with Cortex Search—what did customers actually say?
>
> Step 3: Synthesizing findings from both sources
>
> **This is autonomous reasoning.** The agent is investigating like your best analyst would."

[AGENT COMPLETES - SHOWS FINDINGS]

[POINT TO RESULTS]

> "Look at what it found:
> - West has **30% higher billing issues**
> - Resolution rate is **15% lower**
> - Escalation rate is **higher**
> - [Point to transcript evidence] Found specific mentions of 'overcharge' and 'billing errors' in West region transcripts
>
> **This is the magic.** Three capabilities working together:
> 1. **Cortex Analyst** for structured metrics
> 2. **Cortex Search** for unstructured transcript patterns
> 3. **Agentic reasoning** to orchestrate and synthesize
>
> I didn't write a single line of code. The agent **investigated autonomously** across multiple data sources."

---

### **QUESTION 3: The Action** 🚀 (1.5 minutes)

> "Now here's what makes this truly powerful. This agent doesn't just analyze—**it can take action**."

[TYPE]
```
Schedule a high-priority callback for David Thompson tomorrow regarding his unresolved billing issue. Make sure we assign our best agent.
```

[WAIT - Agent executes ~3 seconds]

[POINT TO CONFIRMATION]

> "Look at that response:
> - **Callback scheduled!**
> - Customer: David Thompson
> - It detected he's a Premium customer
> - Automatically assigned a senior agent—Sarah Chen
> - Set time to 10am because it's high priority
>
> The agent made intelligent business decisions and **took action**."

[SWITCH TO SQL WORKSHEET]

> "Let me prove this is real."

[RUN QUERY]
```sql
SELECT * FROM CALLBACK_QUEUE 
WHERE CUSTOMER_NAME = 'David Thompson' 
  AND STATUS = 'PENDING';
```

[POINT TO TABLE]

> "There it is. **Real data, written by the AI.**
> - Customer name
> - Scheduled date and time
> - Assigned agent
> - Priority level
> - Reason captured
>
> **From conversation to action in 5 seconds.**
>
> This custom tool is 40 lines of SQL we wrote. You could build custom tools for:
> - Slack alerts to managers
> - Salesforce updates
> - Jira ticket creation  
> - Email campaigns
> - **Anything you can code, the agent can execute**"

---

### **CLOSING: The Setup** (1.5 minutes)

[SWITCH TO SNOWSIGHT - SHOW AGENT CONFIGURATION]

> "How did we build this? **No code.**
>
> [SHOW TOOLS TAB]
> Three tools: Cortex Analyst, Cortex Search, Custom callback scheduler.
>
> [SHOW ORCHESTRATION TAB]
> **Planning instructions** teach the agent which tool to use. See this? 'For WHY questions—use Analyst, then Search, then synthesize.' That's exactly what it did.
>
> **Response instructions** shape how it communicates. 'Create charts for comparisons'—that's why we got that bar chart automatically.
>
> [SHOW SEMANTIC MODEL - BRIEFLY]
> Our semantic model: YAML file with business synonyms, metrics, verified queries. Uploaded via UI.
>
> **Total setup time: 30 minutes.**
> **Code written: Zero.**
> **Business impact: Transformational.**"

---

### **FINAL MESSAGE** (30 seconds)

> "So what did we just see?
>
> ✅ **Unstructured data** → Structured insights  
> ✅ **Autonomous reasoning** → Multi-step investigation  
> ✅ **Action taken** → Callback scheduled automatically  
> ✅ **No code required** → YAML and UI configuration  
> ✅ **Minutes to deploy** → Not months
>
> **This is Snowflake Intelligence.**
>
> Your data. Your questions. Your actions. Your business logic.
>
> **No boundaries.**
>
> Thank you!"

---

## 🎤 DELIVERY TIPS

### **Pacing:**
- **Intro:** Quick (set context)
- **Q1:** Moderate pace (explain chart)
- **Q2:** **SLOW DOWN** - Let agent think, build suspense
- **Q3:** Moderate (show action + proof)
- **Closing:** Quick tour

### **Energy:**
- **HIGH:** When introducing "the magic"
- **PAUSE:** During agent's multi-step reasoning (let it work)
- **CONFIDENT:** "No code required"

### **Audience Engagement:**
- Make eye contact during pauses
- Point to screen when explaining
- Use hand gestures for "three questions, three capabilities"

---

## 📊 TIMING BREAKDOWN

| Section | Duration | Key Point |
|---------|----------|-----------|
| **Intro** | 45 sec | Set the problem |
| **Q1: Regional comparison** | 45 sec | Fast, visual, identifies issue |
| **Q2: Why West underperforming** | 2.5-3 min | WOW - autonomous reasoning |
| **Q3: Schedule callback** | 1.5 min | ACTION - custom tool |
| **Closing** | 1.5 min | Setup tour, no-code message |
| **TOTAL** | **7-8 min** | ✅ On time |

---

## 🎯 KEY PHRASES TO MEMORIZE

**Opening hook:**
> "What if you could just... ask?"

**After Q1:**
> "Instant answer. No SQL. No dashboard. Just conversation."

**During Q2:**
> "Watch the agent work. **This is autonomous reasoning.**"

**After Q2:**
> "**This is the magic.** Three technologies working together, orchestrated automatically."

**After Q3:**
> "**From conversation to action in 5 seconds.** That's agentic AI."

**Final line:**
> "Your data. Your questions. Your actions. **No boundaries.**"

---

## 🛡️ BACKUP PLAN (If Demo Breaks)

**If Q1 fails:**
- Show screenshot
- Explain what should happen
- Move to Q2

**If Q2 fails:**
- Skip to showing the semantic model
- Explain multi-step reasoning concept
- Show screenshot of working version

**If Q3 fails:**
- Show pre-populated CALLBACK_QUEUE table
- Explain the concept
- Move to closing

**If everything breaks:**
- Have slide deck with screenshots
- Walk through the concept
- Emphasize the vision even if tech doesn't cooperate

---

## 📱 PRE-DEMO SETUP (30 min before)

**Browser Setup:**
- Tab 1: Snowflake Intelligence (Agent chat)
- Tab 2: Snowsight SQL worksheet (for showing CALLBACK_QUEUE table)
- Tab 3: Agent configuration (for showing tools/instructions)
- Disable notifications
- Increase font size (200% for readability)

**Test Run:**
- Test all 3 questions
- Clear any test callbacks
- Close unnecessary tabs
- Have water nearby

**Mental Prep:**
- Review key phrases
- Breathe
- Remember: You're showing something genuinely amazing
- Have fun!

---

## 🏆 SUCCESS CRITERIA

**Audience should leave thinking:**
1. "We have similar unstructured data we could unlock"
2. "This doesn't require months of engineering"
3. "The AI actually reasons, not just searches"
4. "I can extend it with my business logic"
5. "I want to try this with our data"

---

## 🎉 YOU'VE GOT THIS!

**Your demo showcases:**
- ✅ Enterprise-scale data (500 calls)
- ✅ Intelligent orchestration (autonomous reasoning)
- ✅ Action-oriented AI (schedules callbacks)
- ✅ No-code deployment (30 min setup)
- ✅ Production-ready governance (verified queries, RBAC)

**Break a leg at London World Tour!** 🇬🇧🚀

---

*Demo script finalized - October 3, 2025*



