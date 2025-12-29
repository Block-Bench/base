#!/usr/bin/env python3
"""
Full Sanitization Strategy for Smart Contract Originals

Reads from: data/originals/contracts/o_tc_*.sol + metadata/o_tc_*.json
Outputs to: data/originals/sanitized/contracts/sn_tc_*.sol + metadata/sn_tc_*.json

This uses the main sanitize strategy to process originals.
Full sanitization removes ALL identifying information including:
- Vulnerability hints in code
- Protocol names in code (Nomad -> Bridge, Beanstalk -> Governance, etc.)
- Protocol names in metadata sample_id

Metadata is updated to reflect:
- New contract names matching sanitized code
- Transformation tracking with rename mappings

Usage:
    python strategies/sanitize/sanitize_originals.py
"""

import sys
import re
import json
from pathlib import Path

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from strategies.sanitize.sanitize import sanitize_code

# Paths
ORIGINALS_DIR = PROJECT_ROOT / "data" / "originals"
INPUT_CONTRACTS = ORIGINALS_DIR / "contracts"
INPUT_METADATA = ORIGINALS_DIR / "metadata"
OUTPUT_DIR = ORIGINALS_DIR / "sanitized"
OUTPUT_CONTRACTS = OUTPUT_DIR / "contracts"
OUTPUT_METADATA = OUTPUT_DIR / "metadata"

# Protocol name mappings for metadata sanitization
PROTOCOL_MAPPINGS = {
    'nomad': 'bridge',
    'beanstalk': 'governance',
    'parity': 'wallet',
    'ronin': 'gamebridge',
    'harvest': 'yield',
    'yearn': 'yield',
    'curve': 'stable',
    'compound': 'lending',
    'cream': 'lending',
    'kyber': 'dex',
    'rari': 'lending',
    'bzx': 'margin',
    'hunny': 'reward',
    'pickle': 'yield',
    'alpha': 'leveraged',
    'homora': 'leveraged',
    'anyswap': 'cross',
    'bedrock': 'staking',
    'belt': 'yield',
    'blueberry': 'leveraged',
    'burgerswap': 'swap',
    'dodo': 'liquidity',
    'exactly': 'lending',
    'fixedfloat': 'exchange',
    'gamma': 'liquidity',
    'hedgey': 'vesting',
    'hundred': 'lending',
    'inverse': 'synthetic',
    'munchables': 'game',
    'orbit': 'cross',
    'pendle': 'yield',
    'penpie': 'staking',
    'playdapp': 'game',
    'qbridge': 'quantum',
    'radiant': 'crosslending',
    'seneca': 'cdp',
    'shezmu': 'collateral',
    'socket': 'bridge',
    'sonne': 'lending',
    'spartan': 'liquidity',
    'uranium': 'swap',
    'uwu': 'lending',
    'warp': 'collateral',
    'wise': 'isolated',
}

# Fields to remove entirely from sanitized metadata
# Note: Metadata is for judge only, not shown to models
# Keep fields needed for evaluation (root_cause, attack_scenario, fix_description, description)
FIELDS_TO_REMOVE = [
    # These are redundant or not needed for judging
    'source_reference',      # External links not needed for judging
    'external_references',   # External links not needed for judging
]

# Fields to sanitize (remove protocol names) - only sample_id shown to distinguish variants
FIELDS_TO_SANITIZE = [
    'sample_id',
]


def sanitize_text(text: str) -> str:
    """Remove protocol names from text."""
    result = text
    for protocol, replacement in PROTOCOL_MAPPINGS.items():
        # Case-insensitive replacement
        pattern = re.compile(re.escape(protocol), re.IGNORECASE)
        result = pattern.sub(replacement, result)
    return result


def get_main_contract_from_code(code: str) -> str:
    """Extract the main (first) contract name from Solidity code."""
    match = re.search(r'contract\s+(\w+)', code)
    return match.group(1) if match else None


def _get_renamed_contract(old_name: str, rename_mappings: dict) -> str:
    """Get the renamed contract name using the full rename chain."""
    # First check direct mapping
    if old_name in rename_mappings:
        return rename_mappings[old_name]

    # Try removing "Vulnerable" prefix and checking
    if old_name.startswith('Vulnerable'):
        base_name = old_name[len('Vulnerable'):]
        # Check for Basic + base_name mapping
        basic_name = f'Basic{base_name}'
        if basic_name in rename_mappings:
            return rename_mappings[basic_name]
        elif base_name in rename_mappings:
            return rename_mappings[base_name]
        else:
            # Apply generic sanitization
            return sanitize_text(old_name.replace('Vulnerable', 'Basic'))

    # No mapping found, return original
    return old_name


