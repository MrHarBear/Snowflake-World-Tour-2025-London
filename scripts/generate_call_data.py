"""
Generate realistic call center data for Snowflake Intelligence demo
Creates 448 additional call records with diverse scenarios, realistic transcripts,
and varied sentiment/resolution patterns.
"""

import csv
import random
import json
from datetime import datetime, timedelta

# Configuration
NUM_RECORDS = 448
START_CALL_ID = 52  # Continue from existing data
OUTPUT_FILE = "ADDITIONAL_CALL_DATA.csv"

# Agent names (mix of existing and new)
AGENTS = [
    "Emily Davis", "James Martinez", "David Thompson", "Christopher Lee",
    "Robert Kim", "Amanda Williams", "Kelly Smith", "Ashley Brown",
    "Rachel Green", "Daniel Garcia", "Nicole Taylor", "Sarah Chen",
    "Michael Rodriguez", "Brian Wilson", "Kevin Wong", "Tina Davis",
    "Lisa Johnson", "Mike Thompson", "Tony Garcia", "Steve Johnson",
    "Jennifer Lopez", "Mark Anderson", "Patricia White", "Jason Miller",
    "Maria Garcia", "Thomas Moore", "Susan Clark", "Richard Taylor"
]

# Customer names (new diverse names)
CUSTOMER_FIRST = [
    "Michael", "Jennifer", "William", "Jessica", "Richard", "Sarah", "Joseph",
    "Karen", "Thomas", "Nancy", "Charles", "Lisa", "Daniel", "Betty", "Mark",
    "Maria", "George", "Susan", "Kenneth", "Margaret", "Steven", "Dorothy",
    "Edward", "Sandra", "Brian", "Ashley", "Ronald", "Kimberly", "Anthony",
    "Emily", "Kevin", "Donna", "Jason", "Michelle", "Matthew", "Carol", "Gary",
    "Melissa", "Timothy", "Amanda", "Jose", "Stephanie", "Larry", "Rebecca",
    "Jeffrey", "Sharon", "Frank", "Cynthia", "Scott", "Kathleen", "Eric",
    "Amy", "Raymond", "Angela", "Jacob", "Helen", "Alexander", "Anna"
]

CUSTOMER_LAST = [
    "Anderson", "Martinez", "Lopez", "Gonzalez", "Wilson", "Taylor", "Moore",
    "Jackson", "Martin", "Lee", "Harris", "Clark", "Lewis", "Robinson", "Walker",
    "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill",
    "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell",
    "Mitchell", "Carter", "Roberts", "Turner", "Phillips", "Evans", "Parker"
]

