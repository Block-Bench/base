"""
Explicit Mode for Guardian Strategy

Wrapper around GuardianShield strategy for real protection injection.
These protections actually fix the vulnerabilities.
"""

import sys
from pathlib import Path

# Add parent to path to import guardianshield
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

# Re-export from guardianshield
from strategies.guardianshield.guardianshield import (
    transform_one as _transform_one_explicit,
    transform_all as _transform_all_explicit,
    VALID_PROTECTIONS as PROTECTION_TYPES,
    TransformResult as ExplicitResult,
    TransformReport as ExplicitReport,
)

__all__ = [
    'transform_one',
    'transform_all',
    'PROTECTION_TYPES',
    'ExplicitResult',
    'ExplicitReport',
]


def transform_one(file_id: str, protection: str, source: str = 'sanitized', save: bool = True) -> ExplicitResult:
    """Transform a single file using explicit protection mode."""
    return _transform_one_explicit(file_id, protection, source, save)


def transform_all(protection: str, source: str = 'sanitized') -> ExplicitReport:
    """Transform all files using explicit protection mode."""
    return _transform_all_explicit(protection, source)
