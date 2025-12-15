#!/usr/bin/env python3
"""
Display sample entries from the processed dataset for inspection.
"""

import json
from pathlib import Path
import random


def truncate_content(content: str, max_lines: int = 30) -> str:
    """Truncate long content for display."""
    lines = content.split('\n')
    if len(lines) <= max_lines:
        return content
    return '\n'.join(lines[:max_lines]) + f"\n... ({len(lines) - max_lines} more lines)"


def display_entry(entry: dict, show_content: bool = False):
    """Pretty print a dataset entry."""
    print("="*80)
    print(f"ID: {entry['id']}")
    print(f"Source: {entry['source_dataset']}")
    print(f"Language: {entry['language']} | Chain: {entry.get('chain', 'N/A')}")
    print(f"Vulnerability: {entry['vulnerability_type']}")
    print(f"Severity: {entry['severity'].upper()} | Difficulty Tier: {entry['difficulty_tier']}")
    print(f"File: {entry['file_name']}")
    
    if 'vulnerable_function' in entry:
        print(f"Vulnerable Function: {entry['vulnerable_function']}")
    
    print(f"\nDescription:")
    print(f"  {entry.get('description', 'N/A')}")
    
    print(f"\nFix:")
    print(f"  {entry.get('fix_description', 'N/A')}")
    
    print(f"\nMetadata:")
    print(f"  - Has PoC: {entry.get('has_poc', False)}")
    print(f"  - Has Remediation: {entry.get('has_remediation', False)}")
    print(f"  - Context Level: {entry.get('context_level', 'N/A')}")
    
    if show_content:
        print(f"\nCode (truncated):")
        print("-"*80)
        print(truncate_content(entry['file_content']))
        print("-"*80)
    
    print()


def main():
    base_path = Path("/Users/poamen/projects/grace/blockbench/base/dataset")
    master_file = base_path / "metadata" / "difficulty_stratified_master.json"
    
    # Load master dataset
    with open(master_file, "r") as f:
        all_entries = json.load(f)
    
    print(f"\n{'='*80}")
    print(f"SAMPLE ENTRIES FROM DIFFICULTY STRATIFIED DATASET")
    print(f"{'='*80}")
    print(f"Total entries: {len(all_entries)}\n")
    
    # Show one sample from each tier
    print("="*80)
    print("SAMPLES BY DIFFICULTY TIER (one from each)")
    print("="*80)
    print()
    
    for tier in [1, 2, 3, 4]:
        tier_entries = [e for e in all_entries if e['difficulty_tier'] == tier]
        if tier_entries:
            print(f"\n{'='*80}")
            print(f"TIER {tier} SAMPLE ({len(tier_entries)} total entries in this tier)")
            print(f"{'='*80}")
            sample = tier_entries[0]  # Show first entry
            display_entry(sample, show_content=False)
    
    # Show one Solana sample
    solana_entries = [e for e in all_entries if e['language'] == 'rust']
    if solana_entries:
        print(f"\n{'='*80}")
        print(f"SOLANA/RUST SAMPLE ({len(solana_entries)} total Solana entries)")
        print(f"{'='*80}")
        display_entry(solana_entries[0], show_content=False)
    
    # Show vulnerability type distribution
    print(f"\n{'='*80}")
    print("TOP 10 VULNERABILITY TYPES")
    print(f"{'='*80}")
    
    vuln_counts = {}
    for entry in all_entries:
        vtype = entry['vulnerability_type']
        vuln_counts[vtype] = vuln_counts.get(vtype, 0) + 1
    
    sorted_vulns = sorted(vuln_counts.items(), key=lambda x: -x[1])[:10]
    for i, (vtype, count) in enumerate(sorted_vulns, 1):
        print(f"{i:2}. {vtype:35} {count:3} entries")
    
    print(f"\n{'='*80}")
    print("To view full code samples, modify show_content=True in display_entry()")
    print(f"{'='*80}\n")


if __name__ == "__main__":
    main()