def sanitize_metadata(metadata: dict, rename_mappings: dict, sanitized_code: str = None) -> dict:
    """
    Fully sanitize metadata for the sanitized variant.

    - Removes fields that reveal exploit details
    - Sanitizes text fields to remove protocol names
    - Updates contract/function names based on rename mappings
    - Infers vulnerable_contract from sanitized code if not set in original
    """
    result = metadata.copy()

    # Remove fields that reveal exploit details
    for field in FIELDS_TO_REMOVE:
        if field in result:
            del result[field]

    # Sanitize text fields
    for field in FIELDS_TO_SANITIZE:
        if field in result and isinstance(result[field], str):
            result[field] = sanitize_text(result[field])

    # Update vulnerable_contract using the full rename chain
    if result.get('vulnerable_contract'):
        old_value = result['vulnerable_contract']

        # Handle nested vulnerable_contract (dict with 'name' key)
        if isinstance(old_value, dict):
            old_name = old_value.get('name', '')
            if old_name:
                new_name = _get_renamed_contract(old_name, rename_mappings)
                old_value['name'] = new_name
        elif isinstance(old_value, str):
            result['vulnerable_contract'] = _get_renamed_contract(old_value, rename_mappings)
    elif sanitized_code:
        # Infer vulnerable_contract from the sanitized code if not set in original
        main_contract = get_main_contract_from_code(sanitized_code)
        if main_contract:
            result['vulnerable_contract'] = main_contract

    # Sanitize tags if present
    if 'tags' in result and isinstance(result['tags'], list):
        sanitized_tags = []
        for tag in result['tags']:
            sanitized_tag = sanitize_text(tag)
            # Skip tags that are just protocol names
            if sanitized_tag.lower() not in PROTOCOL_MAPPINGS.values():
                sanitized_tags.append(sanitized_tag)
        result['tags'] = sanitized_tags

    return result


def sanitize_originals():
    """Sanitize all o_tc_* files using the main sanitize strategy."""
    # Ensure output dirs exist
    OUTPUT_CONTRACTS.mkdir(parents=True, exist_ok=True)
    OUTPUT_METADATA.mkdir(parents=True, exist_ok=True)

    # Find all o_tc_*.sol files
    original_files = sorted(INPUT_CONTRACTS.glob("o_tc_*.sol"))
    print(f"Found {len(original_files)} original TC files to sanitize")

    results = []

    for orig_file in original_files:
        file_stem = orig_file.stem  # e.g., "o_tc_001"
        original_id = file_stem.replace("o_", "")  # e.g., "tc_001"
        sanitized_id = f"sn_{original_id}"  # e.g., "sn_tc_001"

        # Read original code
        original_code = orig_file.read_text()

        # Sanitize using the main strategy
        sanitized_code, changes, rename_mappings = sanitize_code(original_code)

        # Save sanitized contract
        output_file = OUTPUT_CONTRACTS / f"{sanitized_id}.sol"
        output_file.write_text(sanitized_code)

        # Load and update metadata
        orig_metadata_file = INPUT_METADATA / f"{file_stem}.json"
        if orig_metadata_file.exists():
            metadata = json.loads(orig_metadata_file.read_text())
        else:
            metadata = {"original_id": original_id}

        # Fully sanitize metadata (pass sanitized_code to infer vulnerable_contract if missing)
        metadata = sanitize_metadata(metadata, rename_mappings, sanitized_code)

        # Update basic identifiers
        metadata['id'] = sanitized_id
        metadata['original_id'] = original_id
        metadata['contract_file'] = f"contracts/{sanitized_id}.sol"
        metadata['variant_type'] = 'sanitized'
        metadata['sanitization_changes'] = changes
        metadata['rename_mappings'] = rename_mappings

        output_metadata = OUTPUT_METADATA / f"{sanitized_id}.json"
        output_metadata.write_text(json.dumps(metadata, indent=2))

        results.append({
            'file_id': original_id,
            'sanitized_id': sanitized_id,
            'changes_count': len(changes),
            'renames': rename_mappings
        })

        status = f"✓ {len(changes)} changes" if changes else "○ no changes"
        print(f"  {file_stem} → {sanitized_id}: {status}")
        if rename_mappings:
            for old, new in list(rename_mappings.items())[:3]:
                print(f"      {old} → {new}")

    # Summary
    files_with_changes = [r for r in results if r['changes_count'] > 0]
    print(f"\nSummary:")
    print(f"  Total files: {len(results)}")
    print(f"  Files with changes: {len(files_with_changes)}")
    print(f"  Files unchanged: {len(results) - len(files_with_changes)}")

    return results

if __name__ == "__main__":
    sanitize_originals()
