"""
Mirror Strategy - Format Transformation

Transform code formatting without changing semantics.
"""

from .mirror import (
    transform_code,
    transform_one,
    transform_all,
    apply_compressed,
    apply_expanded,
    apply_allman,
    apply_knr,
    apply_minified,
    VALID_MODES,
    TransformResult,
    TransformReport,
)

__all__ = [
    'transform_code',
    'transform_one',
    'transform_all',
    'apply_compressed',
    'apply_expanded',
    'apply_allman',
    'apply_knr',
    'apply_minified',
    'VALID_MODES',
    'TransformResult',
    'TransformReport',
]
