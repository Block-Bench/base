#!/usr/bin/env python3
"""
Shapeshifter Strategy for Temporal Contamination Dataset

Applies multi-level obfuscation to nocomments temporal contamination contracts:
- L1: Formatting changes (whitespace normalization)
- L2: Identifier obfuscation (hex style)
- L3: Control flow obfuscation (always-true conditionals)

Input: dataset/temporal_contamination/nocomments/
Output: dataset/temporal_contamination/shapeshifter_l3/

Naming: ss_tc_NNN (e.g., ss_tc_001.sol)
"""

import json
import re
import sys
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, List, Any

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from strategies.common.line_markers import strip_line_markers, add_line_markers
from strategies.common import check_syntax
from strategies.shapeshifter.obfuscation import apply_obfuscation

# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATASET_DIR = BASE_DIR / "dataset" / "temporal_contamination"
INPUT_DIR = DATASET_DIR / "nocomments"
OUTPUT_DIR = DATASET_DIR / "shapeshifter_l3"

# Obfuscation settings
OBFUSCATION_LEVEL = 3  # L2 + L3
IDENTIFIER_STYLE = 'hex'  # _0x1a2b3c style
INTENSITY = 'medium'  # Control flow intensity
SEED = 42  # For reproducibility


# =============================================================================
# FORMATTING (L1)
# =============================================================================

def apply_l1_formatting(source: str) -> str:
    """
    Apply L1 tight/compressed formatting:
    - Remove all blank lines
    - K&R style braces (on same line)
    - Compact code structure
    """
    # Normalize line endings
    result = source.replace('\r\n', '\n')

    # Remove ALL blank lines (lines that are empty or only whitespace)
    lines = result.split('\n')
    non_blank_lines = [line for line in lines if line.strip()]
    result = '\n'.join(non_blank_lines)

    # Move opening braces to same line (K&R style)
    result = re.sub(r'\)\s*\n\s*\{', ') {', result)
    result = re.sub(r'(\w)\s*\n\s*\{', r'\1 {', result)

    # Compact } else { pattern
    result = re.sub(r'\}\s*\n\s*else', '} else', result)

    return result


# =============================================================================
# TRANSFORMATION
# =============================================================================

def transform_contract(source: str, seed: int = SEED) -> tuple[str, Dict[str, str], List[str], bool]:
    """
    Apply full shapeshifter transformation to a contract.

    Steps:
    1. Strip existing line markers
    2. Apply L3 obfuscation (includes L2 hex identifiers + L3 control flow)
    3. Apply L1 formatting
    4. Add fresh line markers

    Args:
        source: Original source code with line markers
        seed: Random seed for reproducibility

    Returns:
        Tuple of (transformed_code, rename_map, changes, success)
    """
    changes = []

    # Step 1: Strip line markers
    clean_code = strip_line_markers(source)
    changes.append("Stripped existing line markers")

    # Step 2: Apply L3 obfuscation (L2 hex + L3 control flow)
    obf_result = apply_obfuscation(
        clean_code,
        level=OBFUSCATION_LEVEL,
        style=IDENTIFIER_STYLE,
        intensity=INTENSITY,
        seed=seed
    )

    if not obf_result.success:
        return source, {}, [f"Obfuscation failed: {obf_result.error}"], False

    transformed = obf_result.code
    rename_map = obf_result.rename_map
    changes.extend(obf_result.changes_made)

    # Step 3: Apply L1 formatting
    transformed = apply_l1_formatting(transformed)
    changes.append("Applied L1 tight formatting (removed blank lines, K&R braces)")

    # Step 4: Add fresh line markers
    transformed = add_line_markers(transformed)
    changes.append("Added fresh sequential line markers")

    return transformed, rename_map, changes, True


