"""
Hydra Transformation Strategy

Splits vulnerable functions into multiple helper functions to test
whether AI models can trace vulnerability patterns across function boundaries.
"""

from .hydra import (
    HydraTransformer,
    transform_code,
    transform_one,
    transform_all,
    TransformationResult,
    TransformationReport,
    SPLIT_PATTERNS,
)

__all__ = [
    'HydraTransformer',
    'transform_code',
    'transform_one',
    'transform_all',
    'TransformationResult',
    'TransformationReport',
    'SPLIT_PATTERNS',
]
