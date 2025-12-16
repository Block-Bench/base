"""
Chameleon Transformation Strategy for BlockBench Contracts

Systematically renames all user-defined identifiers using randomized
synonym pools to test whether AI models rely on keyword patterns
rather than understanding code semantics.

Output naming: ch_{theme}_{source}_{original_id}
Examples:
  - ch_gaming_sn_ds_001.sol (from sanitized ds_001)
  - ch_gaming_nc_tc_042.sol (from nocomments tc_042)
"""

from .chameleon import (
    ChameleonTransformer,
    transform_one,
    transform_all,
    transform_subset,
    transform_code,
    THEMES,
)

__all__ = [
    'ChameleonTransformer',
    'transform_one',
    'transform_all',
    'transform_subset',
    'transform_code',
    'THEMES',
]
