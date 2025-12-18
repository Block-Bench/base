"""
L1 Formatting Mode for Shapeshifter Strategy

Wrapper around Mirror strategy for formatting transformations.
Modes: compressed, expanded, allman, knr, minified
"""

import sys
from pathlib import Path

# Add parent to path to import mirror
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

# Re-export from mirror
from strategies.mirror.mirror import (
    transform_code as transform_format,
    transform_one as _transform_one_format,
    transform_all as _transform_all_format,
    apply_compressed,
    apply_expanded,
    apply_allman,
    apply_knr,
    apply_minified,
    VALID_MODES as FORMAT_MODES,
    TransformResult as FormatResult,
    TransformReport as FormatReport,
)

__all__ = [
    'transform_format',
    'transform_one',
    'transform_all',
    'apply_compressed',
    'apply_expanded',
    'apply_allman',
    'apply_knr',
    'apply_minified',
    'FORMAT_MODES',
    'FormatResult',
    'FormatReport',
]


def transform_one(file_id: str, mode: str, source: str = 'sanitized', save: bool = True) -> FormatResult:
    """Transform a single file using L1 formatting mode."""
    return _transform_one_format(file_id, mode, source, save)


def transform_all(mode: str, source: str = 'sanitized') -> FormatReport:
    """Transform all files using L1 formatting mode."""
    return _transform_all_format(mode, source)
