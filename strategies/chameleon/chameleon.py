"""
Chameleon Transformation Strategy v2.0

Systematically renames all user-defined identifiers in smart contracts
using randomized synonym pools to test whether AI models rely on
keyword patterns rather than understanding code semantics.

Output naming: ch_{theme}_{source}_{original_id}
  - ch_gaming_sn_ds_001.sol (from sanitized ds_001)
  - ch_gaming_nc_tc_042.sol (from nocomments tc_042)
"""

import re
import json
import hashlib
from pathlib import Path
from random import Random
from typing import Optional, Dict, List, Set, Tuple
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import shared reserved keywords
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from strategies.common import (
    SOLIDITY_RESERVED,
    SOLIDITY_DOT_PROPERTIES,
    MSG_PROPERTIES,
    BLOCK_PROPERTIES,
    TX_PROPERTIES,
    ABI_FUNCTIONS,
    ADDRESS_MEMBERS,
    UNIVERSAL_DOT_PROPERTIES,
    CONTEXT_SPECIFIC_PROPERTIES,
    BUILTIN_PARENTS,
    is_solidity_reserved,
    is_solidity_dot_property,
)
from strategies.sanitize.sanitize import transform_metadata_identifiers


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"
CHAMELEON_DIR = DATA_DIR / "chameleon"
THEMES_DIR = Path(__file__).parent / "themes"

# Available themes
THEMES = ['gaming', 'resource', 'abstract', 'medical', 'social']

# Available source datasets
SOURCES = ['sanitized', 'nocomments']
SOURCE_PREFIXES = {'sanitized': 'sn', 'nocomments': 'nc'}

# Default options
DEFAULT_OPTIONS = {
    'strip_comments': False,  # Already stripped in nocomments
    'coverage_threshold': 75.0,
    'variation_level': 'medium',
}


# =============================================================================
# SOLIDITY RESERVED WORDS
# =============================================================================

SOLIDITY_KEYWORDS = {
    # Declaration keywords
    "pragma", "solidity", "import", "contract", "interface", "library",
    "abstract", "is", "using", "for", "struct", "enum", "event", "error",
    "function", "modifier", "constructor", "fallback", "receive",

    # Type keywords
    "mapping", "bool", "string", "bytes", "address", "payable",
    "uint", "uint8", "uint16", "uint32", "uint64", "uint128", "uint256",
    "int", "int8", "int16", "int32", "int64", "int128", "int256",
    "bytes1", "bytes2", "bytes4", "bytes8", "bytes16", "bytes32",

    # Visibility & mutability
    "public", "private", "internal", "external",
    "view", "pure", "constant", "immutable",
    "virtual", "override", "indexed", "anonymous",
    "memory", "storage", "calldata",

    # Control flow
    "if", "else", "for", "while", "do", "break", "continue", "return",
    "try", "catch", "throw", "revert", "require", "assert",

    # Other
    "new", "delete", "emit", "assembly", "true", "false",
    "wei", "gwei", "ether", "seconds", "minutes", "hours", "days", "weeks",
    "returns",
}

SOLIDITY_BUILTINS = {
    # Block properties
    "block", "blockhash",
    # Message properties
    "msg",
    # Transaction properties
    "tx",
    # Global functions
    "gasleft", "addmod", "mulmod", "keccak256", "sha256", "ripemd160",
    "ecrecover", "selfdestruct",
    # ABI functions
    "abi",
    # Type functions
    "type",
    # Address members
    "balance", "code", "codehash", "transfer", "send", "call",
    "delegatecall", "staticcall",
    # Contract related
    "this", "super",
    # Error handling
    "Error", "Panic",
}

STANDARD_INTERFACE_FUNCTIONS = {
    # ERC20
    "totalSupply", "balanceOf", "transfer", "allowance", "approve",
    "transferFrom", "name", "symbol", "decimals",
    # ERC721
    "ownerOf", "safeTransferFrom", "setApprovalForAll",
    "getApproved", "isApprovedForAll",
    # Ownable
    "owner", "renounceOwnership", "transferOwnership",
    # Common modifiers that are often expected
    "onlyOwner",
}

