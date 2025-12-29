#!/usr/bin/env python3
"""
No-Comments Transformation for Temporal Contamination Contracts

Takes sanitized temporal contamination contracts and removes ALL comments,
creating a stripped-down version that forces models to rely purely on code structure.

Input: dataset/temporal_contamination/sanitized/contracts/sn_tc_*.sol
Output: dataset/temporal_contamination/nocomments/contracts/nc_tc_*.sol

Line markers are stripped before processing and fresh sequential markers
are added after processing.

Usage:
    python strategies/nocomments/nocomments_tc.py
    python strategies/nocomments/nocomments_tc.py <input_dir> <output_dir>
"""

import sys
import re
import json
from pathlib import Path
from datetime import datetime

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from strategies.common.line_markers import strip_line_markers, add_line_markers


def remove_comments(code: str) -> tuple[str, int]:
    """
    Remove all comments from Solidity code.

    Line markers are stripped before processing and fresh markers
    are added after processing.

    Args:
        code: The source code to process (may contain line markers)

    Returns:
        Tuple of (code_without_comments_with_fresh_markers, number_of_comments_removed)
    """
    # Step 0: Strip existing line markers
    code = strip_line_markers(code)

    comments_removed = 0
    result = code

    # Step 1: Remove multi-line comments (/* ... */ and /** ... */)
    multiline_pattern = r'/\*[\s\S]*?\*/'
    multiline_matches = re.findall(multiline_pattern, result)
    comments_removed += len(multiline_matches)
    result = re.sub(multiline_pattern, '', result)

    # Step 2: Remove single-line comments (// ...)
    # Be careful not to remove URLs (http://, https://)
    lines = result.split('\n')
    new_lines = []
    for line in lines:
        # Find // that's not part of a URL
        match = re.search(r'(?<!:)//.*$', line)
        if match:
            comments_removed += 1
            line = line[:match.start()]
        new_lines.append(line)
    result = '\n'.join(new_lines)

    # Step 3: Clean up excessive blank lines (more than 2 consecutive)
    result = re.sub(r'\n\s*\n\s*\n\s*\n', '\n\n\n', result)

    # Step 4: Remove trailing whitespace
    result = '\n'.join(line.rstrip() for line in result.split('\n'))

    # Step 5: Remove leading/trailing blank lines
    result = result.strip()

    # Step 6: Add fresh sequential line markers
    result = add_line_markers(result)

    return result, comments_removed


def update_metadata(original_metadata: dict, nc_id: str, sanitized_id: str,
                   comments_removed: int, source_dir: str) -> dict:
    """
    Update metadata for nocomments variant.

    Copies sanitized metadata and updates transformation tracking.
    """
    metadata = original_metadata.copy()

    # Update identifiers and paths
    metadata['sample_id'] = nc_id
    metadata['contract_file'] = f"contracts/{nc_id}.sol"
    metadata['variant_type'] = 'nocomments'
    metadata['variant_parent_id'] = sanitized_id

    # Update transformation tracking
    metadata['transformation'] = {
        'type': 'comment_removal',
        'source_dir': source_dir,
        'source_contract': f"{source_dir}/contracts/{sanitized_id}.sol",
        'source_metadata': f"{source_dir}/metadata/{sanitized_id}.json",
        'script': 'strategies/nocomments/nocomments_tc.py',
        'changes': [
            f"Removed {comments_removed} comments (single-line and multi-line)",
            "Regenerated fresh line markers"
        ],
        'comments_removed': comments_removed,
        'created_date': datetime.now().isoformat()
    }

    # vulnerable_lines stays empty (inherited from sanitized)

    return metadata


def process_nocomments(input_base: Path = None, output_base: Path = None):
    """Remove comments from all sanitized tc_* files."""

    # Determine paths
    if input_base is None:
        input_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / "sanitized"
    if output_base is None:
        output_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / "nocomments"

    input_contracts_dir = input_base / "contracts"
    input_metadata_dir = input_base / "metadata"
    output_contracts_dir = output_base / "contracts"
    output_metadata_dir = output_base / "metadata"

    # Detect file pattern
    if list(input_contracts_dir.glob("sn_tc_*.sol")):
        file_pattern = "sn_tc_*.sol"
        prefix = "nc_tc_"
    elif list(input_contracts_dir.glob("sn_*.sol")):
        file_pattern = "sn_*.sol"
        prefix = "nc_"
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
    sanitized_files = sorted(input_contracts_dir.glob(file_pattern))
    print(f"Found {len(sanitized_files)} files to process")

    results = []
    total_comments = 0

    for sn_file in sanitized_files:
        file_stem = sn_file.stem  # e.g., sn_tc_001
        # Extract base id and create nc id
        if file_stem.startswith("sn_"):
            base_id = file_stem[3:]  # tc_001
        else:
            base_id = file_stem
        nc_id = f"nc_{base_id}"

        # Read sanitized code
        sanitized_code = sn_file.read_text()
        lines_before = len(sanitized_code.split('\n'))

        # Remove comments (handles line markers automatically)
        nocomments_code, comments_removed = remove_comments(sanitized_code)
        lines_after = len(nocomments_code.split('\n'))
        total_comments += comments_removed

        # Save nocomments contract
        output_file = output_contracts_dir / f"{nc_id}.sol"
        output_file.write_text(nocomments_code)

        # Load sanitized metadata
        sn_metadata_file = input_metadata_dir / f"{file_stem}.json"
        if sn_metadata_file.exists():
            sanitized_metadata = json.loads(sn_metadata_file.read_text())
        else:
            sanitized_metadata = {"sample_id": file_stem}

        # Update metadata
        updated_metadata = update_metadata(
            sanitized_metadata, nc_id, file_stem,
            comments_removed,
            source_dir=str(input_base)
        )

        # Save metadata
        output_metadata_file = output_metadata_dir / f"{nc_id}.json"
        output_metadata_file.write_text(json.dumps(updated_metadata, indent=2))

        results.append({
            'sanitized_id': file_stem,
            'nc_id': nc_id,
            'comments_removed': comments_removed,
            'lines_before': lines_before,
            'lines_after': lines_after
        })

        print(f"  {file_stem} → {nc_id}: {comments_removed} comments removed ({lines_before} → {lines_after} lines)")

    # Summary
    print(f"\n{'='*50}")
    print(f"No-Comments Transformation Complete")
    print(f"{'='*50}")
    print(f"Processed: {len(results)} files")
    print(f"Total comments removed: {total_comments}")
    print(f"Output: {output_base}")

    # Create index file
    index = {
        "description": "Temporal contamination contracts with all comments removed",
        "transformation_rules": [
            "Remove all single-line comments (//)",
            "Remove all multi-line comments (/* */)",
            "Remove all NatSpec comments (/** */)",
            "Clean up excessive blank lines",
            "Add fresh sequential line markers"
        ],
        "total_files": len(results),
        "prefix": prefix,
        "source_dir": str(input_base),
        "source_contracts": str(input_contracts_dir),
        "source_metadata": str(input_metadata_dir),
        "total_comments_removed": total_comments,
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
        process_nocomments(input_base, output_base)
    else:
        process_nocomments()


if __name__ == "__main__":
    main()
