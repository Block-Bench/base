"""
Cross-Domain Strategy (D3) - Terminology Swap

Transforms contracts from one domain (e.g., DeFi) to another (e.g., Gaming,
Healthcare, Social, Logistics) while preserving the same vulnerability pattern.

Tests whether models can recognize vulnerabilities when presented in
unfamiliar domain contexts.

Output naming: cd_{target_domain}_{source_id} (e.g., cd_gaming_sn_ds_001)
"""

import re
import json
import hashlib
from pathlib import Path
from random import Random
from typing import Optional, Dict, List, Set, Tuple, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import shared utilities
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from strategies.common import (
    parse,
    extract_identifiers,
    check_syntax,
    get_node_text,
    walk_tree,
    find_all,
    is_solidity_reserved,
    is_solidity_dot_property,
    SOLIDITY_DOT_PROPERTIES,
)


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"
CROSSDOMAIN_DIR = DATA_DIR / "crossdomain"
DOMAINS_DIR = Path(__file__).parent / "domains"

# Available target domains
VALID_DOMAINS = ['gaming', 'healthcare', 'social', 'logistics']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class TransformResult:
    """Result of a single transformation."""
    original_id: str
    transformed_id: str
    target_domain: str
    success: bool
    identifiers_transformed: int = 0
    total_identifiers: int = 0
    coverage: float = 0.0
    rename_map: Dict[str, str] = field(default_factory=dict)
    unmapped_identifiers: List[str] = field(default_factory=list)
    error: Optional[str] = None


@dataclass
class TransformReport:
    """Report for batch transformation."""
    timestamp: str
    target_domain: str
    source_dataset: str
    total_files: int
    successful: int
    failed: int
    average_coverage: float = 0.0
    results: List[TransformResult] = field(default_factory=list)

    def to_dict(self):
        return {
            'timestamp': self.timestamp,
            'target_domain': self.target_domain,
            'source_dataset': self.source_dataset,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'average_coverage': self.average_coverage,
            'results': [asdict(r) for r in self.results]
        }


# =============================================================================
# DOMAIN LOADING
# =============================================================================

_domain_cache: Dict[str, dict] = {}


def load_domain(domain_name: str) -> dict:
    """Load domain terminology definitions."""
    if domain_name in _domain_cache:
        return _domain_cache[domain_name]

    domain_path = DOMAINS_DIR / f"{domain_name}.json"
    if not domain_path.exists():
        raise ValueError(f"Domain not found: {domain_name}")

    with open(domain_path) as f:
        data = json.load(f)

    _domain_cache[domain_name] = data
    return data


def build_domain_mapping(source_domain: str, target_domain: str) -> Dict[str, List[str]]:
    """
    Build mapping from source domain terms to target domain terms.

    Returns dict where keys are source terms (lowercase) and values are
    lists of possible target terms.
    """
    source = load_domain(source_domain)
    target = load_domain(target_domain)

    mapping = {}

    source_terms = source.get('terminology', {})
    target_terms = target.get('terminology', {})

    # Build mappings for each category
    for category in ['entities', 'actions', 'actors', 'metrics', 'contracts']:
        source_cat = source_terms.get(category, {})
        target_cat = target_terms.get(category, {})

        for concept, source_term in source_cat.items():
            if concept in target_cat:
                target_options = target_cat[concept]

                # Handle both string and list formats
                if isinstance(source_term, str):
                    source_key = source_term.lower()
                else:
                    source_key = source_term[0].lower() if source_term else concept.lower()

                if isinstance(target_options, list):
                    mapping[source_key] = target_options
                else:
                    mapping[source_key] = [target_options]

    return mapping


# =============================================================================
# IDENTIFIER TRANSFORMATION
# =============================================================================

def split_identifier(identifier: str) -> Tuple[List[str], str]:
    """
    Split identifier into words and detect naming style.

    Returns (words, style) where style is 'camel', 'snake', 'pascal', or 'unknown'.
    """
    # Check for snake_case
    if '_' in identifier:
        words = identifier.split('_')
        return words, 'snake'

    # Check for camelCase or PascalCase
    words = re.findall(r'[A-Z]?[a-z]+|[A-Z]+(?=[A-Z][a-z]|\d|\W|$)|\d+', identifier)
    if words:
        if identifier[0].isupper():
            return words, 'pascal'
        return words, 'camel'

    return [identifier], 'unknown'


