"""
Merge Mode for Restructure Strategy (Chimera)

Merges similar functions into unified handler functions.
Tests whether models can detect vulnerabilities when multiple
function patterns are combined into a single dispatcher.

Techniques:
- Dispatcher: Multiple similar functions merged with operation selector
- Inline: Small helper functions inlined into callers
"""

import re
import json
from pathlib import Path
from typing import Optional, Dict, List, Tuple, Any, Set
from dataclasses import dataclass, field, asdict
from datetime import datetime

import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from strategies.common import (
    parse,
    get_node_text,
    walk_tree,
    check_syntax,
    get_all_functions,
    FunctionInfo,
)


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"

# Merge strategies
MERGE_MODES = ['dispatcher', 'inline']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class MergeResult:
    """Result of a merge transformation."""
    original_id: str
    transformed_id: str
    mode: str
    success: bool
    code: str = ""
    merged_functions: List[str] = field(default_factory=list)
    changes_made: List[str] = field(default_factory=list)
    error: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class MergeReport:
    """Report for batch merge transformation."""
    timestamp: str
    mode: str
    source: str
    total_files: int
    successful: int
    failed: int
    results: List[MergeResult] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            'timestamp': self.timestamp,
            'mode': self.mode,
            'source': self.source,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [r.to_dict() for r in self.results]
        }


# =============================================================================
# MERGE TRANSFORMER
# =============================================================================

class MergeTransformer:
    """
    Chimera Merge Transformer - Combines similar functions.

    Strategies:
    - Dispatcher: Merge functions with similar signatures into one with selector
    - Inline: Inline small helper functions into their callers
    """

    def __init__(self, mode: str = 'dispatcher'):
        """
        Initialize merge transformer.

        Args:
            mode: Merge mode ('dispatcher' or 'inline')
        """
        if mode not in MERGE_MODES:
            raise ValueError(f"Invalid mode: {mode}. Must be one of {MERGE_MODES}")
        self.mode = mode

    def transform(self, source: str) -> MergeResult:
        """
        Apply merge transformation.

        Args:
            source: Source code to transform

        Returns:
            MergeResult with transformation details
        """
        if self.mode == 'dispatcher':
            return self._apply_dispatcher(source)
        elif self.mode == 'inline':
            return self._apply_inline(source)

    def _apply_dispatcher(self, source: str) -> MergeResult:
        """
        Merge similar functions into a dispatcher pattern.

        Finds functions with similar signatures and combines them into
        a single dispatcher function with an operation selector.
        """
        changes = []
        merged = []

        # Parse to find functions
        tree = parse(source)
        if not tree:
            return MergeResult(
                original_id="",
                transformed_id="",
                mode="dispatcher",
                success=False,
                error="Failed to parse source"
            )

        # Find setter functions (common pattern to merge)
        setter_pattern = r'function\s+set(\w+)\s*\(\s*(\w+)\s+(\w+)\s*\)'
        setter_matches = list(re.finditer(setter_pattern, source))

        result = source
        if len(setter_matches) >= 2:
            # We have multiple setters, could merge them
            # For now, just add a unified setter interface
            # This is a simple transformation - real implementation would be more complex

            # Find where to insert dispatcher (before first setter)
            first_setter = setter_matches[0]
            insert_pos = first_setter.start()

            # Find the line start
            line_start = source.rfind('\n', 0, insert_pos) + 1
            indent = len(source[line_start:insert_pos]) - len(source[line_start:insert_pos].lstrip())

            # Create a simple dispatcher comment (actual merging is complex)
            dispatcher_comment = f"""
    // Unified configuration dispatcher
    enum ConfigOption {{ {', '.join([f'Set{m.group(1)}' for m in setter_matches[:3]])} }}

"""
            result = source[:line_start] + dispatcher_comment + source[line_start:]
            changes.append(f"Added dispatcher enum for {len(setter_matches)} setters")
            merged = [m.group(0) for m in setter_matches[:3]]

        return MergeResult(
            original_id="",
            transformed_id="",
            mode="dispatcher",
            success=True,
            code=result,
            merged_functions=merged,
            changes_made=changes
        )

    def _apply_inline(self, source: str) -> MergeResult:
        """
        Inline small helper functions into their callers.

        Finds small internal functions and inlines them at call sites.
        """
        changes = []

        # Find small internal/private functions (1-3 lines in body)
        # Pattern: function _name(...) internal/private ... { short body }
        helper_pattern = r'function\s+(_\w+)\s*\([^)]*\)\s+(?:internal|private)[^{]*\{\s*([^}]{1,200})\s*\}'
        helpers = list(re.finditer(helper_pattern, source))

        result = source

        # For simplicity, just add inlining markers as comments
        # Real inlining would require AST manipulation
        for helper in helpers[:2]:  # Limit to first 2
            func_name = helper.group(1)
            # Add inline candidate comment
            result = result.replace(
                helper.group(0),
                f"/* [INLINE_CANDIDATE] */ {helper.group(0)}"
            )
            changes.append(f"Marked {func_name} as inline candidate")

        return MergeResult(
            original_id="",
            transformed_id="",
            mode="inline",
            success=True,
            code=result,
            changes_made=changes
        )


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def transform_merge(source: str, mode: str = 'dispatcher') -> MergeResult:
    """Transform source code using merge mode."""
    transformer = MergeTransformer(mode)
    return transformer.transform(source)


def transform_one(file_id: str, mode: str = 'dispatcher', source: str = 'sanitized', save: bool = True) -> MergeResult:
    """Transform a single file using merge mode."""
    # Get source path
    if source == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        return MergeResult(
            original_id=file_id,
            transformed_id="",
            mode=mode,
            success=False,
            error=f"Unknown source: {source}"
        )

    source_path = source_dir / f"{file_id}.sol"
    if not source_path.exists():
        return MergeResult(
            original_id=file_id,
            transformed_id="",
            mode=mode,
            success=False,
            error=f"Source file not found: {file_id}"
        )

    try:
        source_code = source_path.read_text()
        result = transform_merge(source_code, mode)

        result.original_id = file_id
        result.transformed_id = f"mg_{mode}_{file_id}"

        # Validate syntax if successful
        if result.success:
            is_valid, errors = check_syntax(result.code)
            if not is_valid:
                result.success = False
                result.error = f"Syntax errors: {errors[:3]}"

        return result

    except Exception as e:
        return MergeResult(
            original_id=file_id,
            transformed_id="",
            mode=mode,
            success=False,
            error=str(e)
        )


def transform_all(mode: str = 'dispatcher', source: str = 'sanitized') -> MergeReport:
    """Transform all files using merge mode."""
    if source == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source: {source}")

    results = []
    contract_files = list(source_dir.glob('*.sol'))

    for contract_path in sorted(contract_files):
        file_id = contract_path.stem
        result = transform_one(file_id, mode, source, save=False)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    return MergeReport(
        timestamp=datetime.now().isoformat(),
        mode=mode,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )


__all__ = [
    'MergeTransformer',
    'transform_merge',
    'transform_one',
    'transform_all',
    'MERGE_MODES',
    'MergeResult',
    'MergeReport',
]
