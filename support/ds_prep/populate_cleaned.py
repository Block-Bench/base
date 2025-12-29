#!/usr/bin/env python3
"""
Populate the cleaned folder with sanitized versions of contracts.

Maps tier-based IDs (ds_t1_001) to their sanitized versions (sn_ds_001)
using the original_ds_id field in metadata.
"""

import json
import shutil
from pathlib import Path
from datetime import datetime


def main():
    script_dir = Path(__file__).parent
    original_dir = script_dir / "original"
    cleaned_dir = script_dir / "cleaned"

    # Sanitized contracts source
    data_dir = script_dir.parent.parent / "data"
    sanitized_contracts_dir = data_dir / "sanitized" / "contracts"
    sanitized_metadata_dir = data_dir / "sanitized" / "metadata"

    print("Populating cleaned folder with sanitized versions...")
    print(f"Source: {sanitized_contracts_dir}")
    print(f"Output: {cleaned_dir}")
    print()

    total_copied = 0
    missing = []

    for tier_num in [1, 2, 3, 4]:
        tier_dir = original_dir / f"tier{tier_num}"
        original_metadata_dir = tier_dir / "metadata"

        if not original_metadata_dir.exists():
            print(f"Tier {tier_num}: not found, skipping")
            continue

        # Create cleaned tier directories
        cleaned_tier_dir = cleaned_dir / f"tier{tier_num}"
        cleaned_contracts_dir = cleaned_tier_dir / "contracts"
        cleaned_metadata_dir = cleaned_tier_dir / "metadata"

        cleaned_contracts_dir.mkdir(parents=True, exist_ok=True)
        cleaned_metadata_dir.mkdir(parents=True, exist_ok=True)

        tier_count = 0

        # Process each contract in the tier
        for metadata_file in sorted(original_metadata_dir.glob("ds_t*.json")):
            tier_id = metadata_file.stem  # e.g., ds_t1_001

            # Read metadata to get original_ds_id
            metadata = json.loads(metadata_file.read_text())
            original_ds_id = metadata.get("original_ds_id")  # e.g., ds_001

            if not original_ds_id:
                missing.append((tier_id, "no original_ds_id in metadata"))
                continue

            # Find sanitized version
            sanitized_id = f"sn_{original_ds_id}"  # e.g., sn_ds_001
            sanitized_contract = sanitized_contracts_dir / f"{sanitized_id}.sol"
            sanitized_meta = sanitized_metadata_dir / f"{sanitized_id}.json"

            if not sanitized_contract.exists():
                missing.append((tier_id, f"sanitized contract not found: {sanitized_id}"))
                continue

            # Copy contract with new tier-based name
            dest_contract = cleaned_contracts_dir / f"{tier_id}.sol"
            shutil.copy(sanitized_contract, dest_contract)

            # Create updated metadata
            new_metadata = metadata.copy()
            new_metadata["id"] = tier_id
            new_metadata["contract_file"] = f"contracts/{tier_id}.sol"
            new_metadata["subset"] = "cleaned"
            new_metadata["sanitized_from"] = original_ds_id
            new_metadata["sanitized_id"] = sanitized_id

            # Copy identifier_mappings from sanitized metadata if available
            if sanitized_meta.exists():
                san_meta = json.loads(sanitized_meta.read_text())
                if "identifier_mappings" in san_meta:
                    new_metadata["identifier_mappings"] = san_meta["identifier_mappings"]

            dest_metadata = cleaned_metadata_dir / f"{tier_id}.json"
            dest_metadata.write_text(json.dumps(new_metadata, indent=2))

            tier_count += 1
            total_copied += 1

        # Create tier index
        contracts = sorted([f.stem for f in cleaned_contracts_dir.glob("*.sol")])
        tier_index = {
            "tier": tier_num,
            "description": metadata.get("description", f"Tier {tier_num}"),
            "total_contracts": len(contracts),
            "contracts": contracts,
            "subset": "cleaned",
            "created_date": datetime.now().isoformat()
        }
        (cleaned_tier_dir / "index.json").write_text(json.dumps(tier_index, indent=2))

        print(f"Tier {tier_num}: {tier_count} contracts copied")

    # Create overall cleaned index
    overall_index = {
        "name": "difficulty_stratified_cleaned",
        "description": "Sanitized versions of difficulty-stratified contracts with vulnerability hints removed",
        "total_contracts": total_copied,
        "tiers": {
            "tier1": len(list((cleaned_dir / "tier1" / "contracts").glob("*.sol"))) if (cleaned_dir / "tier1").exists() else 0,
            "tier2": len(list((cleaned_dir / "tier2" / "contracts").glob("*.sol"))) if (cleaned_dir / "tier2").exists() else 0,
            "tier3": len(list((cleaned_dir / "tier3" / "contracts").glob("*.sol"))) if (cleaned_dir / "tier3").exists() else 0,
            "tier4": len(list((cleaned_dir / "tier4" / "contracts").glob("*.sol"))) if (cleaned_dir / "tier4").exists() else 0,
        },
        "sanitization_applied": [
            "Removed vulnerability-hinting identifiers",
            "Removed hint comments and vulnerability descriptions",
            "Removed DeFiVulnLabs documentation blocks",
            "Removed security challenge hints"
        ],
        "created_date": datetime.now().isoformat()
    }
    (cleaned_dir / "index.json").write_text(json.dumps(overall_index, indent=2))

    print()
    print("=" * 50)
    print(f"Total copied: {total_copied} contracts")
    print("=" * 50)

    if missing:
        print(f"\nMissing/errors ({len(missing)}):")
        for tier_id, reason in missing[:10]:
            print(f"  - {tier_id}: {reason}")
        if len(missing) > 10:
            print(f"  ... and {len(missing) - 10} more")


if __name__ == "__main__":
    main()
