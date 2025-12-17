"""
Chameleon Strategy v2.0 - Unified Interface

Combines theme and domain modes for keyword/terminology transformation.

Modes:
- theme: Random synonyms from thematic pools (gaming, medical, social, etc.)
- domain: Coherent terminology shift to new business domain (defi→gaming, etc.)

Output naming: ch_{mode}_{param}_{source}_{original_id}
  - ch_theme_gaming_sn_ds_001.sol (theme mode with gaming theme)
  - ch_domain_healthcare_sn_ds_001.sol (domain mode targeting healthcare)
"""

import json
from pathlib import Path
from typing import Literal, Optional, Union
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import mode-specific implementations
from .theme import (
    ThemeTransformer,
    transform_theme,
    transform_one as theme_transform_one,
    transform_all as theme_transform_all,
    THEMES,
    TransformationResult as ThemeResult,
    TransformationReport as ThemeReport,
)

from .domain import (
    DomainTransformer,
    transform_domain,
    transform_one as domain_transform_one,
    transform_all as domain_transform_all,
    VALID_DOMAINS,
    DomainTransformResult as DomainResult,
    DomainTransformReport as DomainReport,
)


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
CHAMELEON_V2_DIR = DATA_DIR / "chameleon_v2"

# Mode options
VALID_MODES = ['theme', 'domain']
VALID_SOURCES = ['sanitized', 'nocomments']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class ChameleonResult:
    """Unified result for Chameleon transformation."""
    original_id: str
    chameleon_id: str
    mode: str
    mode_param: str  # theme name or target domain
    source: str
    success: bool
    code: str = ""
    rename_map: dict = field(default_factory=dict)
    coverage: float = 0.0
    error: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class ChameleonReport:
    """Unified report for batch Chameleon transformation."""
    timestamp: str
    mode: str
    mode_param: str
    source: str
    total_files: int
    successful: int
    failed: int
    average_coverage: float = 0.0
    results: list = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            'timestamp': self.timestamp,
            'mode': self.mode,
            'mode_param': self.mode_param,
            'source': self.source,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'average_coverage': self.average_coverage,
            'results': [r.to_dict() if hasattr(r, 'to_dict') else r for r in self.results]
        }


# =============================================================================
# UNIFIED TRANSFORMER
# =============================================================================

class ChameleonTransformer:
    """
    Unified Chameleon transformer supporting both theme and domain modes.

    Theme mode: Each identifier independently mapped to random synonym from theme.
    Domain mode: Entire contract shifts to coherent target domain terminology.
    """

    def __init__(
        self,
        mode: Literal["theme", "domain"],
        theme: Optional[str] = None,
        target_domain: Optional[str] = None,
        source: str = "sanitized",
        variation_level: str = "medium"
    ):
        """
        Initialize Chameleon transformer.

        Args:
            mode: 'theme' or 'domain'
            theme: Theme name for theme mode (gaming, medical, social, etc.)
            target_domain: Target domain for domain mode (gaming, healthcare, etc.)
            source: Source dataset ('sanitized' or 'nocomments')
            variation_level: Variation level for theme mode ('low', 'medium', 'high')
        """
        if mode not in VALID_MODES:
            raise ValueError(f"Invalid mode: {mode}. Must be one of {VALID_MODES}")

        self.mode = mode
        self.source = source
        self.variation_level = variation_level

        if mode == "theme":
            if not theme:
                raise ValueError("Theme mode requires 'theme' parameter")
            if theme not in THEMES:
                raise ValueError(f"Invalid theme: {theme}. Must be one of {THEMES}")
            self.theme = theme
            self.target_domain = None
            self._transformer = ThemeTransformer(theme)

        elif mode == "domain":
            if not target_domain:
                raise ValueError("Domain mode requires 'target_domain' parameter")
            if target_domain not in VALID_DOMAINS:
                raise ValueError(f"Invalid domain: {target_domain}. Must be one of {VALID_DOMAINS}")
            self.theme = None
            self.target_domain = target_domain
            self._transformer = DomainTransformer(target_domain)

    @property
    def mode_param(self) -> str:
        """Get the mode-specific parameter (theme or target_domain)."""
        return self.theme if self.mode == "theme" else self.target_domain

    def transform(self, source_code: str, seed: Optional[int] = None) -> tuple:
        """
        Transform source code using the configured mode.

        Args:
            source_code: Solidity source code to transform
            seed: Optional random seed for reproducibility

        Returns:
            Tuple of (transformed_code, rename_map, coverage)
        """
        if self.mode == "theme":
            return transform_theme(source_code, self.theme, seed)
        else:
            return transform_domain(source_code, self.target_domain, seed)


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def transform_one(
    file_id: str,
    mode: str,
    mode_param: str,
    source: str = 'sanitized',
    save: bool = True
) -> ChameleonResult:
    """
    Transform a single file using Chameleon strategy.

    Args:
        file_id: Source file ID (e.g., 'sn_ds_001')
        mode: 'theme' or 'domain'
        mode_param: Theme name (for theme mode) or target domain (for domain mode)
        source: Source dataset
        save: Whether to save the result

    Returns:
        ChameleonResult with transformation details
    """
    if mode == "theme":
        result = theme_transform_one(file_id, mode_param, source, save)
        return ChameleonResult(
            original_id=result.original_id,
            chameleon_id=result.chameleon_id,
            mode="theme",
            mode_param=mode_param,
            source=source,
            success=result.success,
            code=result.code,
            rename_map=result.rename_map,
            coverage=result.coverage.coverage_percent if result.coverage else 0.0,
            error=result.error
        )
    elif mode == "domain":
        result = domain_transform_one(file_id, mode_param, source, save)
        return ChameleonResult(
            original_id=result.original_id,
            chameleon_id=result.transformed_id,
            mode="domain",
            mode_param=mode_param,
            source=source,
            success=result.success,
            code="",  # Domain mode doesn't return code in result
            rename_map=result.rename_map,
            coverage=result.coverage * 100 if result.coverage else 0.0,
            error=result.error
        )
    else:
        raise ValueError(f"Invalid mode: {mode}")


