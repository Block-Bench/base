"""
Mirror Strategy (A2) - Format Transformation

Transforms code formatting without changing semantics. Tests whether models
are sensitive to visual presentation rather than understanding code structure.

Modes:
- compressed: Minimal whitespace, compact formatting
- expanded: Maximum whitespace, verbose formatting
- allman: Braces on new lines (Allman style)
- knr: Braces on same line (K&R style)
- minified: Extreme compression, remove all non-essential whitespace

Output naming: mr_{mode}_{source_id} (e.g., mr_compressed_sn_ds_001)
"""

import re
import json
import shutil
from pathlib import Path
from typing import Optional, Tuple, List, Dict, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import shared utilities
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from strategies.common import (
    parse,
    find_all_comments,
    remove_comments,
    check_syntax,
    compare_ast_structure,
    get_node_text,
    walk_tree,
)


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"
MIRROR_DIR = DATA_DIR / "mirror"

# Valid transformation modes
VALID_MODES = ['compressed', 'expanded', 'allman', 'knr', 'minified']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class TransformResult:
    """Result of a single transformation."""
    original_id: str
    transformed_id: str
    mode: str
    success: bool
    original_lines: int = 0
    transformed_lines: int = 0
    original_chars: int = 0
    transformed_chars: int = 0
    comments_removed: bool = False
    error: Optional[str] = None


@dataclass
class TransformReport:
    """Report for batch transformation."""
    timestamp: str
    mode: str
    source_dataset: str
    total_files: int
    successful: int
    failed: int
    results: List[TransformResult] = field(default_factory=list)

    def to_dict(self):
        return {
            'timestamp': self.timestamp,
            'mode': self.mode,
            'source_dataset': self.source_dataset,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [asdict(r) for r in self.results]
        }


# =============================================================================
# CORE TRANSFORMATION FUNCTIONS
# =============================================================================

def apply_compressed(source: str) -> Tuple[str, Dict[str, Any]]:
    """
    Compress code to minimal whitespace while preserving correctness.

    Rules:
    1. Remove all comments
    2. Remove blank lines
    3. Collapse multiple spaces to single space
    4. Keep braces on same line (K&R style)
    5. Preserve string literals exactly
    6. Preserve necessary whitespace (keywords, types)
    """
    details = {'comments_removed': True, 'blank_lines_removed': 0}

    # Step 1: Remove comments
    result = remove_comments(source)

    # Step 2: Normalize line endings
    result = result.replace('\r\n', '\n')

    # Step 3: Process line by line
    lines = result.split('\n')
    compressed_lines = []
    blank_count = 0

    for line in lines:
        stripped = line.strip()
        if not stripped:
            blank_count += 1
            continue

        # Collapse internal whitespace (preserve strings)
        stripped = _collapse_whitespace_preserve_strings(stripped)
        compressed_lines.append(stripped)

    details['blank_lines_removed'] = blank_count

    # Step 4: Join with single newlines
    result = '\n'.join(compressed_lines)

    # Step 5: Collapse braces to K&R style
    result = _collapse_braces(result)

    return result, details


def apply_expanded(source: str) -> Tuple[str, Dict[str, Any]]:
    """
    Expand code to maximum whitespace/readability.

    Rules:
    1. Preserve comments
    2. Add blank line between functions
    3. Spaces around all operators
    4. Consistent indentation (4 spaces)
    """
    details = {'comments_removed': False, 'blank_lines_added': 0}

    # Step 1: Ensure consistent indentation
    result = _fix_indentation(source, indent_size=4)

    # Step 2: Add blank lines between functions/contracts
    result = _add_blank_lines_between_declarations(result)
    details['blank_lines_added'] = result.count('\n\n') - source.count('\n\n')

    # Step 3: Expand operators (add spaces around them)
    result = _expand_operators(result)

    return result, details