def transform_metadata(
    original_metadata: Dict,
    shapeshifter_id: str,
    source_id: str,
    rename_map: Dict[str, str],
    changes: List[str],
    source_contract: str,
    source_metadata: str
) -> Dict:
    """
    Transform metadata for shapeshifter variant.

    - Updates sample_id
    - Updates vulnerable_function if renamed
    - Updates nested function names in vulnerable_contract.functions
    - Updates vulnerability_details.vulnerable_functions
    - Clears vulnerable_lines (no longer valid)
    - Adds transformation tracking
    """
    import copy
    metadata = copy.deepcopy(original_metadata)

    # Update sample ID
    metadata['sample_id'] = shapeshifter_id

    # Update variant info
    metadata['variant_type'] = 'shapeshifter_l3'
    metadata['variant_parent_id'] = source_id

    # Transform vulnerable_function if it was renamed
    if 'vulnerable_function' in metadata:
        old_func = metadata['vulnerable_function']
        if isinstance(old_func, str) and old_func in rename_map:
            metadata['vulnerable_function'] = rename_map[old_func]

    # Transform nested vulnerable_contract.functions if present
    if 'vulnerable_contract' in metadata and isinstance(metadata['vulnerable_contract'], dict):
        vc = metadata['vulnerable_contract']
        if 'functions' in vc and isinstance(vc['functions'], list):
            for func_entry in vc['functions']:
                if isinstance(func_entry, dict) and 'name' in func_entry:
                    old_name = func_entry['name']
                    if old_name in rename_map:
                        func_entry['name'] = rename_map[old_name]

    # Transform vulnerability_details.vulnerable_functions if present
    if 'vulnerability_details' in metadata and isinstance(metadata['vulnerability_details'], dict):
        vd = metadata['vulnerability_details']
        if 'vulnerable_functions' in vd and isinstance(vd['vulnerable_functions'], list):
            new_funcs = []
            for func_name in vd['vulnerable_functions']:
                # Handle names like "functionName()" - strip parens for lookup
                base_name = func_name.rstrip('()')
                if base_name in rename_map:
                    suffix = '()' if func_name.endswith('()') else ''
                    new_funcs.append(rename_map[base_name] + suffix)
                else:
                    new_funcs.append(func_name)
            vd['vulnerable_functions'] = new_funcs

    # Clear vulnerable_lines (they're invalid after control flow changes)
    if 'vulnerable_lines' in metadata:
        metadata['vulnerable_lines'] = []

    # Update contract file path
    metadata['contract_file'] = f"contracts/{shapeshifter_id}.sol"

    # Add transformation tracking
    metadata['transformation'] = {
        'type': 'shapeshifter',
        'level': 'l3',
        'includes': ['L1 formatting', 'L2 hex identifiers', 'L3 control flow'],
        'identifier_style': IDENTIFIER_STYLE,
        'intensity': INTENSITY,
        'source_dir': str(INPUT_DIR),
        'source_contract': source_contract,
        'source_metadata': source_metadata,
        'script': 'strategies/shapeshifter/shapeshifter_tc.py',
        'changes': changes,
        'rename_map': rename_map,
        'coverage_percent': round(len(rename_map) / max(1, len(rename_map) + 10) * 100, 2),  # Approximate
        'identifiers_transformed': len(rename_map),
        'created_date': datetime.now().isoformat()
    }

    return metadata


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def get_shapeshifter_id(source_id: str) -> str:
    """Generate shapeshifter file ID from source ID."""
    # nc_tc_001 -> ss_tc_001
    match = re.match(r'nc_tc_(\d+)', source_id)
    if match:
        return f"ss_tc_{match.group(1)}"
    return f"ss_{source_id}"


