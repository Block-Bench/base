#!/usr/bin/env python3
"""
Parse themeresponse.md and generate updated medical theme JSON for chameleon.
"""

import re
import json
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
THEME_RESPONSE_PATH = BASE_DIR / "support" / "themeresponse.md"
MEDICAL_THEME_PATH = BASE_DIR / "strategies" / "chameleon" / "themes" / "medical.json"
OUTPUT_PATH = BASE_DIR / "strategies" / "chameleon" / "themes" / "medical.json"


def parse_mappings(content: str) -> dict:
    """Parse the themeresponse.md and extract mappings by category."""

    mappings = {
        'contract_names': {},
        'function_names': {},
        'variable_names': {},
        'event_names': {},
        'modifier_names': {},
        'struct_names': {},
    }

    current_category = None
    category_map = {
        'CATEGORY 1: Contract Names': 'contract_names',
        'CATEGORY 2: Function Names': 'function_names',
        'CATEGORY 3: Variable Names': 'variable_names',
        'CATEGORY 4: Event Names': 'event_names',
        'CATEGORY 5: Modifier Names': 'modifier_names',
        'CATEGORY 6: Struct Names': 'struct_names',
    }

    lines = content.split('\n')
    in_code_block = False

    for line in lines:
        line = line.strip()

        # Check for category headers
        for header, cat_key in category_map.items():
            if header in line:
                current_category = cat_key
                break

        # Track code blocks
        if line.startswith('```'):
            in_code_block = not in_code_block
            continue

        # Skip non-mapping lines
        if not current_category or not in_code_block:
            continue

        # Parse mapping: "original -> medical_equivalent"
        if ' -> ' in line:
            parts = line.split(' -> ', 1)
            if len(parts) == 2:
                original = parts[0].strip()
                target = parts[1].strip()

                # Skip empty or placeholder mappings
                if original and target and not target.startswith('['):
                    # Store as lowercase key for lookup, target preserves case
                    mappings[current_category][original.lower()] = [target]

    return mappings


def merge_with_existing(new_mappings: dict, existing_pools: dict) -> dict:
    """Merge new specific mappings with existing generic pools."""

    merged = {}

    for category in new_mappings:
        merged[category] = {}

        # Add new specific mappings first (they take priority)
        for key, values in new_mappings[category].items():
            merged[category][key] = values

        # Add existing generic pools that don't conflict
        if category in existing_pools:
            for key, values in existing_pools[category].items():
                if key not in merged[category]:
                    merged[category][key] = values

    return merged


def main():
    # Read theme response
    content = THEME_RESPONSE_PATH.read_text()

    # Parse new mappings
    new_mappings = parse_mappings(content)

    # Print stats
    print("Parsed mappings from themeresponse.md:")
    for cat, mappings in new_mappings.items():
        print(f"  {cat}: {len(mappings)} mappings")

    # Read existing medical theme
    existing = json.loads(MEDICAL_THEME_PATH.read_text())
    existing_pools = existing.get('pools', {})

    # Merge mappings
    merged_pools = merge_with_existing(new_mappings, existing_pools)

    # Create updated theme
    updated_theme = {
        "theme_name": "medical",
        "description": "Comprehensive healthcare, hospital, clinical, pharmaceutical, and patient care terminology. Includes specific contract-level mappings.",
        "pools": merged_pools
    }

    # Write updated theme
    OUTPUT_PATH.write_text(json.dumps(updated_theme, indent=2))

    print(f"\nUpdated medical theme written to: {OUTPUT_PATH}")
    print("\nMerged pool sizes:")
    for cat, pool in merged_pools.items():
        print(f"  {cat}: {len(pool)} entries")


if __name__ == '__main__':
    main()