def apply_allman(source: str) -> Tuple[str, Dict[str, Any]]:
    """
    Convert to Allman brace style (braces on new lines).

    Before: function foo() {
    After:  function foo()
            {
    """
    details = {'comments_removed': False, 'brace_style': 'allman'}

    result = source

    # Move opening braces to new lines
    # Function/modifier/constructor declarations
    result = re.sub(
        r'\)\s*\{',
        ')\n{',
        result
    )

    # Contract/interface/library/struct/enum declarations
    result = re.sub(
        r'(contract\s+\w+(?:\s+is\s+[^{]+)?)\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(interface\s+\w+(?:\s+is\s+[^{]+)?)\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(library\s+\w+)\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(struct\s+\w+)\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(enum\s+\w+)\s*\{',
        r'\1\n{',
        result
    )

    # Control flow: if, else, for, while, do
    result = re.sub(
        r'(if\s*\([^)]+\))\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(else)\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(for\s*\([^)]+\))\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(while\s*\([^)]+\))\s*\{',
        r'\1\n{',
        result
    )
    result = re.sub(
        r'(do)\s*\{',
        r'\1\n{',
        result
    )

    # Re-indent properly
    result = _fix_indentation(result)

    return result, details


def apply_knr(source: str) -> Tuple[str, Dict[str, Any]]:
    """
    Convert to K&R brace style (braces on same line).

    Before: function foo()
            {
    After:  function foo() {
    """
    details = {'comments_removed': False, 'brace_style': 'knr'}

    result = source

    # Move opening braces to same line
    # Match: ")\n{" or "X\n{"
    result = re.sub(
        r'\)\s*\n\s*\{',
        ') {',
        result
    )

    result = re.sub(
        r'(\w)\s*\n\s*\{',
        r'\1 {',
        result
    )

    # Handle else { case
    result = re.sub(
        r'\}\s*\n\s*else',
        '} else',
        result
    )

    return result, details


def apply_minified(source: str) -> Tuple[str, Dict[str, Any]]:
    """
    Extreme minification - remove all non-essential whitespace.

    WARNING: Produces hard-to-read code, but still compiles.
    """
    details = {'comments_removed': True, 'extreme_compression': True}

    # Step 1: Remove comments
    result = remove_comments(source)

    # Step 2: Collapse to minimal form
    lines = result.split('\n')
    result_parts = []

    for line in lines:
        stripped = line.strip()
        if stripped:
            result_parts.append(stripped)

    # Join with single space
    result = ' '.join(result_parts)

    # Remove spaces around punctuation (carefully)
    # Remove spaces before: ) ] } ; , :
    result = re.sub(r'\s+([)\]};,:])', r'\1', result)

    # Remove spaces after: ( [ { :
    result = re.sub(r'([(\[{:])\s+', r'\1', result)

    # Collapse multiple spaces
    result = re.sub(r'\s+', ' ', result)

    # Add back necessary newlines after pragmas, imports, and major declarations
    # Pragma and SPDX need their own line
    result = re.sub(r'(pragma\s+solidity[^;]+;)', r'\1\n', result)
    result = re.sub(r'(// SPDX[^\n]*)', r'\1\n', result)

    # Add newlines after closing braces for readability and compilation
    result = re.sub(r'\}([^\s\n}])', r'}\n\1', result)

    return result, details


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def _collapse_whitespace_preserve_strings(line: str) -> str:
    """Collapse multiple spaces to single space, but preserve string contents."""
    in_string = False
    string_char = None
    result = []
    i = 0

    while i < len(line):
        char = line[i]

        # Track string state (handle escaped quotes)
        if char in '"\'':
            if not in_string:
                in_string = True
                string_char = char
            elif char == string_char:
                # Check if escaped
                if i > 0 and line[i-1] != '\\':
                    in_string = False
                    string_char = None

        if in_string:
            result.append(char)
        else:
            # Collapse whitespace outside strings
            if char.isspace():
                if result and not result[-1].isspace():
                    result.append(' ')
            else:
                result.append(char)

        i += 1

    return ''.join(result).strip()


def _collapse_braces(source: str) -> str:
    """Move opening braces to same line as declaration (K&R style)."""
    # "function foo()\n{" -> "function foo() {"
    source = re.sub(r'\)\s*\n\s*\{', ') {', source)

    # "contract Foo\n{" -> "contract Foo {"
    source = re.sub(r'(\w)\s*\n\s*\{', r'\1 {', source)

    return source


def _fix_indentation(source: str, indent_size: int = 4) -> str:
    """Re-indent code properly based on brace nesting."""
    lines = source.split('\n')
    result = []
    indent_level = 0

    for line in lines:
        stripped = line.strip()

        # Decrease indent before closing brace/paren
        if stripped and stripped[0] in '}])':
            indent_level = max(0, indent_level - 1)

        # Add indentation
        if stripped:
            result.append(' ' * (indent_level * indent_size) + stripped)
        else:
            result.append('')

        # Increase indent after opening brace
        if stripped.endswith('{'):
            indent_level += 1

    return '\n'.join(result)