def recombine_identifier(words: List[str], style: str) -> str:
    """Recombine words into identifier using specified style."""
    if style == 'snake':
        return '_'.join(w.lower() for w in words)
    elif style == 'pascal':
        return ''.join(w.capitalize() for w in words)
    elif style == 'camel':
        if not words:
            return ''
        return words[0].lower() + ''.join(w.capitalize() for w in words[1:])
    else:
        return ''.join(words)


class CrossDomainTransformer:
    """Transform contract terminology from source to target domain."""

    def __init__(
        self,
        target_domain: str,
        source_domain: str = 'defi',
        seed: Optional[int] = None
    ):
        self.source_domain = source_domain
        self.target_domain = target_domain
        self.domain_mapping = build_domain_mapping(source_domain, target_domain)

        # Create seeded RNG for deterministic transformations
        self.seed = seed
        self.rng = Random(seed) if seed else Random()

    def _create_seed(self, source_code: str) -> int:
        """Create deterministic seed from source code."""
        return int(hashlib.md5(source_code.encode()).hexdigest()[:8], 16)

    def _is_reserved(self, name: str) -> bool:
        """Check if identifier is a Solidity reserved word."""
        return is_solidity_reserved(name)

    def _is_dot_property_context(self, code: str, pos: int) -> Optional[str]:
        """
        Check if the identifier at position is a dot property.
        Returns the parent object name (msg, block, tx, etc.) if it's a dot property.
        """
        if pos <= 0:
            return None

        before = code[:pos].rstrip()
        if not before.endswith('.'):
            return None

        before_dot = before[:-1].rstrip()
        match = re.search(r'([a-zA-Z_][a-zA-Z0-9_]*)$', before_dot)
        if not match:
            return None

        parent = match.group(1)
        if parent in ('msg', 'block', 'tx', 'abi', 'type', 'address'):
            return parent

        return None

    def _should_skip_rename(self, name: str, code: str, pos: int) -> bool:
        """Determine if an identifier should be skipped from renaming."""
        if self._is_reserved(name):
            return True

        parent = self._is_dot_property_context(code, pos)
        if parent and is_solidity_dot_property(name):
            return True

        return False

    def _transform_identifier(self, identifier: str, rng: Random) -> Optional[str]:
        """
        Transform identifier from source to target domain.

        Uses layered lookup:
        1. Direct domain mapping
        2. Compound word decomposition
        3. Leave unchanged if no mapping
        """
        ident_lower = identifier.lower()

        # Layer 1: Direct mapping
        if ident_lower in self.domain_mapping:
            options = self.domain_mapping[ident_lower]
            selected = rng.choice(options)

            # Preserve original casing style
            if identifier[0].isupper():
                return selected[0].upper() + selected[1:]
            return selected[0].lower() + selected[1:]

        # Layer 2: Compound decomposition
        words, style = split_identifier(identifier)
        transformed_words = []
        any_transformed = False

        for word in words:
            word_lower = word.lower()
            if word_lower in self.domain_mapping:
                options = self.domain_mapping[word_lower]
                new_word = rng.choice(options)

                # Preserve word casing
                if word[0].isupper():
                    new_word = new_word[0].upper() + new_word[1:]
                else:
                    new_word = new_word[0].lower() + new_word[1:]

                transformed_words.append(new_word)
                any_transformed = True
            else:
                transformed_words.append(word)

        if any_transformed:
            return recombine_identifier(transformed_words, style)

        # Layer 3: No mapping found
        return None

    def transform(self, source_code: str) -> Tuple[str, Dict[str, str], float]:
        """
        Transform contract from source domain to target domain.

        Returns:
            (transformed_code, rename_map, coverage)
        """
        # Create deterministic RNG from source
        seed = self._create_seed(source_code)
        rng = Random(seed)

        # Parse and extract identifiers
        tree = parse(source_code)
        identifiers = extract_identifiers(tree, source_code)

        # Build rename map
        rename_map: Dict[str, str] = {}
        unmapped = set()

        for ident in identifiers:
            if ident.name in rename_map or ident.name in unmapped:
                continue

            if self._is_reserved(ident.name):
                continue

            new_name = self._transform_identifier(ident.name, rng)
            if new_name and new_name != ident.name:
                rename_map[ident.name] = new_name
            else:
                unmapped.add(ident.name)

        # Apply renames (back-to-front for position validity)
        edits = []
        for ident in identifiers:
            if ident.name in rename_map:
                # Skip if this is a dot property context
                if self._should_skip_rename(ident.name, source_code, ident.start_byte):
                    continue

                edits.append((ident.start_byte, ident.end_byte, rename_map[ident.name]))

        # Sort by position descending
        edits.sort(key=lambda e: e[0], reverse=True)

        # Apply edits
        result = source_code
        for start, end, new_text in edits:
            result = result[:start] + new_text + result[end:]

        # Calculate coverage
        unique_user_idents = len(set(i.name for i in identifiers if not self._is_reserved(i.name)))
        coverage = len(rename_map) / unique_user_idents if unique_user_idents > 0 else 0.0

        return result, rename_map, coverage


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _ensure_output_dirs(target_domain: str, source_dataset: str):
    """Ensure output directories exist."""
    out_dir = CROSSDOMAIN_DIR / f"{target_domain}_{source_dataset[:2]}"
    (out_dir / 'contracts').mkdir(parents=True, exist_ok=True)
    (out_dir / 'metadata').mkdir(parents=True, exist_ok=True)


