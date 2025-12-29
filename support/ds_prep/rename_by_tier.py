#!/usr/bin/env python3
"""
Rename difficulty-stratified contracts with tier-based naming.

Renames files from ds_XXX.sol to ds_tN_XXX.sol format:
- Tier 1: ds_t1_001.sol, ds_t1_002.sol, ...
- Tier 2: ds_t2_001.sol, ds_t2_002.sol, ...
- Tier 3: ds_t3_001.sol, ds_t3_002.sol, ...
- Tier 4: ds_t4_001.sol, ds_t4_002.sol, ...
"""

import json
import os
from pathlib import Path
from datetime import datetime


def main():
    script_dir = Path(__file__).parent
    original_dir = script_dir / "original"

    print("Renaming files with tier-based naming convention...")
    print()

    total_renamed = 0

    for tier_num in [1, 2, 3, 4]:
        tier_dir = original_dir / f"tier{tier_num}"
        contracts_dir = tier_dir / "contracts"
        metadata_dir = tier_dir / "metadata"

        if not contracts_dir.exists():
            print(f"Tier {tier_num}: directory not found, skipping")
            continue

        # Get all current contract files, sorted
        contract_files = sorted(contracts_dir.glob("ds_*.sol"))

        if not contract_files:
            print(f"Tier {tier_num}: no contracts found")
            continue

        print(f"Tier {tier_num}: {len(contract_files)} contracts")

        # Create mapping from old name to new name
        rename_map = {}
        for idx, old_contract in enumerate(contract_files, start=1):
            old_id = old_contract.stem  # e.g., "ds_001"
            new_id = f"ds_t{tier_num}_{idx:03d}"  # e.g., "ds_t1_001"
            rename_map[old_id] = new_id

        # Rename contracts and metadata
        for old_id, new_id in rename_map.items():
            # Rename contract
            old_contract_path = contracts_dir / f"{old_id}.sol"
            new_contract_path = contracts_dir / f"{new_id}.sol"

            if old_contract_path.exists():
                # Read contract content
                content = old_contract_path.read_text()
                # Write to new file
                new_contract_path.write_text(content)
                # Remove old file
                old_contract_path.unlink()

            # Rename and update metadata
            old_metadata_path = metadata_dir / f"{old_id}.json"
            new_metadata_path = metadata_dir / f"{new_id}.json"

            if old_metadata_path.exists():
                # Read and update metadata
                metadata = json.loads(old_metadata_path.read_text())

                # Store original ID for reference
                metadata["original_ds_id"] = old_id
                metadata["id"] = new_id
                metadata["contract_file"] = f"contracts/{new_id}.sol"

                # Write to new file
                new_metadata_path.write_text(json.dumps(metadata, indent=2))
                # Remove old file
                old_metadata_path.unlink()

            total_renamed += 1

        # Update tier index
        tier_index_path = tier_dir / "index.json"
        if tier_index_path.exists():
            tier_index = json.loads(tier_index_path.read_text())
            tier_index["contracts"] = sorted([f"ds_t{tier_num}_{i:03d}" for i in range(1, len(contract_files) + 1)])
            tier_index["naming_convention"] = f"ds_t{tier_num}_XXX"
            tier_index["last_updated"] = datetime.now().isoformat()
            tier_index_path.write_text(json.dumps(tier_index, indent=2))

        print(f"  Renamed {len(rename_map)} files -> ds_t{tier_num}_001 to ds_t{tier_num}_{len(rename_map):03d}")

    # Update overall index
    overall_index_path = original_dir / "index.json"
    if overall_index_path.exists():
        overall_index = json.loads(overall_index_path.read_text())
        overall_index["naming_convention"] = "ds_tN_XXX where N is tier number (1-4)"
        overall_index["last_updated"] = datetime.now().isoformat()
        overall_index_path.write_text(json.dumps(overall_index, indent=2))

    print()
    print("=" * 50)
    print(f"Total renamed: {total_renamed} files")
    print("Naming convention: ds_tN_XXX (e.g., ds_t1_001, ds_t2_015)")
    print("=" * 50)


if __name__ == "__main__":
    main()
