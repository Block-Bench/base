"""
Guardian Strategy v2.0 - Protection Pattern Testing

Combines:
- Explicit mode (GuardianShield): Real protection mechanisms that fix vulnerabilities
- Implicit mode (Confidence Trap): Fake patterns that look protective but don't fix

Tests whether AI models distinguish real protections from security theater.
"""

from .guardian import GuardianTransformer, transform_one, transform_all, MODES

__all__ = ['GuardianTransformer', 'transform_one', 'transform_all', 'MODES']