def transform_all(
    mode: str,
    mode_param: str,
    source: str = 'sanitized'
) -> ChameleonReport:
    """
    Transform all files using Chameleon strategy.

    Args:
        mode: 'theme' or 'domain'
        mode_param: Theme name (for theme mode) or target domain (for domain mode)
        source: Source dataset

    Returns:
        ChameleonReport with batch transformation details
    """
    if mode == "theme":
        report = theme_transform_all(mode_param, source)
        return ChameleonReport(
            timestamp=report.timestamp,
            mode="theme",
            mode_param=mode_param,
            source=source,
            total_files=report.total_files,
            successful=report.successful,
            failed=report.failed,
            results=report.results
        )
    elif mode == "domain":
        report = domain_transform_all(mode_param, source)
        return ChameleonReport(
            timestamp=report.timestamp,
            mode="domain",
            mode_param=mode_param,
            source=source,
            total_files=report.total_files,
            successful=report.successful,
            failed=report.failed,
            average_coverage=report.average_coverage,
            results=report.results
        )
    else:
        raise ValueError(f"Invalid mode: {mode}")


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Chameleon v2 strategy."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Chameleon v2 - Unified Keyword/Terminology Transformation'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts')
    all_parser.add_argument('--mode', required=True, choices=VALID_MODES,
                           help='Transformation mode')
    all_parser.add_argument('--theme', help='Theme name (for theme mode)')
    all_parser.add_argument('--domain', help='Target domain (for domain mode)')
    all_parser.add_argument('--source', default='sanitized',
                           choices=VALID_SOURCES, help='Source dataset')

    # Transform one
    one_parser = subparsers.add_parser('one', help='Transform single contract')
    one_parser.add_argument('file_id', help='Source file ID')
    one_parser.add_argument('--mode', required=True, choices=VALID_MODES,
                           help='Transformation mode')
    one_parser.add_argument('--theme', help='Theme name (for theme mode)')
    one_parser.add_argument('--domain', help='Target domain (for domain mode)')
    one_parser.add_argument('--source', default='sanitized',
                           choices=VALID_SOURCES, help='Source dataset')

    # List options
    list_parser = subparsers.add_parser('list', help='List available options')
    list_parser.add_argument('--themes', action='store_true', help='List themes')
    list_parser.add_argument('--domains', action='store_true', help='List domains')

    args = parser.parse_args()

    if args.command == 'all':
        mode_param = args.theme if args.mode == 'theme' else args.domain
        if not mode_param:
            print(f"Error: --{'theme' if args.mode == 'theme' else 'domain'} is required for {args.mode} mode")
            return

        print(f"Transforming all contracts using {args.mode} mode ({mode_param})...")
        report = transform_all(args.mode, mode_param, args.source)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")

    elif args.command == 'one':
        mode_param = args.theme if args.mode == 'theme' else args.domain
        if not mode_param:
            print(f"Error: --{'theme' if args.mode == 'theme' else 'domain'} is required for {args.mode} mode")
            return

        result = transform_one(args.file_id, args.mode, mode_param, args.source)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.chameleon_id}")
            print(f"Coverage: {result.coverage:.1f}%")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'list':
        if args.themes:
            print("Available themes:", ', '.join(THEMES))
        if args.domains:
            print("Available domains:", ', '.join(VALID_DOMAINS))
        if not args.themes and not args.domains:
            print("Available themes:", ', '.join(THEMES))
            print("Available domains:", ', '.join(VALID_DOMAINS))

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