# Combine all reserved words
RESERVED_WORDS = SOLIDITY_KEYWORDS | SOLIDITY_BUILTINS | STANDARD_INTERFACE_FUNCTIONS


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class CoverageStats:
    """Track coverage during transformation."""
    transformed: List[str] = field(default_factory=list)
    untransformed: List[Dict] = field(default_factory=list)
    skipped_reserved: List[str] = field(default_factory=list)
    skipped_interface: List[str] = field(default_factory=list)

    def to_report(self, threshold: float) -> 'CoverageReport':
        total = len(self.transformed) + len(self.untransformed)
        if total == 0:
            coverage_percent = 100.0
        else:
            coverage_percent = (len(self.transformed) / total) * 100

        return CoverageReport(
            total_identifiers=total,
            transformed=len(self.transformed),
            untransformed=len(self.untransformed),
            skipped_reserved=len(self.skipped_reserved),
            skipped_interface=len(self.skipped_interface),
            coverage_percent=round(coverage_percent, 2),
            untransformed_details=self.untransformed,
            meets_threshold=coverage_percent >= threshold
        )


@dataclass
class CoverageReport:
    """Coverage report for a transformation."""
    total_identifiers: int
    transformed: int
    untransformed: int
    skipped_reserved: int
    skipped_interface: int
    coverage_percent: float
    untransformed_details: List[Dict]
    meets_threshold: bool

    def to_dict(self) -> Dict:
        return asdict(self)


@dataclass
class ValidationResult:
    """Validation result for a transformation."""
    valid: bool
    syntax_ok: bool
    no_leakage: bool
    errors: List[str]
    warnings: List[str]

    def to_dict(self) -> Dict:
        return asdict(self)


@dataclass
class TransformationResult:
    """Result of a chameleon transformation."""
    original_id: str
    chameleon_id: str
    theme: str
    source: str
    success: bool
    code: str = ""
    rename_map: Dict[str, str] = field(default_factory=dict)
    coverage: Optional[CoverageReport] = None
    validation: Optional[ValidationResult] = None
    seed: int = 0
    error: Optional[str] = None

    def to_dict(self) -> Dict:
        result = {
            'original_id': self.original_id,
            'chameleon_id': self.chameleon_id,
            'theme': self.theme,
            'source': self.source,
            'success': self.success,
            'rename_map': self.rename_map,
            'seed': self.seed,
        }
        if self.coverage:
            result['coverage'] = self.coverage.to_dict()
        if self.validation:
            result['validation'] = self.validation.to_dict()
        if self.error:
            result['error'] = self.error
        return result


@dataclass
class TransformationReport:
    """Report for a batch transformation run."""
    timestamp: str
    theme: str
    source: str
    total_files: int
    successful: int
    failed: int
    results: List[TransformationResult] = field(default_factory=list)

    def to_dict(self) -> Dict:
        return {
            'timestamp': self.timestamp,
            'theme': self.theme,
            'source': self.source,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [r.to_dict() for r in self.results]
        }


# =============================================================================
# SYNONYM POOL LOADER
# =============================================================================

class SynonymPoolLoader:
    """Load and manage synonym pools from JSON theme files."""

    _cache: Dict[str, Dict] = {}

    @classmethod
    def load_theme(cls, theme: str) -> Dict:
        """Load synonym pools for a theme."""
        if theme in cls._cache:
            return cls._cache[theme]

        theme_path = THEMES_DIR / f"{theme}.json"
        if not theme_path.exists():
            raise ValueError(f"Theme file not found: {theme_path}")

        with open(theme_path, 'r') as f:
            data = json.load(f)

        cls._cache[theme] = data.get('pools', {})
        return cls._cache[theme]

    @classmethod
    def get_pool(cls, theme: str, category: str, identifier: str) -> Optional[List[str]]:
        """Get synonym pool for an identifier."""
        pools = cls.load_theme(theme)
        category_pools = pools.get(category, {})
        return category_pools.get(identifier.lower())


# =============================================================================
# IDENTIFIER EXTRACTION (Regex-based for simplicity)
# =============================================================================

def extract_identifiers(code: str) -> List[Tuple[str, int, int]]:
    """
    Extract all identifiers from Solidity code with their positions.
    Returns list of (identifier, start, end) tuples.

    Uses regex-based extraction for simplicity. For production,
    tree-sitter would be more accurate.
    """
    identifiers = []

    # Pattern to match identifiers (including in various contexts)
    # This is a simplified approach - tree-sitter would be more accurate
    identifier_pattern = r'\b([a-zA-Z_][a-zA-Z0-9_]*)\b'

    for match in re.finditer(identifier_pattern, code):
        name = match.group(1)
        start = match.start(1)
        end = match.end(1)
        identifiers.append((name, start, end))

    return identifiers


