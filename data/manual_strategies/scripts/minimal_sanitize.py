#!/usr/bin/env python3
"""
Minimal Sanitization Script for Smart Contract Originals

This script creates minimally sanitized versions of original exploit contracts.
It removes only vulnerability-hinting content while preserving:
- Original code structure
- Normal comments (NatSpec, inline explanations)
- Function and variable names
- Protocol-specific naming (just removes "Vulnerable" prefix)

Input: data/originals/contracts/o_tc_*.sol
Output: data/originals/minimalsanitized/contracts/ms_o_tc_*.sol
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime

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


def should_remove_line(line: str) -> bool:
    """Check if a line should be removed entirely."""
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
    """Remove inline comments that contain vulnerability keywords."""
    # Check if line has code followed by inline comment
    if '//' in line:
        code_part, comment_part = line.split('//', 1)
        # Check if comment contains vulnerability keywords
        if VULN_PATTERN.search(comment_part):
            # Return just the code part (strip trailing whitespace)
            return code_part.rstrip()
    return line


def process_solidity_file(content: str) -> str:
    """Process a Solidity file to minimally sanitize it."""
    lines = content.split('\n')
    result_lines = []

    i = 0
    in_block_comment = False
    block_comment_lines = []

    while i < len(lines):
        line = lines[i]

        # Track block comments
        if '/**' in line or '/*' in line:
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
                block_comment_lines = []
            i += 1
            continue

        # Handle single-line comments
        if should_remove_line(line):
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

    # Clean up multiple consecutive blank lines
    cleaned_lines = []
    prev_blank = False
    for line in result_lines:
        is_blank = not line.strip()
        if is_blank and prev_blank:
            continue
        cleaned_lines.append(line)
        prev_blank = is_blank

    return '\n'.join(cleaned_lines)


def create_metadata(original_id: str, input_path: str, output_path: str) -> dict:
    """Create metadata for the minimally sanitized file."""
    return {
        "id": f"ms_o_{original_id}",
        "original_id": original_id,
        "source_file": str(input_path),
        "sanitization_type": "minimal",
        "sanitization_applied": [
            "Removed 'Vulnerable' prefix from contract names",
            "Removed vulnerability-hinting comment blocks",
            "Removed lines with vulnerability keywords",
            "Preserved normal NatSpec and inline comments",
            "Preserved all code structure and logic"
        ],
        "created_date": datetime.now().isoformat(),
        "contract_file": f"contracts/ms_o_{original_id}.sol"
    }


def main():
    # Paths - script is in data/manual_strategies/scripts/
    script_dir = Path(__file__).parent  # scripts/
    data_dir = script_dir.parent.parent  # data/
    input_dir = data_dir / "originals" / "contracts"
    output_dir = data_dir / "originals" / "minimalsanitized" / "contracts"
    metadata_dir = data_dir / "originals" / "minimalsanitized" / "metadata"

    print(f"Input directory: {input_dir}")
    print(f"Output directory: {output_dir}")

    # Ensure output directories exist
    output_dir.mkdir(parents=True, exist_ok=True)
    metadata_dir.mkdir(parents=True, exist_ok=True)

    # Process all o_tc_*.sol files
    processed = 0
    errors = []

    for input_file in sorted(input_dir.glob("o_tc_*.sol")):
        try:
            # Read original
            content = input_file.read_text()

            # Extract ID (e.g., "tc_001" from "o_tc_001.sol")
            original_id = input_file.stem.replace("o_", "")  # "tc_001"

            # Process
            sanitized_content = process_solidity_file(content)

            # Write output
            output_file = output_dir / f"ms_o_{original_id}.sol"
            output_file.write_text(sanitized_content)

            # Create metadata
            metadata = create_metadata(original_id, input_file, output_file)
            metadata_file = metadata_dir / f"ms_o_{original_id}.json"
            metadata_file.write_text(json.dumps(metadata, indent=2))

            processed += 1
            print(f"Processed: {input_file.name} -> {output_file.name}")

        except Exception as e:
            errors.append((input_file.name, str(e)))
            print(f"Error processing {input_file.name}: {e}")

    # Summary
    print(f"\n{'='*50}")
    print(f"Minimal Sanitization Complete")
    print(f"{'='*50}")
    print(f"Processed: {processed} files")
    print(f"Errors: {len(errors)}")
    print(f"Output: {output_dir}")

    if errors:
        print("\nErrors encountered:")
        for filename, error in errors:
            print(f"  - {filename}: {error}")

    # Create index file
    index = {
        "description": "Minimally sanitized original contracts",
        "sanitization_rules": [
            "Remove 'Vulnerable' prefix from contract names",
            "Remove vulnerability-hinting comment blocks and lines",
            "Preserve normal comments, code structure, and logic"
        ],
        "total_files": processed,
        "prefix": "ms_o_tc_",
        "source": "data/originals/contracts/o_tc_*.sol",
        "created_date": datetime.now().isoformat()
    }

    index_file = data_dir / "originals" / "minimalsanitized" / "index.json"
    index_file.write_text(json.dumps(index, indent=2))
    print(f"\nIndex created: {index_file}")


if __name__ == "__main__":
    main()
