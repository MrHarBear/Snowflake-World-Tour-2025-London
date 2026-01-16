"""
Generate comprehensive customer profiles for ALL customers in the call data
Ensures every call can be joined to customer demographic information
"""

import csv
import random
from datetime import datetime, timedelta
from collections import defaultdict

# Read all unique customers from both datasets
def get_all_customers():
    """Extract unique customer names from both call datasets"""
    customers = set()
    
    # From original FINAL_TABLE
    with open('Reference/FINAL_TABLE.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('CUSTOMER_NAME', '').strip()
            if name and name != 'None' and name.lower() != 'unknown':
                customers.add(name)
    
    # From ADDITIONAL_CALL_DATA
    with open('ADDITIONAL_CALL_DATA.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('CUSTOMER_NAME', '').strip()
            if name and name != 'None' and name.lower() != 'unknown':
                customers.add(name)
    
    return sorted(list(customers))

# Configuration for realistic demographic generation
REGIONS = {
    'West': {
        'states': ['California', 'Washington', 'Oregon', 'Nevada', 'Arizona', 'Montana', 'Hawaii', 'Colorado'],
        'cities': {
            'California': ['Los Angeles', 'San Francisco', 'San Diego', 'Sacramento', 'San Jose'],
            'Washington': ['Seattle', 'Spokane', 'Tacoma'],
            'Oregon': ['Portland', 'Eugene'],
            'Nevada': ['Las Vegas', 'Reno'],
            'Arizona': ['Phoenix', 'Tucson'],
            'Montana': ['Billings', 'Missoula'],
            'Hawaii': ['Honolulu'],
            'Colorado': ['Denver', 'Colorado Springs']
        },
        'weight': 0.35  # 35% of customers in West
    },
    'South': {
        'states': ['Texas', 'North Carolina', 'Georgia', 'Florida'],
        'cities': {
            'Texas': ['Houston', 'Austin', 'Dallas', 'San Antonio'],
            'North Carolina': ['Charlotte', 'Raleigh'],
            'Georgia': ['Atlanta', 'Savannah'],
            'Florida': ['Miami', 'Tampa', 'Jacksonville', 'Orlando']
        },
        'weight': 0.20
    },
    'Northeast': {
        'states': ['New York', 'Massachusetts', 'Pennsylvania', 'New Jersey'],
        'cities': {
            'New York': ['New York', 'Brooklyn', 'Buffalo', 'Albany'],
            'Massachusetts': ['Boston', 'Cambridge'],
            'Pennsylvania': ['Philadelphia', 'Pittsburgh'],
            'New Jersey': ['Newark', 'Jersey City']
        },
        'weight': 0.20
    },
    'Southeast': {
        'states': ['Virginia', 'South Carolina', 'Alabama'],
        'cities': {
            'Virginia': ['Richmond', 'Norfolk'],
            'South Carolina': ['Charleston', 'Columbia'],
            'Alabama': ['Birmingham', 'Montgomery']
        },
        'weight': 0.15
    },
    'Midwest': {
        'states': ['Illinois', 'Ohio', 'Michigan', 'Indiana', 'Minnesota', 'Missouri'],
        'cities': {
            'Illinois': ['Chicago', 'Springfield'],
            'Ohio': ['Cleveland', 'Columbus', 'Cincinnati'],
            'Michigan': ['Detroit', 'Grand Rapids'],
            'Indiana': ['Indianapolis', 'Fort Wayne'],
            'Minnesota': ['Minneapolis', 'St. Paul'],
            'Missouri': ['Kansas City', 'St. Louis']
        },
        'weight': 0.10
    }
}

ACCOUNT_TYPES = [
    ('Residential', 0.85),
    ('Business', 0.15)
]

CUSTOMER_SEGMENTS = {
    'Residential': [
        ('Individual', 0.50),
        ('Premium', 0.35),
        ('Senior', 0.15)
    ],
    'Business': [
        ('Enterprise', 0.40),
        ('Mid-Market', 0.60)
    ]
}

INDUSTRIES = [
    'Technology', 'Financial Services', 'Healthcare', 'Retail', 
    'Manufacturing', 'Professional Services', 'Education', 'Real Estate'
]

ACCOUNT_STATUS = [
    ('Active', 0.92),
    ('Cancelled', 0.05),
    ('Churned', 0.03)
]

AGE_GROUPS = ['25-34', '35-44', '45-54', '55-64', '65+']

PAYMENT_METHODS = ['Credit Card', 'Bank Transfer', 'Debit Card', 'Invoice']

PREFERRED_CONTACT = ['Phone', 'Email', 'SMS']

LANGUAGES = [
    ('English', 0.90),
    ('Spanish', 0.07),
    ('Korean', 0.02),
    ('Chinese', 0.01)
]

def weighted_choice(choices):
    """Make a weighted random choice from (value, weight) tuples"""
    values, weights = zip(*choices)
    total = sum(weights)
    r = random.random() * total
    cumsum = 0
    for value, weight in zip(values, weights):
        cumsum += weight
        if r < cumsum:
            return value
    return values[-1]

def assign_region(customer_name):
    """Assign region based on distribution"""
    return weighted_choice([(region, data['weight']) for region, data in REGIONS.items()])

def generate_customer_profile(customer_id, customer_name):
    """Generate complete profile for a customer"""
    
    # Assign region
    region = assign_region(customer_name)
    region_data = REGIONS[region]
    
    # Pick state from region
    state = random.choice(region_data['states'])
    
    # Pick city from state
    city = random.choice(region_data['cities'].get(state, ['City']))
    
    # Generate postal code (realistic format)
    postal_code = f"{random.randint(10000, 99999)}"
    
    # Account type
    account_type = weighted_choice(ACCOUNT_TYPES)
    
    # Customer segment based on account type
    segment = weighted_choice(CUSTOMER_SEGMENTS[account_type])
    
    # Account status
    account_status = weighted_choice(ACCOUNT_STATUS)
    
    # Customer since (random date 1-5 years ago)
    days_ago = random.randint(365, 1825)  # 1-5 years
    customer_since = (datetime.now() - timedelta(days=days_ago)).strftime('%Y-%m-%d')
    
    # Monthly plan value based on segment
    plan_values = {
        'Individual': (69.99, 99.99),
        'Premium': (129.99, 179.99),
        'Senior': (45.00, 79.99),
        'Enterprise': (249.99, 399.99),
        'Mid-Market': (199.99, 299.99)
    }
    monthly_plan = round(random.uniform(*plan_values[segment]), 2)
    
    # Lifetime value based on tenure and monthly value
    months_active = days_ago / 30
    lifetime_value = round(monthly_plan * months_active, 2)
    
    # Payment method (Business uses Invoice more often)
    if account_type == 'Business':
        payment_method = random.choice(['Invoice', 'Invoice', 'Invoice', 'Bank Transfer'])
    else:
        payment_method = random.choice(PAYMENT_METHODS)
    
    # Preferred contact
    preferred_contact = random.choice(PREFERRED_CONTACT)
    
    # Language
    language = weighted_choice(LANGUAGES)
    
    # Age group
    age_group = random.choice(AGE_GROUPS)
    
    # Industry (only for Business accounts)
    industry = random.choice(INDUSTRIES) if account_type == 'Business' else 'N/A'
    
    # Email and phone
    email_name = customer_name.lower().replace(' ', '.')
    if account_type == 'Business':
        email_domain = random.choice(['techcorp.com', 'business.com', 'corporate.com', 'consulting.com'])
    else:
        email_domain = 'email.com'
    email = f"{email_name}@{email_domain}"
    
    phone = f"555-555-{random.randint(1000, 9999)}"
    
    # Build profile
    profile = {
        'CUSTOMER_ID': customer_id,
        'CUSTOMER_NAME': customer_name,
        'EMAIL': email,
        'PHONE': phone,
        'STATE': state,
        'REGION': region,
        'COUNTRY': 'United States',
        'CITY': city,
        'POSTAL_CODE': postal_code,
        'ACCOUNT_TYPE': account_type,
        'CUSTOMER_SEGMENT': segment,
        'CUSTOMER_SINCE': customer_since,
        'ACCOUNT_STATUS': account_status,
        'MONTHLY_PLAN_VALUE': monthly_plan,
        'LIFETIME_VALUE': lifetime_value,
        'PAYMENT_METHOD': payment_method,
        'PREFERRED_CONTACT': preferred_contact,
        'LANGUAGE_PREFERENCE': language,
        'AGE_GROUP': age_group,
        'INDUSTRY': industry
    }
    
    return profile

def main():
    """Generate customer profiles for ALL unique customers"""
    print("Extracting unique customers from call data...")
    
    customers = get_all_customers()
    
    print(f"Found {len(customers)} unique customers")
    print(f"Generating comprehensive customer profiles...")
    
    profiles = []
    for idx, customer_name in enumerate(customers, start=1):
        profile = generate_customer_profile(idx, customer_name)
        profiles.append(profile)
        
        if idx % 20 == 0:
            print(f"  Generated {idx}/{len(customers)} profiles...")
    
    # Write to CSV
    output_file = 'CUSTOMER_PROFILE_COMPLETE.csv'
    print(f"\nWriting to {output_file}...")
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        if profiles:
            writer = csv.DictWriter(f, fieldnames=profiles[0].keys())
            writer.writeheader()
            writer.writerows(profiles)
    
    print(f"✓ Successfully generated {len(profiles)} customer profiles!")
    print(f"✓ Output: {output_file}")
    
    # Print statistics
    print("\n=== CUSTOMER PROFILE STATISTICS ===")
    
    regions = defaultdict(int)
    segments = defaultdict(int)
    account_types = defaultdict(int)
    statuses = defaultdict(int)
    
    for profile in profiles:
        regions[profile['REGION']] += 1
        segments[profile['CUSTOMER_SEGMENT']] += 1
        account_types[profile['ACCOUNT_TYPE']] += 1
        statuses[profile['ACCOUNT_STATUS']] += 1
    
    print("\nRegion Distribution:")
    for region, count in sorted(regions.items(), key=lambda x: -x[1]):
        print(f"  {region}: {count} ({count/len(profiles)*100:.1f}%)")
    
    print("\nCustomer Segment Distribution:")
    for segment, count in sorted(segments.items(), key=lambda x: -x[1]):
        print(f"  {segment}: {count} ({count/len(profiles)*100:.1f}%)")
    
    print("\nAccount Type Distribution:")
    for acc_type, count in sorted(account_types.items()):
        print(f"  {acc_type}: {count} ({count/len(profiles)*100:.1f}%)")
    
    print("\nAccount Status Distribution:")
    for status, count in sorted(statuses.items()):
        print(f"  {status}: {count} ({count/len(profiles)*100:.1f}%)")
    
    # Calculate revenue metrics
    total_mrr = sum(p['MONTHLY_PLAN_VALUE'] for p in profiles)
    avg_ltv = sum(p['LIFETIME_VALUE'] for p in profiles) / len(profiles)
    
    print(f"\n💰 Revenue Metrics:")
    print(f"  Total MRR: ${total_mrr:,.2f}")
    print(f"  Average LTV: ${avg_ltv:,.2f}")
    
    print("\n✅ Customer profiles are now aligned with call data!")
    print("   All calls will have matching customer demographic information.")

if __name__ == "__main__":
    main()

