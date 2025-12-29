#!/usr/bin/env python3
"""
Script to set up differential pairs for qualifying TC samples.
Uses existing df_a_tc_* (safe) and base tc_* (vulnerable) files.
"""

import json
import os
import shutil
import subprocess
from pathlib import Path

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
TC_CONTRACTS = BASE_DIR / "data/base/contracts"
TC_METADATA = BASE_DIR / "data/base/metadata"
DF_SOURCE = BASE_DIR / "support/rough/differential"
OUTPUT_DIR = BASE_DIR / "data/manual_strategies/differential"
CONTRACTS_DIR = OUTPUT_DIR / "contracts"
METADATA_DIR = OUTPUT_DIR / "metadata"

# Qualifying pairs (diff <= 20 lines) - tc_006 to tc_050
QUALIFYING_IDS = [
    6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22,
    24, 26, 28, 29, 30, 32, 33, 35, 36, 38, 42, 43, 47, 48, 49, 50
]

def get_diff_lines(file1, file2):
    """Get number of differing lines between two files."""
    result = subprocess.run(['diff', str(file1), str(file2)], capture_output=True, text=True)
    return len([l for l in result.stdout.split('\n') if l.startswith('<') or l.startswith('>')])

def get_diff_details(file1, file2):
    """Get actual diff content."""
    result = subprocess.run(['diff', str(file1), str(file2)], capture_output=True, text=True)
    return result.stdout

def create_pair_metadata(tc_id, tc_meta, diff_lines, diff_details):
    """Create metadata for a differential pair."""

    ground_truth = tc_meta.get('ground_truth', {})
    temporal = tc_meta.get('temporal_fields', {})
    exploit_info = temporal.get('exploit_info', {})

    return {
        "pair_id": f"df_pair_tc_{tc_id:03d}",
        "strategy": "differential",
        "variant": "minimal",
        "original_id": f"tc_{tc_id:03d}",
        "original_subset": "temporal_contamination",

        "version_a": {
            "id": f"df_a_tc_{tc_id:03d}",
            "file": f"contracts/df_a_tc_{tc_id:03d}.sol",
            "is_vulnerable": False,
            "status": "safe",
            "description": "Fixed version with minimal changes to address the vulnerability"
        },
        "version_b": {
            "id": f"df_b_tc_{tc_id:03d}",
            "file": f"contracts/df_b_tc_{tc_id:03d}.sol",
            "is_vulnerable": True,
            "status": "vulnerable",
            "description": "Original vulnerable version from base dataset"
        },

        "ground_truth": {
            "vulnerability_type": ground_truth.get('vulnerability_type', 'unknown'),
            "severity": ground_truth.get('severity', 'unknown'),
            "vulnerable_location": ground_truth.get('vulnerable_location', {}),
            "root_cause": ground_truth.get('root_cause', ''),
            "attack_vector": ground_truth.get('attack_vector', ''),
            "impact": ground_truth.get('impact', ''),
            "correct_fix": ground_truth.get('correct_fix', '')
        },

        "differential_details": {
            "difference_type": "minimal_fix",
            "diff_lines": diff_lines,
            "diff_summary": f"Minimal fix with {diff_lines} lines changed",
            "raw_diff": diff_details[:2000] if len(diff_details) > 2000 else diff_details
        },

        "provenance": {
            "source": tc_meta.get('provenance', {}).get('source', 'rekt_news'),
            "original_exploit": exploit_info.get('protocol_name', 'Unknown'),
            "exploit_date": exploit_info.get('exploit_date', 'Unknown'),
            "protocol_name": exploit_info.get('protocol_name', 'Unknown'),
            "chain": exploit_info.get('chain', 'ethereum'),
            "funds_lost_usd": exploit_info.get('funds_lost_usd', 0)
        },

        "tags": [
            "differential",
            "minimal_fix",
            "temporal_contamination",
            ground_truth.get('vulnerability_type', 'unknown')
        ],

        "quality_metrics": {
            "diff_lines": diff_lines,
            "is_minimal": diff_lines <= 10,
            "solidity_version_match": True
        }
    }


def main():
    # Ensure output directories exist
    CONTRACTS_DIR.mkdir(parents=True, exist_ok=True)
    METADATA_DIR.mkdir(parents=True, exist_ok=True)

    processed = []
    errors = []

    for tc_id in QUALIFYING_IDS:
        tc_file = TC_CONTRACTS / f"tc_{tc_id:03d}.sol"
        df_a_file = DF_SOURCE / f"df_a_tc_{tc_id:03d}.sol"
        tc_meta_file = TC_METADATA / f"tc_{tc_id:03d}.json"

        # Check files exist
        if not tc_file.exists():
            errors.append(f"tc_{tc_id:03d}: Missing base contract")
            continue
        if not df_a_file.exists():
            errors.append(f"tc_{tc_id:03d}: Missing df_a contract")
            continue
        if not tc_meta_file.exists():
            errors.append(f"tc_{tc_id:03d}: Missing metadata")
            continue

        # Get diff info
        diff_lines = get_diff_lines(tc_file, df_a_file)
        diff_details = get_diff_details(tc_file, df_a_file)

        # Load original metadata
        with open(tc_meta_file) as f:
            tc_meta = json.load(f)

        # Copy df_a (safe version)
        df_a_dest = CONTRACTS_DIR / f"df_a_tc_{tc_id:03d}.sol"
        shutil.copy(df_a_file, df_a_dest)

        # Copy tc as df_b (vulnerable version)
        df_b_dest = CONTRACTS_DIR / f"df_b_tc_{tc_id:03d}.sol"
        shutil.copy(tc_file, df_b_dest)

        # Create metadata
        pair_meta = create_pair_metadata(tc_id, tc_meta, diff_lines, diff_details)
        meta_dest = METADATA_DIR / f"df_pair_tc_{tc_id:03d}.json"
        with open(meta_dest, 'w') as f:
            json.dump(pair_meta, f, indent=2)

        exploit_name = tc_meta.get('temporal_fields', {}).get('exploit_info', {}).get('protocol_name', 'Unknown')
        processed.append(f"tc_{tc_id:03d}: {diff_lines:2d} lines - {exploit_name}")
        print(f"Processed: tc_{tc_id:03d} ({exploit_name})")

    # Summary
    print(f"\n{'='*50}")
    print(f"SUMMARY")
    print(f"{'='*50}")
    print(f"Processed: {len(processed)} pairs")
    print(f"Created: {len(processed) * 2} .sol files")
    print(f"Created: {len(processed)} metadata files")

    if errors:
        print(f"\nErrors ({len(errors)}):")
        for err in errors:
            print(f"  - {err}")

    # Create index file
    index = {
        "strategy": "differential",
        "variant": "minimal",
        "description": "Minimal differential pairs for testing precise vulnerability understanding",
        "total_pairs": len(processed),
        "pairs": [f"df_pair_tc_{tc_id:03d}" for tc_id in QUALIFYING_IDS if f"tc_{tc_id:03d}" in ' '.join(processed)],
        "excluded_ids": [8, 20, 23, 25, 27, 31, 34, 37, 39, 40, 41, 44, 45, 46],
        "exclusion_reason": "diff > 20 lines - not minimal enough"
    }

    with open(OUTPUT_DIR / "index.json", 'w') as f:
        json.dump(index, f, indent=2)

    print(f"\nCreated index.json")


if __name__ == "__main__":
    main()
