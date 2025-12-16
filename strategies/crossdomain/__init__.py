"""
Cross-Domain Strategy - Terminology Swap

Transform contracts from DeFi to other domains (Gaming, Healthcare, Social, Logistics).
"""

from .crossdomain import (
    CrossDomainTransformer,
    transform_one,
    transform_all,
    load_domain,
    build_domain_mapping,
    detect_domain,
    VALID_DOMAINS,
    TransformResult,
    TransformReport,
)

__all__ = [
    'CrossDomainTransformer',
    'transform_one',
    'transform_all',
    'load_domain',
    'build_domain_mapping',
    'detect_domain',
    'VALID_DOMAINS',
    'TransformResult',
    'TransformReport',
]
