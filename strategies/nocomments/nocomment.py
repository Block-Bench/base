"""
No-Comments Transformation for BlockBench Contracts

Takes sanitized contracts and removes ALL comments, creating a stripped-down
version that forces models to rely purely on code structure.

Output naming: nc_{original_prefix}_{number} (e.g., nc_tc_001, nc_ds_001)
- nc_tc_* = derived from temporal_contamination via sanitized
- nc_ds_* = derived from difficulty_stratified via sanitized
"""

import re
import json
from pathlib import Path
from typing import Optional
from dataclasses import dataclass, field, asdict
from datetime import datetime


# =============================================================================
# CONFIGURATION
# =============================================================================

# Base paths
BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class TransformResult:
    """Result of transforming a single file."""
    original_id: str
    transformed_id: str
    success: bool
    comments_removed: int = 0
    lines_before: int = 0
    lines_after: int = 0
    error: Optional[str] = None


@dataclass
class TransformReport:
    """Report for a batch transformation run."""
    timestamp: str
    total_files: int
    successful: int
    failed: int
    total_comments_removed: int
    results: list = field(default_factory=list)

    def to_dict(self):
        return {
            'timestamp': self.timestamp,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'total_comments_removed': self.total_comments_removed,
            'results': [asdict(r) for r in self.results]
        }


# =============================================================================
# CORE TRANSFORMATION FUNCTION
# =============================================================================

def remove_comments(code: str) -> tuple[str, int]:
    """
    Remove all comments from Solidity/Rust code.

    Args:
        code: The source code to process

    Returns:
        Tuple of (code_without_comments, number_of_comments_removed)
    """
    comments_removed = 0
    result = code

    # Step 1: Remove multi-line comments (/* ... */ and /** ... */)
    # Use non-greedy matching to handle nested-looking patterns
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
        # Simple approach: remove // and everything after, unless preceded by : (URL)
        match = re.search(r'(?<!:)//.*$', line)
        if match:
            comments_removed += 1
            line = line[:match.start()]
        new_lines.append(line)
    result = '\n'.join(new_lines)

    # Step 3: Remove Rust-style comments (// and /* */ already handled, add /// and //!)
    # These are already caught by the single-line pattern above

    # Step 4: Clean up excessive blank lines (more than 2 consecutive)
    result = re.sub(r'\n\s*\n\s*\n\s*\n', '\n\n\n', result)

    # Step 5: Remove trailing whitespace
    result = '\n'.join(line.rstrip() for line in result.split('\n'))

    # Step 6: Remove leading/trailing blank lines
    result = result.strip()

    return result, comments_removed


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _ensure_output_dirs():
    """Ensure the nocomments output directories exist."""
    (NOCOMMENTS_DIR / 'contracts').mkdir(parents=True, exist_ok=True)
    (NOCOMMENTS_DIR / 'metadata').mkdir(parents=True, exist_ok=True)


def _get_nc_id(sanitized_id: str) -> str:
    """
    Convert sanitized ID to nocomments ID.

    sn_tc_001 -> nc_tc_001
    sn_ds_001 -> nc_ds_001
    """
    if sanitized_id.startswith('sn_'):
        return 'nc_' + sanitized_id[3:]  # Replace 'sn_' with 'nc_'
    return 'nc_' + sanitized_id


def _save_transformed(
    sanitized_id: str,
    transformed_code: str,
    original_metadata: dict,
    extension: str
) -> str:
    """
    Save transformed contract and create updated metadata.

    Args:
        sanitized_id: The sanitized file ID (e.g., sn_tc_001)
        transformed_code: The code with comments removed
        original_metadata: The sanitized metadata dict
        extension: File extension (.sol or .rs)

    Returns:
        The nocomments file ID (nc_tc_001)
    """
    _ensure_output_dirs()

    nc_id = _get_nc_id(sanitized_id)

    # Save transformed contract
    output_path = NOCOMMENTS_DIR / 'contracts' / f"{nc_id}{extension}"
    output_path.write_text(transformed_code)

    # Create updated metadata
    metadata = original_metadata.copy()

    # Update IDs and references
    metadata['id'] = nc_id
    metadata['contract_file'] = f"contracts/{nc_id}{extension}"
    metadata['original_contract_file'] = original_metadata.get(
        'original_contract_file',
        original_metadata.get('contract_file', '')
    )
    metadata['derived_from'] = sanitized_id
    metadata['subset'] = 'nocomments'

    # Track transformation chain
    if 'sanitized_from' in original_metadata:
        metadata['original_id'] = original_metadata['sanitized_from']

    output_metadata = NOCOMMENTS_DIR / 'metadata' / f"{nc_id}.json"
    output_metadata.write_text(json.dumps(metadata, indent=2))

    return nc_id