# Call scenarios with realistic patterns
BILLING_SCENARIOS = [
    {
        "intent": "billing",
        "issue": "unexpected charge",
        "resolution": ["yes", "no"],
        "sentiment_range": (-0.8, 0.3),
        "performance_range": (5, 9),
        "transcript_template": [
            "I'm calling about an unexpected ${amount} charge on my bill. I never authorized this {service}. The agent {action} and {resolution}.",
            "There's a ${amount} charge on my account for {service} that I didn't order. Been happening for {duration}. The representative {action}.",
            "I need help with a billing issue. My bill shows ${amount} for {service} but I cancelled that months ago. {resolution}."
        ]
    },
    {
        "intent": "technical_support",
        "issue": "service outage",
        "resolution": ["yes", "no"],
        "sentiment_range": (-0.7, 0.7),
        "performance_range": (4, 10),
        "transcript_template": [
            "My {service} has been down for {duration} and I can't {impact}. The technician {action} and {resolution}.",
            "I need technical support. The {service} keeps {problem} every {frequency}. It's affecting my {impact}. {resolution}.",
            "Technical issue - my {service} isn't working properly. The agent {action} and we {resolution}."
        ]
    },
    {
        "intent": "cancellation",
        "issue": "service cancellation",
        "resolution": ["yes", "no"],
        "sentiment_range": (-0.3, 0.8),
        "performance_range": (6, 10),
        "transcript_template": [
            "I need to cancel my service because {reason}. The agent {action} and {resolution}.",
            "Calling to cancel my {service} account. Reason: {reason}. The representative {action}.",
            "I want to cancel. I'm {reason}. The agent {action} and {resolution}."
        ]
    },
    {
        "intent": "compliment",
        "issue": "positive feedback",
        "resolution": ["yes"],
        "sentiment_range": (0.7, 0.95),
        "performance_range": (9, 10),
        "transcript_template": [
            "I wanted to call and thank {agent} for the excellent service. The {service} has been {positive} and {positive2}.",
            "Just calling to give positive feedback about {service}. It's been {positive} and I'm very {emotion}.",
            "Excellent experience with your {service}. The {aspect} is {positive} and I've recommended it to {people}."
        ]
    },
    {
        "intent": "information",
        "issue": "account inquiry",
        "resolution": ["yes"],
        "sentiment_range": (0.3, 0.8),
        "performance_range": (7, 10),
        "transcript_template": [
            "I have questions about my {service} account. The agent explained {topic} clearly and answered all my questions about {topic2}.",
            "Calling for information about {topic}. The representative was helpful and explained everything about {topic2}.",
            "I needed clarification on {topic}. The agent provided clear information and I understand now."
        ]
    },
    {
        "intent": "complaint",
        "issue": "service complaint",
        "resolution": ["no", "yes"],
        "sentiment_range": (-0.9, -0.3),
        "performance_range": (2, 6),
        "transcript_template": [
            "I'm very disappointed with {service}. The {problem} and it's been {duration}. The agent {action} but {outcome}.",
            "Calling to complain about {service}. This is {adjective} customer service. {problem} and nobody can {resolution}.",
            "This is unacceptable. {problem} for {duration} and the {service} is {adjective}. {outcome}."
        ]
    }
]

# Substitution values for templates
SUBSTITUTIONS = {
    "amount": ["$42.50", "$89.99", "$125.00", "$67.49", "$156.00", "$234.99", "$45.00"],
    "service": ["internet", "premium package", "equipment rental", "billing dispute service", 
                "router", "mobile hotspot", "fiber optic service", "Wi-Fi extender"],
    "duration": ["two days", "a week", "three months", "over a month", "several weeks", "two weeks"],
    "impact": ["work from home", "access important files", "attend video calls", "run my business"],
    "frequency": ["10-15 minutes", "few hours", "day", "morning"],
    "problem": ["dropping connections", "cutting out", "running slow", "not working", "overheating"],
    "reason": ["moving to a new area", "found a better deal", "no longer need it", "dissatisfied with service"],
    "positive": ["fantastic", "excellent", "amazing", "reliable", "fast", "perfect"],
    "positive2": ["exceeds expectations", "works flawlessly", "very impressed", "exactly what I needed"],
    "emotion": ["satisfied", "happy", "pleased", "impressed"],
    "people": ["friends", "family", "colleagues", "neighbors"],
    "aspect": ["setup", "performance", "range", "speed", "reliability"],
    "topic": ["billing cycle", "plan options", "upgrade options", "account details", "service coverage"],
    "topic2": ["pricing", "features", "installation", "payment options"],
    "adjective": ["terrible", "poor", "awful", "ridiculous", "disappointing"],
    "outcome": ["still not resolved", "no solution", "very disappointing", "unacceptable"],
    "action": ["looked into it", "checked my account", "ran diagnostics", "reviewed the charges", 
               "explained the policy", "offered solutions", "escalated to supervisor"],
    "resolution": ["issue was resolved", "scheduled a technician", "processed a refund",
                  "still waiting", "problem persists", "no solution yet"]
}

def generate_transcript(scenario, agent_name):
    """Generate a realistic call transcript based on scenario"""
    template = random.choice(scenario["transcript_template"])
    
    # Replace placeholders with random substitutions
    transcript = template
    for key, values in SUBSTITUTIONS.items():
        placeholder = "{" + key + "}"
        if placeholder in transcript:
            transcript = transcript.replace(placeholder, random.choice(values))
    
    # Replace agent name
    transcript = transcript.replace("{agent}", agent_name)
    
    # Add opening and closing
    greetings = [
        f"Thank you for calling TechCorp. This is {agent_name}. How can I help you today?",
        f"TechCorp Support, {agent_name} speaking. How can I help?",
        f"Good morning, you've reached TechCorp support. My name is {agent_name}. What can I do for you?",
        f"Hello, this is {agent_name} from TechCorp Customer Care. How may I assist you?"
    ]
    
    closings = [
        "Thank you for calling. Have a great day.",
        "Is there anything else I can help you with today?",
        "Thank you for your patience with this issue.",
        "Thanks for contacting us.",
        "Have a wonderful day."
    ]
    
    full_transcript = f"{random.choice(greetings)} {transcript} {random.choice(closings)}"
    
    return full_transcript