def transform_one(source_id: str, save: bool = True) -> Dict[str, Any]:
    """
    Transform a single contract.

    Args:
        source_id: Source file ID (e.g., 'nc_tc_001')
        save: Whether to save the result

    Returns:
        Dict with transformation result
    """
    # Input paths
    input_contract = INPUT_DIR / "contracts" / f"{source_id}.sol"
    input_metadata = INPUT_DIR / "metadata" / f"{source_id}.json"

    if not input_contract.exists():
        return {
            'success': False,
            'source_id': source_id,
            'error': f"Contract not found: {input_contract}"
        }

    if not input_metadata.exists():
        return {
            'success': False,
            'source_id': source_id,
            'error': f"Metadata not found: {input_metadata}"
        }

    # Read source files
    source_code = input_contract.read_text()
    original_metadata = json.loads(input_metadata.read_text())

    # Transform
    transformed_code, rename_map, changes, success = transform_contract(source_code)

    if not success:
        return {
            'success': False,
            'source_id': source_id,
            'error': changes[0] if changes else "Unknown error"
        }

    # Verify syntax
    # Strip markers for syntax check
    code_for_check = strip_line_markers(transformed_code)
    is_valid, errors = check_syntax(code_for_check)

    if not is_valid:
        return {
            'success': False,
            'source_id': source_id,
            'error': f"Syntax errors after transformation: {errors[:3]}"
        }

    # Generate output ID
    shapeshifter_id = get_shapeshifter_id(source_id)

    # Transform metadata
    transformed_metadata = transform_metadata(
        original_metadata,
        shapeshifter_id,
        source_id,
        rename_map,
        changes,
        str(input_contract),
        str(input_metadata)
    )

    result = {
        'success': True,
        'source_id': source_id,
        'shapeshifter_id': shapeshifter_id,
        'rename_map': rename_map,
        'changes': changes,
        'identifiers_renamed': len(rename_map),
        'original_lines': len(source_code.split('\n')),
        'transformed_lines': len(transformed_code.split('\n'))
    }

    if save:
        # Ensure output directories exist
        (OUTPUT_DIR / "contracts").mkdir(parents=True, exist_ok=True)
        (OUTPUT_DIR / "metadata").mkdir(parents=True, exist_ok=True)

        # Save contract
        output_contract = OUTPUT_DIR / "contracts" / f"{shapeshifter_id}.sol"
        output_contract.write_text(transformed_code)

        # Save metadata
        output_metadata = OUTPUT_DIR / "metadata" / f"{shapeshifter_id}.json"
        output_metadata.write_text(json.dumps(transformed_metadata, indent=2))

        result['output_contract'] = str(output_contract)
        result['output_metadata'] = str(output_metadata)
    else:
        result['transformed_code'] = transformed_code
        result['transformed_metadata'] = transformed_metadata

    return result


def transform_all() -> Dict[str, Any]:
    """
    Transform all nocomments contracts to shapeshifter_l3.

    Returns:
        Dict with batch transformation results
    """
    input_contracts = INPUT_DIR / "contracts"
    if not input_contracts.exists():
        return {
            'success': False,
            'error': f"Input directory not found: {input_contracts}"
        }

    results = []
    contracts = sorted(input_contracts.glob("nc_tc_*.sol"))

    for contract_path in contracts:
        source_id = contract_path.stem
        print(f"Processing {source_id}...")
        result = transform_one(source_id, save=True)
        results.append(result)

        if result['success']:
            print(f"  -> {result['shapeshifter_id']} ({result['identifiers_renamed']} identifiers renamed)")
        else:
            print(f"  ERROR: {result['error']}")

    successful = sum(1 for r in results if r['success'])
    failed = len(results) - successful

    # Generate index
    generate_index()

    return {
        'success': failed == 0,
        'total': len(results),
        'successful': successful,
        'failed': failed,
        'results': results
    }


