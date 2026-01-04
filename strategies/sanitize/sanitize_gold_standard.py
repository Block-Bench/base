#!/usr/bin/env python3
"""
Minimal Sanitization for Gold Standard Contracts

Removes vulnerability-hinting content while preserving code structure:
- Header block with vulnerability description
- // ^^^ VULNERABLE LINE ^^^ markers
- // @audit-issue VULNERABLE FUNCTION comments

Input: dataset/gold_standard/original/
Output: dataset/gold_standard/cleaned/

Usage:
    python strategies/sanitize/sanitize_gold_standard.py
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Tuple, List

# Patterns to remove
VULNERABLE_LINE_MARKER = re.compile(r'\s*//\s*\^\^\^\s*VULNERABLE LINE\s*\^\^\^\s*$')
AUDIT_ISSUE_PATTERN = re.compile(r'\s*//\s*@audit-issue\s+VULNERABLE FUNCTION.*$')

def find_vulnerability_header_block(lines: List[str]) -> Tuple[int, int]:
    """
    Find the vulnerability header block comment.

    Returns (start_line, end_line) indices, or (-1, -1) if not found.
    """
    in_block = False
    start_idx = -1

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Look for block comment start with vulnerability info
        if not in_block:
            if stripped.startswith('/**') or stripped.startswith('/*'):
                # Check if this block contains vulnerability info
                # Look ahead to see if it's the vuln header
                for j in range(i, min(i + 10, len(lines))):
                    if 'VULNERABLE CONTRACT' in lines[j] or 'VULNERABILITY INFORMATION' in lines[j]:
                        in_block = True
                        start_idx = i
                        break

        if in_block:
            # Look for end of block comment
            if '*/' in stripped:
                return (start_idx, i)

    return (-1, -1)


def process_contract(content: str) -> Tuple[str, List[str]]:
    """
    Process a gold standard contract to remove vulnerability hints.

    Returns (cleaned_content, list_of_changes)
    """
    changes = []
    lines = content.split('\n')

    # Step 1: Remove vulnerability header block
    start, end = find_vulnerability_header_block(lines)
    if start >= 0 and end >= 0:
        # Remove the block and any trailing empty lines
        del lines[start:end + 1]
        # Remove extra blank lines after deletion
        while start < len(lines) and not lines[start].strip():
            del lines[start]
        changes.append(f"Removed vulnerability header block (lines {start+1}-{end+1})")

    # Step 2: Remove // ^^^ VULNERABLE LINE ^^^ markers
    result_lines = []
    removed_markers = 0
    removed_audit = 0

    for line in lines:
        # Check for vulnerable line marker
        if VULNERABLE_LINE_MARKER.search(line):
            # Remove just the marker, keep the code
            cleaned = VULNERABLE_LINE_MARKER.sub('', line)
            if cleaned.strip():  # If there's code left, keep it
                result_lines.append(cleaned.rstrip())
            removed_markers += 1
            continue

        # Check for @audit-issue comment
        if AUDIT_ISSUE_PATTERN.search(line):
            removed_audit += 1
            continue

        result_lines.append(line)

    if removed_markers > 0:
        changes.append(f"Removed {removed_markers} '^^^ VULNERABLE LINE ^^^' markers")
    if removed_audit > 0:
        changes.append(f"Removed {removed_audit} '@audit-issue' comments")

    # Clean up multiple consecutive blank lines
    cleaned_lines = []
    prev_blank = False
    for line in result_lines:
        is_blank = not line.strip()
        if is_blank and prev_blank:
            continue
        cleaned_lines.append(line)
        prev_blank = is_blank

    return '\n'.join(cleaned_lines), changes


def update_metadata(original_metadata: dict, changes: List[str]) -> dict:
    """
    Update metadata for cleaned version.
    """
    metadata = original_metadata.copy()

    # Update variant info
    metadata['variant_type'] = 'cleaned'
    metadata['variant_parent_id'] = original_metadata.get('sample_id')

    # Clear vulnerable_lines - they've changed
    if 'vulnerable_lines' in metadata:
        metadata['vulnerable_lines'] = []

    # Add transformation tracking
    metadata['transformation'] = {
        'type': 'minimal_sanitization',
        'source': 'gold_standard/original',
        'changes': changes,
        'script': 'strategies/sanitize/sanitize_gold_standard.py',
        'created_date': datetime.now().isoformat()
    }

    return metadata


def main():
    # Paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent

    input_dir = project_root / "dataset" / "gold_standard" / "original"
    output_dir = project_root / "dataset" / "gold_standard" / "cleaned"

    input_contracts = input_dir / "contracts"
    input_metadata = input_dir / "metadata"
    output_contracts = output_dir / "contracts"
    output_metadata = output_dir / "metadata"

    print(f"Input: {input_dir}")
    print(f"Output: {output_dir}")

    # Create output directories
    output_contracts.mkdir(parents=True, exist_ok=True)
    output_metadata.mkdir(parents=True, exist_ok=True)

    # Also copy context folder if it exists
    input_context = input_contracts / "context"
    if input_context.exists():
        output_context = output_contracts / "context"
        output_context.mkdir(parents=True, exist_ok=True)
        for ctx_file in input_context.glob("*"):
            if ctx_file.is_file():
                (output_context / ctx_file.name).write_text(ctx_file.read_text())
        print(f"Copied context folder")

    # Process contracts
    processed = 0
    total_changes = []

    for contract_file in sorted(input_contracts.glob("gs_*.sol")):
        file_id = contract_file.stem  # gs_001

        try:
            # Read and process contract
            content = contract_file.read_text()
            cleaned_content, changes = process_contract(content)

            # Write cleaned contract
            output_file = output_contracts / contract_file.name
            output_file.write_text(cleaned_content)

            # Read and update metadata
            meta_file = input_metadata / f"{file_id}.json"
            if meta_file.exists():
                original_meta = json.loads(meta_file.read_text())
                updated_meta = update_metadata(original_meta, changes)

                # Update contract_file path
                updated_meta['contract_file'] = f"contracts/{file_id}.sol"

                output_meta = output_metadata / f"{file_id}.json"
                output_meta.write_text(json.dumps(updated_meta, indent=2))

            processed += 1
            total_changes.extend(changes)

            change_summary = f" ({len(changes)} changes)" if changes else ""
            print(f"  {file_id}{change_summary}")

        except Exception as e:
            print(f"  ERROR {file_id}: {e}")

    # Create index.json
    index = {
        "dataset_name": "gold_standard_cleaned",
        "description": "Minimally sanitized gold standard contracts with vulnerability hints removed",
        "source": "gold_standard/original",
        "total_samples": processed,
        "sanitization_rules": [
            "Removed vulnerability header block comments",
            "Removed '^^^ VULNERABLE LINE ^^^' markers",
            "Removed '@audit-issue VULNERABLE FUNCTION' comments",
            "Preserved all code and normal comments"
        ],
        "created_date": datetime.now().isoformat()
    }

    index_file = output_dir / "index.json"
    index_file.write_text(json.dumps(index, indent=2))

    print(f"\n{'='*50}")
    print(f"Gold Standard Minimal Sanitization Complete")
    print(f"{'='*50}")
    print(f"Processed: {processed} files")
    print(f"Total changes: {len(total_changes)}")
    print(f"Output: {output_dir}")


if __name__ == "__main__":
    main()