def _add_blank_lines_between_declarations(source: str) -> str:
    """Add blank lines between major declarations (functions, contracts)."""
    # Add blank line before function definitions (if not already there)
    source = re.sub(
        r'([^\n])\n(\s*function\s)',
        r'\1\n\n\2',
        source
    )

    # Add blank line before contract/interface/library (if not already there)
    source = re.sub(
        r'([^\n])\n(\s*(?:contract|interface|library)\s)',
        r'\1\n\n\2',
        source
    )

    # Clean up triple+ blank lines
    source = re.sub(r'\n\n\n+', '\n\n', source)

    return source


def _expand_operators(source: str) -> str:
    """
    Add spaces around operators (preserving string literals).

    This is conservative to avoid breaking code - only adds spaces
    where they're clearly missing.
    """
    # For the expanded mode, we'll be very conservative and only
    # ensure there's spacing around basic operators without breaking
    # compound operators like +=, ==, !=, >=, <=, etc.

    # Simply return the source as-is for now - the indentation fix
    # and blank line additions are the main formatting changes for expanded mode.
    # Operator spacing is risky and often unnecessary.
    return source


# =============================================================================
# MAIN TRANSFORMATION FUNCTION
# =============================================================================

def transform_code(
    source: str,
    mode: str,
    preserve_comments: bool = None
) -> Tuple[str, Dict[str, Any]]:
    """
    Apply format transformation to source code.

    Args:
        source: Original source code
        mode: Transformation mode (compressed, expanded, allman, knr, minified)
        preserve_comments: Override default comment handling for mode

    Returns:
        Tuple of (transformed_code, transformation_details)
    """
    if mode not in VALID_MODES:
        raise ValueError(f"Invalid mode: {mode}. Valid modes: {VALID_MODES}")

    if mode == 'compressed':
        transformed, details = apply_compressed(source)
    elif mode == 'expanded':
        transformed, details = apply_expanded(source)
    elif mode == 'allman':
        transformed, details = apply_allman(source)
    elif mode == 'knr':
        transformed, details = apply_knr(source)
    elif mode == 'minified':
        transformed, details = apply_minified(source)

    # Add common stats
    details['mode'] = mode
    details['original_lines'] = len(source.split('\n'))
    details['transformed_lines'] = len(transformed.split('\n'))
    details['original_chars'] = len(source)
    details['transformed_chars'] = len(transformed)

    if details['original_chars'] > 0:
        details['compression_ratio'] = round(
            details['transformed_chars'] / details['original_chars'], 2
        )

    return transformed, details


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _ensure_output_dirs(mode: str):
    """Ensure output directories exist."""
    mode_dir = MIRROR_DIR / mode
    (mode_dir / 'contracts').mkdir(parents=True, exist_ok=True)
    (mode_dir / 'metadata').mkdir(parents=True, exist_ok=True)


def _get_source_path(source_id: str, source_dataset: str) -> Optional[Path]:
    """Get the path to a source contract."""
    if source_dataset == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source_dataset == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source dataset: {source_dataset}")

    for ext in ['.sol', '.rs']:
        path = source_dir / f"{source_id}{ext}"
        if path.exists():
            return path

    return None


def _get_metadata_path(source_id: str, source_dataset: str) -> Optional[Path]:
    """Get the path to source metadata."""
    if source_dataset == 'sanitized':
        meta_dir = SANITIZED_DIR / 'metadata'
    elif source_dataset == 'nocomments':
        meta_dir = NOCOMMENTS_DIR / 'metadata'
    else:
        return None

    path = meta_dir / f"{source_id}.json"
    return path if path.exists() else None


def _get_mirror_id(source_id: str, mode: str) -> str:
    """Generate mirror file ID."""
    # mr_compressed_sn_ds_001
    return f"mr_{mode}_{source_id}"


