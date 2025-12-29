#!/usr/bin/env python3
"""
Script to create original versions (o_tc_* and nc_o_tc_*) for tc_006 to tc_050
"""

import json
import re
import shutil
from pathlib import Path

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
ANNOTATED_DIR = BASE_DIR / "support/dataset/processed/temporal_contamination/pre_cutoff_originals/annotated"
MAPPING_FILE = BASE_DIR / "support/dataset/processed/temporal_contamination/pre_cutoff_originals/unannotated/mapping.json"
OUTPUT_DIR = BASE_DIR / "data/originals"
CONTRACTS_DIR = OUTPUT_DIR / "contracts"
METADATA_DIR = OUTPUT_DIR / "metadata"

def strip_comments(solidity_code: str) -> str:
    """Remove all comments from Solidity code while preserving structure."""
    # Remove multi-line comments (/* ... */ and /** ... */)
    code = re.sub(r'/\*[\s\S]*?\*/', '', solidity_code)

    # Remove single-line comments (// ...)
    code = re.sub(r'//.*$', '', code, flags=re.MULTILINE)

    # Clean up excessive blank lines (more than 2 consecutive)
    code = re.sub(r'\n{3,}', '\n\n', code)

    # Remove trailing whitespace from each line
    lines = [line.rstrip() for line in code.split('\n')]

    # Remove leading blank lines
    while lines and not lines[0].strip():
        lines.pop(0)

    return '\n'.join(lines)

def create_metadata(sample_id: int, mapping_entry: dict, annotated_file: str) -> dict:
    """Create metadata JSON for an original file."""
    tc_id = f"tc_{sample_id:03d}"
    o_id = f"o_{tc_id}"

    return {
        "id": o_id,
        "contract_file": f"contracts/{o_id}.sol",
        "subset": "originals",
        "variant": "annotated",
        "original_id": tc_id,
        "exploit_info": {
            "exploit_name": mapping_entry.get("exploit_name", "Unknown"),
            "date": mapping_entry.get("date", "Unknown"),
            "amount_lost_usd": mapping_entry.get("amount_lost_usd", "0"),
            "vulnerability_type": mapping_entry.get("vulnerability_type", "unknown")
        },
        "source_file": f"pre_cutoff_originals/annotated/{annotated_file}",
        "description": f"Original annotated version of {tc_id} with full vulnerability documentation",
        "contains_annotations": True,
        "leaky_contract_name": True,
        "suitable_for_evaluation": False,
        "tags": [
            "original",
            "annotated",
            "temporal_contamination",
            mapping_entry.get("vulnerability_type", "unknown")
        ]
    }

def create_nc_metadata(sample_id: int, mapping_entry: dict) -> dict:
    """Create metadata JSON for a no-comment original file."""
    tc_id = f"tc_{sample_id:03d}"
    nc_o_id = f"nc_o_{tc_id}"

    return {
        "id": nc_o_id,
        "contract_file": f"contracts/{nc_o_id}.sol",
        "subset": "originals",
        "variant": "no_comment",
        "original_id": tc_id,
        "exploit_info": {
            "exploit_name": mapping_entry.get("exploit_name", "Unknown"),
            "date": mapping_entry.get("date", "Unknown"),
            "amount_lost_usd": mapping_entry.get("amount_lost_usd", "0"),
            "vulnerability_type": mapping_entry.get("vulnerability_type", "unknown")
        },
        "description": f"No-comment version of {tc_id} - comments stripped but leaky contract names preserved",
        "contains_annotations": False,
        "leaky_contract_name": True,
        "suitable_for_evaluation": False,
        "tags": [
            "original",
            "no_comment",
            "temporal_contamination",
            mapping_entry.get("vulnerability_type", "unknown")
        ]
    }

def main():
    # Load mapping
    with open(MAPPING_FILE, 'r') as f:
        mapping_data = json.load(f)

    mappings = mapping_data['mappings']

    # Process samples 6-50 (indices 5-49)
    processed = 0
    errors = []

    for i, entry in enumerate(mappings):
        sample_num = i + 1  # sample_001 is index 0

        # Skip tc_001 to tc_005 (already done)
        if sample_num < 6:
            continue

        annotated_file = entry['annotated_file']
        annotated_path = ANNOTATED_DIR / annotated_file

        if not annotated_path.exists():
            errors.append(f"Missing: {annotated_file}")
            continue

        tc_id = f"tc_{sample_num:03d}"
        o_id = f"o_{tc_id}"
        nc_o_id = f"nc_o_{tc_id}"

        # Read annotated source
        with open(annotated_path, 'r') as f:
            annotated_code = f.read()

        # Write annotated version (o_tc_XXX.sol)
        o_path = CONTRACTS_DIR / f"{o_id}.sol"
        with open(o_path, 'w') as f:
            f.write(annotated_code)

        # Create and write no-comment version (nc_o_tc_XXX.sol)
        nc_code = strip_comments(annotated_code)
        nc_path = CONTRACTS_DIR / f"{nc_o_id}.sol"
        with open(nc_path, 'w') as f:
            f.write(nc_code)

        # Create and write metadata for annotated version
        o_metadata = create_metadata(sample_num, entry, annotated_file)
        o_meta_path = METADATA_DIR / f"{o_id}.json"
        with open(o_meta_path, 'w') as f:
            json.dump(o_metadata, f, indent=2)

        # Create and write metadata for no-comment version
        nc_metadata = create_nc_metadata(sample_num, entry)
        nc_meta_path = METADATA_DIR / f"{nc_o_id}.json"
        with open(nc_meta_path, 'w') as f:
            json.dump(nc_metadata, f, indent=2)

        processed += 1
        print(f"Processed: {tc_id} ({entry['exploit_name']})")

    print(f"\n=== Summary ===")
    print(f"Processed: {processed} samples")
    print(f"Created: {processed * 2} .sol files")
    print(f"Created: {processed * 2} .json metadata files")

    if errors:
        print(f"\nErrors ({len(errors)}):")
        for err in errors:
            print(f"  - {err}")

if __name__ == "__main__":
    main()
