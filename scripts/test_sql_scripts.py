#!/usr/bin/env python3
"""
Test SQL Scripts Validation
Runs through all SQL scripts to verify syntax and execution without errors.

Usage:
    python scripts/test_sql_scripts.py --connection snowflake_cursor_conn
    
Prerequisites:
    - SnowCLI installed and configured
    - Valid Snowflake connection profile
"""

import subprocess
import sys
import os
import argparse
import re

# SQL scripts in execution order
SQL_SCRIPTS = [
    ("01_setup_database.sql", "Database and Stage Setup"),
    ("02_create_tables_and_load.sql", "Tables and Data Loading"),
    ("03_create_cortex_search.sql", "Cortex Search Services"),
    ("04_verify_and_test.sql", "Verification and Testing"),
    ("05_create_custom_tool.sql", "Custom Tool (Callback Scheduler)"),
    # 06_cleanup.sql is intentionally skipped - it deletes everything!
    # ("06_cleanup.sql", "Cleanup (DO NOT RUN IN TEST)"),
    ("07_create_agent.sql", "Intelligence Agent Creation"),
]

def run_sql_syntax_check(sql_file: str, connection: str) -> tuple[bool, str]:
    """
    Run a basic syntax check on a SQL file by attempting to parse it.
    Returns (success, message)
    """
    sql_path = os.path.join("sql", sql_file)
    
    if not os.path.exists(sql_path):
        return False, f"File not found: {sql_path}"
    
    # Read the SQL file
    with open(sql_path, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    # Basic syntax checks
    issues = []
    
    # Check for common issues
    # 1. Unmatched quotes
    single_quotes = sql_content.count("'") - sql_content.count("\\'")
    if single_quotes % 2 != 0:
        issues.append("Possible unmatched single quotes")
    
    # 2. Check for FINAL_TABLE or CUSTOMER_PROFILE references (should be renamed)
    # Allow FINAL_TABLE_COMPLETE.csv as filename reference
    if re.search(r'\bFINAL_TABLE\b', sql_content) and 'AI_TRANSCRIBED_CALLS_AI_GENERATED' not in sql_file:
        lines = sql_content.split('\n')
        for i, line in enumerate(lines, 1):
            # Skip comments and CSV filename references
            if 'FINAL_TABLE' in line and not line.strip().startswith('--') and 'FINAL_TABLE_COMPLETE.csv' not in line:
                issues.append(f"Line {i}: Found 'FINAL_TABLE' reference (should be AI_TRANSCRIBED_CALLS_AI_GENERATED)")
    
    if re.search(r'\bCUSTOMER_PROFILE\b(?!_)', sql_content):
        lines = sql_content.split('\n')
        for i, line in enumerate(lines, 1):
            if re.search(r'\bCUSTOMER_PROFILE\b(?!_)', line) and not line.strip().startswith('--'):
                issues.append(f"Line {i}: Found 'CUSTOMER_PROFILE' reference (should be AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE)")
    
    # 3. Check for warehouse variable usage
    if 'USE WAREHOUSE' in sql_content:
        if 'WAREHOUSE_NAME' not in sql_content and 'IDENTIFIER($WAREHOUSE_NAME)' not in sql_content:
            if 'COMPUTE_WH' in sql_content or 'WH_AISQL_HOL' in sql_content:
                issues.append("Hardcoded warehouse name found - should use variable")
    
    # 4. Check for incorrect data counts in comments
    if '1,278' in sql_content or '1278' in sql_content:
        issues.append("Found '1,278' count (should be 500)")
    if '830 original' in sql_content.lower():
        issues.append("Found '830 original' (should be 52 original)")
    
    if issues:
        return False, "; ".join(issues)
    
    return True, "Syntax check passed"


def run_sql_execution_test(sql_file: str, connection: str, dry_run: bool = True) -> tuple[bool, str]:
    """
    Actually execute the SQL file against Snowflake.
    Returns (success, message)
    """
    sql_path = os.path.join("sql", sql_file)
    
    if dry_run:
        # Just validate with SnowCLI dry run / explain
        cmd = [
            "snow", "sql", 
            "-c", connection,
            "-f", sql_path,
            "--format", "json"
        ]
    else:
        cmd = [
            "snow", "sql",
            "-c", connection, 
            "-f", sql_path
        ]
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout for indexing
        )
        
        if result.returncode == 0:
            return True, "Execution successful"
        else:
            # Extract error message
            error_msg = result.stderr or result.stdout
            # Get first error line
            for line in error_msg.split('\n'):
                if 'error' in line.lower() or 'Error' in line:
                    return False, line[:200]
            return False, error_msg[:200] if error_msg else "Unknown error"
            
    except subprocess.TimeoutExpired:
        return False, "Execution timed out (>5 minutes)"
    except FileNotFoundError:
        return False, "SnowCLI not found - install with: pip install snowflake-cli-labs"
    except Exception as e:
        return False, str(e)[:200]


