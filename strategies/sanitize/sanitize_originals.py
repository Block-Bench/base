#!/usr/bin/env python3
"""
Full Sanitization Strategy for Smart Contract Originals

This script creates fully sanitized versions of original exploit contracts.
Full sanitization removes ALL identifying information including:
- Vulnerability hints in code (comments and identifiers)
- Protocol names in code (Nomad -> Bridge, Beanstalk -> Governance, etc.)

Input: dataset/temporal_contamination/original/contracts/tc_*.sol + metadata/tc_*.json
Output: dataset/temporal_contamination/sanitized/contracts/sn_tc_*.sol + metadata/sn_tc_*.json

Metadata is copied from originals and updated to reflect:
- New contract names matching sanitized code
- Transformation tracking with rename mappings

Usage:
    python strategies/sanitize/sanitize_originals.py
    python strategies/sanitize/sanitize_originals.py <input_dir> <output_dir>
"""

import sys
import re
import json
from pathlib import Path
from datetime import datetime

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from strategies.sanitize.sanitize import sanitize_code

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

# Fields to sanitize in sample_id (remove protocol names)
FIELDS_TO_SANITIZE = ['sample_id']


def sanitize_text(text: str) -> str:
    """Remove protocol names from text."""
    result = text
    for protocol, replacement in PROTOCOL_MAPPINGS.items():
        pattern = re.compile(re.escape(protocol), re.IGNORECASE)
        result = pattern.sub(replacement, result)
    return result


def get_main_contract_from_code(code: str) -> str:
    """Extract the main (first) contract name from Solidity code."""
    # Skip line markers when searching for contract
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
        basic_name = f'Basic{base_name}'
        if basic_name in rename_mappings:
            return rename_mappings[basic_name]
        elif base_name in rename_mappings:
            return rename_mappings[base_name]
        else:
            # Apply generic sanitization
            return sanitize_text(old_name.replace('Vulnerable', 'Basic'))

    return old_name


def update_metadata(original_metadata: dict, sanitized_id: str, original_id: str,
                   rename_mappings: dict, changes: list, source_dir: str) -> dict:
    """
    Update metadata to reflect sanitization changes.

    Copies all original metadata and updates only what changes with transformation:
    - sample_id, contract_file (paths)
    - vulnerable_contract (if renamed)
    - vulnerable_lines (cleared - needs manual update for new line numbers)
    - Adds transformation tracking

    All other fields (description, attack_scenario, etc.) remain unchanged.
    """
    metadata = original_metadata.copy()

    # Update identifiers and paths
    metadata['sample_id'] = sanitized_id
    metadata['contract_file'] = f"contracts/{sanitized_id}.sol"
    metadata['variant_type'] = 'sanitized'
    metadata['variant_parent_id'] = original_id

    # Update vulnerable_contract using the rename chain
    if 'vulnerable_contract' in metadata:
        old_contract = metadata['vulnerable_contract']
        if isinstance(old_contract, dict):
            contract_name = old_contract.get('name', '')
            if contract_name:
                old_contract['name'] = _get_renamed_contract(contract_name, rename_mappings)
        elif isinstance(old_contract, str):
            metadata['vulnerable_contract'] = _get_renamed_contract(old_contract, rename_mappings)

    # Sanitize tags if present (remove protocol name tags)
    if 'tags' in metadata and isinstance(metadata['tags'], list):
        sanitized_tags = []
        for tag in metadata['tags']:
            sanitized_tag = sanitize_text(tag)
            if sanitized_tag.lower() not in PROTOCOL_MAPPINGS.values():
                sanitized_tags.append(sanitized_tag)
        metadata['tags'] = sanitized_tags

    # Add transformation tracking with proper source path
    metadata['transformation'] = {
        'type': 'full_sanitization',
        'source_dir': source_dir,
        'source_contract': f"{source_dir}/contracts/{original_id}.sol",
        'source_metadata': f"{source_dir}/metadata/{original_id}.json",
        'script': 'strategies/sanitize/sanitize_originals.py',
        'changes': changes,
        'contract_renames': rename_mappings,
        'created_date': datetime.now().isoformat()
    }

    # Clear vulnerable_lines - line numbers change after sanitization
    if 'vulnerable_lines' in metadata:
        metadata['vulnerable_lines'] = []

    return metadata


