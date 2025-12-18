"""
Restructure Strategy - Unified Function Split and Merge

Combines:
- Split mode: Hydra-style function splitting into helpers
- Merge mode: Chimera-style combining similar functions

Output naming: rs_{mode}_{variant}_{source}_{original_id}
  - rs_split_int_sn_ds_001.sol (split with internal_external pattern)
  - rs_merge_dispatcher_sn_ds_001.sol (merge with dispatcher pattern)
"""

import json
from pathlib import Path
from typing import Literal, Optional, Union, List, Dict, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import mode-specific implementations
from .split import (
    SplitTransformer,
    transform_one as split_transform_one,
    transform_all as split_transform_all,
    SPLIT_MODES,
    SplitResult,
)

from .merge import (
    MergeTransformer,
    transform_one as merge_transform_one,
    transform_all as merge_transform_all,
    MERGE_MODES,
    MergeResult,
)

import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from strategies.common import check_syntax


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"
RESTRUCTURE_DIR = DATA_DIR / "restructure"

# Mode definitions
MODES = {
    'split': 'Split functions into helpers (Hydra)',
    'merge': 'Merge similar functions (Chimera)',
}

# Variants per mode
MODE_VARIANTS = {
    'split': SPLIT_MODES,  # internal_external, sequential
    'merge': MERGE_MODES,  # dispatcher, inline
}

VALID_SOURCES = ['sanitized', 'nocomments']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class RestructureResult:
    """Result of a Restructure transformation."""
    original_id: str
    transformed_id: str
    mode: str
    variant: str
    source: str
    success: bool
    code: str = ""
    changes: List[str] = field(default_factory=list)
    stats: Dict[str, Any] = field(default_factory=dict)
    error: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class RestructureReport:
    """Report for batch Restructure transformation."""
    timestamp: str
    mode: str
    variant: str
    source: str
    total_files: int
    successful: int
    failed: int
    results: List[RestructureResult] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            'timestamp': self.timestamp,
            'mode': self.mode,
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

class RestructureTransformer:
    """
    Unified Restructure transformer supporting split and merge modes.

    Split mode: Breaks functions into smaller helper functions
    Merge mode: Combines similar functions into unified handlers
    """

    def __init__(
        self,
        mode: Literal["split", "merge"],
        variant: str,
    ):
        """
        Initialize Restructure transformer.

        Args:
            mode: 'split' or 'merge'
            variant: Variant for the mode
        """
        if mode not in MODES:
            raise ValueError(f"Invalid mode: {mode}. Must be one of {list(MODES.keys())}")

        if variant not in MODE_VARIANTS.get(mode, []):
            raise ValueError(f"Invalid variant '{variant}' for mode {mode}. "
                           f"Must be one of {MODE_VARIANTS[mode]}")

        self.mode = mode
        self.variant = variant

        if mode == 'split':
            self._transformer = SplitTransformer(variant)
        elif mode == 'merge':
            self._transformer = MergeTransformer(variant)

    def transform(self, source_code: str) -> RestructureResult:
        """
        Transform source code using configured mode and variant.

        Args:
            source_code: Solidity source code to transform

        Returns:
            RestructureResult with transformation details
        """
        if self.mode == 'split':
            return self._apply_split(source_code)
        elif self.mode == 'merge':
            return self._apply_merge(source_code)

    def _apply_split(self, source: str) -> RestructureResult:
        """Apply split transformation using Hydra."""
        try:
            result = self._transformer.transform(source)

            return RestructureResult(
                original_id="",
                transformed_id="",
                mode='split',
                variant=self.variant,
                source="",
                success=result.success,
                code=result.transformed_code if hasattr(result, 'transformed_code') else "",
                changes=result.split_info if hasattr(result, 'split_info') else [],
                error=result.error if hasattr(result, 'error') else None
            )
        except Exception as e:
            return RestructureResult(
                original_id="",
                transformed_id="",
                mode='split',
                variant=self.variant,
                source="",
                success=False,
                error=str(e)
            )

    def _apply_merge(self, source: str) -> RestructureResult:
        """Apply merge transformation using Chimera."""
        result = self._transformer.transform(source)

        return RestructureResult(
            original_id="",
            transformed_id="",
            mode='merge',
            variant=self.variant,
            source="",
            success=result.success,
            code=result.code,
            changes=result.changes_made,
            error=result.error
        )


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _ensure_output_dirs(mode: str, variant: str):
    """Ensure output directories exist."""
    mode_dir = RESTRUCTURE_DIR / mode / variant
    (mode_dir / 'contracts').mkdir(parents=True, exist_ok=True)
    (mode_dir / 'metadata').mkdir(parents=True, exist_ok=True)


def _get_source_path(source_id: str, source_dataset: str) -> Optional[Path]:
    """Get the path to a source contract."""
    if source_dataset == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source_dataset == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        return None

    path = source_dir / f"{source_id}.sol"
    return path if path.exists() else None


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


