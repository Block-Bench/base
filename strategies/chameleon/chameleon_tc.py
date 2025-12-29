#!/usr/bin/env python3
"""
Chameleon Transformation for Temporal Contamination Contracts

Applies themed identifier renaming to temporal contamination contracts.
Can use either sanitized or nocomments as source.

Input: dataset/temporal_contamination/{sanitized,nocomments}/
Output: dataset/temporal_contamination/chameleon_{theme}/

Line markers are stripped before processing and fresh sequential markers
are added after processing.

Usage:
    python strategies/chameleon/chameleon_tc.py --theme medical --source nocomments
    python strategies/chameleon/chameleon_tc.py --theme gaming --source sanitized
"""

import sys
import re
import json
import hashlib
from pathlib import Path
from random import Random
from datetime import datetime
from typing import Dict, List, Tuple, Optional, Set

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from strategies.common.line_markers import strip_line_markers, add_line_markers
from strategies.common import is_solidity_reserved, is_solidity_dot_property

# Theme directory
THEMES_DIR = Path(__file__).parent / "themes"

# Available themes
THEMES = ['gaming', 'resource', 'abstract', 'medical', 'social']

# Available sources
SOURCES = ['sanitized', 'nocomments']
SOURCE_PREFIXES = {'sanitized': 'sn', 'nocomments': 'nc'}

# Solidity reserved words that should never be renamed
SOLIDITY_KEYWORDS = {
    "pragma", "solidity", "import", "contract", "interface", "library",
    "abstract", "is", "using", "for", "struct", "enum", "event", "error",
    "function", "modifier", "constructor", "fallback", "receive",
    "mapping", "bool", "string", "bytes", "address", "payable",
    "uint", "uint8", "uint16", "uint32", "uint64", "uint128", "uint256",
    "int", "int8", "int16", "int32", "int64", "int128", "int256",
    "bytes1", "bytes2", "bytes4", "bytes8", "bytes16", "bytes32",
    "public", "private", "internal", "external",
    "view", "pure", "constant", "immutable",
    "virtual", "override", "indexed", "anonymous",
    "memory", "storage", "calldata",
    "if", "else", "for", "while", "do", "break", "continue", "return",
    "try", "catch", "throw", "revert", "require", "assert",
    "new", "delete", "emit", "assembly", "true", "false",
    "wei", "gwei", "ether", "seconds", "minutes", "hours", "days", "weeks",
    "returns",
}

SOLIDITY_BUILTINS = {
    "block", "blockhash", "msg", "tx", "gasleft", "addmod", "mulmod",
    "keccak256", "sha256", "ripemd160", "ecrecover", "selfdestruct",
    "abi", "type", "balance", "code", "codehash", "transfer", "send",
    "call", "delegatecall", "staticcall", "this", "super", "Error", "Panic",
}

STANDARD_INTERFACE_FUNCTIONS = {
    "totalSupply", "balanceOf", "transfer", "allowance", "approve",
    "transferFrom", "name", "symbol", "decimals", "ownerOf",
    "safeTransferFrom", "setApprovalForAll", "getApproved", "isApprovedForAll",
    "owner", "renounceOwnership", "transferOwnership", "onlyOwner",
}

RESERVED_WORDS = SOLIDITY_KEYWORDS | SOLIDITY_BUILTINS | STANDARD_INTERFACE_FUNCTIONS


class SynonymPoolLoader:
    """Load and manage synonym pools from JSON theme files."""
    _cache: Dict[str, Dict] = {}

    @classmethod
    def load_theme(cls, theme: str) -> Dict:
        if theme in cls._cache:
            return cls._cache[theme]
        theme_path = THEMES_DIR / f"{theme}.json"
        if not theme_path.exists():
            raise ValueError(f"Theme file not found: {theme_path}")
        with open(theme_path, 'r') as f:
            data = json.load(f)
        cls._cache[theme] = data.get('pools', {})
        return cls._cache[theme]


def extract_identifiers(code: str) -> List[Tuple[str, int, int]]:
    """Extract all identifiers from Solidity code with positions."""
    identifiers = []
    pattern = r'\b([a-zA-Z_][a-zA-Z0-9_]*)\b'
    for match in re.finditer(pattern, code):
        name = match.group(1)
        start = match.start(1)
        end = match.end(1)
        identifiers.append((name, start, end))
    return identifiers