def generate_index():
    """Generate index.json for the shapeshifter_l3 dataset."""
    metadata_dir = OUTPUT_DIR / "metadata"

    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'by_vulnerability_type': {},
        'by_difficulty_tier': {},
        'avg_identifiers_renamed': 0
    }

    total_renamed = 0

    for meta_file in sorted(metadata_dir.glob("ss_tc_*.json")):
        try:
            metadata = json.loads(meta_file.read_text())

            sample = {
                'id': metadata.get('sample_id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
                'variant_parent_id': metadata.get('variant_parent_id'),
                'is_vulnerable': metadata.get('is_vulnerable', True),
                'vulnerability_type': metadata.get('vulnerability_type', 'unknown'),
                'difficulty_tier': metadata.get('difficulty_tier', 0)
            }

            samples.append(sample)

            # Update stats
            stats['total_samples'] += 1
            if sample['is_vulnerable']:
                stats['vulnerable_count'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_vulnerability_type'][vuln_type] = \
                stats['by_vulnerability_type'].get(vuln_type, 0) + 1

            tier = sample['difficulty_tier']
            stats['by_difficulty_tier'][str(tier)] = \
                stats['by_difficulty_tier'].get(str(tier), 0) + 1

            # Track rename counts
            transformation = metadata.get('transformation', {})
            total_renamed += transformation.get('identifiers_transformed', 0)

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")

    if stats['total_samples'] > 0:
        stats['avg_identifiers_renamed'] = round(total_renamed / stats['total_samples'], 1)

    index = {
        'dataset_name': 'shapeshifter_l3_temporal_contamination',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'description': 'Temporal contamination contracts with L3 shapeshifter obfuscation '
                       '(hex identifiers + control flow obfuscation). Tests if models rely on '
                       'code patterns rather than semantic understanding.',
        'source': 'dataset/temporal_contamination/nocomments',
        'transformation': {
            'strategy': 'shapeshifter',
            'level': 'l3',
            'includes': ['L1 formatting', 'L2 hex identifiers', 'L3 control flow'],
            'identifier_style': IDENTIFIER_STYLE,
            'intensity': INTENSITY,
            'preserves_vulnerability': True,
            'line_markers': 'Fresh sequential /*LN-N*/ markers'
        },
        'transformation_chain': [
            'original (tc_*)',
            '-> sanitized (sn_tc_*)',
            '-> nocomments (nc_tc_*)',
            '-> shapeshifter_l3 (ss_tc_*)'
        ],
        'statistics': stats,
        'samples': samples
    }

    index_path = OUTPUT_DIR / "index.json"
    index_path.write_text(json.dumps(index, indent=2))
    print(f"Generated index.json with {stats['total_samples']} samples")


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Shapeshifter L3 transformation for temporal contamination dataset'
    )

    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Transform all
    subparsers.add_parser('all', help='Transform all contracts')

    # Transform one
    one_parser = subparsers.add_parser('one', help='Transform single contract')
    one_parser.add_argument('source_id', help='Source file ID (e.g., nc_tc_001)')
    one_parser.add_argument('--no-save', action='store_true', help='Preview without saving')

    # Preview
    preview_parser = subparsers.add_parser('preview', help='Preview transformation')
    preview_parser.add_argument('source_id', help='Source file ID (e.g., nc_tc_001)')

    # Generate index
    subparsers.add_parser('index', help='Generate index.json')

    args = parser.parse_args()

    if args.command == 'all':
        print("Transforming all nocomments contracts to shapeshifter_l3...")
        print(f"Input: {INPUT_DIR}")
        print(f"Output: {OUTPUT_DIR}")
        print()

        result = transform_all()

        print()
        print(f"Completed: {result['successful']}/{result['total']} successful")

        if result['failed'] > 0:
            print(f"\nFailed ({result['failed']}):")
            for r in result['results']:
                if not r['success']:
                    print(f"  {r['source_id']}: {r['error']}")

    elif args.command == 'one':
        result = transform_one(args.source_id, save=not args.no_save)

        if result['success']:
            print(f"Transformed: {result['source_id']} -> {result['shapeshifter_id']}")
            print(f"Lines: {result['original_lines']} -> {result['transformed_lines']}")
            print(f"Identifiers renamed: {result['identifiers_renamed']}")
            print(f"Changes: {len(result['changes'])}")
            for change in result['changes']:
                print(f"  - {change}")

            if 'output_contract' in result:
                print(f"\nSaved to: {result['output_contract']}")
        else:
            print(f"Error: {result['error']}")

    elif args.command == 'preview':
        result = transform_one(args.source_id, save=False)

        if result['success']:
            print(f"Preview: {result['source_id']} -> {result['shapeshifter_id']}")
            print(f"Lines: {result['original_lines']} -> {result['transformed_lines']}")
            print(f"Identifiers renamed: {result['identifiers_renamed']}")
            print()

            print("=== Rename Map ===")
            for old, new in sorted(result['rename_map'].items()):
                print(f"  {old} -> {new}")

            print()
            print("=== Transformed Code (first 3000 chars) ===")
            code = result['transformed_code']
            print(code[:3000])
            if len(code) > 3000:
                print(f"\n... ({len(code) - 3000} more chars)")
        else:
            print(f"Error: {result['error']}")

    elif args.command == 'index':
        generate_index()

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