def _get_source_path(source_id: str, source_dataset: str) -> Optional[Path]:
    """Get the path to a source contract."""
    if source_dataset == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source_dataset == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source dataset: {source_dataset}")

    for ext in ['.sol', '.rs']:
        path = source_dir / f"{source_id}{ext}"
        if path.exists():
            return path

    return None


def _get_metadata_path(source_id: str, source_dataset: str) -> Optional[Path]:
    """Get the path to source metadata."""
    if source_dataset == 'sanitized':
        meta_dir = SANITIZED_DIR / 'metadata'
    elif source_dataset == 'nocomments':
        meta_dir = NOCOMMENTS_DIR / 'metadata'
    else:
        return None

    path = meta_dir / f"{source_id}.json"
    return path if path.exists() else None


def _get_crossdomain_id(source_id: str, target_domain: str) -> str:
    """Generate cross-domain file ID."""
    # cd_gaming_sn_ds_001
    return f"cd_{target_domain}_{source_id}"


def transform_one(
    source_id: str,
    target_domain: str,
    source_dataset: str = 'sanitized',
    save: bool = True
) -> TransformResult:
    """
    Transform a single file to target domain.

    Args:
        source_id: Source file ID (e.g., sn_ds_001)
        target_domain: Target domain (gaming, healthcare, social, logistics)
        source_dataset: Which dataset to read from
        save: Whether to save the result

    Returns:
        TransformResult with details
    """
    if target_domain not in VALID_DOMAINS:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            target_domain=target_domain,
            success=False,
            error=f"Invalid domain: {target_domain}. Valid: {VALID_DOMAINS}"
        )

    # Find source file
    source_path = _get_source_path(source_id, source_dataset)
    if not source_path:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            target_domain=target_domain,
            success=False,
            error=f"Source file not found: {source_id}"
        )

    try:
        # Read source
        source = source_path.read_text()

        # Transform
        transformer = CrossDomainTransformer(target_domain)
        transformed, rename_map, coverage = transformer.transform(source)

        # Validate syntax
        is_valid, errors = check_syntax(transformed)
        if not is_valid:
            return TransformResult(
                original_id=source_id,
                transformed_id='',
                target_domain=target_domain,
                success=False,
                error=f"Syntax errors: {errors[:3]}"
            )

        cd_id = _get_crossdomain_id(source_id, target_domain)

        if save:
            _ensure_output_dirs(target_domain, source_dataset)
            out_dir = CROSSDOMAIN_DIR / f"{target_domain}_{source_dataset[:2]}"

            # Save transformed contract
            output_path = out_dir / 'contracts' / f"{cd_id}{source_path.suffix}"
            output_path.write_text(transformed)

            # Load and update metadata
            meta_path = _get_metadata_path(source_id, source_dataset)
            if meta_path:
                metadata = json.loads(meta_path.read_text())
            else:
                metadata = {'id': source_id}

            # Update metadata
            metadata['id'] = cd_id
            metadata['contract_file'] = f"contracts/{cd_id}{source_path.suffix}"
            metadata['derived_from'] = source_id
            metadata['subset'] = 'crossdomain'
            metadata['transformation'] = {
                'strategy': 'cross_domain',
                'source_domain': 'defi',
                'target_domain': target_domain,
                'coverage': round(coverage, 2),
                'identifiers_transformed': len(rename_map),
                'rename_map': rename_map
            }

            # Save metadata
            meta_output = out_dir / 'metadata' / f"{cd_id}.json"
            meta_output.write_text(json.dumps(metadata, indent=2))

        return TransformResult(
            original_id=source_id,
            transformed_id=cd_id,
            target_domain=target_domain,
            success=True,
            identifiers_transformed=len(rename_map),
            total_identifiers=len(set(rename_map.keys())),
            coverage=coverage,
            rename_map=rename_map
        )

    except Exception as e:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            target_domain=target_domain,
            success=False,
            error=str(e)
        )


