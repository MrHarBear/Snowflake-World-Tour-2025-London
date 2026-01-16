# 📋 Agent Instructions - Copy-Paste Ready

## For Configuring Your Cortex Agent in Snowflake Intelligence

---

## 🧠 PLANNING INSTRUCTIONS

### Copy and paste this into Agent → Orchestration → Planning Instructions:

```
When answering user questions, intelligently select and orchestrate tools:

For QUANTITATIVE questions (numbers, metrics, KPIs, comparisons):
- Use "Call Center Metrics" (Cortex Analyst)
- Examples: "What's our satisfaction rate?", "Compare regions", "Show top agents"
- This is fastest for structured data queries

For QUALITATIVE questions (what was said, specific customer feedback):
- Use "Call Transcript Search" (Cortex Search)
- Examples: "Find calls mentioning billing errors", "What did frustrated customers say?"
- Then optionally aggregate findings with Cortex Analyst

For ACTION requests (scheduling, creating tasks, taking next steps):
- Use "Schedule Customer Callback" custom tool
- Examples: "Schedule a callback for [customer]", "Create callback for unresolved issues"
- This writes data and takes action

For "WHY" questions requiring multi-step investigation:
- Start with Cortex Analyst to identify metric patterns
- Use Cortex Search to find supporting evidence in transcripts  
- Synthesize findings from both sources
- Example: "Why is West region underperforming?"

For BATCH ACTIONS on multiple customers:
- First use Cortex Analyst to identify the target customers
- Then use custom tools to take action on those customers
- Example: "Schedule callbacks for all high-risk Premium customers"

PRIORITY RULES:
- For questions about specific customers: Always check their profile first
- For revenue questions: Prioritize Premium and Enterprise segments
- For agent performance: Be constructive, focus on improvement opportunities
- When in doubt: Use Cortex Analyst for data, Cortex Search for context

Always prefer using tools over general knowledge.
Combine multiple tools when needed to provide comprehensive answers.
```

---

## 💬 RESPONSE INSTRUCTIONS

### Copy and paste this into Agent → Orchestration → Response Instructions:

```
You are a professional call center intelligence assistant helping business users make data-driven decisions.

TONE & COMMUNICATION:
- Professional, helpful, and concise
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
```

---

## 🎯 WHY THESE INSTRUCTIONS

### Planning Instructions:
**Purpose:** Teach the agent **which tool** to use for different question types

**Key Features:**
- ✅ Tool selection logic (Analyst vs Search vs Custom Tool)
- ✅ Handles "WHY" questions (multi-step reasoning)
- ✅ Supports batch actions
- ✅ Priority rules for Premium customers

**Without this:** Agent might search transcripts when asked for a count (slow)  
**With this:** Agent routes to Cortex Analyst for metrics (instant)

---

### Response Instructions:
**Purpose:** Shape **how** the agent communicates and formats answers

**Key Features:**
- ✅ Professional business tone
- ✅ Chart creation rules (visual is powerful)
- ✅ Context with every number
- ✅ Actionable insights, not raw data
- ✅ Action confirmation format

**Without this:** "68%" (just data)  
**With this:** "68%, below target, affecting $8.5K—investigate West region billing" (actionable)

---

## 🎤 DEMO TALK TRACK

### **Setup: Transitioning to Configuration** (15 seconds)

> "You just saw the agent in action. Now let me show you how we configured this intelligence—**in about 5 minutes, with no custom code**."
> 
> [Navigate to Agent Configuration in Snowsight]

---

### **Part 1: The Three Tools** (30 seconds)

> [Show Tools tab]
> 
> "Our agent has three tools:
> 
> **Cortex Analyst** for querying metrics—satisfaction rates, agent performance, revenue data.
> 
> **Cortex Search** for searching through 500 call transcripts—what did customers actually say?
> 
> **And this custom tool we built**—Schedule Customer Callback. **This is where it gets cool.** The agent can take action, not just answer questions."

---

### **Part 2: Planning Instructions** (60 seconds)

> [Show Orchestration → Planning Instructions]
> 
> "How does the agent know which tool to use? **Planning instructions.**
> 
> [READ 2-3 LINES FROM SCREEN]
> 'For quantitative questions—use Cortex Analyst.' 'For action requests—use the callback scheduler.'
> 
> **This is the agent's playbook.** We're teaching it strategy in plain English.
> 
> Remember when you asked 'Why is West underperforming?' and it used multiple tools automatically? **It followed these instructions:**
> - Step 1: Check metrics with Analyst
> - Step 2: Search transcripts for evidence  
> - Step 3: Synthesize
> 
> No coding. Just **teaching the AI how to think about your business.**"

---

### **Part 3: Response Instructions** (45 seconds)

> [Show Orchestration → Response Instructions]
> 
> "**Response instructions** control the personality and format.
> 
> [READ 1-2 LINES]
> 'Create charts for comparisons.' 'Provide context with numbers.' 'Suggest actionable insights.'
> 
> **This is why every answer felt polished.** Not raw data dumps—business-ready insights with charts, context, and recommendations.
> 
> You're defining how your agent communicates. Professional tone, visual charts, always actionable. **Configured, not coded.**"

---

### **Part 4: Custom Tool Demo** (60-90 seconds) ⭐

