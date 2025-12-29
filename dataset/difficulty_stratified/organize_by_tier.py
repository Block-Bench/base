#!/usr/bin/env python3
"""
Organize difficulty-stratified contracts by tier.

Reads ds_* contracts and metadata from data/annotated/ and copies them
to the appropriate tier folder based on the difficulty_tier field.
"""

import json
import shutil
from pathlib import Path
from datetime import datetime


def main():
    # Paths
    script_dir = Path(__file__).parent
    base_dir = script_dir.parent.parent  # blockbench/base

    # Source directories
    annotated_contracts = base_dir / "data" / "annotated" / "contracts"
    annotated_metadata = base_dir / "data" / "annotated" / "metadata"

    # Output base
    output_base = script_dir / "original"

    print(f"Source contracts: {annotated_contracts}")
    print(f"Source metadata: {annotated_metadata}")
    print(f"Output: {output_base}")
    print()

    # Track statistics
    stats = {1: 0, 2: 0, 3: 0, 4: 0}
    errors = []

    # Process all ds_* metadata files
    for metadata_file in sorted(annotated_metadata.glob("ds_*.json")):
        try:
            # Read metadata
            metadata = json.loads(metadata_file.read_text())
            ds_id = metadata_file.stem  # e.g., "ds_001"

            # Get difficulty tier
            tier = metadata.get("difficulty_tier")
            if tier is None:
                errors.append((ds_id, "No difficulty_tier field"))
                continue

            if tier not in [1, 2, 3, 4]:
                errors.append((ds_id, f"Invalid tier: {tier}"))
                continue

            # Source contract file
            contract_file = annotated_contracts / f"{ds_id}.sol"
            if not contract_file.exists():
                errors.append((ds_id, "Contract file not found"))
                continue

            # Destination paths
            tier_dir = output_base / f"tier{tier}"
            dest_contract = tier_dir / "contracts" / f"{ds_id}.sol"
            dest_metadata = tier_dir / "metadata" / f"{ds_id}.json"

            # Copy files
            shutil.copy2(contract_file, dest_contract)
            shutil.copy2(metadata_file, dest_metadata)

            stats[tier] += 1

        except Exception as e:
            errors.append((metadata_file.stem, str(e)))

    # Create index for each tier
    for tier in [1, 2, 3, 4]:
        tier_dir = output_base / f"tier{tier}"
        contracts_dir = tier_dir / "contracts"

        # List all contracts in this tier
        contracts = sorted([f.stem for f in contracts_dir.glob("*.sol")])

        index = {
            "tier": tier,
            "description": get_tier_description(tier),
            "total_contracts": len(contracts),
            "contracts": contracts,
            "created_date": datetime.now().isoformat()
        }

        index_file = tier_dir / "index.json"
        index_file.write_text(json.dumps(index, indent=2))

    # Create overall index
    overall_index = {
        "name": "difficulty_stratified_original",
        "description": "Difficulty-stratified contracts organized by tier (original annotated versions)",
        "tiers": {
            "tier1": {"count": stats[1], "description": get_tier_description(1)},
            "tier2": {"count": stats[2], "description": get_tier_description(2)},
            "tier3": {"count": stats[3], "description": get_tier_description(3)},
            "tier4": {"count": stats[4], "description": get_tier_description(4)},
        },
        "total_contracts": sum(stats.values()),
        "source": "data/annotated/",
        "created_date": datetime.now().isoformat()
    }

    overall_index_file = output_base / "index.json"
    overall_index_file.write_text(json.dumps(overall_index, indent=2))

    # Summary
    print("=" * 50)
    print("Organization Complete")
    print("=" * 50)
    print(f"Tier 1: {stats[1]} contracts")
    print(f"Tier 2: {stats[2]} contracts")
    print(f"Tier 3: {stats[3]} contracts")
    print(f"Tier 4: {stats[4]} contracts")
    print(f"Total: {sum(stats.values())} contracts")
    print(f"Errors: {len(errors)}")

    if errors:
        print("\nErrors:")
        for ds_id, error in errors[:10]:
            print(f"  - {ds_id}: {error}")
        if len(errors) > 10:
            print(f"  ... and {len(errors) - 10} more")


def get_tier_description(tier: int) -> str:
    """Get description for each difficulty tier."""
    descriptions = {
        1: "Easy - Basic vulnerabilities with clear patterns (e.g., simple reentrancy, obvious access control issues)",
        2: "Medium - Moderate complexity requiring understanding of contract interactions",
        3: "Hard - Complex vulnerabilities involving multiple contracts or subtle logic errors",
        4: "Expert - Advanced vulnerabilities requiring deep protocol knowledge and sophisticated analysis"
    }
    return descriptions.get(tier, "Unknown tier")


if __name__ == "__main__":
    main()