def generate_call_summary(transcript, scenario):
    """Generate AI-style call summary"""
    summaries = {
        "billing": f"Customer contacted regarding billing issue. {random.choice(['Issue was resolved with refund processed.', 'Charge was explained and removed.', 'Billing dispute remains unresolved.', 'Customer satisfied with explanation.'])}",
        "technical_support": f"Technical support call for service issues. {random.choice(['Technician scheduled for resolution.', 'Issue resolved remotely.', 'Problem persists, escalated to engineering.', 'Diagnostic completed, awaiting follow-up.'])}",
        "cancellation": f"Customer requested service cancellation. {random.choice(['Cancellation processed successfully.', 'Retention offer presented.', 'Account closed per customer request.', 'Service terminated, final bill sent.'])}",
        "compliment": "Customer provided positive feedback about service quality and performance. No issues reported.",
        "information": "Customer inquiry about account and service details. Questions answered satisfactorily.",
        "complaint": f"Customer complaint regarding service quality. {random.choice(['Issue escalated for resolution.', 'Complaint logged, no immediate resolution.', 'Customer dissatisfied with response.', 'Follow-up scheduled.'])}"
    }
    return summaries.get(scenario["intent"], "Call regarding customer service issue.")

def generate_improvement_opportunities(performance_score):
    """Generate realistic improvement suggestions based on performance"""
    if performance_score >= 9:
        return random.choice([
            "Excellent call handling. Minor suggestion: Could proactively offer related services.",
            "Outstanding performance. Consider documenting best practices for team training.",
            "Great empathy and problem-solving. No major improvements needed."
        ])
    elif performance_score >= 7:
        return random.choice([
            "Good call resolution. Could improve by setting clearer expectations on timelines.",
            "Solid performance. Opportunity to show more empathy during frustrated moments.",
            "Effective problem-solving. Could enhance by offering proactive solutions."
        ])
    elif performance_score >= 5:
        return random.choice([
            "Adequate handling. Needs to improve active listening and ask clarifying questions.",
            "Resolution attempted but customer left dissatisfied. Work on empathy and acknowledgment.",
            "Followed process but lacked flexibility. Consider offering alternatives sooner."
        ])
    else:
        return random.choice([
            "Significant improvements needed. Failed to acknowledge customer frustration or resolve issue.",
            "Poor call handling. Needs training on de-escalation and problem-solving techniques.",
            "Customer left very dissatisfied. Agent must improve empathy, listening, and solution offerings."
        ])