def sanitize_originals(input_base: Path = None, output_base: Path = None):
    """Sanitize all tc_* files using the main sanitize strategy."""

    # Determine paths
    if input_base is None:
        input_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / "original"
    if output_base is None:
        output_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / "sanitized"

    input_contracts_dir = input_base / "contracts"
    input_metadata_dir = input_base / "metadata"
    output_contracts_dir = output_base / "contracts"
    output_metadata_dir = output_base / "metadata"

    # Detect file pattern
    if list(input_contracts_dir.glob("tc_*.sol")):
        file_pattern = "tc_*.sol"
    elif list(input_contracts_dir.glob("o_tc_*.sol")):
        file_pattern = "o_tc_*.sol"
    else:
        print("No matching files found")
        return []

    print(f"Input contracts: {input_contracts_dir}")
    print(f"Input metadata: {input_metadata_dir}")
    print(f"Output directory: {output_base}")
    print(f"File pattern: {file_pattern}")

    # Ensure output directories exist
    output_contracts_dir.mkdir(parents=True, exist_ok=True)
    output_metadata_dir.mkdir(parents=True, exist_ok=True)

    # Find all matching .sol files
    original_files = sorted(input_contracts_dir.glob(file_pattern))
    print(f"Found {len(original_files)} files to sanitize")

    results = []
    all_renames = {}

    for orig_file in original_files:
        file_stem = orig_file.stem
        # Extract original_id (handle both tc_001 and o_tc_001 patterns)
        if file_stem.startswith("o_"):
            original_id = file_stem.replace("o_", "")
        else:
            original_id = file_stem
        sanitized_id = f"sn_{original_id}"

        # Read original code
        original_code = orig_file.read_text()

        # Sanitize using the main strategy (now handles line markers automatically)
        sanitized_code, changes, rename_mappings = sanitize_code(original_code)
        all_renames.update(rename_mappings)

        # Save sanitized contract
        output_file = output_contracts_dir / f"{sanitized_id}.sol"
        output_file.write_text(sanitized_code)

        # Load original metadata
        orig_metadata_file = input_metadata_dir / f"{file_stem}.json"
        if orig_metadata_file.exists():
            original_metadata = json.loads(orig_metadata_file.read_text())
        else:
            original_metadata = {"original_id": original_id}

        # Update metadata
        updated_metadata = update_metadata(
            original_metadata, sanitized_id, original_id,
            rename_mappings, changes,
            source_dir=str(input_base)
        )

        # Save metadata
        output_metadata_file = output_metadata_dir / f"{sanitized_id}.json"
        output_metadata_file.write_text(json.dumps(updated_metadata, indent=2))

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
    print(f"\n{'='*50}")
    print(f"Full Sanitization Complete")
    print(f"{'='*50}")
    print(f"Processed: {len(results)} files")
    print(f"Files with changes: {len(files_with_changes)}")
    print(f"Files unchanged: {len(results) - len(files_with_changes)}")
    print(f"Output: {output_base}")

    if all_renames:
        print(f"\nContract renames ({len(all_renames)}):")
        for old, new in sorted(all_renames.items())[:10]:
            print(f"  {old} → {new}")
        if len(all_renames) > 10:
            print(f"  ... and {len(all_renames) - 10} more")

    # Create index file
    index = {
        "description": "Fully sanitized temporal contamination contracts",
        "sanitization_rules": [
            "Remove 'Vulnerable' prefix from contract names",
            "Remove all vulnerability-hinting comments and identifiers",
            "Replace protocol names with generic names (Nomad -> Bridge, etc.)",
            "Preserve code structure and logic"
        ],
        "total_files": len(results),
        "prefix": "sn_tc_",
        "source_dir": str(input_base),
        "source_contracts": str(input_contracts_dir),
        "source_metadata": str(input_metadata_dir),
        "contract_renames": all_renames,
        "created_date": datetime.now().isoformat()
    }

    index_file = output_base / "index.json"
    index_file.write_text(json.dumps(index, indent=2))
    print(f"\nIndex created: {index_file}")

    return results


def main():
    if len(sys.argv) >= 3:
        input_base = Path(sys.argv[1])
        output_base = Path(sys.argv[2])
        sanitize_originals(input_base, output_base)
    else:
        sanitize_originals()


if __name__ == "__main__":
    main()
