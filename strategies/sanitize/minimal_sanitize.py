#!/usr/bin/env python3
"""
Minimal Sanitization Strategy for Smart Contract Originals

This script creates minimally sanitized versions of original exploit contracts.
It removes only vulnerability-hinting content while preserving:
- Original code structure
- Normal comments (NatSpec, inline explanations)
- Function and variable names
- Protocol-specific naming (just removes "Vulnerable" prefix)

Input: data/originals/contracts/o_tc_*.sol + metadata/o_tc_*.json
Output: data/originals/minimalsanitized/contracts/ms_tc_*.sol + metadata/ms_tc_*.json

Metadata is copied from originals and updated to reflect:
- New contract names (Vulnerable* prefix removed)
- Transformation tracking

Usage:
    python strategies/sanitize/minimal_sanitize.py
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Tuple, Dict, List

# Patterns to identify lines that should be removed or cleaned
VULNERABILITY_KEYWORDS = [
    r'\bVULNERABILITY\b',
    r'\bVULNERABLE\b',
    r'\bATTACK VECTOR\b',
    r'\bATTACK FLOW\b',
    r'\bATTACK:\b',
    r'\bAttack:\b',
    r'\bROOT CAUSE\b',
    r'\bREAL-WORLD IMPACT\b',
    r'\bKEY LESSON\b',
    r'\bVULNERABLE LINES\b',
    r'\bFIX:\b',
    r'\bhack\b',
    r'\bhacked\b',
    r'\bexploit\b',
    r'\bexploited\b',
    r'\bexploitable\b',
    r'\bexploitation\b',
    r'\battacker\b',
    r'\battackers\b',
    r'\bAttacker\b',
    r'0xAttacker',
    r'\bmalicious\b',
    r'\bstolen\b',
    r'\bdrained\b',
    r'\benables the attack\b',
    r'\bflash loan attack\b',
    r'\bflash loan attacks\b',
    r'\bthe attack\b',
    r'\breal attack\b',
    r'\bIn the real attack\b',
    r'\bsandwich attack\b',
    r'\bsandwich attacks\b',
    r'\breentrancy exploit\b',
    r'\breentrancy exploits\b',
    r'\ban attack\b',
    r'\bthrough an attack\b',
]

# Compile regex for efficiency
VULN_PATTERN = re.compile('|'.join(VULNERABILITY_KEYWORDS), re.IGNORECASE)

# Pattern to match "Vulnerable" prefix in contract names
VULNERABLE_CONTRACT_PATTERN = re.compile(r'\bcontract\s+Vulnerable(\w+)')

# Pattern to match line markers /*LN-N*/ (with optional trailing space)
LINE_MARKER_PATTERN = re.compile(r'/\*LN-\d+\*/ ?')


def strip_line_markers(content: str) -> str:
    """
    Remove all line markers from content.

    This allows processing scripts to work on clean content
    and generate fresh markers for output.
    """
    # Remove line markers from each line
    lines = content.split('\n')
    clean_lines = []
    for line in lines:
        clean_line = LINE_MARKER_PATTERN.sub('', line)
        clean_lines.append(clean_line)
    return '\n'.join(clean_lines)


def add_line_markers(content: str) -> str:
    """
    Add fresh sequential line markers to content.

    Format: /*LN-N*/ where N is 1-indexed line number.
    """
    lines = content.split('\n')
    marked_lines = []
    for i, line in enumerate(lines, start=1):
        marked_lines.append(f'/*LN-{i}*/ {line}')
    return '\n'.join(marked_lines)


def should_remove_line(line: str) -> bool:
    """Check if a line should be removed entirely.

    Note: Expects clean content without line markers.
    """
    stripped = line.strip()

    # Skip empty lines (keep them)
    if not stripped:
        return False

    # Check if line is a comment with vulnerability keywords
    if stripped.startswith('//') or stripped.startswith('*') or stripped.startswith('/*'):
        if VULN_PATTERN.search(line):
            return True

    return False


def should_remove_block_comment(block: str) -> bool:
    """Check if an entire block comment should be removed."""
    # Remove blocks that are primarily about vulnerabilities
    vuln_indicators = [
        'VULNERABILITY:',
        'ATTACK VECTOR:',
        'ATTACK FLOW:',
        'Attack:',
        'ROOT CAUSE:',
        'REAL-WORLD IMPACT:',
        'KEY LESSON:',
        'VULNERABLE LINES:',
        'This contract demonstrates the vulnerability',
        'demonstrates the vulnerability that led to',
        'FIX:',
        'hack',
        'Hack',
        'exploit',
        'Exploit',
        'attacker',
        'Attacker',
    ]

    block_lower = block.lower()
    for indicator in vuln_indicators:
        if indicator.lower() in block_lower:
            return True

    return False


def extract_contract_renames(content: str) -> Dict[str, str]:
    """Extract contract name changes (Vulnerable* -> *)."""
    renames = {}
    matches = VULNERABLE_CONTRACT_PATTERN.findall(content)
    for match in matches:
        old_name = f"Vulnerable{match}"
        new_name = match
        renames[old_name] = new_name
    return renames


def clean_contract_name(line: str) -> str:
    """Remove 'Vulnerable' prefix from contract declarations."""
    return VULNERABLE_CONTRACT_PATTERN.sub(r'contract \1', line)


def clean_title_comment(line: str) -> str:
    """Clean @title comments that mention 'Vulnerable Version'."""
    if '@title' in line and 'Vulnerable' in line:
        # Remove "(Vulnerable Version)" or similar
        line = re.sub(r'\s*\(Vulnerable Version\)', '', line)
        line = re.sub(r'\s*\(Vulnerable\)', '', line)
        line = re.sub(r'\s*- Vulnerable', '', line)
    return line


def clean_inline_comment(line: str) -> str:
    """Remove inline comments that contain vulnerability keywords.

    Note: This function expects line content WITHOUT line markers.
    """
    # Check if line has code followed by inline comment
    if '//' in line:
        code_part, comment_part = line.split('//', 1)
        # Check if comment contains vulnerability keywords
        if VULN_PATTERN.search(comment_part):
            # Return just the code part (strip trailing whitespace)
            return code_part.rstrip()
    return line


def process_solidity_file(content: str) -> Tuple[str, Dict[str, str], List[str]]:
    """
    Process a Solidity file to minimally sanitize it.

    Returns:
        Tuple of (sanitized_content, contract_renames, changes_list)

    Note: Input may contain line markers - they are stripped first.
          Output will have fresh sequential line markers.
    """
    # First, strip any existing line markers from input
    content = strip_line_markers(content)

    # Extract contract renames before processing
    contract_renames = extract_contract_renames(content)
    changes = []

    if contract_renames:
        for old, new in contract_renames.items():
            changes.append(f"Renamed contract: {old} -> {new}")

    lines = content.split('\n')
    result_lines = []

    i = 0
    in_block_comment = False
    block_comment_lines = []
    removed_blocks = 0
    removed_lines = 0

    while i < len(lines):
        line = lines[i]

        # Track block comments
        if not in_block_comment and ('/**' in line or '/*' in line):
            in_block_comment = True
            block_comment_lines = [line]
            i += 1
            continue

        if in_block_comment:
            block_comment_lines.append(line)
            if '*/' in line:
                in_block_comment = False
                # Check if entire block should be removed
                block_content = '\n'.join(block_comment_lines)
                if not should_remove_block_comment(block_content):
                    # Clean individual lines in the block
                    for block_line in block_comment_lines:
                        if not should_remove_line(block_line):
                            cleaned = clean_title_comment(block_line)
                            result_lines.append(cleaned)
                else:
                    removed_blocks += 1
                block_comment_lines = []
            i += 1
            continue

        # Handle single-line comments
        if should_remove_line(line):
            removed_lines += 1
            i += 1
            continue

        # Clean contract names
        line = clean_contract_name(line)

        # Clean title comments
        line = clean_title_comment(line)

        # Clean inline comments with vulnerability keywords
        line = clean_inline_comment(line)

        result_lines.append(line)
        i += 1

    if removed_blocks > 0:
        changes.append(f"Removed {removed_blocks} vulnerability comment block(s)")
    if removed_lines > 0:
        changes.append(f"Removed {removed_lines} vulnerability hint line(s)")

    # Clean up multiple consecutive blank lines
    cleaned_lines = []
    prev_blank = False
    for line in result_lines:
        is_blank = not line.strip()
        if is_blank and prev_blank:
            continue
        cleaned_lines.append(line)
        prev_blank = is_blank

    # Generate fresh sequential line markers for output
    sanitized_content = '\n'.join(cleaned_lines)
    marked_content = add_line_markers(sanitized_content)

    return marked_content, contract_renames, changes


def update_metadata(original_metadata: dict, sanitized_id: str, original_id: str,
                   contract_renames: Dict[str, str], changes: List[str],
                   source_dir: str = None) -> dict:
    """
    Update metadata to reflect sanitization changes.

    Copies all original metadata and updates only what changes with transformation:
    - sample_id, contract_file (paths)
    - vulnerable_contract (if renamed)
    - vulnerable_lines (cleared - needs manual update for new line numbers)
    - Adds transformation tracking

    All other fields (description, attack_scenario, etc.) remain unchanged.
    """
    # Start with a copy of original metadata
    metadata = original_metadata.copy()

    # Update identifiers and paths
    metadata['sample_id'] = sanitized_id
    metadata['contract_file'] = f"contracts/{sanitized_id}.sol"
    metadata['variant_type'] = 'minimalsanitized'
    metadata['variant_parent_id'] = original_id

    # Update vulnerable_contract if it was renamed
    if 'vulnerable_contract' in metadata:
        old_contract = metadata['vulnerable_contract']
        # Handle nested vulnerable_contract (dict with 'name' key)
        if isinstance(old_contract, dict):
            contract_name = old_contract.get('name', '')
            if contract_name in contract_renames:
                old_contract['name'] = contract_renames[contract_name]
        elif isinstance(old_contract, str) and old_contract in contract_renames:
            metadata['vulnerable_contract'] = contract_renames[old_contract]

    # Add transformation tracking with proper source path
    source_path = source_dir if source_dir else f"dataset/temporal_contamination/original"
    metadata['transformation'] = {
        'type': 'minimal_sanitization',
        'source_dir': source_path,
        'source_contract': f"{source_path}/contracts/{original_id}.sol",
        'source_metadata': f"{source_path}/metadata/{original_id}.json",
        'script': 'strategies/sanitize/minimal_sanitize.py',
        'changes': changes,
        'contract_renames': contract_renames,
        'created_date': datetime.now().isoformat()
    }

    # Clear vulnerable_lines - line numbers change after sanitization
    # Must be manually updated to match new LN-* markers
    if 'vulnerable_lines' in metadata:
        metadata['vulnerable_lines_original'] = metadata['vulnerable_lines']  # Keep for reference
        metadata['vulnerable_lines'] = []  # Clear - needs manual update

    return metadata


def main():
    import sys

    # Paths - script is in strategies/sanitize/
    script_dir = Path(__file__).parent  # sanitize/
    project_root = script_dir.parent.parent  # blockbench/base/

    # Check for command line arguments
    if len(sys.argv) >= 3:
        # Usage: python minimal_sanitize.py <input_dir> <output_dir>
        input_base = Path(sys.argv[1])
        output_base = Path(sys.argv[2])
        input_contracts_dir = input_base / "contracts"
        input_metadata_dir = input_base / "metadata"
        output_dir = output_base / "contracts"
        metadata_dir = output_base / "metadata"
        # Detect file pattern from input directory
        file_pattern = "tc_*.sol" if list(input_contracts_dir.glob("tc_*.sol")) else "o_tc_*.sol"
    else:
        # Default: data/originals -> data/originals/minimalsanitized
        data_dir = project_root / "data"
        input_contracts_dir = data_dir / "originals" / "contracts"
        input_metadata_dir = data_dir / "originals" / "metadata"
        output_dir = data_dir / "originals" / "minimalsanitized" / "contracts"
        metadata_dir = data_dir / "originals" / "minimalsanitized" / "metadata"
        file_pattern = "o_tc_*.sol"

    print(f"Input contracts: {input_contracts_dir}")
    print(f"Input metadata: {input_metadata_dir}")
    print(f"Output directory: {output_dir}")
    print(f"File pattern: {file_pattern}")

    # Ensure output directories exist
    output_dir.mkdir(parents=True, exist_ok=True)
    metadata_dir.mkdir(parents=True, exist_ok=True)

    # Process all matching .sol files
    processed = 0
    errors = []
    all_renames = {}

    for input_file in sorted(input_contracts_dir.glob(file_pattern)):
        try:
            # Read original contract
            content = input_file.read_text()

            # Extract ID - handle both "o_tc_001" and "tc_001" patterns
            file_stem = input_file.stem
            if file_stem.startswith("o_"):
                original_id = file_stem.replace("o_", "")  # "o_tc_001" -> "tc_001"
            else:
                original_id = file_stem  # "tc_001" -> "tc_001"
            sanitized_id = f"ms_{original_id}"  # "ms_tc_001"

            # Process contract
            sanitized_content, contract_renames, changes = process_solidity_file(content)
            all_renames.update(contract_renames)

            # Write output contract
            output_file = output_dir / f"{sanitized_id}.sol"
            output_file.write_text(sanitized_content)

            # Read original metadata - try both patterns
            orig_metadata_file = input_metadata_dir / f"{file_stem}.json"
            if orig_metadata_file.exists():
                original_metadata = json.loads(orig_metadata_file.read_text())
            else:
                # Fallback if no original metadata
                original_metadata = {"original_id": original_id}

            # Update and write metadata
            updated_metadata = update_metadata(
                original_metadata, sanitized_id, original_id,
                contract_renames, changes,
                source_dir=str(input_base)
            )
            metadata_file = metadata_dir / f"{sanitized_id}.json"
            metadata_file.write_text(json.dumps(updated_metadata, indent=2))

            processed += 1
            rename_info = f" (renamed: {list(contract_renames.keys())})" if contract_renames else ""
            print(f"Processed: {input_file.name} -> {output_file.name}{rename_info}")

        except Exception as e:
            errors.append((input_file.name, str(e)))
            print(f"Error processing {input_file.name}: {e}")

    # Summary
    print(f"\n{'='*50}")
    print(f"Minimal Sanitization Complete")
    print(f"{'='*50}")
    print(f"Processed: {processed} files")
    print(f"Errors: {len(errors)}")
    print(f"Contract renames: {len(all_renames)}")
    print(f"Output: {output_dir}")

    if errors:
        print("\nErrors encountered:")
        for filename, error in errors:
            print(f"  - {filename}: {error}")

    if all_renames:
        print(f"\nContract renames ({len(all_renames)}):")
        for old, new in sorted(all_renames.items())[:10]:
            print(f"  {old} -> {new}")
        if len(all_renames) > 10:
            print(f"  ... and {len(all_renames) - 10} more")

    # Create index file
    index = {
        "description": "Minimally sanitized temporal contamination contracts",
        "sanitization_rules": [
            "Remove 'Vulnerable' prefix from contract names",
            "Remove vulnerability-hinting comment blocks and lines",
            "Preserve protocol names (Nomad, Beanstalk, etc.)",
            "Preserve normal comments, code structure, and logic"
        ],
        "total_files": processed,
        "prefix": "ms_tc_",
        "source_dir": str(input_base),
        "source_contracts": str(input_contracts_dir),
        "source_metadata": str(input_metadata_dir),
        "contract_renames": all_renames,
        "created_date": datetime.now().isoformat()
    }

    # Write index file to output directory
    if len(sys.argv) >= 3:
        index_file = output_base / "index.json"
    else:
        index_file = data_dir / "originals" / "minimalsanitized" / "index.json"
    index_file.write_text(json.dumps(index, indent=2))
    print(f"\nIndex created: {index_file}")


if __name__ == "__main__":
    main()
