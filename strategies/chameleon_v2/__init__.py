"""
Chameleon Strategy v2.0 - Unified Keyword/Terminology Transformation

Combines:
- Theme mode: Random synonyms from thematic pools (original Chameleon)
- Domain mode: Coherent terminology shift to new business domain (Cross-Domain)

Tests whether AI models rely on keyword patterns rather than semantic understanding.
"""

from .chameleon import ChameleonTransformer, transform_one, transform_all

__all__ = ['ChameleonTransformer', 'transform_one', 'transform_all']
