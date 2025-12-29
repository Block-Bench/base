#!/usr/bin/env python3
"""
Verify cleaned contracts for:
1. No remaining leakage (vulnerability hints)
2. Not over-sanitized (too different from original)
"""

import re
import json
from pathlib import Path
from difflib import unified_diff


# Leakage patterns to check
LEAKAGE_PATTERNS = [
    # Contract/variable names with vulnerability hints
    (r'\bVulnerable\w*', "Contract name contains 'Vulnerable'"),
    (r'\bvulnerable_\w*', "Variable name contains 'vulnerable_'"),
    (r'\bExploit\w*', "Contract name contains 'Exploit'"),
    (r'\bAttacker\w*', "Variable/contract contains 'Attacker'"),
    (r'\bAttackContract', "Contract name contains 'Attack'"),
    (r'\b\w+Bug\b(?<!debug)(?<!DEBUG)', "Contract name ends with 'Bug'"),
    (r'\bInsecure\w+', "Contract name contains 'Insecure'"),

    # Comments with vulnerability hints
    (r'@vulnerable_at_lines', "Contains @vulnerable_at_lines annotation"),
    (r'// <yes> <report>', "Contains vulnerability marker comment"),
    (r'//.*\bvulnerab', "Comment contains 'vulnerab'"),
    (r'//.*\bexploit', "Comment contains 'exploit' (case-insensitive)"),
    (r'//.*\battack\b', "Comment contains 'attack'"),

    # DeFiVulnLabs documentation
    (r'Name:.*\n.*Description:', "Contains DeFiVulnLabs documentation block"),
    (r'Mitigation:', "Contains 'Mitigation:' documentation"),

    # Security challenge hints
    (r'#spotthebug', "Contains #spotthebug challenge"),
    (r'immunefi', "Contains Immunefi reference"),
]

# Acceptable patterns (false positives)
ACCEPTABLE_PATTERNS = [
    r'abi\.encode',  # Built-in function
    r'msg\.sender',  # Built-in
    r'tx\.origin',   # Built-in
    r'".*attack.*"',  # String literals (revert messages etc)
    r"'.*attack.*'",  # String literals
    r'\bdebug\b',    # Common programming term
    r'\bDEBUG\b',    # Common programming term
]


def check_leakage(content: str, filename: str) -> list:
    """Check for remaining leakage patterns."""
    issues = []

    for pattern, description in LEAKAGE_PATTERNS:
        matches = re.findall(pattern, content, re.IGNORECASE | re.MULTILINE)
        if matches:
            # Filter out acceptable patterns
            real_matches = []
            for match in matches:
                is_acceptable = False
                for acceptable in ACCEPTABLE_PATTERNS:
                    if re.search(acceptable, match, re.IGNORECASE):
                        is_acceptable = True
                        break
                if not is_acceptable:
                    real_matches.append(match)

            if real_matches:
                issues.append({
                    "type": "leakage",
                    "description": description,
                    "matches": real_matches[:3],  # Show first 3
                    "count": len(real_matches)
                })

    return issues


def check_over_sanitization(original: str, cleaned: str, filename: str) -> list:
    """Check if sanitization is too aggressive."""
    issues = []

    # Count lines
    orig_lines = len(original.strip().split('\n'))
    clean_lines = len(cleaned.strip().split('\n'))

    # If cleaned is much shorter (>30% removed), flag it
    if orig_lines > 10 and clean_lines < orig_lines * 0.7:
        issues.append({
            "type": "over_sanitized",
            "description": f"Too many lines removed: {orig_lines} -> {clean_lines} ({100*(orig_lines-clean_lines)/orig_lines:.0f}% removed)",
            "severity": "warning"
        })

    # Count function definitions (lines starting with 'function' to avoid comments)
    orig_funcs = len(re.findall(r'^\s*function\s+\w+', original, re.MULTILINE))
    clean_funcs = len(re.findall(r'^\s*function\s+\w+', cleaned, re.MULTILINE))

    if orig_funcs > 0 and clean_funcs < orig_funcs:
        issues.append({
            "type": "over_sanitized",
            "description": f"Functions removed: {orig_funcs} -> {clean_funcs}",
            "severity": "error"
        })

    # Count contract definitions (only lines starting with 'contract' to avoid comments)
    orig_contracts = len(re.findall(r'^contract\s+\w+', original, re.MULTILINE))
    clean_contracts = len(re.findall(r'^contract\s+\w+', cleaned, re.MULTILINE))

    if orig_contracts > 0 and clean_contracts < orig_contracts:
        issues.append({
            "type": "over_sanitized",
            "description": f"Contracts removed: {orig_contracts} -> {clean_contracts}",
            "severity": "error"
        })

    return issues


def main():
    script_dir = Path(__file__).parent
    original_dir = script_dir / "original"
    cleaned_dir = script_dir / "cleaned"

    print("Verifying cleaned contracts...")
    print("=" * 60)

    total_files = 0
    leakage_files = []
    over_sanitized_files = []
    clean_files = 0

    for tier_num in [1, 2, 3, 4]:
        orig_tier = original_dir / f"tier{tier_num}" / "contracts"
        clean_tier = cleaned_dir / f"tier{tier_num}" / "contracts"

        if not clean_tier.exists():
            continue

        print(f"\n--- Tier {tier_num} ---")

        for clean_file in sorted(clean_tier.glob("*.sol")):
            total_files += 1
            filename = clean_file.name

            # Read cleaned content
            cleaned_content = clean_file.read_text()

            # Read original content
            orig_file = orig_tier / filename
            original_content = orig_file.read_text() if orig_file.exists() else ""

            # Check for leakage
            leakage_issues = check_leakage(cleaned_content, filename)

            # Check for over-sanitization
            over_issues = check_over_sanitization(original_content, cleaned_content, filename)

            if leakage_issues:
                leakage_files.append((filename, leakage_issues))
                print(f"  LEAKAGE: {filename}")
                for issue in leakage_issues:
                    print(f"    - {issue['description']}: {issue['matches'][:2]}")

            if over_issues:
                error_issues = [i for i in over_issues if i.get('severity') == 'error']
                if error_issues:
                    over_sanitized_files.append((filename, over_issues))
                    print(f"  OVER-SANITIZED: {filename}")
                    for issue in error_issues:
                        print(f"    - {issue['description']}")

            if not leakage_issues and not [i for i in over_issues if i.get('severity') == 'error']:
                clean_files += 1

    # Summary
    print("\n" + "=" * 60)
    print("VERIFICATION SUMMARY")
    print("=" * 60)
    print(f"Total files checked: {total_files}")
    print(f"Clean files: {clean_files}")
    print(f"Files with leakage: {len(leakage_files)}")
    print(f"Files over-sanitized: {len(over_sanitized_files)}")

    if leakage_files:
        print(f"\nLEAKAGE ISSUES ({len(leakage_files)} files):")
        for filename, issues in leakage_files[:10]:
            print(f"  - {filename}: {[i['description'] for i in issues]}")
        if len(leakage_files) > 10:
            print(f"  ... and {len(leakage_files) - 10} more")

    if over_sanitized_files:
        print(f"\nOVER-SANITIZATION ISSUES ({len(over_sanitized_files)} files):")
        for filename, issues in over_sanitized_files[:10]:
            print(f"  - {filename}: {[i['description'] for i in issues]}")
        if len(over_sanitized_files) > 10:
            print(f"  ... and {len(over_sanitized_files) - 10} more")

    # Return exit code
    if leakage_files or over_sanitized_files:
        return 1
    return 0


if __name__ == "__main__":
    exit(main())
