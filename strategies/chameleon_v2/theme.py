"""
Theme Mode for Chameleon Strategy

Transforms identifiers using themed synonym pools.
Each identifier is independently mapped to a random synonym from the theme.

This is a wrapper around the original chameleon implementation.
"""

import sys
from pathlib import Path

# Add parent to path to import original chameleon
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

# Re-export from original chameleon
from strategies.chameleon.chameleon import (
    ChameleonTransformer as ThemeTransformer,
    transform_code as transform_theme,
    transform_one as _transform_one_theme,
    transform_all as _transform_all_theme,
    SynonymPoolLoader,
    THEMES,
    TransformationResult,
    TransformationReport,
    CoverageStats,
    CoverageReport,
    ValidationResult,
)

__all__ = [
    'ThemeTransformer',
    'transform_theme',
    'transform_one',
    'transform_all',
    'SynonymPoolLoader',
    'THEMES',
    'TransformationResult',
    'TransformationReport',
]


def transform_one(file_id: str, theme: str, source: str = 'sanitized', save: bool = True) -> TransformationResult:
    """Transform a single file using theme mode."""
    return _transform_one_theme(file_id, theme, source, save)


def transform_all(theme: str, source: str = 'sanitized') -> TransformationReport:
    """Transform all files using theme mode."""
    return _transform_all_theme(theme, source)