def split_identifier(identifier: str) -> Tuple[List[str], str]:
    """Split camelCase or snake_case identifier into words."""
    leading_underscores = len(identifier) - len(identifier.lstrip('_'))
    clean = identifier[leading_underscores:]
    if not clean:
        return [], 'unknown'
    if '_' in clean:
        parts = [p for p in clean.split('_') if p]
        return parts, "snake_case"
    words = []
    current = ""
    for i, char in enumerate(clean):
        if char.isupper() and current:
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
    else:
        result = words[0].lower()
        for word in words[1:]:
            result += word.capitalize()
        return prefix + result


class ChameleonTransformer:
    """Transform identifiers using themed synonym pools."""

    def __init__(self, theme: str, variation_level: str = 'medium'):
        if theme not in THEMES:
            raise ValueError(f"Unknown theme: {theme}. Available: {THEMES}")
        self.theme = theme
        self.pools = SynonymPoolLoader.load_theme(theme)
        self.variation_level = variation_level

    def _create_seed(self, source_code: str) -> int:
        seed_input = f"{self.theme}:{hashlib.sha256(source_code.encode()).hexdigest()}"
        return int(hashlib.md5(seed_input.encode()).hexdigest(), 16) % (2**32)

    def _is_reserved(self, name: str) -> bool:
        if name in RESERVED_WORDS or name.lower() in RESERVED_WORDS:
            return True
        return is_solidity_reserved(name)

    def _select_from_pool(self, pool: List[str], rng: Random) -> str:
        if not pool:
            return None
        if self.variation_level == 'low':
            subset = pool[:min(3, len(pool))]
        elif self.variation_level == 'medium':
            subset = pool[:max(1, len(pool) // 2)]
        elif self.variation_level == 'high':
            subset = pool
        else:
            subset = pool
        return rng.choice(subset)

    def _find_synonym(self, identifier: str, rng: Random) -> Tuple[Optional[str], bool]:
        identifier_lower = identifier.lower()

        # Layer 1: Direct lookup
        for category in ['function_names', 'variable_names', 'contract_names',
                         'event_names', 'error_names', 'modifier_names', 'struct_names']:
            pools = self.pools.get(category, {})
            if identifier_lower in pools:
                pool = pools[identifier_lower]
                selected = self._select_from_pool(pool, rng)
                if selected:
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

        # Layer 3: Prefix pattern matching
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

    def _resolve_collision(self, proposed: str, used: Set[str], rng: Random) -> str:
        if proposed not in used:
            return proposed
        for _ in range(100):
            suffix = rng.randint(1, 999)
            candidate = f"{proposed}{suffix}"
            if candidate not in used:
                return candidate
        return f"{proposed}_{rng.randint(1000, 9999)}"

    def _is_in_string_or_comment(self, code: str, pos: int) -> bool:
        before = code[:pos]
        last_newline = before.rfind('\n')
        line_before = before[last_newline + 1:] if last_newline >= 0 else before
        if '//' in line_before:
            comment_pos = line_before.find('//')
            if pos - (last_newline + 1) > comment_pos:
                return True
        double_quotes = before.count('"') - before.count('\\"')
        single_quotes = before.count("'") - before.count("\\'")
        if double_quotes % 2 == 1 or single_quotes % 2 == 1:
            return True
        return False

    def transform(self, source_code: str) -> Tuple[str, Dict[str, str], int, int]:
        """
        Transform source code by renaming identifiers.

        Line markers are stripped before processing and fresh markers added after.

        Returns:
            (transformed_code, rename_map, transformed_count, total_count)
        """
        # Strip line markers before processing
        clean_code = strip_line_markers(source_code)

        seed = self._create_seed(clean_code)
        rng = Random(seed)

        all_identifiers = extract_identifiers(clean_code)
        rename_map = {}
        used_names = set()
        transformed_count = 0
        seen_names = set()

        for name, start, end in all_identifiers:
            if name in seen_names:
                continue
            seen_names.add(name)
            if self._is_reserved(name):
                continue
            if len(name) <= 2:
                continue
            synonym, found = self._find_synonym(name, rng)
            if found and synonym and synonym != name:
                final_name = self._resolve_collision(synonym, used_names, rng)
                rename_map[name] = final_name
                used_names.add(final_name)
                transformed_count += 1

        # Apply renames
        edits = []
        for name, start, end in all_identifiers:
            if name in rename_map:
                if self._is_in_string_or_comment(clean_code, start):
                    continue
                edits.append((start, end, rename_map[name]))

        edits.sort(key=lambda x: x[0], reverse=True)
        result = clean_code
        for start, end, new_name in edits:
            result = result[:start] + new_name + result[end:]

        # Add fresh line markers
        result = add_line_markers(result)

        return result, rename_map, transformed_count, len(seen_names)


def transform_metadata(original_metadata: dict, chameleon_id: str, source_id: str,
                       theme: str, source: str, rename_map: dict,
                       transformed_count: int, total_count: int,
                       source_dir: str) -> dict:
    """
    Update metadata for chameleon variant.

    Transforms identifier references in metadata using rename_map.
    """
    metadata = original_metadata.copy()

    # Update identifiers and paths
    metadata['sample_id'] = chameleon_id
    metadata['contract_file'] = f"contracts/{chameleon_id}.sol"
    metadata['variant_type'] = f'chameleon_{theme}'
    metadata['variant_parent_id'] = source_id

    # Transform vulnerable_contract if it was renamed
    if 'vulnerable_contract' in metadata:
        old_contract = metadata['vulnerable_contract']
        if isinstance(old_contract, str) and old_contract in rename_map:
            metadata['vulnerable_contract'] = rename_map[old_contract]

    # Transform vulnerable_function if it was renamed
    if 'vulnerable_function' in metadata:
        old_func = metadata['vulnerable_function']
        if isinstance(old_func, str) and old_func in rename_map:
            metadata['vulnerable_function'] = rename_map[old_func]

    # Calculate coverage
    coverage = (transformed_count / total_count * 100) if total_count > 0 else 0

    # Update transformation tracking
    metadata['transformation'] = {
        'type': 'chameleon',
        'theme': theme,
        'source_dir': source_dir,
        'source_contract': f"{source_dir}/contracts/{source_id}.sol",
        'source_metadata': f"{source_dir}/metadata/{source_id}.json",
        'script': 'strategies/chameleon/chameleon_tc.py',
        'changes': [
            f"Applied {theme} theme transformation",
            f"Renamed {transformed_count}/{total_count} identifiers ({coverage:.1f}% coverage)"
        ],
        'rename_map': rename_map,
        'coverage_percent': round(coverage, 2),
        'identifiers_transformed': transformed_count,
        'identifiers_total': total_count,
        'created_date': datetime.now().isoformat()
    }

    # vulnerable_lines stays empty (inherited from source)

    return metadata


def process_chameleon(theme: str, source: str = 'nocomments',
                      input_base: Path = None, output_base: Path = None):
    """Apply chameleon transformation to temporal contamination contracts."""

    if theme not in THEMES:
        raise ValueError(f"Unknown theme: {theme}. Available: {THEMES}")
    if source not in SOURCES:
        raise ValueError(f"Unknown source: {source}. Available: {SOURCES}")

    # Determine paths
    if input_base is None:
        input_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / source
    if output_base is None:
        output_base = PROJECT_ROOT / "dataset" / "temporal_contamination" / f"chameleon_{theme}"

    input_contracts_dir = input_base / "contracts"
    input_metadata_dir = input_base / "metadata"
    output_contracts_dir = output_base / "contracts"
    output_metadata_dir = output_base / "metadata"

    # Detect file pattern based on source
    source_prefix = SOURCE_PREFIXES[source]
    if list(input_contracts_dir.glob(f"{source_prefix}_tc_*.sol")):
        file_pattern = f"{source_prefix}_tc_*.sol"
    else:
        print(f"No matching files found in {input_contracts_dir}")
        return []

    print(f"Theme: {theme}")
    print(f"Source: {source}")
    print(f"Input contracts: {input_contracts_dir}")
    print(f"Output directory: {output_base}")
    print(f"File pattern: {file_pattern}")

    # Ensure output directories exist
    output_contracts_dir.mkdir(parents=True, exist_ok=True)
    output_metadata_dir.mkdir(parents=True, exist_ok=True)

    # Initialize transformer
    transformer = ChameleonTransformer(theme)

    # Find all matching files
    source_files = sorted(input_contracts_dir.glob(file_pattern))
    print(f"Found {len(source_files)} files to process")

    results = []
    total_transformed = 0
    total_identifiers = 0

    for source_file in source_files:
        file_stem = source_file.stem  # e.g., nc_tc_001
        # Extract base id and create chameleon id
        if file_stem.startswith(f"{source_prefix}_"):
            base_id = file_stem[len(source_prefix)+1:]  # tc_001
        else:
            base_id = file_stem
        chameleon_id = f"ch_{theme}_{base_id}"

        # Read source code
        source_code = source_file.read_text()

        # Transform (handles line markers automatically)
        transformed_code, rename_map, transformed_count, total_count = transformer.transform(source_code)
        total_transformed += transformed_count
        total_identifiers += total_count

        # Save chameleon contract
        output_file = output_contracts_dir / f"{chameleon_id}.sol"
        output_file.write_text(transformed_code)

        # Load source metadata
        source_metadata_file = input_metadata_dir / f"{file_stem}.json"
        if source_metadata_file.exists():
            source_metadata = json.loads(source_metadata_file.read_text())
        else:
            source_metadata = {"sample_id": file_stem}

        # Update metadata
        updated_metadata = transform_metadata(
            source_metadata, chameleon_id, file_stem,
            theme, source, rename_map,
            transformed_count, total_count,
            source_dir=str(input_base)
        )

        # Save metadata
        output_metadata_file = output_metadata_dir / f"{chameleon_id}.json"
        output_metadata_file.write_text(json.dumps(updated_metadata, indent=2))

        coverage = (transformed_count / total_count * 100) if total_count > 0 else 0
        results.append({
            'source_id': file_stem,
            'chameleon_id': chameleon_id,
            'identifiers_transformed': transformed_count,
            'identifiers_total': total_count,
            'coverage': coverage,
            'renames': len(rename_map)
        })

        print(f"  {file_stem} → {chameleon_id}: {transformed_count}/{total_count} identifiers ({coverage:.1f}%)")

    # Summary
    avg_coverage = (total_transformed / total_identifiers * 100) if total_identifiers > 0 else 0
    print(f"\n{'='*50}")
    print(f"Chameleon Transformation Complete ({theme} theme)")
    print(f"{'='*50}")
    print(f"Processed: {len(results)} files")
    print(f"Total identifiers transformed: {total_transformed}/{total_identifiers}")
    print(f"Average coverage: {avg_coverage:.1f}%")
    print(f"Output: {output_base}")

    # Create index file
    index = {
        "description": f"Temporal contamination contracts with {theme} theme chameleon transformation",
        "transformation_rules": [
            f"Applied {theme} themed synonym pools",
            "Renamed user-defined identifiers using theme vocabulary",
            "Preserved Solidity keywords and built-ins",
            "Added fresh sequential line markers"
        ],
        "theme": theme,
        "source": source,
        "total_files": len(results),
        "prefix": f"ch_{theme}_",
        "source_dir": str(input_base),
        "average_coverage_percent": round(avg_coverage, 2),
        "total_identifiers_transformed": total_transformed,
        "total_identifiers": total_identifiers,
        "created_date": datetime.now().isoformat()
    }

    index_file = output_base / "index.json"
    index_file.write_text(json.dumps(index, indent=2))
    print(f"\nIndex created: {index_file}")

    return results


def main():
    import argparse
    parser = argparse.ArgumentParser(
        description='Chameleon transformation for temporal contamination contracts'
    )
    parser.add_argument('--theme', '-t', default='medical', choices=THEMES,
                       help='Theme for transformation (default: medical)')
    parser.add_argument('--source', '-s', default='nocomments', choices=SOURCES,
                       help='Source dataset (default: nocomments)')
    args = parser.parse_args()

    process_chameleon(args.theme, args.source)


if __name__ == "__main__":
    main()