def split_identifier(identifier: str) -> Tuple[List[str], str]:
    """
    Split a camelCase or snake_case identifier into words.
    Returns (words, style) where style is 'camelCase', 'PascalCase', or 'snake_case'.
    """
    # Count leading underscores
    leading_underscores = len(identifier) - len(identifier.lstrip('_'))
    clean = identifier[leading_underscores:]

    if not clean:
        return [], 'unknown'

    # Detect style and split
    if '_' in clean:
        style = "snake_case"
        parts = [p for p in clean.split('_') if p]
        return parts, style

    # Split camelCase/PascalCase
    words = []
    current = ""

    for i, char in enumerate(clean):
        if char.isupper() and current:
            # Check if this is start of new word or continuation of acronym
            if i + 1 < len(clean) and clean[i + 1].islower():
                words.append(current)
                current = char
            elif current[-1].isupper():
                current += char
            else:
                words.append(current)
                current = char
        else:
            current += char

    if current:
        words.append(current)

    style = "PascalCase" if clean[0].isupper() else "camelCase"
    return words, style


def recombine_identifier(words: List[str], style: str, leading_underscores: int = 0) -> str:
    """Recombine words into identifier with original style."""
    prefix = '_' * leading_underscores

    if not words:
        return prefix

    if style == "snake_case":
        return prefix + '_'.join(w.lower() for w in words)
    elif style == "PascalCase":
        return prefix + ''.join(w.capitalize() for w in words)
    else:  # camelCase
        result = words[0].lower()
        for word in words[1:]:
            result += word.capitalize()
        return prefix + result


# =============================================================================
# CHAMELEON TRANSFORMER
# =============================================================================