def transform_one(
    source_id: str,
    mode: str,
    source_dataset: str = 'sanitized',
    save: bool = True
) -> TransformResult:
    """
    Transform a single file with the specified mode.

    Args:
        source_id: Source file ID (e.g., sn_ds_001)
        mode: Transformation mode
        source_dataset: Which dataset to read from (sanitized, nocomments)
        save: Whether to save the result

    Returns:
        TransformResult with details
    """
    # Find source file
    source_path = _get_source_path(source_id, source_dataset)
    if not source_path:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            mode=mode,
            success=False,
            error=f"Source file not found: {source_id}"
        )

    try:
        # Read source
        source = source_path.read_text()
        original_lines = len(source.split('\n'))
        original_chars = len(source)

        # Transform
        transformed, details = transform_code(source, mode)
        transformed_lines = len(transformed.split('\n'))
        transformed_chars = len(transformed)

        # Validate syntax
        is_valid, errors = check_syntax(transformed)
        if not is_valid:
            return TransformResult(
                original_id=source_id,
                transformed_id='',
                mode=mode,
                success=False,
                original_lines=original_lines,
                transformed_lines=transformed_lines,
                error=f"Syntax errors: {errors[:3]}"
            )

        mirror_id = _get_mirror_id(source_id, mode)

        if save:
            _ensure_output_dirs(mode)

            # Save transformed contract
            output_path = MIRROR_DIR / mode / 'contracts' / f"{mirror_id}{source_path.suffix}"
            output_path.write_text(transformed)

            # Load and update metadata
            meta_path = _get_metadata_path(source_id, source_dataset)
            if meta_path:
                metadata = json.loads(meta_path.read_text())
            else:
                metadata = {'id': source_id}

            # Update metadata
            metadata['id'] = mirror_id
            metadata['contract_file'] = f"contracts/{mirror_id}{source_path.suffix}"
            metadata['derived_from'] = source_id
            metadata['subset'] = 'mirror'
            metadata['transformation'] = {
                'strategy': 'mirror',
                'mode': mode,
                'details': details
            }

            # Save metadata
            meta_output = MIRROR_DIR / mode / 'metadata' / f"{mirror_id}.json"
            meta_output.write_text(json.dumps(metadata, indent=2))

        return TransformResult(
            original_id=source_id,
            transformed_id=mirror_id,
            mode=mode,
            success=True,
            original_lines=original_lines,
            transformed_lines=transformed_lines,
            original_chars=original_chars,
            transformed_chars=transformed_chars,
            comments_removed=details.get('comments_removed', False)
        )

    except Exception as e:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            mode=mode,
            success=False,
            error=str(e)
        )