def transform_all(
    target_domain: str,
    source_dataset: str = 'sanitized'
) -> TransformReport:
    """
    Transform all contracts from source dataset to target domain.

    Args:
        target_domain: Target domain
        source_dataset: Source dataset (sanitized, nocomments)

    Returns:
        TransformReport with all results
    """
    if source_dataset == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source_dataset == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source dataset: {source_dataset}")

    if not source_dir.exists():
        raise FileNotFoundError(f"Source directory not found: {source_dir}")

    results = []
    contract_files = list(source_dir.glob('*.sol')) + list(source_dir.glob('*.rs'))

    for contract_path in sorted(contract_files):
        source_id = contract_path.stem
        result = transform_one(source_id, target_domain, source_dataset, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    coverages = [r.coverage for r in results if r.success]
    avg_coverage = sum(coverages) / len(coverages) if coverages else 0.0

    report = TransformReport(
        timestamp=datetime.now().isoformat(),
        target_domain=target_domain,
        source_dataset=source_dataset,
        total_files=len(results),
        successful=successful,
        failed=failed,
        average_coverage=round(avg_coverage, 2),
        results=results
    )

    # Save report
    _ensure_output_dirs(target_domain, source_dataset)
    out_dir = CROSSDOMAIN_DIR / f"{target_domain}_{source_dataset[:2]}"
    report_path = out_dir / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    # Generate index
    _generate_index(target_domain, source_dataset)

    return report


def _generate_index(target_domain: str, source_dataset: str):
    """Generate index.json for a cross-domain dataset."""
    out_dir = CROSSDOMAIN_DIR / f"{target_domain}_{source_dataset[:2]}"
    metadata_dir = out_dir / 'metadata'

    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'safe_count': 0,
        'by_vulnerability_type': {},
        'avg_coverage': 0,
    }

    coverages = []

    for meta_file in sorted(metadata_dir.glob('*.json')):
        try:
            metadata = json.loads(meta_file.read_text())
            sample = {
                'id': metadata.get('id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
                'derived_from': metadata.get('derived_from'),
            }

            # Extract ground truth
            ground_truth = metadata.get('ground_truth', {})
            sample['is_vulnerable'] = ground_truth.get('is_vulnerable', True)
            sample['vulnerability_type'] = ground_truth.get('vulnerability_type', 'unknown')

            # Extract transformation details
            transform = metadata.get('transformation', {})
            if 'coverage' in transform:
                coverages.append(transform['coverage'])

            samples.append(sample)

            # Update stats
            stats['total_samples'] += 1
            if sample['is_vulnerable']:
                stats['vulnerable_count'] += 1
            else:
                stats['safe_count'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_vulnerability_type'][vuln_type] = \
                stats['by_vulnerability_type'].get(vuln_type, 0) + 1

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")

    if coverages:
        stats['avg_coverage'] = round(sum(coverages) / len(coverages), 2)

    index = {
        'dataset_name': f'crossdomain_{target_domain}',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'description': f'Contracts transformed from DeFi to {target_domain} domain. '
                       'Tests domain transfer ability.',
        'transformation': {
            'strategy': 'cross_domain',
            'source_domain': 'defi',
            'target_domain': target_domain,
            'preserves_vulnerability': True
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = out_dir / 'index.json'
    index_path.write_text(json.dumps(index, indent=2))


# =============================================================================
# DOMAIN DETECTION (OPTIONAL)
# =============================================================================

def detect_domain(source_code: str) -> str:
    """
    Attempt to detect the domain of a contract based on terminology.
    """
    source_lower = source_code.lower()

    domain_signals = {
        'defi': ['deposit', 'withdraw', 'stake', 'collateral', 'liquidity',
                 'borrow', 'lend', 'vault', 'pool', 'token', 'yield', 'apy'],
        'gaming': ['player', 'game', 'loot', 'reward', 'quest', 'level',
                   'score', 'achievement', 'item', 'inventory', 'hero'],
        'healthcare': ['patient', 'treatment', 'coverage', 'benefit',
                       'premium', 'claim', 'medical', 'health', 'insurance'],
        'social': ['reputation', 'karma', 'tip', 'creator', 'supporter',
                   'community', 'member', 'influence', 'follow'],
        'logistics': ['warehouse', 'shipment', 'cargo', 'inventory',
                      'delivery', 'storage', 'freight', 'dispatch']
    }

    scores = {}
    for domain, signals in domain_signals.items():
        score = sum(1 for signal in signals if signal in source_lower)
        scores[domain] = score

    # Return domain with highest score, default to 'defi'
    if max(scores.values()) == 0:
        return 'defi'

    return max(scores, key=scores.get)


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Cross-Domain strategy."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Cross-Domain Strategy - Terminology Swap'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts')
    all_parser.add_argument('--domain', required=True, choices=VALID_DOMAINS,
                           help='Target domain')
    all_parser.add_argument('--source', default='sanitized',
                           choices=['sanitized', 'nocomments'],
                           help='Source dataset')

    # Transform one
    one_parser = subparsers.add_parser('one', help='Transform single contract')
    one_parser.add_argument('file_id', help='Source file ID')
    one_parser.add_argument('--domain', required=True, choices=VALID_DOMAINS,
                           help='Target domain')
    one_parser.add_argument('--source', default='sanitized',
                           choices=['sanitized', 'nocomments'],
                           help='Source dataset')

    # Preview
    preview_parser = subparsers.add_parser('preview', help='Preview transformation')
    preview_parser.add_argument('file_id', help='Source file ID')
    preview_parser.add_argument('--domain', required=True, choices=VALID_DOMAINS,
                               help='Target domain')
    preview_parser.add_argument('--source', default='sanitized',
                               choices=['sanitized', 'nocomments'],
                               help='Source dataset')

    # List domains
    subparsers.add_parser('domains', help='List available domains')

    args = parser.parse_args()

    if args.command == 'all':
        print(f"Transforming all contracts to '{args.domain}' domain...")
        report = transform_all(args.domain, args.source)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")
        print(f"Average coverage: {report.average_coverage:.1%}")

        if report.failed > 0:
            print(f"\nFailed files ({report.failed}):")
            for r in report.results[:10]:
                if not r.success:
                    print(f"  {r.original_id}: {r.error}")

    elif args.command == 'one':
        result = transform_one(args.file_id, args.domain, args.source)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.transformed_id}")
            print(f"Coverage: {result.coverage:.1%}")
            print(f"Identifiers transformed: {result.identifiers_transformed}")
            print("\nRename map (first 10):")
            for old, new in list(result.rename_map.items())[:10]:
                print(f"  {old} -> {new}")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'preview':
        source_path = _get_source_path(args.file_id, args.source)
        if source_path:
            source = source_path.read_text()
            transformer = CrossDomainTransformer(args.domain)
            transformed, rename_map, coverage = transformer.transform(source)

            print(f"Preview for {args.file_id} (domain: {args.domain}):")
            print(f"  Coverage: {coverage:.1%}")
            print(f"  Identifiers transformed: {len(rename_map)}")
            print("\n--- Rename Map ---")
            for old, new in sorted(rename_map.items())[:20]:
                print(f"  {old} -> {new}")
            print("\n--- Transformed Code (first 2000 chars) ---")
            print(transformed[:2000])
            if len(transformed) > 2000:
                print(f"\n... ({len(transformed) - 2000} more chars)")
        else:
            print(f"Error: Source file not found: {args.file_id}")

    elif args.command == 'domains':
        print("Available target domains:")
        for domain in VALID_DOMAINS:
            data = load_domain(domain)
            print(f"  - {domain}: {data.get('description', '')}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
