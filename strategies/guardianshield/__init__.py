"""
Guardian Shield Strategy - Protection Injection

Inject protection mechanisms that neutralize vulnerabilities.
CHANGES vulnerability status from true to false.
"""

from .guardianshield import (
    GuardianShieldTransformer,
    ReentrancyGuardInjector,
    CEIPatternFixer,
    AccessControlInjector,
    SolidityVersionUpdater,
    transform_one,
    transform_all,
    VALID_PROTECTIONS,
    PROTECTION_TARGETS,
    TransformResult,
    TransformReport,
)

__all__ = [
    'GuardianShieldTransformer',
    'ReentrancyGuardInjector',
    'CEIPatternFixer',
    'AccessControlInjector',
    'SolidityVersionUpdater',
    'transform_one',
    'transform_all',
    'VALID_PROTECTIONS',
    'PROTECTION_TARGETS',
    'TransformResult',
    'TransformReport',
]
