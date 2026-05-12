#!/usr/bin/env python3
"""
Apply Minimized Differential Script

This script creates differential pairs using minimally sanitized originals (ms_o_tc_*)
as the vulnerable version and generates corresponding fixed versions.

The approach:
1. Read the existing df_a_tc_* fixed contract
2. Read the ms_o_tc_* source to get the correct contract name
3. Adapt the fix by replacing contract names
4. Generate metadata pointing to ms_o_tc_* as vulnerable version

Input:
- data/manual_strategies/differential/contracts/df_a_tc_*.sol (existing fixes)
- data/originals/minimalsanitized/contracts/ms_o_tc_*.sol (vulnerable versions)

Output:
- data/manual_strategies/minimizeddifferential/contracts/df_a_ms_o_tc_*.sol
- data/manual_strategies/minimizeddifferential/metadata/df_pair_ms_o_tc_*.json
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime


def extract_contract_names(content: str) -> list:
    """Extract all contract names from Solidity content."""
    pattern = r'contract\s+(\w+)'
    return re.findall(pattern, content)


def get_contract_name_mapping(tc_content: str, ms_o_tc_content: str) -> dict:
    """Create mapping from tc contract names to ms_o_tc contract names."""
    tc_names = extract_contract_names(tc_content)
    ms_names = extract_contract_names(ms_o_tc_content)

    mapping = {}

    # Common patterns for mapping
    # tc uses generic names, ms_o_tc uses protocol-specific names
    name_mappings = {
        'LendingProtocol': 'CreamLending',
        'BridgeReplica': 'NomadReplica',
        'GovernanceVault': 'BeanstalkGovernance',
        'WalletLibrary': 'ParityWalletLibrary',
        'StakingVault': 'HarvestVault',
        'LiquidityPool': 'CurvePool',
        'CrossChainBridge': 'RoninBridge',
        'CrossChainManager': 'EthCrossChainManager',
    }

    # Try direct mapping first
    for tc_name in tc_names:
        if tc_name in name_mappings and name_mappings[tc_name] in ms_names:
            mapping[tc_name] = name_mappings[tc_name]
        elif tc_name in ms_names:
            mapping[tc_name] = tc_name
        else:
            # Try to find by removing common prefixes/suffixes
            for ms_name in ms_names:
                if tc_name.lower() in ms_name.lower() or ms_name.lower() in tc_name.lower():
                    mapping[tc_name] = ms_name
                    break

    return mapping


def adapt_fix_to_ms_o_tc(df_a_content: str, tc_content: str, ms_o_tc_content: str) -> str:
    """
    Adapt a fix from df_a_tc to work with ms_o_tc.

    Strategy:
    1. Get contract name mapping
    2. Replace contract names in the fix
    3. Return adapted content
    """
    # Get contract names
    tc_names = extract_contract_names(tc_content)
    ms_names = extract_contract_names(ms_o_tc_content)
    df_a_names = extract_contract_names(df_a_content)

    result = df_a_content

    # Create mapping based on position/order
    # Usually the main contract is in the same position
    for i, df_name in enumerate(df_a_names):
        # Check if this name exists in tc_names
        if df_name in tc_names:
            tc_idx = tc_names.index(df_name)
            if tc_idx < len(ms_names):
                ms_name = ms_names[tc_idx]
                if df_name != ms_name:
                    # Replace contract declaration
                    result = re.sub(
                        rf'\bcontract\s+{df_name}\b',
                        f'contract {ms_name}',
                        result
                    )
                    # Replace any references to the contract
                    # (but be careful not to replace substrings)

    # Also try common generic-to-specific mappings
    replacements = [
        ('LendingProtocol', 'CreamLending'),
        ('BridgeReplica', 'NomadReplica'),
        ('GovernanceVault', 'BeanstalkGovernance'),
        ('WalletLibrary', 'ParityWalletLibrary'),
        ('StakingVault', 'HarvestVault'),
        ('LiquidityPool', 'CurvePool'),
        ('CrossChainBridge', 'RoninBridge'),
    ]

    for generic, specific in replacements:
        if specific in ms_o_tc_content and generic in result:
            result = re.sub(rf'\b{generic}\b', specific, result)

    return result


def create_metadata(tc_id: str, original_metadata: dict, ms_o_tc_path: str) -> dict:
    """Create metadata for the minimized differential pair."""

    new_metadata = {
        "pair_id": f"df_pair_ms_o_{tc_id}",
        "strategy": "minimized_differential",
        "variant": original_metadata.get("variant", "minimal"),
        "original_id": tc_id,
        "original_subset": "temporal_contamination",
        "version_a": {
            "id": f"df_a_ms_o_{tc_id}",
            "file": f"contracts/df_a_ms_o_{tc_id}.sol",
            "is_vulnerable": False,
            "status": "safe",
            "description": original_metadata.get("version_a", {}).get("description", "Fixed version")
        },
        "version_b": {
            "id": f"ms_o_{tc_id}",
            "file": f"../../../originals/minimalsanitized/contracts/ms_o_{tc_id}.sol",
            "is_vulnerable": True,
            "status": "vulnerable",
            "description": "Minimally sanitized original (vulnerable)"
        },
        "ground_truth": original_metadata.get("ground_truth", {}),
        "differential_details": original_metadata.get("differential_details", {}),
        "provenance": original_metadata.get("provenance", {}),
        "tags": original_metadata.get("tags", []) + ["minimized_differential"],
        "source_differential": f"df_pair_{tc_id}",
        "created_date": datetime.now().isoformat()
    }

    return new_metadata


def main():
    # Paths
    script_dir = Path(__file__).parent
    data_dir = script_dir.parent.parent

    # Input directories
    df_contracts_dir = data_dir / "manual_strategies" / "differential" / "contracts"
    df_metadata_dir = data_dir / "manual_strategies" / "differential" / "metadata"
    tc_contracts_dir = data_dir / "base" / "contracts"
    ms_o_tc_dir = data_dir / "originals" / "minimalsanitized" / "contracts"

    # Output directories
    output_contracts_dir = data_dir / "manual_strategies" / "minimizeddifferential" / "contracts"
    output_metadata_dir = data_dir / "manual_strategies" / "minimizeddifferential" / "metadata"

    output_contracts_dir.mkdir(parents=True, exist_ok=True)
    output_metadata_dir.mkdir(parents=True, exist_ok=True)

    print(f"Input df_a contracts: {df_contracts_dir}")
    print(f"Input ms_o_tc: {ms_o_tc_dir}")
    print(f"Output: {output_contracts_dir}")
    print()

    processed = 0
    errors = []
    pairs = []

    # Get list of existing differential pairs
    for df_a_file in sorted(df_contracts_dir.glob("df_a_tc_*.sol")):
        tc_id = df_a_file.stem.replace("df_a_", "")  # e.g., "tc_001"

        try:
            # Check if corresponding files exist
            tc_file = tc_contracts_dir / f"{tc_id}.sol"
            ms_o_tc_file = ms_o_tc_dir / f"ms_o_{tc_id}.sol"
            df_metadata_file = df_metadata_dir / f"df_pair_{tc_id}.json"

            if not ms_o_tc_file.exists():
                errors.append((tc_id, f"ms_o_{tc_id}.sol not found"))
                continue

            if not df_metadata_file.exists():
                errors.append((tc_id, f"df_pair_{tc_id}.json not found"))
                continue

            # Read files
            df_a_content = df_a_file.read_text()
            tc_content = tc_file.read_text() if tc_file.exists() else ""
            ms_o_tc_content = ms_o_tc_file.read_text()
            original_metadata = json.loads(df_metadata_file.read_text())

            # Adapt the fix
            adapted_content = adapt_fix_to_ms_o_tc(df_a_content, tc_content, ms_o_tc_content)

            # Write adapted contract
            output_contract_file = output_contracts_dir / f"df_a_ms_o_{tc_id}.sol"
            output_contract_file.write_text(adapted_content)

            # Create and write metadata
            new_metadata = create_metadata(tc_id, original_metadata, str(ms_o_tc_file))
            output_metadata_file = output_metadata_dir / f"df_pair_ms_o_{tc_id}.json"
            output_metadata_file.write_text(json.dumps(new_metadata, indent=2))

            pairs.append(f"df_pair_ms_o_{tc_id}")
            processed += 1
            print(f"Processed: {tc_id} -> df_a_ms_o_{tc_id}.sol")

        except Exception as e:
            errors.append((tc_id, str(e)))
            print(f"Error processing {tc_id}: {e}")

    # Create index
    index = {
        "strategy": "minimized_differential",
        "description": "Differential pairs using minimally sanitized originals. Each pair contains a vulnerable version (ms_o_tc_*) and safe version (df_a_ms_o_tc_*) with minimal code differences.",
        "total_pairs": processed,
        "pairs": sorted(pairs),
        "source": {
            "vulnerable": "data/originals/minimalsanitized/contracts/ms_o_tc_*.sol",
            "fixed": "data/manual_strategies/minimizeddifferential/contracts/df_a_ms_o_tc_*.sol",
            "based_on": "data/manual_strategies/differential/"
        },
        "version_naming": {
            "df_a_ms_o_tc_*": "Safe/fixed version",
            "ms_o_tc_*": "Vulnerable version (minimally sanitized original)"
        },
        "created_date": datetime.now().isoformat()
    }

    index_file = output_contracts_dir.parent / "index.json"
    index_file.write_text(json.dumps(index, indent=2))

    # Summary
    print(f"\n{'='*50}")
    print(f"Minimized Differential Generation Complete")
    print(f"{'='*50}")
    print(f"Processed: {processed} pairs")
    print(f"Errors: {len(errors)}")
    print(f"Output: {output_contracts_dir.parent}")

    if errors:
        print("\nErrors encountered:")
        for tc_id, error in errors:
            print(f"  - {tc_id}: {error}")


if __name__ == "__main__":
    main()