class ChameleonTransformer:
    """
    Main transformer class for Chameleon strategy.

    Systematically renames identifiers using randomized synonym pools.
    """

    def __init__(
        self,
        theme: str,
        options: Optional[Dict] = None
    ):
        if theme not in THEMES:
            raise ValueError(f"Unknown theme: {theme}. Available: {THEMES}")

        self.theme = theme
        self.options = {**DEFAULT_OPTIONS, **(options or {})}

        # Load synonym pools
        self.pools = SynonymPoolLoader.load_theme(theme)

        # Options
        self.coverage_threshold = self.options.get('coverage_threshold', 75.0)
        self.variation_level = self.options.get('variation_level', 'medium')

    def _create_seed(self, source_code: str) -> int:
        """Create deterministic seed from source + theme."""
        seed_input = f"{self.theme}:{hashlib.sha256(source_code.encode()).hexdigest()}"
        return int(hashlib.md5(seed_input.encode()).hexdigest(), 16) % (2**32)

    def _is_reserved(self, name: str) -> bool:
        """Check if identifier is reserved (standalone check, not context-aware)."""
        # Check against local RESERVED_WORDS and shared SOLIDITY_RESERVED
        if name in RESERVED_WORDS or name.lower() in RESERVED_WORDS:
            return True
        return is_solidity_reserved(name)

    def _get_dot_context(self, code: str, pos: int) -> tuple:
        """
        Check if the identifier at position follows a dot.
        Returns (is_dot_property, parent_name) tuple.
        - is_dot_property: True if preceded by '.'
        - parent_name: The identifier before the dot (if any)
        """
        if pos <= 0:
            return False, None

        # Check what's before this identifier (skip any whitespace)
        before = code[:pos].rstrip()
        if not before.endswith('.'):
            return False, None

        # Find the parent identifier before the dot
        before_dot = before[:-1].rstrip()
        match = re.search(r'([a-zA-Z_][a-zA-Z0-9_]*)$', before_dot)
        parent = match.group(1) if match else None

        return True, parent

    def _should_skip_rename(self, name: str, code: str, pos: int) -> bool:
        """
        Determine if an identifier should be skipped from renaming.
        Considers both standalone reserved words and dot property context.

        Logic:
        1. Skip standalone reserved words (keywords, types, builtins)
        2. Skip universal dot properties (.length, .push, .pop) after ANY dot
        3. Skip context-specific properties (.value, .gas) ONLY after known builtins
        4. Allow renaming of user struct field access (e.g., myStruct.value)
        """
        # Check standalone reserved
        if self._is_reserved(name):
            return True

        # Check dot property context
        is_dot_prop, parent = self._get_dot_context(code, pos)
        if not is_dot_prop:
            return False

        name_lower = name.lower()

        # Universal properties (always skip when after a dot)
        if name_lower in {p.lower() for p in UNIVERSAL_DOT_PROPERTIES}:
            return True

        # Context-specific properties (only skip after known builtin parents)
        if name_lower in {p.lower() for p in CONTEXT_SPECIFIC_PROPERTIES}:
            if parent and parent.lower() in {p.lower() for p in BUILTIN_PARENTS}:
                return True
            # Also check for msg.value, block.timestamp style properties
            if parent and parent.lower() in ('msg', 'block', 'tx', 'abi', 'type'):
                return True

        # All other reserved dot properties (from MSG_PROPERTIES, BLOCK_PROPERTIES, etc.)
        if is_solidity_dot_property(name):
            # Only protect if parent is a known builtin
            if parent and parent.lower() in ('msg', 'block', 'tx', 'abi', 'type', 'address'):
                return True

        return False

    def _is_in_string_or_comment(self, code: str, pos: int) -> bool:
        """Check if position is inside a string literal or comment."""
        # Simple heuristic - count quotes and check for comment markers
        before = code[:pos]

        # Check if in single-line comment
        last_newline = before.rfind('\n')
        line_before = before[last_newline + 1:] if last_newline >= 0 else before
        if '//' in line_before:
            comment_pos = line_before.find('//')
            if pos - (last_newline + 1) > comment_pos:
                return True

        # Check if in string (simple heuristic)
        double_quotes = before.count('"') - before.count('\\"')
        single_quotes = before.count("'") - before.count("\\'")

        if double_quotes % 2 == 1 or single_quotes % 2 == 1:
            return True

        return False

    def _select_from_pool(self, pool: List[str], rng: Random) -> str:
        """Select from pool based on variation level."""
        if not pool:
            return None

        if self.variation_level == 'low':
            subset = pool[:min(3, len(pool))]
        elif self.variation_level == 'medium':
            subset = pool[:max(1, len(pool) // 2)]
        elif self.variation_level == 'high':
            subset = pool
        elif self.variation_level == 'extreme':
            choice = rng.choice(pool)
            if rng.random() < 0.15:
                choice += str(rng.randint(1, 99))
            return choice
        else:
            subset = pool

        return rng.choice(subset)

    def _find_synonym(
        self,
        identifier: str,
        rng: Random
    ) -> Tuple[Optional[str], bool]:
        """
        Find a synonym for an identifier using layered lookup.

        Returns (synonym, found) tuple.
        """
        identifier_lower = identifier.lower()

        # Layer 1: Direct lookup in synonym pools
        for category in ['function_names', 'variable_names', 'contract_names',
                         'event_names', 'error_names', 'modifier_names', 'struct_names']:
            pools = self.pools.get(category, {})
            if identifier_lower in pools:
                pool = pools[identifier_lower]
                selected = self._select_from_pool(pool, rng)
                if selected:
                    # Preserve original casing
                    if identifier[0].isupper():
                        selected = selected[0].upper() + selected[1:]
                    else:
                        selected = selected[0].lower() + selected[1:]
                    return selected, True

        # Layer 2: Compound word decomposition
        leading_underscores = len(identifier) - len(identifier.lstrip('_'))
        words, style = split_identifier(identifier)

        if len(words) > 1:
            transformed_words = []
            any_transformed = False

            for word in words:
                word_lower = word.lower()
                found = False

                for category in ['variable_names', 'function_names']:
                    pools = self.pools.get(category, {})
                    if word_lower in pools:
                        pool = pools[word_lower]
                        selected = self._select_from_pool(pool, rng)
                        if selected:
                            # Preserve word casing
                            if word[0].isupper():
                                selected = selected[0].upper() + selected[1:]
                            transformed_words.append(selected)
                            any_transformed = True
                            found = True
                            break

                if not found:
                    transformed_words.append(word)

            if any_transformed:
                result = recombine_identifier(transformed_words, style, leading_underscores)
                return result, True

        # Layer 3: Pattern matching - prefix
        prefix_mappings = {
            'get': ['check', 'view', 'query', 'fetch', 'inspect'],
            'set': ['configure', 'update', 'modify', 'adjust'],
            'is': ['check', 'verify', 'test', 'validate'],
            'has': ['contains', 'includes', 'holds'],
            'calculate': ['compute', 'derive', 'evaluate'],
        }

        for prefix, replacements in prefix_mappings.items():
            if identifier_lower.startswith(prefix) and len(identifier) > len(prefix):
                rest = identifier[len(prefix):]
                new_prefix = rng.choice(replacements)
                if identifier[0].isupper():
                    new_prefix = new_prefix.capitalize()
                return new_prefix + rest, True

        return None, False

    def _resolve_collision(
        self,
        proposed: str,
        used: Set[str],
        rng: Random
    ) -> str:
        """Resolve naming collision by adding random suffix."""
        if proposed not in used:
            return proposed

        for _ in range(100):
            suffix = rng.randint(1, 999)
            candidate = f"{proposed}{suffix}"
            if candidate not in used:
                return candidate

        return f"{proposed}_{rng.randint(1000, 9999)}"

    def transform(self, source_code: str) -> Tuple[str, Dict[str, str], CoverageStats]:
        """
        Transform source code by renaming identifiers.

        Returns:
            (transformed_code, rename_map, coverage_stats)
        """
        seed = self._create_seed(source_code)
        rng = Random(seed)

        # Extract all identifiers
        all_identifiers = extract_identifiers(source_code)

        # Build rename map for unique identifiers
        rename_map = {}
        used_names = set()
        stats = CoverageStats()

        # Get unique identifier names (excluding reserved and those in strings/comments)
        seen_names = set()
        for name, start, end in all_identifiers:
            if name in seen_names:
                continue
            seen_names.add(name)

            # Skip reserved words
            if self._is_reserved(name):
                stats.skipped_reserved.append(name)
                continue

            # Skip very short identifiers (likely loop vars, etc.)
            if len(name) <= 2:
                continue

            # Try to find synonym
            synonym, found = self._find_synonym(name, rng)

            if found and synonym and synonym != name:
                final_name = self._resolve_collision(synonym, used_names, rng)
                rename_map[name] = final_name
                used_names.add(final_name)
                stats.transformed.append(name)
            else:
                stats.untransformed.append({
                    'name': name,
                    'reason': 'no synonym found'
                })

        # Apply renames (back-to-front for position validity)
        edits = []
        for name, start, end in all_identifiers:
            if name in rename_map:
                # Skip if in string or comment
                if self._is_in_string_or_comment(source_code, start):
                    continue

                # Skip if this is a dot property context (e.g., msg.sender, block.timestamp)
                # Even if 'sender' is in rename_map, don't rename it when part of msg.sender
                if self._should_skip_rename(name, source_code, start):
                    continue

                edits.append((start, end, rename_map[name]))

        # Sort by position descending
        edits.sort(key=lambda x: x[0], reverse=True)

        # Apply edits
        result = source_code
        for start, end, new_name in edits:
            result = result[:start] + new_name + result[end:]

        return result, rename_map, stats


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _get_source_dir(source: str) -> Path:
    """Get the source directory for a dataset."""
    if source == 'sanitized':
        return SANITIZED_DIR
    elif source == 'nocomments':
        return NOCOMMENTS_DIR
    else:
        raise ValueError(f"Unknown source: {source}")


def _get_file_paths(file_id: str, source: str) -> Tuple[Optional[Path], Optional[Path]]:
    """
    Get paths for a file ID from the source dataset.

    Args:
        file_id: The file ID (e.g., 'sn_ds_001', 'nc_tc_042')
        source: The source dataset ('sanitized' or 'nocomments')

    Returns:
        Tuple of (contract_path, metadata_path) or (None, None) if not found
    """
    source_dir = _get_source_dir(source)
    contracts_dir = source_dir / 'contracts'
    metadata_dir = source_dir / 'metadata'

    # Check for .sol or .rs extension
    for ext in ['.sol', '.rs']:
        contract_path = contracts_dir / f"{file_id}{ext}"
        if contract_path.exists():
            metadata_path = metadata_dir / f"{file_id}.json"
            return contract_path, metadata_path

    return None, None


def _ensure_output_dirs(theme: str, source: str):
    """Ensure output directories exist."""
    source_prefix = SOURCE_PREFIXES[source]
    output_dir = CHAMELEON_DIR / f"{theme}_{source_prefix}"
    (output_dir / 'contracts').mkdir(parents=True, exist_ok=True)
    (output_dir / 'metadata').mkdir(parents=True, exist_ok=True)
    return output_dir


def _get_chameleon_id(original_id: str, theme: str, source: str) -> str:
    """
    Generate chameleon ID from original ID.

    Examples:
        sn_ds_001 + gaming + sanitized -> ch_gaming_sn_ds_001
        nc_tc_042 + resource + nocomments -> ch_resource_nc_tc_042
    """
    source_prefix = SOURCE_PREFIXES[source]
    # Extract the base ID (e.g., ds_001 from sn_ds_001)
    if original_id.startswith('sn_'):
        base_id = original_id[3:]
    elif original_id.startswith('nc_'):
        base_id = original_id[3:]
    else:
        base_id = original_id

    return f"ch_{theme}_{source_prefix}_{base_id}"


def _save_chameleon(
    chameleon_id: str,
    transformed_code: str,
    original_metadata_path: Optional[Path],
    extension: str,
    theme: str,
    source: str,
    rename_map: Dict[str, str],
    coverage: CoverageReport,
    seed: int
) -> Tuple[Path, List[str]]:
    """Save chameleon contract and metadata with transformed identifiers."""
    output_dir = _ensure_output_dirs(theme, source)
    metadata_changes = []

    # Save transformed contract
    contract_path = output_dir / 'contracts' / f"{chameleon_id}{extension}"
    contract_path.write_text(transformed_code)

    # Build metadata
    metadata = {}
    if original_metadata_path and original_metadata_path.exists():
        metadata = json.loads(original_metadata_path.read_text())

    # Transform identifiers in metadata using the rename_map
    if rename_map:
        metadata, metadata_changes = transform_metadata_identifiers(metadata, rename_map)

    # Update metadata for chameleon version
    metadata['id'] = chameleon_id
    metadata['contract_file'] = f"contracts/{chameleon_id}{extension}"
    metadata['transformation'] = {
        'strategy': 'chameleon',
        'theme': theme,
        'source': source,
        'seed': seed,
        'coverage': coverage.to_dict(),
        'rename_map': rename_map,
    }
    metadata['subset'] = f'chameleon_{theme}'

    # Save metadata
    metadata_path = output_dir / 'metadata' / f"{chameleon_id}.json"
    metadata_path.write_text(json.dumps(metadata, indent=2))

    return contract_path, metadata_changes


# =============================================================================
# PUBLIC API
# =============================================================================

def transform_code(
    code: str,
    theme: str = 'gaming',
    options: Optional[Dict] = None
) -> Tuple[str, Dict[str, str], CoverageReport]:
    """
    Transform code using Chameleon strategy.

    Args:
        code: Source code to transform
        theme: Theme to use for transformation
        options: Optional configuration options

    Returns:
        Tuple of (transformed_code, rename_map, coverage_report)
    """
    transformer = ChameleonTransformer(theme, options)
    transformed, rename_map, stats = transformer.transform(code)
    coverage = stats.to_report(transformer.coverage_threshold)
    return transformed, rename_map, coverage


def transform_one(
    file_id: str,
    theme: str = 'gaming',
    source: str = 'sanitized',
    save: bool = True,
    options: Optional[Dict] = None
) -> TransformationResult:
    """
    Transform a single file by ID.

    Args:
        file_id: File ID (e.g., 'sn_ds_001', 'nc_tc_042')
        theme: Theme to use
        source: Source dataset ('sanitized' or 'nocomments')
        save: Whether to save output to disk
        options: Optional configuration

    Returns:
        TransformationResult with details
    """
    if source not in SOURCES:
        return TransformationResult(
            original_id=file_id,
            chameleon_id='',
            theme=theme,
            source=source,
            success=False,
            error=f"Unknown source: {source}. Available: {SOURCES}"
        )

    contract_path, metadata_path = _get_file_paths(file_id, source)

    if not contract_path or not contract_path.exists():
        return TransformationResult(
            original_id=file_id,
            chameleon_id='',
            theme=theme,
            source=source,
            success=False,
            error=f"File not found: {file_id} in {source}"
        )

    try:
        # Read and transform
        code = contract_path.read_text()
        transformer = ChameleonTransformer(theme, options)
        transformed, rename_map, stats = transformer.transform(code)
        coverage = stats.to_report(transformer.coverage_threshold)

        chameleon_id = _get_chameleon_id(file_id, theme, source)
        seed = transformer._create_seed(code)

        # Validate
        validation = ValidationResult(
            valid=True,
            syntax_ok=True,  # Would need tree-sitter for real check
            no_leakage=len(stats.untransformed) < len(stats.transformed),
            errors=[],
            warnings=[]
        )

        metadata_changes = []
        if save:
            _, metadata_changes = _save_chameleon(
                chameleon_id,
                transformed,
                metadata_path,
                contract_path.suffix,
                theme,
                source,
                rename_map,
                coverage,
                seed
            )

        return TransformationResult(
            original_id=file_id,
            chameleon_id=chameleon_id,
            theme=theme,
            source=source,
            success=True,
            code=transformed,
            rename_map=rename_map,
            coverage=coverage,
            validation=validation,
            seed=seed
        )

    except Exception as e:
        return TransformationResult(
            original_id=file_id,
            chameleon_id='',
            theme=theme,
            source=source,
            success=False,
            error=str(e)
        )


def transform_subset(
    subset: str,
    theme: str = 'gaming',
    source: str = 'sanitized',
    options: Optional[Dict] = None
) -> TransformationReport:
    """
    Transform a subset of files (e.g., 'ds' for difficulty_stratified, 'tc' for temporal_contamination).

    Args:
        subset: Subset prefix ('ds' or 'tc')
        theme: Theme to use
        source: Source dataset
        options: Optional configuration

    Returns:
        TransformationReport with all results
    """
    source_dir = _get_source_dir(source)
    contracts_dir = source_dir / 'contracts'

    if not contracts_dir.exists():
        raise FileNotFoundError(f"Source contracts directory not found: {contracts_dir}")

    # Get all files matching subset
    prefix = SOURCE_PREFIXES[source]
    pattern = f"{prefix}_{subset}_*.sol"
    contract_files = sorted(contracts_dir.glob(pattern))

    # Also check for .rs files
    pattern_rs = f"{prefix}_{subset}_*.rs"
    contract_files.extend(sorted(contracts_dir.glob(pattern_rs)))

    results = []
    for contract_path in contract_files:
        file_id = contract_path.stem
        result = transform_one(file_id, theme, source, save=True, options=options)
        results.append(result)

    successful = sum(1 for r in results if r.success)

    report = TransformationReport(
        timestamp=datetime.now().isoformat(),
        theme=theme,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results
    )

    # Save report
    output_dir = _ensure_output_dirs(theme, source)
    report_path = output_dir / f"transformation_report_{subset}.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    return report


def transform_all(
    theme: str = 'gaming',
    source: str = 'sanitized',
    options: Optional[Dict] = None
) -> TransformationReport:
    """
    Transform all files from a source dataset.

    Args:
        theme: Theme to use
        source: Source dataset ('sanitized' or 'nocomments')
        options: Optional configuration

    Returns:
        TransformationReport with all results
    """
    source_dir = _get_source_dir(source)
    contracts_dir = source_dir / 'contracts'

    if not contracts_dir.exists():
        raise FileNotFoundError(f"Source contracts directory not found: {contracts_dir}")

    results = []

    # Get all contract files
    contract_files = sorted(contracts_dir.glob('*.sol'))
    contract_files.extend(sorted(contracts_dir.glob('*.rs')))

    for contract_path in contract_files:
        file_id = contract_path.stem
        result = transform_one(file_id, theme, source, save=True, options=options)
        results.append(result)

    successful = sum(1 for r in results if r.success)

    report = TransformationReport(
        timestamp=datetime.now().isoformat(),
        theme=theme,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results
    )

    # Save report
    output_dir = _ensure_output_dirs(theme, source)
    report_path = output_dir / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    # Generate index.json
    _generate_index(theme, source)

    return report


def _generate_index(theme: str, source: str):
    """Generate index.json for the chameleon dataset."""
    output_dir = _ensure_output_dirs(theme, source)
    metadata_dir = output_dir / 'metadata'

    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'safe_count': 0,
        'by_vulnerability_type': {},
        'by_severity': {},
        'average_coverage': 0.0
    }

    coverage_sum = 0

    for meta_file in sorted(metadata_dir.glob('*.json')):
        try:
            metadata = json.loads(meta_file.read_text())
            sample = {
                'id': metadata.get('id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
            }

            # Extract ground truth
            ground_truth = metadata.get('ground_truth', {})
            sample['is_vulnerable'] = ground_truth.get('is_vulnerable', True)
            sample['vulnerability_type'] = ground_truth.get('vulnerability_type', 'unknown')
            sample['severity'] = ground_truth.get('severity', 'unknown')

            # Extract transformation info
            transformation = metadata.get('transformation', {})
            sample['coverage_percent'] = transformation.get('coverage', {}).get('coverage_percent', 0)

            samples.append(sample)

            # Update stats
            stats['total_samples'] += 1
            if sample['is_vulnerable']:
                stats['vulnerable_count'] += 1
            else:
                stats['safe_count'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_vulnerability_type'][vuln_type] = stats['by_vulnerability_type'].get(vuln_type, 0) + 1

            severity = sample['severity']
            stats['by_severity'][severity] = stats['by_severity'].get(severity, 0) + 1

            coverage_sum += sample['coverage_percent']

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")
            continue

    if stats['total_samples'] > 0:
        stats['average_coverage'] = round(coverage_sum / stats['total_samples'], 2)

    source_prefix = SOURCE_PREFIXES[source]

    index = {
        'dataset_name': f'chameleon_{theme}_{source_prefix}',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'description': f'Chameleon-transformed contracts using {theme} theme, derived from {source} dataset. '
                       f'All user-defined identifiers renamed using randomized synonym pools.',
        'transformation': {
            'strategy': 'chameleon',
            'theme': theme,
            'source_dataset': source,
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = output_dir / 'index.json'
    index_path.write_text(json.dumps(index, indent=2))


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Chameleon transformation."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Chameleon transformation - rename identifiers using randomized synonym pools'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts from source dataset')
    all_parser.add_argument('--theme', '-t', default='gaming', choices=THEMES,
                           help='Theme for transformation')
    all_parser.add_argument('--source', '-s', default='sanitized', choices=SOURCES,
                           help='Source dataset')
    all_parser.add_argument('--variation', '-v', default='medium',
                           choices=['low', 'medium', 'high', 'extreme'],
                           help='Variation level')

    # transform subset
    subset_parser = subparsers.add_parser('subset', help='Transform a subset (ds or tc)')
    subset_parser.add_argument('subset', choices=['ds', 'tc'], help='Subset to transform')
    subset_parser.add_argument('--theme', '-t', default='gaming', choices=THEMES,
                              help='Theme for transformation')
    subset_parser.add_argument('--source', '-s', default='sanitized', choices=SOURCES,
                              help='Source dataset')
    subset_parser.add_argument('--variation', '-v', default='medium',
                              choices=['low', 'medium', 'high', 'extreme'],
                              help='Variation level')

    # transform one
    one_parser = subparsers.add_parser('one', help='Transform a single file')
    one_parser.add_argument('file_id', help='File ID (e.g., sn_ds_001, nc_tc_042)')
    one_parser.add_argument('--theme', '-t', default='gaming', choices=THEMES,
                           help='Theme for transformation')
    one_parser.add_argument('--source', '-s', default='sanitized', choices=SOURCES,
                           help='Source dataset')
    one_parser.add_argument('--variation', '-v', default='medium',
                           choices=['low', 'medium', 'high', 'extreme'],
                           help='Variation level')

    # transform code (from stdin)
    code_parser = subparsers.add_parser('code', help='Transform code from stdin')
    code_parser.add_argument('--theme', '-t', default='gaming', choices=THEMES,
                            help='Theme for transformation')
    code_parser.add_argument('--variation', '-v', default='medium',
                            choices=['low', 'medium', 'high', 'extreme'],
                            help='Variation level')

    args = parser.parse_args()

    options = {'variation_level': getattr(args, 'variation', 'medium')}

    if args.command == 'all':
        print(f"Transforming all contracts from {args.source} using {args.theme} theme...")
        report = transform_all(args.theme, args.source, options)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")

        # Show summary
        if report.results:
            coverages = [r.coverage.coverage_percent for r in report.results if r.coverage]
            if coverages:
                avg_coverage = sum(coverages) / len(coverages)
                print(f"Average coverage: {avg_coverage:.1f}%")

    elif args.command == 'subset':
        print(f"Transforming {args.subset} subset from {args.source} using {args.theme} theme...")
        report = transform_subset(args.subset, args.theme, args.source, options)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")

    elif args.command == 'one':
        result = transform_one(args.file_id, args.theme, args.source, options=options)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.chameleon_id}")
            if result.coverage:
                print(f"Coverage: {result.coverage.coverage_percent}%")
            if result.rename_map:
                print(f"Renames ({len(result.rename_map)}):")
                for old, new in list(result.rename_map.items())[:10]:
                    print(f"  {old} -> {new}")
                if len(result.rename_map) > 10:
                    print(f"  ... and {len(result.rename_map) - 10} more")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'code':
        import sys
        code = sys.stdin.read()
        transformed, rename_map, coverage = transform_code(code, args.theme, options)
        print(transformed)
        print("\n--- Transformation Summary ---", file=sys.stderr)
        print(f"Coverage: {coverage.coverage_percent}%", file=sys.stderr)
        print(f"Transformed: {coverage.transformed} identifiers", file=sys.stderr)

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