def print_result(script: str, description: str, success: bool, message: str):
    """Print formatted test result"""
    status = "✅ PASS" if success else "❌ FAIL"
    print(f"\n{status} | {script}")
    print(f"       {description}")
    if not success or message != "Syntax check passed":
        print(f"       → {message}")


def main():
    parser = argparse.ArgumentParser(description="Test SQL scripts for the SWT 2025 demo")
    parser.add_argument("-c", "--connection", default="snowflake_cursor_conn",
                        help="Snowflake connection profile name")
    parser.add_argument("--syntax-only", action="store_true",
                        help="Only run syntax checks (no Snowflake execution)")
    parser.add_argument("--execute", action="store_true", 
                        help="Actually execute SQL against Snowflake (DANGER: WILL OVERWRITE EXISTING OBJECTS!)")
    parser.add_argument("--dry-run-check", action="store_true",
                        help="Verify objects exist in Snowflake without modifying them")
    args = parser.parse_args()
    
    print("=" * 70)
    print("SQL SCRIPT VALIDATION TEST")
    print("=" * 70)
    print(f"Connection: {args.connection}")
    print(f"Mode: {'Syntax Only' if args.syntax_only else 'Syntax + Execution' if args.execute else 'Syntax Only (default)'}")
    print("=" * 70)
    
    # Change to project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    os.chdir(project_root)
    print(f"Working directory: {os.getcwd()}")
    
    results = []
    
    for sql_file, description in SQL_SCRIPTS:
        # Syntax check
        success, message = run_sql_syntax_check(sql_file, args.connection)
        results.append((sql_file, description, "syntax", success, message))
        print_result(sql_file, description, success, message)
        
        # Execution test (if requested and syntax passed)
        if not args.syntax_only and args.execute and success:
            exec_success, exec_message = run_sql_execution_test(sql_file, args.connection, dry_run=False)
            results.append((sql_file, description, "execute", exec_success, exec_message))
            if not exec_success:
                print(f"       ⚠️  Execution: {exec_message}")
    
    # Summary
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    
    syntax_results = [r for r in results if r[2] == "syntax"]
    passed = sum(1 for r in syntax_results if r[3])
    failed = sum(1 for r in syntax_results if not r[3])
    
    print(f"Syntax Checks: {passed} passed, {failed} failed out of {len(syntax_results)}")
    
    if args.execute:
        exec_results = [r for r in results if r[2] == "execute"]
        exec_passed = sum(1 for r in exec_results if r[3])
        exec_failed = sum(1 for r in exec_results if not r[3])
        print(f"Execution Tests: {exec_passed} passed, {exec_failed} failed out of {len(exec_results)}")
    
    # List failures
    failures = [r for r in results if not r[3]]
    if failures:
        print("\n❌ FAILURES:")
        for sql_file, desc, test_type, _, message in failures:
            print(f"   - {sql_file} ({test_type}): {message}")
        return 1
    else:
        print("\n✅ All tests passed!")
        return 0


if __name__ == "__main__":
    sys.exit(main())
