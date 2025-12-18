"""
Shapeshifter Strategy - Multi-Level Code Transformation

Combines multiple transformation levels:
- L1: Formatting changes (Mirror strategy)
- L2: Identifier obfuscation (hex names, short names)
- L3: Control flow obfuscation (always-true conditionals)
- L4: Structural obfuscation (dead code injection)

Output naming: ss_{level}_{variant}_{source}_{original_id}
  - ss_l1_compressed_sn_ds_001.sol (L1 compressed formatting)
  - ss_l2_hex_sn_ds_001.sol (L2 hex-style obfuscation)
  - ss_l3_medium_sn_ds_001.sol (L3 medium intensity)
  - ss_l4_high_sn_ds_001.sol (L4 high intensity)
"""

import json
from pathlib import Path
from typing import Literal, Optional, Union, List, Dict, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import level-specific implementations
from .formatting import (
    transform_format,
    FORMAT_MODES,
    FormatResult,
)

from .obfuscation import (
    apply_obfuscation,
    apply_l2_obfuscation,
    apply_l3_obfuscation,
    apply_l4_obfuscation,
    ObfuscationResult,
)

# For reading source files
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from strategies.common import check_syntax
from strategies.sanitize.sanitize import transform_metadata_identifiers


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"
SHAPESHIFTER_DIR = DATA_DIR / "shapeshifter"

# Level definitions
LEVELS = {
    'l1': 'Formatting transformation (Mirror)',
    'l2': 'Identifier obfuscation',
    'l3': 'Control flow obfuscation',
    'l4': 'Structural obfuscation',
}

# Variants per level
LEVEL_VARIANTS = {
    'l1': FORMAT_MODES,  # compressed, expanded, allman, knr, minified
    'l2': ['hex', 'short', 'underscore'],
    'l3': ['low', 'medium', 'high'],
    'l4': ['low', 'medium', 'high'],
}

VALID_SOURCES = ['sanitized', 'nocomments']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class ShapeshifterResult:
    """Result of a Shapeshifter transformation."""
    original_id: str
    transformed_id: str
    level: str
    variant: str
    source: str
    success: bool
    code: str = ""
    rename_map: Dict[str, str] = field(default_factory=dict)
    changes: List[str] = field(default_factory=list)
    stats: Dict[str, Any] = field(default_factory=dict)
    error: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class ShapeshifterReport:
    """Report for batch Shapeshifter transformation."""
    timestamp: str
    level: str
    variant: str
    source: str
    total_files: int
    successful: int
    failed: int
    results: List[ShapeshifterResult] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            'timestamp': self.timestamp,
            'level': self.level,
            'variant': self.variant,
            'source': self.source,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [r.to_dict() for r in self.results]
        }


# =============================================================================
# UNIFIED TRANSFORMER
# =============================================================================

class ShapeshifterTransformer:
    """
    Unified Shapeshifter transformer supporting all levels.

    Levels:
    - L1: Format-only changes (uses Mirror strategy)
    - L2: Identifier renaming to obfuscated names
    - L3: L2 + Control flow complexity
    - L4: L3 + Structural changes (dead code)
    """

    def __init__(
        self,
        level: Literal["l1", "l2", "l3", "l4"],
        variant: str,
        seed: Optional[int] = None
    ):
        """
        Initialize Shapeshifter transformer.

        Args:
            level: Transformation level (l1, l2, l3, l4)
            variant: Variant for the level
            seed: Random seed for reproducibility
        """
        if level not in LEVELS:
            raise ValueError(f"Invalid level: {level}. Must be one of {list(LEVELS.keys())}")

        if variant not in LEVEL_VARIANTS[level]:
            raise ValueError(f"Invalid variant '{variant}' for level {level}. "
                           f"Must be one of {LEVEL_VARIANTS[level]}")

        self.level = level
        self.variant = variant
        self.seed = seed

    def transform(self, source_code: str) -> ShapeshifterResult:
        """
        Transform source code using configured level and variant.

        Args:
            source_code: Solidity source code to transform

        Returns:
            ShapeshifterResult with transformation details
        """
        if self.level == 'l1':
            return self._apply_l1(source_code)
        elif self.level == 'l2':
            return self._apply_l2(source_code)
        elif self.level == 'l3':
            return self._apply_l3(source_code)
        elif self.level == 'l4':
            return self._apply_l4(source_code)

    def _apply_l1(self, source: str) -> ShapeshifterResult:
        """Apply L1 formatting transformation."""
        try:
            transformed, details = transform_format(source, self.variant)

            return ShapeshifterResult(
                original_id="",
                transformed_id="",
                level='l1',
                variant=self.variant,
                source="",
                success=True,
                code=transformed,
                changes=[f"Applied {self.variant} formatting"],
                stats=details
            )
        except Exception as e:
            return ShapeshifterResult(
                original_id="",
                transformed_id="",
                level='l1',
                variant=self.variant,
                source="",
                success=False,
                error=str(e)
            )

    def _apply_l2(self, source: str) -> ShapeshifterResult:
        """Apply L2 identifier obfuscation."""
        result = apply_l2_obfuscation(source, style=self.variant, seed=self.seed)

        return ShapeshifterResult(
            original_id="",
            transformed_id="",
            level='l2',
            variant=self.variant,
            source="",
            success=result.success,
            code=result.code,
            rename_map=result.rename_map,
            changes=result.changes_made,
            error=result.error
        )

    def _apply_l3(self, source: str) -> ShapeshifterResult:
        """Apply L3 obfuscation (L2 + control flow)."""
        result = apply_obfuscation(source, level=3, style='hex', intensity=self.variant, seed=self.seed)

        return ShapeshifterResult(
            original_id="",
            transformed_id="",
            level='l3',
            variant=self.variant,
            source="",
            success=result.success,
            code=result.code,
            rename_map=result.rename_map,
            changes=result.changes_made,
            error=result.error
        )

    def _apply_l4(self, source: str) -> ShapeshifterResult:
        """Apply L4 obfuscation (L3 + structural)."""
        result = apply_obfuscation(source, level=4, style='hex', intensity=self.variant, seed=self.seed)

        return ShapeshifterResult(
            original_id="",
            transformed_id="",
            level='l4',
            variant=self.variant,
            source="",
            success=result.success,
            code=result.code,
            rename_map=result.rename_map,
            changes=result.changes_made,
            error=result.error
        )


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _ensure_output_dirs(level: str, variant: str):
    """Ensure output directories exist."""
    level_dir = SHAPESHIFTER_DIR / level / variant
    (level_dir / 'contracts').mkdir(parents=True, exist_ok=True)
    (level_dir / 'metadata').mkdir(parents=True, exist_ok=True)