# =============================================================================
# PUBLIC API FUNCTIONS
# =============================================================================

def remove_comments_one(sanitized_id: str, save: bool = True) -> TransformResult:
    """
    Remove comments from a single sanitized file.

    Args:
        sanitized_id: The sanitized file ID (e.g., sn_tc_001, sn_ds_001)
        save: Whether to save the result to disk

    Returns:
        TransformResult with details of the operation
    """
    # Find the sanitized contract
    contracts_dir = SANITIZED_DIR / 'contracts'
    metadata_dir = SANITIZED_DIR / 'metadata'

    contract_path = None
    for ext in ['.sol', '.rs']:
        path = contracts_dir / f"{sanitized_id}{ext}"
        if path.exists():
            contract_path = path
            break

    if not contract_path:
        return TransformResult(
            original_id=sanitized_id,
            transformed_id='',
            success=False,
            error=f"Sanitized contract not found: {sanitized_id}"
        )

    metadata_path = metadata_dir / f"{sanitized_id}.json"

    try:
        # Read and transform
        code = contract_path.read_text()
        lines_before = len(code.split('\n'))

        transformed_code, comments_removed = remove_comments(code)
        lines_after = len(transformed_code.split('\n'))

        nc_id = _get_nc_id(sanitized_id)

        if save:
            # Load metadata
            if metadata_path.exists():
                metadata = json.loads(metadata_path.read_text())
            else:
                metadata = {'id': sanitized_id}

            extension = contract_path.suffix
            nc_id = _save_transformed(sanitized_id, transformed_code, metadata, extension)

        return TransformResult(
            original_id=sanitized_id,
            transformed_id=nc_id,
            success=True,
            comments_removed=comments_removed,
            lines_before=lines_before,
            lines_after=lines_after
        )

    except Exception as e:
        return TransformResult(
            original_id=sanitized_id,
            transformed_id='',
            success=False,
            error=str(e)
        )


def remove_comments_all() -> TransformReport:
    """
    Remove comments from all sanitized contracts.

    Returns:
        TransformReport with details of all operations
    """
    contracts_dir = SANITIZED_DIR / 'contracts'

    if not contracts_dir.exists():
        raise FileNotFoundError(f"Sanitized contracts directory not found: {contracts_dir}")

    results = []
    total_comments = 0

    # Get all sanitized contract files
    contract_files = list(contracts_dir.glob('*.sol')) + list(contracts_dir.glob('*.rs'))

    for contract_path in sorted(contract_files):
        sanitized_id = contract_path.stem  # e.g., 'sn_tc_001'
        result = remove_comments_one(sanitized_id, save=True)
        results.append(result)
        if result.success:
            total_comments += result.comments_removed

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    report = TransformReport(
        timestamp=datetime.now().isoformat(),
        total_files=len(results),
        successful=successful,
        failed=failed,
        total_comments_removed=total_comments,
        results=results
    )

    # Save report
    _ensure_output_dirs()
    report_path = NOCOMMENTS_DIR / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    # Generate index.json
    _generate_index()

    return report


