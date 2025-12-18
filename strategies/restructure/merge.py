"""
Merge Mode for Restructure Strategy (Chimera)

Merges multiple functions into a unified dispatcher function.
Tests whether models can detect vulnerabilities when multiple
function patterns are combined into a single handler.

Techniques:
- Dispatcher: Multiple functions merged with operation selector (uint)
"""

import re
import json
import copy
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
from strategies.sanitize.sanitize import transform_metadata_identifiers


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"
MERGE_DIR = DATA_DIR / "restructure" / "merge"

# Merge strategies
MERGE_MODES = ['dispatcher']

# Dispatcher function names
DISPATCHER_NAMES = ['execute', 'dispatch', 'handle', 'perform', 'process']


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
    dispatcher_name: str = ""
    changes_made: List[str] = field(default_factory=list)
    function_to_selector: Dict[str, int] = field(default_factory=dict)
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
    Chimera Merge Transformer - Combines functions into dispatcher.

    Creates a single dispatcher function that routes to different logic
    based on a selector parameter.
    """

    def __init__(self, mode: str = 'dispatcher'):
        """
        Initialize merge transformer.

        Args:
            mode: Merge mode ('dispatcher')
        """
        if mode not in MERGE_MODES:
            raise ValueError(f"Invalid mode: {mode}. Must be one of {MERGE_MODES}")
        self.mode = mode

    def transform(self, source: str, target_function: Optional[str] = None) -> MergeResult:
        """
        Apply merge transformation.

        Args:
            source: Source code to transform
            target_function: Optional vulnerable function to include in merge

        Returns:
            MergeResult with transformation details
        """
        return self._apply_dispatcher(source, target_function)

    def _find_mergeable_functions(self, tree, source: str, target: Optional[str] = None) -> List[FunctionInfo]:
        """
        Find functions that can be merged together.

        Looks for public/external functions that could be combined.
        """
        functions = get_all_functions(tree, source)
        mergeable = []

        for func in functions:
            # Skip constructors and special functions
            if not func.name or func.name in ['constructor', 'receive', 'fallback']:
                continue

            # Only merge public/external functions
            if func.visibility not in ['public', 'external']:
                continue

            # Skip view/pure functions for now (they have different patterns)
            if func.mutability in ['view', 'pure']:
                continue

            mergeable.append(func)

        # If we have a target function, make sure it's included and first
        if target:
            target_func = None
            others = []
            for func in mergeable:
                if func.name == target:
                    target_func = func
                else:
                    others.append(func)

            if target_func:
                return [target_func] + others[:2]  # Target + up to 2 others
            return mergeable[:3]  # Just take first 3

        return mergeable[:3]  # Limit to 3 functions

    def _apply_dispatcher(self, source: str, target_function: Optional[str] = None) -> MergeResult:
        """
        Merge functions into a dispatcher pattern.

        Creates a unified function that uses a selector to dispatch
        to different implementations.
        """
        changes = []
        merged = []
        func_to_selector = {}

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

        # Find functions to merge
        functions = self._find_mergeable_functions(tree, source, target_function)

        if len(functions) < 2:
            return MergeResult(
                original_id="",
                transformed_id="",
                mode="dispatcher",
                success=False,
                error="Need at least 2 mergeable functions"
            )

        # Build the dispatcher function
        dispatcher_name = DISPATCHER_NAMES[0]  # 'execute'

        # Collect function bodies and parameters
        func_data = []
        all_params = set()

        for i, func in enumerate(functions):
            body_node = func.node.child_by_field_name('body')
            if not body_node:
                continue

            body_text = get_node_text(body_node, source)
            # Remove braces
            body_content = body_text[1:-1].strip()

            # Check if function uses msg.sender
            uses_sender = 'msg.sender' in body_content

            # Get the full function text to check for 'constant' keyword (old Solidity)
            func_text = get_node_text(func.node, source)
            mutability = func.mutability
            # Handle 'constant' keyword (old Solidity, equivalent to 'view')
            if 'constant' in func_text and not mutability:
                mutability = 'view'

            func_data.append({
                'name': func.name,
                'body': body_content,
                'params': func.parameters,
                'uses_sender': uses_sender,
                'payable': mutability == 'payable',
                'selector': i,
                'return_types': func.return_types,
                'modifiers': func.modifiers,
                'mutability': mutability,
            })
            merged.append(func.name)
            func_to_selector[func.name] = i

            for p in func.parameters:
                all_params.add((p['type'], p['name']))

        if not func_data:
            return MergeResult(
                original_id="",
                transformed_id="",
                mode="dispatcher",
                success=False,
                error="Could not extract function bodies"
            )

        # Ensure we still have at least 2 functions after body extraction
        if len(func_data) < 2:
            return MergeResult(
                original_id="",
                transformed_id="",
                mode="dispatcher",
                success=False,
                error=f"Need at least 2 functions with extractable bodies, got {len(func_data)}"
            )

        # Check if any function is payable
        any_payable = any(f['payable'] for f in func_data)

        # Check for common return types
        return_types_list = [tuple(f['return_types']) for f in func_data]
        all_same_returns = len(set(return_types_list)) == 1
        dispatcher_returns = list(return_types_list[0]) if all_same_returns and return_types_list[0] else []

        # Check for common modifiers (excluding visibility/mutability)
        all_modifiers = [set(f.get('modifiers', [])) for f in func_data]
        common_modifiers = set.intersection(*all_modifiers) if all_modifiers else set()
        # Remove visibility and mutability keywords from modifiers
        visibility_keywords = {'public', 'external', 'internal', 'private', 'pure', 'view', 'payable'}
        dispatcher_modifiers = [m for m in common_modifiers if m not in visibility_keywords]

        # Check for view/pure - if any function is view/pure, dispatcher should be too
        has_view = any(f['mutability'] == 'view' for f in func_data)
        has_pure = any(f['mutability'] == 'pure' for f in func_data)
        all_view_or_pure = all(f['mutability'] in ['view', 'pure'] for f in func_data)

        # Build dispatcher parameter list
        param_list = [f"uint8 _selector"]
        for ptype, pname in sorted(all_params):
            param_list.append(f"{ptype} {pname}")

        params_str = ", ".join(param_list)

        # Build dispatcher body with if-else chain
        body_parts = []
        for i, fd in enumerate(func_data):
            condition = f"if (_selector == {i})" if i == 0 else f"else if (_selector == {i})"
            # Comment showing original function
            body_parts.append(f"        // Original: {fd['name']}()")
            body_parts.append(f"        {condition} {{")
            # Indent the body
            body_lines = fd['body'].split('\n')
            for line in body_lines:
                if line.strip():
                    body_parts.append(f"            {line.strip()}")
            body_parts.append("        }")

        dispatcher_body = '\n'.join(body_parts)

        # Build the dispatcher function signature
        visibility = "public"

        # Build modifiers string
        modifiers_parts = []
        if any_payable:
            modifiers_parts.append("payable")
        elif all_view_or_pure:
            if has_view:
                modifiers_parts.append("view")
            elif has_pure:
                modifiers_parts.append("pure")

        # Add common modifiers (like whenNotPaused)
        modifiers_parts.extend(dispatcher_modifiers)

        modifiers_str = " ".join(modifiers_parts)
        if modifiers_str:
            modifiers_str = " " + modifiers_str

        # Build returns clause
        returns_str = ""
        if dispatcher_returns:
            returns_types = ", ".join(dispatcher_returns)
            returns_str = f" returns ({returns_types})"

        dispatcher_code = f"""
    // Unified dispatcher - merged from: {', '.join(merged)}
    // Selectors: {', '.join(f'{fn}={i}' for fn, i in func_to_selector.items())}
    function {dispatcher_name}({params_str}) {visibility}{modifiers_str}{returns_str} {{
{dispatcher_body}
    }}"""

        # Find where to insert the dispatcher (at end of contract, before closing brace)
        # Find the last closing brace
        last_brace = source.rfind('}')
        if last_brace == -1:
            return MergeResult(
                original_id="",
                transformed_id="",
                mode="dispatcher",
                success=False,
                error="Could not find contract closing brace"
            )

        # Insert dispatcher before last brace
        result = source[:last_brace] + dispatcher_code + '\n' + source[last_brace:]

        changes.append(f"Created dispatcher '{dispatcher_name}' merging {len(merged)} functions")
        changes.append(f"Merged functions: {', '.join(merged)}")

        return MergeResult(
            original_id="",
            transformed_id="",
            mode="dispatcher",
            success=True,
            code=result,
            merged_functions=merged,
            dispatcher_name=dispatcher_name,
            changes_made=changes,
            function_to_selector=func_to_selector
        )


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def _get_source_dir(source: str) -> Path:
    """Get the source directory for a dataset."""
    if source == 'sanitized':
        return SANITIZED_DIR
    elif source == 'nocomments':
        return NOCOMMENTS_DIR
    else:
        raise ValueError(f"Unknown source: {source}")


def _ensure_output_dirs(variant: str):
    """Ensure output directories exist."""
    output_dir = MERGE_DIR / variant
    (output_dir / 'contracts').mkdir(parents=True, exist_ok=True)
    (output_dir / 'metadata').mkdir(parents=True, exist_ok=True)
    return output_dir


def transform_merge(source: str, mode: str = 'dispatcher', target_function: Optional[str] = None) -> MergeResult:
    """Transform source code using merge mode."""
    transformer = MergeTransformer(mode)
    return transformer.transform(source, target_function)


def transform_one(file_id: str, mode: str = 'dispatcher', source: str = 'nocomments', save: bool = True) -> MergeResult:
    """Transform a single file using merge mode."""
    # Get source path
    source_dir = _get_source_dir(source)
    contracts_dir = source_dir / 'contracts'
    metadata_dir = source_dir / 'metadata'

    source_path = contracts_dir / f"{file_id}.sol"
    metadata_path = metadata_dir / f"{file_id}.json"

    if not source_path.exists():
        return MergeResult(
            original_id=file_id,
            transformed_id="",
            mode=mode,
            success=False,
            error=f"Source file not found: {file_id}"
        )

    try:
        # Read metadata to get vulnerable function
        metadata = {}
        target_function = None
        if metadata_path.exists():
            metadata = json.loads(metadata_path.read_text())
            vuln_loc = metadata.get('ground_truth', {}).get('vulnerable_location', {})
            target_function = vuln_loc.get('function_name')

        source_code = source_path.read_text()
        result = transform_merge(source_code, mode, target_function)

        result.original_id = file_id

        # Generate transformed ID
        source_prefix = 'sn' if source == 'sanitized' else 'nc'
        # Extract base ID
        base_id = file_id
        for prefix in ['sn_', 'nc_', 'ch_']:
            if file_id.startswith(prefix):
                base_id = file_id[len(prefix):]
                break
        result.transformed_id = f"rs_mg_dis_{source_prefix}_{base_id}"

        # Validate syntax if successful
        if result.success:
            is_valid, errors = check_syntax(result.code)
            if not is_valid:
                result.success = False
                result.error = f"Syntax errors: {errors[:3]}"

        # Save if successful
        if save and result.success:
            output_dir = _ensure_output_dirs(mode)

            # Save contract
            contract_path = output_dir / 'contracts' / f"{result.transformed_id}.sol"
            contract_path.write_text(result.code)

            # Update metadata
            new_metadata = copy.deepcopy(metadata)
            new_metadata['derived_from'] = file_id
            new_metadata['id'] = result.transformed_id
            new_metadata['contract_file'] = f"contracts/{result.transformed_id}.sol"
            new_metadata['subset'] = 'restructure'

            # Update vulnerable_location with merge info
            if 'ground_truth' in new_metadata and 'vulnerable_location' in new_metadata['ground_truth']:
                vuln_loc = new_metadata['ground_truth']['vulnerable_location']
                # The vulnerable function is now part of a merged dispatcher
                vuln_loc['merged_into_dispatcher'] = result.dispatcher_name
                vuln_loc['selector'] = result.function_to_selector.get(target_function, 0)
                vuln_loc['original_function'] = target_function

            new_metadata['transformation'] = {
                'strategy': 'restructure',
                'mode': 'merge',
                'variant': mode,
                'source': source,
                'merged_functions': result.merged_functions,
                'dispatcher_name': result.dispatcher_name,
                'function_to_selector': result.function_to_selector,
                'changes': result.changes_made,
            }

            # Save metadata
            meta_path = output_dir / 'metadata' / f"{result.transformed_id}.json"
            meta_path.write_text(json.dumps(new_metadata, indent=2))

        return result

    except Exception as e:
        return MergeResult(
            original_id=file_id,
            transformed_id="",
            mode=mode,
            success=False,
            error=str(e)
        )


def transform_all(mode: str = 'dispatcher', source: str = 'nocomments') -> MergeReport:
    """Transform all files using merge mode."""
    source_dir = _get_source_dir(source)
    contracts_dir = source_dir / 'contracts'

    if not contracts_dir.exists():
        raise ValueError(f"Source contracts directory not found: {contracts_dir}")

    results = []
    contract_files = sorted(contracts_dir.glob('*.sol'))

    for contract_path in contract_files:
        file_id = contract_path.stem
        result = transform_one(file_id, mode, source, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    report = MergeReport(
        timestamp=datetime.now().isoformat(),
        mode=mode,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )

    # Save report
    output_dir = _ensure_output_dirs(mode)
    report_path = output_dir / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    return report


__all__ = [
    'MergeTransformer',
    'transform_merge',
    'transform_one',
    'transform_all',
    'MERGE_MODES',
    'MergeResult',
    'MergeReport',
]