def _get_source_path(source_id: str, source_dataset: str) -> Optional[Path]:
    """Get the path to a source contract."""
    if source_dataset == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source_dataset == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source dataset: {source_dataset}")

    for ext in ['.sol']:
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


def _get_shapeshifter_id(source_id: str, level: str, variant: str) -> str:
    """Generate shapeshifter file ID."""
    # ss_l1_compressed_sn_ds_001
    return f"ss_{level}_{variant}_{source_id}"


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def transform_one(
    file_id: str,
    level: str,
    variant: str,
    source: str = 'sanitized',
    save: bool = True
) -> ShapeshifterResult:
    """
    Transform a single file using Shapeshifter strategy.

    Args:
        file_id: Source file ID (e.g., 'sn_ds_001')
        level: Transformation level (l1, l2, l3, l4)
        variant: Variant for the level
        source: Source dataset
        save: Whether to save the result

    Returns:
        ShapeshifterResult with transformation details
    """
    # Validate inputs
    if level not in LEVELS:
        return ShapeshifterResult(
            original_id=file_id,
            transformed_id="",
            level=level,
            variant=variant,
            source=source,
            success=False,
            error=f"Invalid level: {level}"
        )

    if variant not in LEVEL_VARIANTS.get(level, []):
        return ShapeshifterResult(
            original_id=file_id,
            transformed_id="",
            level=level,
            variant=variant,
            source=source,
            success=False,
            error=f"Invalid variant '{variant}' for level {level}"
        )

    # Find source file
    source_path = _get_source_path(file_id, source)
    if not source_path:
        return ShapeshifterResult(
            original_id=file_id,
            transformed_id="",
            level=level,
            variant=variant,
            source=source,
            success=False,
            error=f"Source file not found: {file_id}"
        )

    try:
        # Read source
        source_code = source_path.read_text()

        # Transform
        transformer = ShapeshifterTransformer(level, variant)
        result = transformer.transform(source_code)

        # Update result with file info
        result.original_id = file_id
        result.source = source
        result.transformed_id = _get_shapeshifter_id(file_id, level, variant)

        if not result.success:
            return result

        # Validate syntax
        is_valid, errors = check_syntax(result.code)
        if not is_valid:
            result.success = False
            result.error = f"Syntax errors after transformation: {errors[:3]}"
            return result

        if save:
            _ensure_output_dirs(level, variant)

            # Save transformed contract
            output_path = SHAPESHIFTER_DIR / level / variant / 'contracts' / f"{result.transformed_id}.sol"
            output_path.write_text(result.code)

            # Load and update metadata
            meta_path = _get_metadata_path(file_id, source)
            if meta_path:
                metadata = json.loads(meta_path.read_text())
            else:
                metadata = {'id': file_id}

            # Apply metadata transformation for identifiers if we have a rename_map
            metadata_changes = []
            if result.rename_map:
                metadata, metadata_changes = transform_metadata_identifiers(metadata, result.rename_map)

            # For L3+, line numbers become invalid due to control flow restructuring
            # Set them to empty to avoid confusion
            if level in ['l3', 'l4']:
                if 'ground_truth' in metadata and 'vulnerable_location' in metadata.get('ground_truth', {}):
                    metadata['ground_truth']['vulnerable_location']['line_numbers'] = []

            # Update metadata
            metadata['id'] = result.transformed_id
            metadata['contract_file'] = f"contracts/{result.transformed_id}.sol"
            metadata['derived_from'] = file_id
            metadata['subset'] = 'shapeshifter'
            metadata['transformation'] = {
                'strategy': 'shapeshifter',
                'level': level,
                'variant': variant,
                'source': source,
                'changes': result.changes,
                'rename_map_size': len(result.rename_map),
                'metadata_changes': metadata_changes
            }

            # Store identifier mappings for traceability
            if result.rename_map:
                metadata['identifier_mappings'] = result.rename_map

            # Save metadata
            meta_output = SHAPESHIFTER_DIR / level / variant / 'metadata' / f"{result.transformed_id}.json"
            meta_output.write_text(json.dumps(metadata, indent=2))

        return result

    except Exception as e:
        return ShapeshifterResult(
            original_id=file_id,
            transformed_id="",
            level=level,
            variant=variant,
            source=source,
            success=False,
            error=str(e)
        )


