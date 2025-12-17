"""
Guardian Strategy v2.0 - Unified Protection Pattern Testing

Combines:
- Explicit mode: Real protections (GuardianShield) - FIXES vulnerabilities
- Implicit mode: Fake protections (Confidence Trap) - PRESERVES vulnerabilities

Output naming: gd_{mode}_{variant}_{source}_{original_id}
  - gd_explicit_reentrancy_sn_ds_001.sol (real reentrancy guard)
  - gd_implicit_fake_guard_sn_ds_001.sol (fake guard that doesn't protect)
"""

import json
from pathlib import Path
from typing import Literal, Optional, Union, List, Dict, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import mode-specific implementations
from .explicit import (
    transform_one as explicit_transform_one,
    transform_all as explicit_transform_all,
    PROTECTION_TYPES,
    ExplicitResult,
)

from .implicit import (
    ConfidenceTrapTransformer,
    transform_one as implicit_transform_one,
    transform_all as implicit_transform_all,
    TRAP_PATTERNS,
    TrapResult,
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
GUARDIAN_DIR = DATA_DIR / "guardian"  # Combined Guardian strategy

# Mode definitions
MODES = {
    'explicit': 'Real protections that fix vulnerabilities (GuardianShield)',
    'implicit': 'Fake protections that look real but preserve vulnerabilities (Confidence Trap)',
}

# Variants per mode
MODE_VARIANTS = {
    'explicit': PROTECTION_TYPES,  # reentrancy_guard, cei_pattern, access_control, solidity_0_8
    'implicit': TRAP_PATTERNS,     # fake_guard, partial_fix, decoy_pattern
}

VALID_SOURCES = ['sanitized', 'nocomments']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class GuardianResult:
    """Result of a Guardian transformation."""
    original_id: str
    transformed_id: str
    mode: str
    variant: str
    source: str
    success: bool
    code: str = ""
    still_vulnerable: bool = True  # Explicit=False, Implicit=True
    changes: List[str] = field(default_factory=list)
    error: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class GuardianReport:
    """Report for batch Guardian transformation."""
    timestamp: str
    mode: str
    variant: str
    source: str
    total_files: int
    successful: int
    failed: int
    results: List[GuardianResult] = field(default_factory=list)

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

class GuardianTransformer:
    """
    Unified Guardian transformer supporting explicit and implicit modes.

    Explicit mode: Applies real protections that fix vulnerabilities
    Implicit mode: Applies fake protections that preserve vulnerabilities
    """

    def __init__(
        self,
        mode: Literal["explicit", "implicit"],
        variant: str,
    ):
        """
        Initialize Guardian transformer.

        Args:
            mode: 'explicit' or 'implicit'
            variant: Variant for the mode
        """
        if mode not in MODES:
            raise ValueError(f"Invalid mode: {mode}. Must be one of {list(MODES.keys())}")

        if variant not in MODE_VARIANTS.get(mode, []):
            raise ValueError(f"Invalid variant '{variant}' for mode {mode}. "
                           f"Must be one of {MODE_VARIANTS[mode]}")

        self.mode = mode
        self.variant = variant

        if mode == 'implicit':
            self._transformer = ConfidenceTrapTransformer(variant)


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _ensure_output_dirs(mode: str, variant: str):
    """Ensure output directories exist."""
    mode_dir = GUARDIAN_DIR / mode / variant
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


def _get_guardian_id(source_id: str, mode: str, variant: str) -> str:
    """Generate guardian file ID."""
    mode_prefix = 'ex' if mode == 'explicit' else 'im'
    var_prefix = variant[:3] if len(variant) > 3 else variant
    return f"gd_{mode_prefix}_{var_prefix}_{source_id}"


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def transform_one(
    file_id: str,
    mode: str,
    variant: str,
    source: str = 'sanitized',
    save: bool = True
) -> GuardianResult:
    """
    Transform a single file using Guardian strategy.

    Args:
        file_id: Source file ID (e.g., 'sn_ds_001')
        mode: 'explicit' or 'implicit'
        variant: Variant for the mode
        source: Source dataset
        save: Whether to save the result

    Returns:
        GuardianResult with transformation details
    """
    # For explicit mode, delegate to GuardianShield
    if mode == 'explicit':
        gs_result = explicit_transform_one(file_id, variant, source, save)
        return GuardianResult(
            original_id=file_id,
            transformed_id=gs_result.transformed_id,
            mode='explicit',
            variant=variant,
            source=source,
            success=gs_result.success,
            code="",  # GuardianShield saves directly
            still_vulnerable=False,  # Explicit mode FIXES the vulnerability
            changes=[f"Applied {variant} protection"],
            error=gs_result.error
        )

    # For implicit mode, use ConfidenceTrap
    if mode == 'implicit':
        trap_result = implicit_transform_one(file_id, variant, source, save=False)

        result = GuardianResult(
            original_id=file_id,
            transformed_id=_get_guardian_id(file_id, mode, variant),
            mode='implicit',
            variant=variant,
            source=source,
            success=trap_result.success,
            code=trap_result.code,
            still_vulnerable=True,  # Implicit mode PRESERVES vulnerability
            changes=trap_result.traps_added,
            error=trap_result.error
        )

        if save and result.success:
            _ensure_output_dirs(mode, variant)

            # Save contract
            output_path = GUARDIAN_DIR / mode / variant / 'contracts' / f"{result.transformed_id}.sol"
            output_path.write_text(result.code)

            # Save metadata
            meta_path = _get_metadata_path(file_id, source)
            if meta_path:
                metadata = json.loads(meta_path.read_text())
            else:
                metadata = {'id': file_id}

            # IMPORTANT: Update vulnerability status based on mode
            if 'ground_truth' not in metadata:
                metadata['ground_truth'] = {}
            metadata['ground_truth']['is_vulnerable'] = result.still_vulnerable

            metadata['id'] = result.transformed_id
            metadata['contract_file'] = f"contracts/{result.transformed_id}.sol"
            metadata['derived_from'] = file_id
            metadata['subset'] = 'guardian'
            metadata['transformation'] = {
                'strategy': 'guardian',
                'mode': mode,
                'variant': variant,
                'changes': result.changes,
                'still_vulnerable': result.still_vulnerable
            }

            meta_output = GUARDIAN_DIR / mode / variant / 'metadata' / f"{result.transformed_id}.json"
            meta_output.write_text(json.dumps(metadata, indent=2))

        return result

    return GuardianResult(
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
) -> GuardianReport:
    """
    Transform all files using Guardian strategy.

    Args:
        mode: 'explicit' or 'implicit'
        variant: Variant for the mode
        source: Source dataset

    Returns:
        GuardianReport with batch transformation details
    """
    # For explicit mode, delegate to GuardianShield
    if mode == 'explicit':
        gs_report = explicit_transform_all(variant, source)
        results = [
            GuardianResult(
                original_id=r.original_id,
                transformed_id=r.transformed_id,
                mode='explicit',
                variant=variant,
                source=source,
                success=r.success,
                still_vulnerable=False,
                error=r.error
            )
            for r in gs_report.results
        ]
        return GuardianReport(
            timestamp=gs_report.timestamp,
            mode='explicit',
            variant=variant,
            source=source,
            total_files=gs_report.total_files,
            successful=gs_report.successful,
            failed=gs_report.failed,
            results=results
        )

    # For implicit mode
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

    report = GuardianReport(
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
    report_path = GUARDIAN_DIR / mode / variant / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    return report


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Guardian strategy."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Guardian Strategy v2.0 - Protection Pattern Testing'
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
            print(f"Still Vulnerable: {result.still_vulnerable}")
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
