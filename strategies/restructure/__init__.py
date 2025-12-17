"""
Restructure Strategy - Function Split and Merge Transformations

Combines:
- Split mode (Hydra): Splits functions into helper functions
- Merge mode (Chimera): Combines similar functions into unified handlers

Tests whether AI models can track vulnerability patterns across function boundaries.
"""

from .restructure import RestructureTransformer, transform_one, transform_all, MODES

__all__ = ['RestructureTransformer', 'transform_one', 'transform_all', 'MODES']
