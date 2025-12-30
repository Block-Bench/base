#!/usr/bin/env python3
"""
Generate metadata for trojan horse variant contracts.
Trojan strategy: Remove vulnerability docs, add distracting code, preserve vulnerability.
"""

import json
import os
import re
from datetime import datetime
from pathlib import Path

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
ORIGINAL_METADATA_DIR = BASE_DIR / "dataset/temporal_contamination/original/metadata"
TROJAN_CONTRACTS_DIR = BASE_DIR / "dataset/temporal_contamination/trojan/contracts"
TROJAN_METADATA_DIR = BASE_DIR / "dataset/temporal_contamination/trojan/metadata"

def count_distractors(contract_path: Path) -> dict:
    """Count distractor patterns in a trojan contract."""
    content = contract_path.read_text()

    distractors = {
        "config_variables": 0,
        "score_variables": 0,
        "activity_variables": 0,
        "fake_functions": 0,
        "view_helpers": 0,
        "suspicious_names": 0,
    }

    # Config/version variables
    config_patterns = [
        r'configVersion', r'configurationVersion', r'protocolVersion',
        r'gatewayConfigVersion', r'systemConfigVersion'
    ]
    for pattern in config_patterns:
        distractors["config_variables"] += len(re.findall(pattern, content))

    # Score/metrics variables
    score_patterns = [
        r'Score\b', r'Metric\b', r'Throughput', r'Activity'
    ]
    for pattern in score_patterns:
        distractors["score_variables"] += len(re.findall(pattern, content))

    # Suspicious-looking names (red herrings)
    suspicious_patterns = [
        r'unsafe', r'Unsafe', r'vulnerable', r'Vulnerable',
        r'malicious', r'Malicious', r'bypass', r'Bypass',
        r'manipulated', r'Manipulated'
    ]
    for pattern in suspicious_patterns:
        distractors["suspicious_names"] += len(re.findall(pattern, content))

    # Fake functions (emergency, toggle, override)
    fake_func_patterns = [
        r'function\s+emergency\w+',
        r'function\s+toggle\w+',
        r'function\s+_record\w+',
        r'function\s+_update\w+Score'
    ]
    for pattern in fake_func_patterns:
        distractors["fake_functions"] += len(re.findall(pattern, content))

    # View helpers (getMetrics, getUserMetrics, etc.)
    view_patterns = [
        r'function\s+get\w+Metrics',
        r'function\s+get\w+Stats',
        r'function\s+get\w+Info'
    ]
    for pattern in view_patterns:
        distractors["view_helpers"] += len(re.findall(pattern, content))

    return distractors

def extract_contract_names(contract_path: Path) -> list:
    """Extract contract names from a Solidity file."""
    content = contract_path.read_text()
    contracts = re.findall(r'contract\s+(\w+)', content)
    return contracts

def generate_trojan_metadata(num: int) -> dict:
    """Generate metadata for a single trojan contract."""
    num_str = f"{num:03d}"

    # Load original metadata
    original_metadata_path = ORIGINAL_METADATA_DIR / f"tc_{num_str}.json"
    if not original_metadata_path.exists():
        print(f"Warning: Original metadata not found: {original_metadata_path}")
        return None

    with open(original_metadata_path) as f:
        original = json.load(f)

    # Get trojan contract path
    trojan_contract_path = TROJAN_CONTRACTS_DIR / f"tr_tc_{num_str}.sol"
    if not trojan_contract_path.exists():
        print(f"Warning: Trojan contract not found: {trojan_contract_path}")
        return None

    # Analyze distractors
    distractors = count_distractors(trojan_contract_path)
    contract_names = extract_contract_names(trojan_contract_path)

    # Build trojan metadata
    trojan_metadata = {
        "sample_id": f"tr_tc_{num_str}",
        "exploit_name": original.get("exploit_name", ""),
        "date": original.get("date", ""),
        "amount_lost_usd": original.get("amount_lost_usd", ""),
        "blockchain": original.get("blockchain", "ethereum"),
        "language": original.get("language", "solidity"),
        "vulnerability_type": original.get("vulnerability_type", ""),
        "vulnerability_subtype": original.get("vulnerability_subtype", ""),
        "severity": original.get("severity", ""),
        "difficulty_tier": original.get("difficulty_tier", 0),
        "is_vulnerable": True,  # Trojans preserve the vulnerability
        "temporal_category": original.get("temporal_category", ""),
        "description": original.get("description", ""),
        "vulnerable_contract": contract_names[0] if contract_names else "",
        "vulnerable_function": original.get("vulnerable_function", ""),
        "vulnerable_lines": [],  # Lines change due to distractors
        "attack_scenario": original.get("attack_scenario", ""),
        "root_cause": original.get("root_cause", ""),
        "fix_description": original.get("fix_description", ""),
        "source_reference": original.get("source_reference", ""),
        "external_references": original.get("external_references", []),
        "tags": [t for t in original.get("tags", []) if t != "bridge"] + ["trojan"],
        "variant_type": "trojan",
        "variant_parent_id": f"tc_{num_str}",
        "notes": original.get("notes", ""),
        "contract_file": f"contracts/tr_tc_{num_str}.sol",
        "subset": "annotated",
        "original_subset": "temporal_contamination",
        "transformation": {
            "type": "trojan",
            "strategy": "decoy",
            "source_dir": str(ORIGINAL_METADATA_DIR.parent),
            "source_contract": str(ORIGINAL_METADATA_DIR.parent / "contracts" / f"tc_{num_str}.sol"),
            "source_metadata": str(original_metadata_path),
            "script": "manual",
            "changes": [
                "Removed vulnerability documentation and comments",
                "Added distractor code (fake security metrics, config tracking)",
                "Added suspicious-named variables as red herrings",
                "Preserved original vulnerability",
                "Renamed contracts to generic names"
            ],
            "distractors": distractors,
            "contracts_renamed": contract_names,
            "vulnerability_preserved": True,
            "documentation_removed": True,
            "created_date": datetime.now().isoformat()
        }
    }

    return trojan_metadata

def main():
    """Generate metadata for all trojan contracts."""
    TROJAN_METADATA_DIR.mkdir(parents=True, exist_ok=True)

    generated = 0
    errors = 0

    for num in range(1, 51):
        num_str = f"{num:03d}"
        metadata = generate_trojan_metadata(num)

        if metadata:
            output_path = TROJAN_METADATA_DIR / f"tr_tc_{num_str}.json"
            with open(output_path, 'w') as f:
                json.dump(metadata, f, indent=2)
            print(f"Generated: {output_path.name}")
            generated += 1
        else:
            errors += 1

    print(f"\nDone: Generated {generated} metadata files, {errors} errors")

if __name__ == "__main__":
    main()
