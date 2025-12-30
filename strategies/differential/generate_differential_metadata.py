#!/usr/bin/env python3
"""
Generate metadata for differential variant contracts.
Differential strategy: Fixed version of vulnerable contract for comparison.
Uses original metadata for exploit info + differential pair metadata for fix details.
"""

import json
import re
from datetime import datetime
from pathlib import Path

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
ORIGINAL_METADATA_DIR = BASE_DIR / "dataset/temporal_contamination/original/metadata"
PAIR_METADATA_DIR = BASE_DIR / "data/manual_strategies/differential/metadata"
DIFFERENTIAL_CONTRACTS_DIR = BASE_DIR / "dataset/temporal_contamination/differential/contracts"
DIFFERENTIAL_METADATA_DIR = BASE_DIR / "dataset/temporal_contamination/differential/metadata"

def extract_contract_names(contract_path: Path) -> list:
    """Extract contract names from a Solidity file."""
    content = contract_path.read_text()
    contracts = re.findall(r'contract\s+(\w+)', content)
    return contracts

def generate_differential_metadata(num: int) -> dict:
    """Generate metadata for a single differential contract."""
    num_str = f"{num:03d}"

    # Load original metadata
    original_metadata_path = ORIGINAL_METADATA_DIR / f"tc_{num_str}.json"
    if not original_metadata_path.exists():
        print(f"Warning: Original metadata not found: {original_metadata_path}")
        return None

    with open(original_metadata_path) as f:
        original = json.load(f)

    # Load pair metadata (for differential details)
    pair_metadata_path = PAIR_METADATA_DIR / f"df_pair_tc_{num_str}.json"
    if not pair_metadata_path.exists():
        print(f"Warning: Pair metadata not found: {pair_metadata_path}")
        return None

    with open(pair_metadata_path) as f:
        pair = json.load(f)

    # Get differential contract path
    diff_contract_path = DIFFERENTIAL_CONTRACTS_DIR / f"df_tc_{num_str}.sol"
    if not diff_contract_path.exists():
        print(f"Warning: Differential contract not found: {diff_contract_path}")
        return None

    contract_names = extract_contract_names(diff_contract_path)

    # Extract differential details from pair metadata
    diff_details = pair.get("differential_details", {})
    ground_truth = pair.get("ground_truth", {})
    version_a = pair.get("version_a", {})

    # Build differential metadata
    diff_metadata = {
        "sample_id": f"df_tc_{num_str}",
        "exploit_name": original.get("exploit_name", ""),
        "date": original.get("date", ""),
        "amount_lost_usd": original.get("amount_lost_usd", ""),
        "blockchain": original.get("blockchain", "ethereum"),
        "language": original.get("language", "solidity"),
        "vulnerability_type": original.get("vulnerability_type", ""),
        "vulnerability_subtype": original.get("vulnerability_subtype", ""),
        "severity": original.get("severity", ""),
        "difficulty_tier": original.get("difficulty_tier", 0),
        "is_vulnerable": False,  # Differential = FIXED version
        "temporal_category": original.get("temporal_category", ""),
        "description": version_a.get("description", f"Fixed version of {original.get('exploit_name', '')} vulnerability"),
        "vulnerable_contract": contract_names[0] if contract_names else "",
        "vulnerable_function": ground_truth.get("vulnerable_location", {}).get("function_name", original.get("vulnerable_function", "")),
        "vulnerable_lines": [],  # Fixed version - no vulnerable lines
        "attack_scenario": original.get("attack_scenario", ""),
        "root_cause": ground_truth.get("root_cause", original.get("root_cause", "")),
        "fix_description": original.get("fix_description", ""),
        "source_reference": original.get("source_reference", ""),
        "external_references": original.get("external_references", []),
        "tags": [t for t in original.get("tags", []) if t not in ["bridge"]] + ["differential", "fixed"],
        "variant_type": "differential",
        "variant_parent_id": f"tc_{num_str}",
        "notes": original.get("notes", ""),
        "contract_file": f"contracts/df_tc_{num_str}.sol",
        "subset": "annotated",
        "original_subset": "temporal_contamination",
        "transformation": {
            "type": "differential",
            "strategy": "minimal_fix",
            "source_dir": str(ORIGINAL_METADATA_DIR.parent),
            "source_contract": str(ORIGINAL_METADATA_DIR.parent / "contracts" / f"tc_{num_str}.sol"),
            "source_metadata": str(original_metadata_path),
            "pair_metadata": str(pair_metadata_path),
            "script": "manual",
            "is_fixed_version": True,
            "fix_type": diff_details.get("difference_type", "unknown"),
            "fix_description": diff_details.get("changes_description_a", ""),
            "exact_changes": diff_details.get("exact_changes", []),
            "why_fix_works": diff_details.get("why_this_matters", ""),
            "contracts_in_file": contract_names,
            "created_date": datetime.now().isoformat()
        }
    }

    return diff_metadata

def main():
    """Generate metadata for all differential contracts."""
    DIFFERENTIAL_METADATA_DIR.mkdir(parents=True, exist_ok=True)

    generated = 0
    errors = 0

    for num in range(1, 51):
        num_str = f"{num:03d}"
        metadata = generate_differential_metadata(num)

        if metadata:
            output_path = DIFFERENTIAL_METADATA_DIR / f"df_tc_{num_str}.json"
            with open(output_path, 'w') as f:
                json.dump(metadata, f, indent=2)
            print(f"Generated: {output_path.name}")
            generated += 1
        else:
            errors += 1

    print(f"\nDone: Generated {generated} metadata files, {errors} errors")

if __name__ == "__main__":
    main()