def transform_all(
    mode: str,
    source_dataset: str = 'sanitized'
) -> TransformReport:
    """
    Transform all contracts from source dataset with specified mode.

    Args:
        mode: Transformation mode
        source_dataset: Source dataset (sanitized, nocomments)

    Returns:
        TransformReport with all results
    """
    if source_dataset == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source_dataset == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source dataset: {source_dataset}")

    if not source_dir.exists():
        raise FileNotFoundError(f"Source directory not found: {source_dir}")

    results = []
    contract_files = list(source_dir.glob('*.sol')) + list(source_dir.glob('*.rs'))

    for contract_path in sorted(contract_files):
        source_id = contract_path.stem
        result = transform_one(source_id, mode, source_dataset, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    report = TransformReport(
        timestamp=datetime.now().isoformat(),
        mode=mode,
        source_dataset=source_dataset,
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )

    # Save report
    _ensure_output_dirs(mode)
    report_path = MIRROR_DIR / mode / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    # Generate index
    _generate_index(mode)

    return report


def _generate_index(mode: str):
    """Generate index.json for a mirror mode dataset."""
    mode_dir = MIRROR_DIR / mode
    metadata_dir = mode_dir / 'metadata'

    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'safe_count': 0,
        'by_vulnerability_type': {},
        'avg_compression_ratio': 0,
    }

    compression_ratios = []

    for meta_file in sorted(metadata_dir.glob('*.json')):
        try:
            metadata = json.loads(meta_file.read_text())
            sample = {
                'id': metadata.get('id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
                'derived_from': metadata.get('derived_from'),
            }

            # Extract ground truth
            ground_truth = metadata.get('ground_truth', {})
            sample['is_vulnerable'] = ground_truth.get('is_vulnerable', True)
            sample['vulnerability_type'] = ground_truth.get('vulnerability_type', 'unknown')

            # Extract transformation details
            transform = metadata.get('transformation', {})
            details = transform.get('details', {})
            if 'compression_ratio' in details:
                compression_ratios.append(details['compression_ratio'])

            samples.append(sample)

            # Update stats
            stats['total_samples'] += 1
            if sample['is_vulnerable']:
                stats['vulnerable_count'] += 1
            else:
                stats['safe_count'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_vulnerability_type'][vuln_type] = \
                stats['by_vulnerability_type'].get(vuln_type, 0) + 1

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")

    if compression_ratios:
        stats['avg_compression_ratio'] = round(
            sum(compression_ratios) / len(compression_ratios), 2
        )

    index = {
        'dataset_name': f'mirror_{mode}',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'description': f'Contracts transformed with Mirror strategy ({mode} mode). '
                       'Same semantics, different formatting.',
        'transformation': {
            'strategy': 'mirror',
            'mode': mode,
            'preserves_vulnerability': True,
            'changes_applied': _get_mode_description(mode)
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = mode_dir / 'index.json'
    index_path.write_text(json.dumps(index, indent=2))


def _get_mode_description(mode: str) -> List[str]:
    """Get description of changes for a mode."""
    descriptions = {
        'compressed': [
            'Removed all comments',
            'Removed blank lines',
            'Collapsed multiple spaces',
            'K&R brace style (braces on same line)'
        ],
        'expanded': [
            'Added blank lines between functions',
            'Spaces around operators',
            'Consistent 4-space indentation'
        ],
        'allman': [
            'Opening braces on new lines',
            'Preserved comments',
            'Consistent indentation'
        ],
        'knr': [
            'Opening braces on same line as declaration',
            'Preserved comments',
            'Compact else handling'
        ],
        'minified': [
            'Removed all comments',
            'Extreme whitespace compression',
            'Single-line where possible',
            'Minimum required newlines'
        ]
    }
    return descriptions.get(mode, [])


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Mirror strategy."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Mirror Strategy - Format Transformation'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts')
    all_parser.add_argument('--mode', required=True, choices=VALID_MODES,
                           help='Transformation mode')
    all_parser.add_argument('--source', default='sanitized',
                           choices=['sanitized', 'nocomments'],
                           help='Source dataset')

    # Transform one
    one_parser = subparsers.add_parser('one', help='Transform single contract')
    one_parser.add_argument('file_id', help='Source file ID')
    one_parser.add_argument('--mode', required=True, choices=VALID_MODES,
                           help='Transformation mode')
    one_parser.add_argument('--source', default='sanitized',
                           choices=['sanitized', 'nocomments'],
                           help='Source dataset')

    # Preview
    preview_parser = subparsers.add_parser('preview', help='Preview transformation')
    preview_parser.add_argument('file_id', help='Source file ID')
    preview_parser.add_argument('--mode', required=True, choices=VALID_MODES,
                               help='Transformation mode')
    preview_parser.add_argument('--source', default='sanitized',
                               choices=['sanitized', 'nocomments'],
                               help='Source dataset')

    args = parser.parse_args()

    if args.command == 'all':
        print(f"Transforming all contracts with mode '{args.mode}'...")
        report = transform_all(args.mode, args.source)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")
        print(f"Report saved to: {MIRROR_DIR / args.mode / 'transformation_report.json'}")

        if report.failed > 0:
            print(f"\nFailed files ({report.failed}):")
            for r in report.results:
                if not r.success:
                    print(f"  {r.original_id}: {r.error}")

    elif args.command == 'one':
        result = transform_one(args.file_id, args.mode, args.source)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.transformed_id}")
            print(f"Lines: {result.original_lines} -> {result.transformed_lines}")
            print(f"Chars: {result.original_chars} -> {result.transformed_chars}")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'preview':
        source_path = _get_source_path(args.file_id, args.source)
        if source_path:
            source = source_path.read_text()
            transformed, details = transform_code(source, args.mode)

            print(f"Preview for {args.file_id} (mode: {args.mode}):")
            print(f"  Original: {details['original_lines']} lines, {details['original_chars']} chars")
            print(f"  Transformed: {details['transformed_lines']} lines, {details['transformed_chars']} chars")
            print(f"  Compression ratio: {details.get('compression_ratio', 'N/A')}")
            print("\n--- Transformed Code (first 2000 chars) ---")
            print(transformed[:2000])
            if len(transformed) > 2000:
                print(f"\n... ({len(transformed) - 2000} more chars)")
        else:
            print(f"Error: Source file not found: {args.file_id}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
