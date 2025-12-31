#!/usr/bin/env python3
"""
Full Sanitization Strategy for MinimalSanitized Contracts

This script creates fully sanitized versions from minimalsanitized contracts.
This preserves any manual fixes/edits made to minimalsanitized files while
applying full sanitization (protocol name removal, identifier sanitization).

Input: dataset/temporal_contamination/minimalsanitized/contracts/ms_tc_*.sol + metadata/ms_tc_*.json
Output: dataset/temporal_contamination/sanitized/contracts/sn_tc_*.sol + metadata/sn_tc_*.json

Benefits of using minimalsanitized as source:
- Preserves manual leakage fixes made to minimalsanitized
- Cleaner contract names (no "Basic" prefix needed since "Vulnerable" already removed)
- Less processing needed (vulnerability comments already removed)

Usage:
    python strategies/sanitize/sanitize_on_minimal_sanitize.py
    python strategies/sanitize/sanitize_on_minimal_sanitize.py <input_dir> <output_dir>
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


def sanitize_text(text: str) -> str:
    """Remove protocol names from text."""
    result = text
    for protocol, replacement in PROTOCOL_MAPPINGS.items():
        pattern = re.compile(re.escape(protocol), re.IGNORECASE)
        result = pattern.sub(replacement, result)
    return result


def get_all_contracts_from_code(code: str) -> list:
    """Extract all contract names from Solidity code."""
    return re.findall(r'contract\s+(\w+)', code)


def get_main_contract_from_code(code: str) -> str:
    """Get the main (last) contract name from Solidity code."""
    contracts = get_all_contracts_from_code(code)
    return contracts[-1] if contracts else None


def _get_renamed_contract(old_name: str, rename_mappings: dict) -> str:
    """Get renamed contract from mappings, or return original if not found."""
    return rename_mappings.get(old_name, old_name)


def get_all_functions_from_code(code: str) -> list:
    """Extract all function names from Solidity code."""
    return re.findall(r'function\s+(\w+)', code)


def find_matching_identifier(old_name: str, actual_identifiers: list, rename_mappings: dict) -> str:
    """
    Find the actual identifier in sanitized code that corresponds to old_name.

    This function handles the case where the rename_mappings might not have
    a direct entry for old_name, but the transformation can be inferred.

    Args:
        old_name: The original identifier name from metadata
        actual_identifiers: List of actual identifiers found in sanitized code
        rename_mappings: The rename mappings from sanitize_code()

    Returns:
        The matching identifier from actual_identifiers, or old_name if no match found
    """
    # 1. Direct lookup in rename_mappings
    if old_name in rename_mappings:
        renamed = rename_mappings[old_name]
        if renamed in actual_identifiers:
            return renamed

    # 2. Check if old_name exists unchanged in actual_identifiers
    if old_name in actual_identifiers:
        return old_name

    # 3. Try to find a matching identifier by checking if any actual identifier
    #    could be a transformation of old_name
    #    (e.g., FixedFloatHotWallet -> FloatHotWalletV2)
    old_name_lower = old_name.lower()

    for actual in actual_identifiers:
        actual_lower = actual.lower()

        # Check if they share a significant common substring (at least 5 chars)
        # This handles cases like FixedFloatHotWallet -> FloatHotWalletV2
        for i in range(len(old_name_lower) - 4):
            substring = old_name_lower[i:i+5]
            if substring in actual_lower:
                # Found a likely match
                return actual

    # 4. Check rename_mappings values - maybe old_name was transformed
    #    through a chain of renames
    for orig, renamed in rename_mappings.items():
        if orig.lower() in old_name.lower() or old_name.lower() in orig.lower():
            if renamed in actual_identifiers:
                return renamed

    # 5. Return first actual identifier as fallback (usually the main contract)
    if actual_identifiers:
        return actual_identifiers[0]

    return old_name


def apply_renames_to_function(func_name: str, rename_mappings: dict, actual_functions: list) -> str:
    """
    Apply rename mappings to a function name and verify it exists in actual code.

    Args:
        func_name: Original function name (may be comma-separated)
        rename_mappings: The rename mappings from sanitize_code()
        actual_functions: List of actual function names in sanitized code

    Returns:
        The renamed function name(s)
    """
    # Handle comma-separated function names
    if ',' in func_name:
        funcs = [f.strip() for f in func_name.split(',')]
        renamed_funcs = [apply_renames_to_function(f, rename_mappings, actual_functions) for f in funcs]
        return ', '.join(renamed_funcs)

    # Direct lookup
    if func_name in rename_mappings:
        return rename_mappings[func_name]

    # Check if it exists in actual functions
    if func_name in actual_functions:
        return func_name

    # Try to find matching function using common substring
    return find_matching_identifier(func_name, actual_functions, rename_mappings)


def update_metadata(original_metadata: dict, sanitized_id: str, original_id: str,
                   ms_id: str, rename_mappings: dict, changes: list,
                   source_dir: str, sanitized_code: str = None) -> dict:
    """
    Update metadata to reflect sanitization changes.

    Args:
        original_metadata: Original metadata from minimalsanitized
        sanitized_id: New sanitized ID (sn_tc_*)
        original_id: Original tc_* ID
        ms_id: MinimalSanitized ID (ms_tc_*)
        rename_mappings: Contract/identifier renames from sanitization
        changes: List of changes made
        source_dir: Source directory path
        sanitized_code: The sanitized code (to extract contract name if needed)
    """
    metadata = original_metadata.copy()

    # Update identifiers and paths
    metadata['sample_id'] = sanitized_id
    metadata['contract_file'] = f"contracts/{sanitized_id}.sol"
    metadata['variant_type'] = 'sanitized'
    metadata['variant_parent_id'] = original_id
    metadata['sanitized_from'] = ms_id  # Track that we sanitized from minimalsanitized

    # Get actual identifiers from sanitized code for accurate matching
    actual_contracts = get_all_contracts_from_code(sanitized_code) if sanitized_code else []
    actual_functions = get_all_functions_from_code(sanitized_code) if sanitized_code else []

    # Update vulnerable_contract using intelligent matching against actual code
    if 'vulnerable_contract' in metadata:
        old_contract = metadata['vulnerable_contract']
        if isinstance(old_contract, dict):
            contract_name = old_contract.get('name', '')
            if contract_name and actual_contracts:
                old_contract['name'] = find_matching_identifier(contract_name, actual_contracts, rename_mappings)
            elif contract_name:
                old_contract['name'] = _get_renamed_contract(contract_name, rename_mappings)
        elif isinstance(old_contract, str):
            if actual_contracts:
                new_contract = find_matching_identifier(old_contract, actual_contracts, rename_mappings)
            else:
                new_contract = _get_renamed_contract(old_contract, rename_mappings)
            metadata['vulnerable_contract'] = new_contract

    # Update vulnerable_function using intelligent matching against actual code
    if 'vulnerable_function' in metadata and metadata['vulnerable_function']:
        old_function = metadata['vulnerable_function']
        if actual_functions:
            new_function = apply_renames_to_function(old_function, rename_mappings, actual_functions)
        else:
            # Direct rename lookup if no code available
            new_function = rename_mappings.get(old_function, old_function)
        metadata['vulnerable_function'] = new_function

    # Sanitize tags if present (remove protocol name tags)
    if 'tags' in metadata and isinstance(metadata['tags'], list):
        sanitized_tags = []
        for tag in metadata['tags']:
            sanitized_tag = sanitize_text(tag)
            # Keep tag if it's not just a protocol name
            if sanitized_tag.lower() not in PROTOCOL_MAPPINGS.values():
                sanitized_tags.append(sanitized_tag)
        metadata['tags'] = sanitized_tags

    # Add transformation tracking
    metadata['transformation'] = {
        'type': 'full_sanitization_from_minimalsanitized',
        'source_dir': source_dir,
        'source_contract': f"{source_dir}/contracts/{ms_id}.sol",
        'source_metadata': f"{source_dir}/metadata/{ms_id}.json",
        'original_id': original_id,
        'minimalsanitized_id': ms_id,
        'script': 'strategies/sanitize/sanitize_on_minimal_sanitize.py',
        'changes': changes,
        'contract_renames': rename_mappings,
        'created_date': datetime.now().isoformat()
    }

    # Clear vulnerable_lines - line numbers change after sanitization
    if 'vulnerable_lines' in metadata:
        metadata['vulnerable_lines'] = []

    return metadata


def sanitize_from_minimalsanitized(input_base: Path = None, output_base: Path = None):
    """Sanitize all ms_tc_* files using the main sanitize strategy."""

    # Determine paths
    if input_base is None:
        input_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / "minimalsanitized"
    if output_base is None:
        output_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / "sanitized"

    input_contracts_dir = input_base / "contracts"
    input_metadata_dir = input_base / "metadata"
    output_contracts_dir = output_base / "contracts"
    output_metadata_dir = output_base / "metadata"

    # Detect file pattern
    if list(input_contracts_dir.glob("ms_tc_*.sol")):
        file_pattern = "ms_tc_*.sol"
    elif list(input_contracts_dir.glob("ms_*.sol")):
        file_pattern = "ms_*.sol"
    else:
        print("No matching minimalsanitized files found")
        return []

    print(f"Input contracts: {input_contracts_dir}")
    print(f"Input metadata: {input_metadata_dir}")
    print(f"Output directory: {output_base}")
    print(f"File pattern: {file_pattern}")

    # Ensure output directories exist
    output_contracts_dir.mkdir(parents=True, exist_ok=True)
    output_metadata_dir.mkdir(parents=True, exist_ok=True)

    # Find all matching .sol files
    ms_files = sorted(input_contracts_dir.glob(file_pattern))
    print(f"Found {len(ms_files)} files to sanitize")

    results = []
    all_renames = {}

    for ms_file in ms_files:
        file_stem = ms_file.stem  # e.g., "ms_tc_001"

        # Extract IDs
        # ms_tc_001 -> original_id = tc_001, sanitized_id = sn_tc_001
        if file_stem.startswith("ms_"):
            original_id = file_stem[3:]  # "ms_tc_001" -> "tc_001"
        else:
            original_id = file_stem

        ms_id = file_stem  # "ms_tc_001"
        sanitized_id = f"sn_{original_id}"  # "sn_tc_001"

        # Read minimalsanitized code
        ms_code = ms_file.read_text()

        # Sanitize using the main strategy
        sanitized_code, changes, rename_mappings = sanitize_code(ms_code)
        all_renames.update(rename_mappings)

        # Save sanitized contract
        output_file = output_contracts_dir / f"{sanitized_id}.sol"
        output_file.write_text(sanitized_code)

        # Load minimalsanitized metadata
        ms_metadata_file = input_metadata_dir / f"{ms_id}.json"
        if ms_metadata_file.exists():
            original_metadata = json.loads(ms_metadata_file.read_text())
        else:
            original_metadata = {"original_id": original_id}

        # Update metadata
        updated_metadata = update_metadata(
            original_metadata, sanitized_id, original_id, ms_id,
            rename_mappings, changes,
            source_dir=str(input_base),
            sanitized_code=sanitized_code
        )

        # Save metadata
        output_metadata_file = output_metadata_dir / f"{sanitized_id}.json"
        output_metadata_file.write_text(json.dumps(updated_metadata, indent=2))

        results.append({
            'ms_id': ms_id,
            'original_id': original_id,
            'sanitized_id': sanitized_id,
            'changes_count': len(changes),
            'renames': rename_mappings
        })

        status = f"[check mark] {len(changes)} changes" if changes else "o no changes"
        print(f"  {ms_id} -> {sanitized_id}: {status}")
        if rename_mappings:
            for old, new in list(rename_mappings.items())[:3]:
                print(f"      {old} -> {new}")

    # Summary
    files_with_changes = [r for r in results if r['changes_count'] > 0]
    print(f"\n{'='*50}")
    print(f"Full Sanitization from MinimalSanitized Complete")
    print(f"{'='*50}")
    print(f"Processed: {len(results)} files")
    print(f"Files with changes: {len(files_with_changes)}")
    print(f"Files unchanged: {len(results) - len(files_with_changes)}")
    print(f"Output: {output_base}")

    if all_renames:
        print(f"\nContract renames ({len(all_renames)}):")
        for old, new in sorted(all_renames.items())[:15]:
            print(f"  {old} -> {new}")
        if len(all_renames) > 15:
            print(f"  ... and {len(all_renames) - 15} more")

    # Create index file
    index = {
        "description": "Fully sanitized temporal contamination contracts (from minimalsanitized)",
        "source": "minimalsanitized",
        "sanitization_rules": [
            "Remove all vulnerability-hinting comments and identifiers",
            "Replace protocol names with generic names (Nomad -> Bridge, etc.)",
            "Preserve code structure and logic",
            "Preserve manual fixes from minimalsanitized"
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
        sanitize_from_minimalsanitized(input_base, output_base)
    else:
        sanitize_from_minimalsanitized()


if __name__ == "__main__":
    main()