def transform_all(
    level: str,
    variant: str,
    source: str = 'sanitized'
) -> ShapeshifterReport:
    """
    Transform all files using Shapeshifter strategy.

    Args:
        level: Transformation level
        variant: Variant for the level
        source: Source dataset

    Returns:
        ShapeshifterReport with batch transformation details
    """
    if source == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source dataset: {source}")

    if not source_dir.exists():
        raise FileNotFoundError(f"Source directory not found: {source_dir}")

    results = []
    contract_files = list(source_dir.glob('*.sol'))

    for contract_path in sorted(contract_files):
        file_id = contract_path.stem
        result = transform_one(file_id, level, variant, source, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    report = ShapeshifterReport(
        timestamp=datetime.now().isoformat(),
        level=level,
        variant=variant,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )

    # Save report
    _ensure_output_dirs(level, variant)
    report_path = SHAPESHIFTER_DIR / level / variant / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    # Generate index
    _generate_index(level, variant)

    return report


def _generate_index(level: str, variant: str):
    """Generate index.json for a shapeshifter level/variant dataset."""
    level_dir = SHAPESHIFTER_DIR / level / variant
    metadata_dir = level_dir / 'metadata'

    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'safe_count': 0,
        'by_vulnerability_type': {},
    }

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

    index = {
        'dataset_name': f'shapeshifter_{level}_{variant}',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'description': f'Contracts transformed with Shapeshifter strategy ({level}/{variant}). '
                       f'{LEVELS.get(level, "Unknown level")}.',
        'transformation': {
            'strategy': 'shapeshifter',
            'level': level,
            'variant': variant,
            'preserves_vulnerability': True,
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = level_dir / 'index.json'
    index_path.write_text(json.dumps(index, indent=2))


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Shapeshifter strategy."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Shapeshifter Strategy - Multi-Level Code Transformation'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts')
    all_parser.add_argument('--level', required=True, choices=list(LEVELS.keys()),
                           help='Transformation level')
    all_parser.add_argument('--variant', required=True,
                           help='Variant for the level')
    all_parser.add_argument('--source', default='sanitized',
                           choices=VALID_SOURCES, help='Source dataset')

    # Transform one
    one_parser = subparsers.add_parser('one', help='Transform single contract')
    one_parser.add_argument('file_id', help='Source file ID')
    one_parser.add_argument('--level', required=True, choices=list(LEVELS.keys()),
                           help='Transformation level')
    one_parser.add_argument('--variant', required=True,
                           help='Variant for the level')
    one_parser.add_argument('--source', default='sanitized',
                           choices=VALID_SOURCES, help='Source dataset')

    # List options
    list_parser = subparsers.add_parser('list', help='List available options')

    args = parser.parse_args()

    if args.command == 'all':
        print(f"Transforming all contracts using level '{args.level}' variant '{args.variant}'...")
        report = transform_all(args.level, args.variant, args.source)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")

        if report.failed > 0:
            print(f"\nFailed files ({report.failed}):")
            for r in report.results:
                if not r.success:
                    print(f"  {r.original_id}: {r.error}")

    elif args.command == 'one':
        result = transform_one(args.file_id, args.level, args.variant, args.source)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.transformed_id}")
            print(f"Changes: {len(result.changes)}")
            if result.rename_map:
                print(f"Identifiers renamed: {len(result.rename_map)}")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'list':
        print("Available levels and variants:")
        for level, description in LEVELS.items():
            variants = LEVEL_VARIANTS[level]
            print(f"  {level}: {description}")
            print(f"       Variants: {', '.join(variants)}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