def generate_call_record(call_id):
    """Generate a single realistic call record"""
    # Select scenario
    scenario = random.choice(BILLING_SCENARIOS)
    
    # Select agent and customer
    agent_name = random.choice(AGENTS)
    customer_name = f"{random.choice(CUSTOMER_FIRST)} {random.choice(CUSTOMER_LAST)}"
    
    # Generate call details
    call_type = random.choice(["inbound", "outbound"])
    issue_resolved = random.choice(scenario["resolution"])
    
    # Generate sentiment
    sentiment_score = round(random.uniform(*scenario["sentiment_range"]), 4)
    if sentiment_score > 0.5:
        sentiment_category = "POSITIVE"
        customer_satisfaction = random.choice(["satisfied", "neutral"])
    elif sentiment_score < -0.3:
        sentiment_category = "NEGATIVE"
        customer_satisfaction = random.choice(["dissatisfied", "neutral"])
    else:
        sentiment_category = "NEUTRAL"
        customer_satisfaction = "neutral"
    
    # Generate performance score
    performance_score = random.randint(*scenario["performance_range"])
    
    # Urgency and escalation
    if sentiment_category == "NEGATIVE" and issue_resolved == "no":
        urgency_level = random.choice(["medium", "high"])
        escalation_required = random.choice(["yes", "no"])
    else:
        urgency_level = random.choice(["low", "medium"])
        escalation_required = "no"
    
    # Generate transcript
    transcript = generate_transcript(scenario, agent_name)
    word_count = len(transcript.split())
    
    # Generate summary
    call_summary = generate_call_summary(transcript, scenario)
    
    # Call classification
    classifications = {
        "billing": "Billing Issue",
        "technical_support": "Technical Support",
        "cancellation": "Billing Issue",
        "compliment": "Compliment",
        "information": "Inquiry",
        "complaint": "Complaint"
    }
    call_classification = classifications[scenario["intent"]]
    
    # Generate timestamp (random within last 90 days)
    days_ago = random.randint(0, 90)
    timestamp = (datetime.now() - timedelta(days=days_ago)).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    
    # Extracted fields (JSON)
    extracted_fields = json.dumps({
        "response": {
            "agent_name": agent_name,
            "customer_name": customer_name
        }
    })
    
    # Call analysis (JSON)
    call_analysis = json.dumps({
        "agent_name": agent_name,
        "call_type": call_type,
        "customer_name": customer_name,
        "customer_satisfaction": customer_satisfaction,
        "escalation_required": escalation_required,
        "issue_resolved": issue_resolved,
        "primary_intent": scenario["intent"],
        "urgency_level": urgency_level
    })
    
    # Improvement opportunities
    improvement_opportunities = generate_improvement_opportunities(performance_score)
    
    # Build record
    record = {
        "": call_id - 1,  # Index column
        "CALL_ID": f"CALL_20250728_{10050 + call_id}",
        "TRANSCRIPT_TEXT": transcript,
        "WORD_COUNT": word_count,
        "SENTIMENT_SCORE": sentiment_score,
        "SENTIMENT_CATEGORY": sentiment_category,
        "CALL_SUMMARY": call_summary,
        "CALL_CLASSIFICATION": call_classification,
        "EXTRACTED_FIELDS": extracted_fields,
        "CALL_ANALYSIS": call_analysis,
        "AGENT_PERFORMANCE_SCORE": performance_score,
        "IMPROVEMENT_OPPORTUNITIES": improvement_opportunities,
        "ANALYSIS_TIMESTAMP": timestamp,
        "CALL_TYPE": call_type,
        "CUSTOMER_NAME": customer_name,
        "AGENT_NAME": agent_name,
        "PRIMARY_INTENT": scenario["intent"],
        "URGENCY_LEVEL": urgency_level,
        "ISSUE_RESOLVED": issue_resolved,
        "ESCALATION_REQUIRED": escalation_required,
        "CUSTOMER_SATISFACTION": customer_satisfaction
    }
    
    return record

def main():
    """Generate all call records and write to CSV"""
    print(f"Generating {NUM_RECORDS} call center records...")
    
    records = []
    for i in range(NUM_RECORDS):
        call_id = START_CALL_ID + i
        record = generate_call_record(call_id)
        records.append(record)
        
        if (i + 1) % 50 == 0:
            print(f"  Generated {i + 1}/{NUM_RECORDS} records...")
    
    # Write to CSV
    print(f"Writing to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
        if records:
            writer = csv.DictWriter(f, fieldnames=records[0].keys())
            writer.writeheader()
            writer.writerows(records)
    
    print(f"✓ Successfully generated {NUM_RECORDS} records!")
    print(f"✓ Output: {OUTPUT_FILE}")
    
    # Print statistics
    intents = {}
    sentiments = {}
    for record in records:
        intent = record["PRIMARY_INTENT"]
        sentiment = record["SENTIMENT_CATEGORY"]
        intents[intent] = intents.get(intent, 0) + 1
        sentiments[sentiment] = sentiments.get(sentiment, 0) + 1
    
    print("\nData Statistics:")
    print("Intent Distribution:")
    for intent, count in sorted(intents.items()):
        print(f"  {intent}: {count} ({count/len(records)*100:.1f}%)")
    print("\nSentiment Distribution:")
    for sentiment, count in sorted(sentiments.items()):
        print(f"  {sentiment}: {count} ({count/len(records)*100:.1f}%)")

if __name__ == "__main__":
    main()

