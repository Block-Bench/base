"""
Split Mode for Restructure Strategy

Wrapper around Hydra strategy for function splitting transformations.
Splits functions into helpers to test cross-function analysis.
"""

import sys
from pathlib import Path

# Add parent to path to import hydra
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

# Re-export from hydra
from strategies.hydra.hydra import (
    HydraTransformer as SplitTransformer,
    transform_one as _transform_one_split,
    transform_all as _transform_all_split,
    SPLIT_PATTERNS as SPLIT_MODES,
    TransformationResult as SplitResult,
    TransformationReport as SplitReport,
)

__all__ = [
    'SplitTransformer',
    'transform_one',
    'transform_all',
    'SPLIT_MODES',
    'SplitResult',
    'SplitReport',
]


def transform_one(file_id: str, split_pattern: str = 'internal_external', source: str = 'sanitized', save: bool = True) -> SplitResult:
    """Transform a single file using split mode."""
    return _transform_one_split(file_id, split_pattern, source, save)


def transform_all(split_pattern: str = 'internal_external', source: str = 'sanitized') -> SplitReport:
    """Transform all files using split mode."""
    return _transform_all_split(split_pattern, source)