> [Navigate back to Chat Interface]
> 
> "Now watch this. I'm going to ask the agent to **take action.**
> 
> [TYPE AND ASK]
> 'Schedule a high-priority callback for David Thompson tomorrow regarding his unresolved billing issue'
> 
> [AGENT EXECUTES - WAIT FOR RESPONSE]
> 
> [POINT TO RESPONSE]
> **Look at what just happened:**
> - It identified David Thompson
> - Looked up his customer segment (Premium)
> - Assigned a senior agent automatically (because Premium customer)
> - Set time to 10am (because high priority)
> - **Wrote the callback into our queue table**
> - Confirmed everything back to me
> 
> **The agent just took action.** Not analysis—**action**.
> 
> [SHOW THE TABLE]
> 
> [RUN QUERY IN WORKSHEET]
> 'SELECT * FROM CALLBACK_QUEUE WHERE STATUS = 'PENDING' ORDER BY SCHEDULED_DATE'
> 
> There it is! **Real data, written by the AI.** Customer name, reason, priority, assigned agent, scheduled time.
> 
> This custom tool is 40 lines of SQL we wrote. **You could build custom tools to:**
> - Send Slack notifications to managers
> - Create Jira tickets for technical issues
> - Update Salesforce with customer sentiment  
> - Generate coaching reports
> - Call external APIs
> - **Anything you can code, the agent can execute**
> 
> That's the power of Cortex Agents. Start with incredible out-of-box tools, extend infinitely with your business logic."

---

## 🎯 DEMO QUESTIONS TO USE

### Show Planning Instructions Working:
**Ask:** "Why is West region underperforming in customer satisfaction?"  
**Agent does:** Uses Analyst + Search (multi-step reasoning)  
**Point out:** "Following the planning instructions—using both tools automatically"

### Show Response Instructions Working:
**Ask:** "Compare satisfaction rates across all regions"  
**Agent does:** Creates bar chart, provides context  
**Point out:** "See the chart? Response instructions say 'create charts for comparisons'"

### Show Custom Tool in Action: ⭐
**Ask:** "Schedule a high-priority callback for David Thompson tomorrow regarding his unresolved billing dispute"  
**Agent does:** Executes procedure, writes to table, confirms action  
**Point out:** "The agent just **took action**—scheduled a real callback. Not just insights—**execution.**"

**Then show the table:**
```sql
SELECT * FROM CALLBACK_QUEUE 
WHERE STATUS = 'PENDING' 
ORDER BY SCHEDULED_DATE;
```

**Point out:** "Real data, written by AI. **From question to action in seconds.**"

---

## 💡 KEY MESSAGES

### Planning Instructions = **The Agent's Brain**
> "Teaching AI **which tool** to use for which question—like giving it a playbook for your business."

### Response Instructions = **The Agent's Personality**
> "Teaching AI **how to communicate**—professional, visual, actionable. Not raw data—business insights."

### Custom Tools = **The Agent's Superpowers**
> "Adding **your business logic**—callbacks, alerts, tickets, integrations. If you can code it, the agent can execute it."

---

## 🎨 VISUAL FOR SLIDE (Optional)

```
┌─────────────────────────────────────────────────┐
│  "Schedule a callback for David Thompson"      │
│                     ↓                           │
│           Planning Instructions                 │
│         "Action request detected"               │
│                     ↓                           │
│      Route to: Custom Callback Tool             │
│                     ↓                           │
│        Execute: schedule_customer_callback()    │
│                     ↓                           │
│       Write to: CALLBACK_QUEUE table            │
│                     ↓                           │
│      Response Instructions Format Result        │
│                     ↓                           │
│  "✓ Callback scheduled for David Thompson      │
│   (Premium) on Oct 8 at 10:00am with           │
│   senior agent Sarah Chen. Reason: Billing     │
│   dispute #12345. Priority: HIGH"              │
└─────────────────────────────────────────────────┘
```

---

## ✅ SETUP CHECKLIST

Before demo:
- [ ] Run `sql/05_create_custom_tool.sql` ✓ Creates table + procedures
- [ ] Test: `CALL schedule_customer_callback('David Thompson', 'Test', '2025-10-08', 'HIGH')`
- [ ] Verify: `SELECT * FROM CALLBACK_QUEUE` shows the test record
- [ ] Create agent via SQL: `snow sql -f sql/07_create_agent.sql` (includes all tools + instructions)
- [ ] Or create agent manually in Snowsight → AI & ML → Agents (paste instructions from above)
- [ ] Test demo question: "Schedule callback for Ashley Brown tomorrow"
- [ ] Verify callback appears in CALLBACK_QUEUE table
- [ ] Clear test data before live demo (optional)

**Note:** The `sql/07_create_agent.sql` script creates the agent with all tools, planning instructions, and response instructions already configured. No manual pasting required!

---

## 🚀 THE WOW MOMENT

**What You'll Show:**

1. **Natural language request:** "Schedule a callback for David Thompson..."
2. **Agent orchestrates:** Checks planning instructions → routes to custom tool
3. **Action executes:** Procedure writes to CALLBACK_QUEUE table
4. **Confirmation delivered:** Following response instructions format
5. **Proof shown:** Query the table, see the actual record

**Audience reaction:** 🤯 "Wait, it can DO things?!"

**Your line:** "**This is agentic AI.** Not just answering questions—**taking action on your behalf.**"

---

**Configuration ready. Go set up your agent and blow minds at London!** 🚀

---

*Planning instructions, response instructions, and custom callback tool complete - October 3, 2025*