def _get_restructure_id(source_id: str, mode: str, variant: str) -> str:
    """Generate restructure file ID."""
    # rs_split_int_sn_ds_001
    mode_prefix = 'sp' if mode == 'split' else 'mg'
    var_prefix = variant[:3]
    return f"rs_{mode_prefix}_{var_prefix}_{source_id}"


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def transform_one(
    file_id: str,
    mode: str,
    variant: str,
    source: str = 'sanitized',
    save: bool = True
) -> RestructureResult:
    """
    Transform a single file using Restructure strategy.

    Args:
        file_id: Source file ID (e.g., 'sn_ds_001')
        mode: 'split' or 'merge'
        variant: Variant for the mode
        source: Source dataset
        save: Whether to save the result

    Returns:
        RestructureResult with transformation details
    """
    # For split mode, delegate to Hydra directly
    if mode == 'split':
        hydra_result = split_transform_one(file_id, variant, source, save)
        helpers_count = 0
        if hydra_result.split_details and hydra_result.split_details.helpers:
            helpers_count = len(hydra_result.split_details.helpers)
        return RestructureResult(
            original_id=file_id,
            transformed_id=hydra_result.hydra_id,
            mode='split',
            variant=variant,
            source=source,
            success=hydra_result.success,
            code="",  # Hydra saves directly
            changes=[f"Split into {helpers_count} helper functions"] if helpers_count > 0 else [],
            error=hydra_result.error
        )

    # For merge mode, use MergeTransformer
    if mode == 'merge':
        merge_result = merge_transform_one(file_id, variant, source, save=False)

        result = RestructureResult(
            original_id=file_id,
            transformed_id=_get_restructure_id(file_id, mode, variant),
            mode='merge',
            variant=variant,
            source=source,
            success=merge_result.success,
            code=merge_result.code,
            changes=merge_result.changes_made,
            error=merge_result.error
        )

        if save and result.success:
            _ensure_output_dirs(mode, variant)

            # Save contract
            output_path = RESTRUCTURE_DIR / mode / variant / 'contracts' / f"{result.transformed_id}.sol"
            output_path.write_text(result.code)

            # Save metadata
            meta_path = _get_metadata_path(file_id, source)
            if meta_path:
                metadata = json.loads(meta_path.read_text())
            else:
                metadata = {'id': file_id}

            metadata['id'] = result.transformed_id
            metadata['contract_file'] = f"contracts/{result.transformed_id}.sol"
            metadata['derived_from'] = file_id
            metadata['subset'] = 'restructure'
            metadata['transformation'] = {
                'strategy': 'restructure',
                'mode': mode,
                'variant': variant,
                'changes': result.changes
            }

            meta_output = RESTRUCTURE_DIR / mode / variant / 'metadata' / f"{result.transformed_id}.json"
            meta_output.write_text(json.dumps(metadata, indent=2))

        return result

    return RestructureResult(
        original_id=file_id,
        transformed_id="",
        mode=mode,
        variant=variant,
        source=source,
        success=False,
        error=f"Invalid mode: {mode}"
    )


def transform_all(
    mode: str,
    variant: str,
    source: str = 'sanitized'
) -> RestructureReport:
    """
    Transform all files using Restructure strategy.

    Args:
        mode: 'split' or 'merge'
        variant: Variant for the mode
        source: Source dataset

    Returns:
        RestructureReport with batch transformation details
    """
    # For split mode, delegate to Hydra
    if mode == 'split':
        hydra_report = split_transform_all(variant, source)
        results = [
            RestructureResult(
                original_id=r.original_id,
                transformed_id=r.hydra_id,  # Hydra uses hydra_id not transformed_id
                mode='split',
                variant=variant,
                source=source,
                success=r.success,
                error=r.error
            )
            for r in hydra_report.results
        ]
        return RestructureReport(
            timestamp=hydra_report.timestamp,
            mode='split',
            variant=variant,
            source=source,
            total_files=hydra_report.total_files,
            successful=hydra_report.successful,
            failed=hydra_report.failed,
            results=results
        )

    # For merge mode
    if source == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source: {source}")

    results = []
    contract_files = list(source_dir.glob('*.sol'))

    for contract_path in sorted(contract_files):
        file_id = contract_path.stem
        result = transform_one(file_id, mode, variant, source, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    report = RestructureReport(
        timestamp=datetime.now().isoformat(),
        mode=mode,
        variant=variant,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )

    # Save report
    _ensure_output_dirs(mode, variant)
    report_path = RESTRUCTURE_DIR / mode / variant / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    return report


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Restructure strategy."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Restructure Strategy - Function Split and Merge'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts')
    all_parser.add_argument('--mode', required=True, choices=list(MODES.keys()),
                           help='Transformation mode')
    all_parser.add_argument('--variant', required=True,
                           help='Variant for the mode')
    all_parser.add_argument('--source', default='sanitized',
                           choices=VALID_SOURCES, help='Source dataset')

    # Transform one
    one_parser = subparsers.add_parser('one', help='Transform single contract')
    one_parser.add_argument('file_id', help='Source file ID')
    one_parser.add_argument('--mode', required=True, choices=list(MODES.keys()),
                           help='Transformation mode')
    one_parser.add_argument('--variant', required=True,
                           help='Variant for the mode')
    one_parser.add_argument('--source', default='sanitized',
                           choices=VALID_SOURCES, help='Source dataset')

    # List options
    list_parser = subparsers.add_parser('list', help='List available options')

    args = parser.parse_args()

    if args.command == 'all':
        print(f"Transforming all contracts using {args.mode} mode ({args.variant})...")
        report = transform_all(args.mode, args.variant, args.source)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")

        if report.failed > 0:
            print(f"\nFailed files ({report.failed}):")
            for r in report.results:
                if not r.success:
                    print(f"  {r.original_id}: {r.error}")

    elif args.command == 'one':
        result = transform_one(args.file_id, args.mode, args.variant, args.source)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.transformed_id}")
            print(f"Changes: {len(result.changes)}")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'list':
        print("Available modes and variants:")
        for mode, description in MODES.items():
            variants = MODE_VARIANTS[mode]
            print(f"  {mode}: {description}")
            print(f"       Variants: {', '.join(variants)}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