def _generate_index():
    """Generate index.json for the nocomments dataset."""
    metadata_dir = NOCOMMENTS_DIR / 'metadata'
    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'safe_count': 0,
        'by_vulnerability_type': {},
        'by_severity': {},
        'by_original_subset': {'difficulty_stratified': 0, 'temporal_contamination': 0, 'gold_standard': 0}
    }

    for meta_file in sorted(metadata_dir.glob('*.json')):
        try:
            metadata = json.loads(meta_file.read_text())
            sample = {
                'id': metadata.get('id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
                'original_contract_file': metadata.get('original_contract_file'),
                'derived_from': metadata.get('derived_from'),
                'original_id': metadata.get('original_id'),
            }

            # Extract ground truth info
            ground_truth = metadata.get('ground_truth', {})
            sample['is_vulnerable'] = ground_truth.get('is_vulnerable', True)
            sample['vulnerability_type'] = ground_truth.get('vulnerability_type', 'unknown')
            sample['severity'] = ground_truth.get('severity', 'unknown')

            samples.append(sample)

            # Update stats
            stats['total_samples'] += 1
            if sample['is_vulnerable']:
                stats['vulnerable_count'] += 1
            else:
                stats['safe_count'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_vulnerability_type'][vuln_type] = stats['by_vulnerability_type'].get(vuln_type, 0) + 1

            severity = sample['severity']
            stats['by_severity'][severity] = stats['by_severity'].get(severity, 0) + 1

            # Track original subset
            orig_id = metadata.get('original_id', '')
            if orig_id.startswith('tc_'):
                stats['by_original_subset']['temporal_contamination'] += 1
            elif orig_id.startswith('ds_'):
                stats['by_original_subset']['difficulty_stratified'] += 1
            elif orig_id.startswith('gs_'):
                stats['by_original_subset']['gold_standard'] += 1

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")
            continue

    index = {
        'dataset_name': 'nocomments',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'last_updated': datetime.now().strftime('%Y-%m-%d'),
        'description': 'Contracts with all comments removed. Derived from sanitized dataset. '
                       'Forces models to rely purely on code structure without comment hints.',
        'transformation': {
            'type': 'comment_removal',
            'source_dataset': 'sanitized',
            'changes_applied': [
                'Removed all single-line comments (//)',
                'Removed all multi-line comments (/* */)',
                'Removed all NatSpec comments (/** */)',
                'Cleaned up excessive blank lines'
            ]
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = NOCOMMENTS_DIR / 'index.json'
    index_path.write_text(json.dumps(index, indent=2))


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for the no-comments transformer."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Remove comments from sanitized BlockBench contracts'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # transform all
    subparsers.add_parser('all', help='Remove comments from all sanitized contracts')

    # transform one
    one_parser = subparsers.add_parser('one', help='Remove comments from a single file')
    one_parser.add_argument('file_id', help='Sanitized file ID (e.g., sn_tc_001, sn_ds_001)')

    # preview (show what would be removed)
    preview_parser = subparsers.add_parser('preview', help='Preview comment removal without saving')
    preview_parser.add_argument('file_id', help='Sanitized file ID')

    args = parser.parse_args()

    if args.command == 'all':
        print("Removing comments from all sanitized contracts...")
        report = remove_comments_all()
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")
        print(f"Total comments removed: {report.total_comments_removed}")
        print(f"Report saved to: {NOCOMMENTS_DIR / 'transformation_report.json'}")

    elif args.command == 'one':
        result = remove_comments_one(args.file_id)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.transformed_id}")
            print(f"Comments removed: {result.comments_removed}")
            print(f"Lines: {result.lines_before} -> {result.lines_after}")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'preview':
        # Preview mode - don't save
        result = remove_comments_one(args.file_id, save=False)
        if result.success:
            print(f"Preview for {args.file_id}:")
            print(f"  Comments that would be removed: {result.comments_removed}")
            print(f"  Lines: {result.lines_before} -> {result.lines_after}")

            # Show the transformed code
            contracts_dir = SANITIZED_DIR / 'contracts'
            for ext in ['.sol', '.rs']:
                path = contracts_dir / f"{args.file_id}{ext}"
                if path.exists():
                    code = path.read_text()
                    transformed, _ = remove_comments(code)
                    print("\n--- Transformed Code ---")
                    print(transformed[:2000])
                    if len(transformed) > 2000:
                        print(f"\n... ({len(transformed) - 2000} more characters)")
                    break
        else:
            print(f"Error: {result.error}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
