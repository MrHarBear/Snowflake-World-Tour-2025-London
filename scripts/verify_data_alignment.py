"""
Verify that customer profiles cover all customers in call data
"""

import csv

def get_customer_names_from_calls(filename):
    """Extract unique customer names from call data"""
    customers = set()
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('CUSTOMER_NAME', '').strip()
            if name and name != 'None' and 'unknown' not in name.lower():
                customers.add(name)
    return customers

def get_customer_names_from_profiles(filename):
    """Extract customer names from profile data"""
    customers = set()
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('CUSTOMER_NAME', '').strip()
            if name:
                customers.add(name)
    return customers

def main():
    print("=" * 60)
    print("DATA ALIGNMENT VERIFICATION")
    print("=" * 60)
    
    # Get customers from combined call data
    print("\n📞 Analyzing call data...")
    call_customers = get_customer_names_from_calls('FINAL_TABLE_COMPLETE.csv')
    print(f"  Unique customers in calls: {len(call_customers)}")
    
    # Get customers from profiles
    print("\n👤 Analyzing customer profiles...")
    profile_customers = get_customer_names_from_profiles('CUSTOMER_PROFILE_COMPLETE.csv')
    print(f"  Unique customers in profiles: {len(profile_customers)}")
    
    # Check coverage
    print("\n🔍 Join Coverage Analysis:")
    covered = call_customers.intersection(profile_customers)
    missing = call_customers - profile_customers
    extra = profile_customers - call_customers
    
    print(f"  Customers with matching profiles: {len(covered)}")
    print(f"  Customers missing profiles: {len(missing)}")
    print(f"  Extra profiles (no calls): {len(extra)}")
    print(f"  Join coverage: {len(covered)/len(call_customers)*100:.1f}%")
    
    if missing:
        print(f"\n⚠️  WARNING: {len(missing)} customers have calls but NO profile:")
        for i, name in enumerate(sorted(missing)[:10], 1):
            print(f"    {i}. {name}")
        if len(missing) > 10:
            print(f"    ... and {len(missing) - 10} more")
    else:
        print("\n✅ PERFECT! All customers have matching profiles!")
    
    if extra:
        print(f"\n📊 Note: {len(extra)} profiles have no calls (this is OK)")
    
    # Sample verification
    print("\n📋 Sample Join Preview:")
    print("  (First 5 customers with calls)")
    for i, name in enumerate(sorted(covered)[:5], 1):
        print(f"    {i}. {name} ✓")
    
    print("\n" + "=" * 60)
    if len(missing) == 0:
        print("✅ DATA ALIGNMENT: PERFECT")
        print("   All calls can be joined to customer profiles!")
    else:
        print("⚠️  DATA ALIGNMENT: NEEDS FIXING")
        print(f"   {len(missing)} customers need profiles generated")
    print("=" * 60)

if __name__ == "__main__":
    main()

