"""
Domain Mode for Chameleon Strategy

Transforms identifiers using coherent domain-to-domain mappings.
The entire contract shifts to a consistent target domain terminology.

This is a wrapper around the original crossdomain implementation.
"""

import sys
from pathlib import Path

# Add parent to path to import original crossdomain
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

# Re-export from original crossdomain
from strategies.crossdomain.crossdomain import (
    CrossDomainTransformer as DomainTransformer,
    transform_one as _transform_one_domain,
    transform_all as _transform_all_domain,
    load_domain,
    build_domain_mapping,
    VALID_DOMAINS,
    TransformResult as DomainTransformResult,
    TransformReport as DomainTransformReport,
)


def transform_domain(source_code: str, target_domain: str, seed: int = None):
    """Transform source code using domain mode."""
    transformer = DomainTransformer(target_domain)
    transformed, rename_map, coverage = transformer.transform(source_code)
    return transformed, rename_map, coverage

__all__ = [
    'DomainTransformer',
    'transform_domain',
    'transform_one',
    'transform_all',
    'load_domain',
    'build_domain_mapping',
    'VALID_DOMAINS',
    'DomainTransformResult',
    'DomainTransformReport',
]


def transform_one(file_id: str, target_domain: str, source: str = 'sanitized', save: bool = True) -> DomainTransformResult:
    """Transform a single file using domain mode."""
    return _transform_one_domain(file_id, target_domain, source, save)


def transform_all(target_domain: str, source: str = 'sanitized') -> DomainTransformReport:
    """Transform all files using domain mode."""
    return _transform_all_domain(target_domain, source)
