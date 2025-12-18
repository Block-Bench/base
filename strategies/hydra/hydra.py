"""
Hydra Transformation Strategy v1.0

Splits vulnerable functions into multiple helper functions to test
whether AI models can trace vulnerability patterns across function boundaries.

Hypothesis: "If a model fails to detect a vulnerability when the vulnerable
pattern is split across multiple functions, it cannot perform cross-function
dataflow analysis."

Output naming: hy_{split_type}_{source}_{original_id}
  - hy_seq_sn_ds_001.sol (sequential split from sanitized ds_001)
  - hy_int_nc_tc_042.sol (internal/external split from nocomments tc_042)
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
    FunctionInfo,
    ContractInfo,
    get_contract_info,
    get_function_info,
    find_function_by_name,
    get_all_functions,
    get_statements,
    categorize_statement,
    get_node_text,
    apply_edits,
    check_syntax,
    find_all,
    walk_tree,
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
HYDRA_DIR = DATA_DIR / "restructure"  # Part of combined Restructure strategy

# Split patterns
# Note: 'sequential' is experimental and may produce code that doesn't compile
# due to local variable scoping issues. Use 'internal_external' for reliable results.
SPLIT_PATTERNS = ['internal_external', 'sequential']
DEFAULT_SPLIT = 'internal_external'

# Source datasets
SOURCES = ['sanitized', 'nocomments', 'chameleon']
SOURCE_PREFIXES = {'sanitized': 'sn', 'nocomments': 'nc', 'chameleon': 'ch'}

# Split type prefixes
SPLIT_PREFIXES = {'sequential': 'seq', 'internal_external': 'int'}

# Helper name pools for different categories
HELPER_NAME_POOLS = {
    'check': {
        'prefixes': ['_validate', '_check', '_verify', '_ensure', '_require', '_assert'],
        'suffixes': ['Conditions', 'Requirements', 'Prerequisites', 'Inputs', 'State'],
    },
    'effect': {
        'prefixes': ['_update', '_modify', '_change', '_set', '_adjust', '_process'],
        'suffixes': ['State', 'Storage', 'Data', 'Values', 'Records'],
    },
    'interaction': {
        'prefixes': ['_execute', '_perform', '_do', '_handle', '_run', '_invoke'],
        'suffixes': ['Transfer', 'Call', 'External', 'Action', 'Operation'],
    },
    'internal': {
        'prefixes': ['_', '_do', '_execute', '_perform', '_handle'],
        'suffixes': ['Internal', 'Impl', 'Core', 'Logic', 'Handler'],
    },
}


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class HelperFunction:
    """Represents a generated helper function."""
    name: str
    visibility: str
    mutability: str
    parameters: List[Dict[str, str]]
    return_types: List[str]
    body: str
    category: str  # check, effect, interaction


@dataclass
class SplitResult:
    """Result of splitting a function."""
    original_function: str
    helpers: List[HelperFunction]
    new_main_body: str
    split_type: str
    statements_per_helper: List[int]


@dataclass
class ValidationResult:
    """Validation result for a transformation."""
    valid: bool
    syntax_ok: bool
    helpers_callable: bool
    errors: List[str]
    warnings: List[str]

    def to_dict(self) -> Dict:
        return asdict(self)


@dataclass
class TransformationResult:
    """Result of a hydra transformation."""
    original_id: str
    hydra_id: str
    split_type: str
    source: str
    success: bool
    code: str = ""
    split_details: Optional[SplitResult] = None
    validation: Optional[ValidationResult] = None
    seed: int = 0
    error: Optional[str] = None

    def to_dict(self) -> Dict:
        result = {
            'original_id': self.original_id,
            'hydra_id': self.hydra_id,
            'split_type': self.split_type,
            'source': self.source,
            'success': self.success,
            'seed': self.seed,
        }
        if self.split_details:
            result['split_details'] = {
                'original_function': self.split_details.original_function,
                'helpers_created': [h.name for h in self.split_details.helpers],
                'split_type': self.split_details.split_type,
                'statements_per_helper': self.split_details.statements_per_helper,
            }
        if self.validation:
            result['validation'] = self.validation.to_dict()
        if self.error:
            result['error'] = self.error
        return result


@dataclass
class TransformationReport:
    """Report for a batch transformation run."""
    timestamp: str
    split_type: str
    source: str
    total_files: int
    successful: int
    failed: int
    results: List[TransformationResult] = field(default_factory=list)

    def to_dict(self) -> Dict:
        return {
            'timestamp': self.timestamp,
            'split_type': self.split_type,
            'source': self.source,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [r.to_dict() for r in self.results]
        }


# =============================================================================
# PARAMETER ANALYSIS
# =============================================================================

def extract_used_identifiers(code: str) -> Set[str]:
    """Extract all identifiers used in a code snippet."""
    pattern = r'\b([a-zA-Z_][a-zA-Z0-9_]*)\b'
    return set(re.findall(pattern, code))


def filter_parameters_for_code(
    params: List[Dict[str, str]],
    code: str
) -> List[Dict[str, str]]:
    """
    Filter parameters to only those actually used in the code.
    """
    used_idents = extract_used_identifiers(code)
    return [p for p in params if p['name'] in used_idents]


def determine_mutability(statements: List[str], full_code: str) -> str:
    """
    Determine the mutability for a helper function based on its statements.

    - 'view': reads state but doesn't modify
    - 'pure': doesn't read or modify state
    - '': modifies state or makes external calls
    """
    combined = ' '.join(statements).lower()

    # If there are external calls or state modifications, no mutability modifier
    state_modifying = [
        '=', '++', '--', '.push', '.pop', 'delete ',
        '.call', '.transfer', '.send', '.delegatecall'
    ]

    for pattern in state_modifying:
        if pattern in combined:
            # Check if it's an assignment (=) vs comparison (==)
            if pattern == '=':
                # Look for actual assignment, not comparison
                if re.search(r'[^=!<>]=[^=]', combined):
                    return ''
            else:
                return ''

    # Check if it reads from storage (mappings, state variables)
    # This is a heuristic - if it has require/assert with storage reads
    storage_read_patterns = [
        r'\bmappings?\s*\[',
        r'\bbalances\s*\[',
        r'\b\w+\[msg\.sender\]',
        r'\b\w+\[address\]',
    ]

    for pattern in storage_read_patterns:
        if re.search(pattern, combined):
            return 'view'

    # Default to view for checks, empty for others
    if any('require' in s or 'assert' in s for s in statements):
        return 'view'

    return ''


# =============================================================================
# HELPER NAME GENERATION
# =============================================================================

def generate_helper_name(
    base_function: str,
    category: str,
    index: int,
    rng: Random
) -> str:
    """Generate a helper function name."""
    pools = HELPER_NAME_POOLS.get(category, HELPER_NAME_POOLS['effect'])

    prefix = rng.choice(pools['prefixes'])
    suffix = rng.choice(pools['suffixes'])

    # Capitalize base function name for camelCase
    base_cap = base_function[0].upper() + base_function[1:] if base_function else ''

    # Add index if there are multiple helpers of same category
    index_str = str(index) if index > 0 else ''

    return f"{prefix}{base_cap}{suffix}{index_str}"


def generate_internal_name(
    base_function: str,
    rng: Random
) -> str:
    """Generate internal function name for internal/external split."""
    pools = HELPER_NAME_POOLS['internal']
    prefix = rng.choice(pools['prefixes'])
    suffix = rng.choice(pools['suffixes'])

    base_cap = base_function[0].upper() + base_function[1:] if base_function else ''
    return f"{prefix}{base_cap}{suffix}"


# =============================================================================
# SEQUENTIAL SPLIT
# =============================================================================

def split_sequential(
    func_info: FunctionInfo,
    source: str,
    rng: Random
) -> Optional[SplitResult]:
    """
    Split a function into sequential helper calls based on statement categories.

    Groups consecutive statements by category (check, effect, interaction)
    and creates helper functions for each group.
    """
    # Get function body
    body_node = func_info.node.child_by_field_name('body')
    if not body_node:
        return None

    # Get statements
    statements = get_statements(body_node, source)
    if len(statements) < 2:
        return None  # Need at least 2 statements to split

    # Group statements by category
    groups = []
    current_group = []
    current_category = None

    for stmt_node, stmt_text in statements:
        category = categorize_statement(stmt_text)

        if category != current_category and current_group:
            groups.append((current_category, current_group))
            current_group = []

        current_group.append(stmt_text.strip())
        current_category = category

    if current_group:
        groups.append((current_category, current_group))

    # Need at least 2 groups to make splitting meaningful
    if len(groups) < 2:
        return None

    # Generate helpers for each group
    helpers = []
    helper_calls = []
    category_counts = {'check': 0, 'effect': 0, 'interaction': 0}

    for category, stmts in groups:
        # Generate helper name
        helper_name = generate_helper_name(
            func_info.name,
            category,
            category_counts[category],
            rng
        )
        category_counts[category] += 1

        # Determine parameters needed
        combined_stmts = '\n        '.join(stmts)
        needed_params = filter_parameters_for_code(func_info.parameters, combined_stmts)

        # Also check for msg.sender usage - need to pass as param
        uses_msg_sender = 'msg.sender' in combined_stmts
        internal_params = needed_params.copy()

        if uses_msg_sender:
            # Add sender parameter
            internal_params.insert(0, {'type': 'address', 'name': '_sender'})
            # Replace msg.sender with _sender in body
            combined_stmts = combined_stmts.replace('msg.sender', '_sender')

        # Determine mutability
        mutability = determine_mutability(stmts, source)

        # Build helper function
        helper = HelperFunction(
            name=helper_name,
            visibility='internal',
            mutability=mutability,
            parameters=internal_params,
            return_types=[],
            body=combined_stmts,
            category=category
        )
        helpers.append(helper)

        # Build call to helper
        call_args = []
        if uses_msg_sender:
            call_args.append('msg.sender')
        call_args.extend(p['name'] for p in needed_params)

        helper_calls.append(f"{helper_name}({', '.join(call_args)});")

    # Build new main function body
    new_main_body = '\n        '.join(helper_calls)

    return SplitResult(
        original_function=func_info.name,
        helpers=helpers,
        new_main_body=new_main_body,
        split_type='sequential',
        statements_per_helper=[len(g[1]) for g in groups]
    )


# =============================================================================
# INTERNAL/EXTERNAL SPLIT
# =============================================================================

def split_internal_external(
    func_info: FunctionInfo,
    source: str,
    rng: Random
) -> Optional[SplitResult]:
    """
    Split a function into external wrapper + internal implementation.

    The external function becomes a thin wrapper that calls the internal
    implementation, passing msg.sender as a parameter.
    """
    body_node = func_info.node.child_by_field_name('body')
    if not body_node:
        return None

    # Get the body text
    body_text = get_node_text(body_node, source)
    # Remove the { and } braces
    body_content = body_text[1:-1].strip()

    if not body_content:
        return None

    # Generate internal function name
    internal_name = generate_internal_name(func_info.name, rng)

    # Check if function uses msg.sender
    uses_msg_sender = 'msg.sender' in body_content

    # Build internal function parameters
    internal_params = func_info.parameters.copy()
    if uses_msg_sender:
        internal_params.insert(0, {'type': 'address', 'name': '_sender'})
        body_content = body_content.replace('msg.sender', '_sender')

    # Internal function is always internal visibility
    internal_mutability = ''  # Internal functions that modify state have no mutability

    # Check for view/pure
    if func_info.mutability in ['view', 'pure']:
        internal_mutability = func_info.mutability

    # Create internal helper
    internal_helper = HelperFunction(
        name=internal_name,
        visibility='internal',
        mutability=internal_mutability,
        parameters=internal_params,
        return_types=func_info.return_types,
        body=body_content,
        category='internal'
    )

    # Build call to internal function
    call_args = []
    if uses_msg_sender:
        call_args.append('msg.sender')
    call_args.extend(p['name'] for p in func_info.parameters)

    # Handle return types
    if func_info.return_types:
        new_main_body = f"return {internal_name}({', '.join(call_args)});"
    else:
        new_main_body = f"{internal_name}({', '.join(call_args)});"

    return SplitResult(
        original_function=func_info.name,
        helpers=[internal_helper],
        new_main_body=new_main_body,
        split_type='internal_external',
        statements_per_helper=[1]
    )


# =============================================================================
# CODE GENERATION
# =============================================================================

def build_helper_function_code(helper: HelperFunction, indent: str = '    ') -> str:
    """Build the code for a helper function."""
    # Build parameter string
    params_str = ', '.join(
        f"{p['type']} {p['name']}" for p in helper.parameters
    )

    # Build visibility and mutability
    modifiers = [helper.visibility]
    if helper.mutability:
        modifiers.append(helper.mutability)
    modifiers_str = ' '.join(modifiers)

    # Build return types
    returns_str = ''
    if helper.return_types:
        returns_str = f" returns ({', '.join(helper.return_types)})"

    # Build function body with proper indentation
    body_lines = helper.body.split('\n')
    indented_body = '\n'.join(f'{indent}    {line.strip()}' for line in body_lines if line.strip())

    return f"""{indent}function {helper.name}({params_str}) {modifiers_str}{returns_str} {{
{indented_body}
{indent}}}"""


def apply_split_to_source(
    source: str,
    func_info: FunctionInfo,
    split_result: SplitResult
) -> str:
    """
    Apply the split transformation to the source code.

    Replaces the original function body with calls to helpers,
    and adds helper functions after the original function.
    """
    # Build new function body
    body_node = func_info.node.child_by_field_name('body')
    old_body = get_node_text(body_node, source)

    # Preserve indentation
    indent = '        '
    new_body = '{\n' + indent + split_result.new_main_body + '\n    }'

    # Build helper functions code
    helpers_code = '\n\n' + '\n\n'.join(
        build_helper_function_code(h) for h in split_result.helpers
    )

    # Replace body and add helpers
    edits = [
        {
            'type': 'replace',
            'start': body_node.start_byte,
            'end': body_node.end_byte,
            'text': new_body
        },
        {
            'type': 'insert',
            'position': func_info.end_byte,
            'text': helpers_code
        }
    ]

    return apply_edits(source, edits)


# =============================================================================
# HYDRA TRANSFORMER
# =============================================================================

class HydraTransformer:
    """
    Main transformer class for Hydra strategy.

    Splits functions into multiple helpers to test cross-function analysis.
    """

    def __init__(
        self,
        split_type: str = 'sequential',
        target_functions: Optional[List[str]] = None
    ):
        if split_type not in SPLIT_PATTERNS:
            raise ValueError(f"Unknown split type: {split_type}. Available: {SPLIT_PATTERNS}")

        self.split_type = split_type
        self.target_functions = target_functions

    def _create_seed(self, source_code: str) -> int:
        """Create deterministic seed from source + split type."""
        seed_input = f"hydra:{self.split_type}:{hashlib.sha256(source_code.encode()).hexdigest()}"
        return int(hashlib.md5(seed_input.encode()).hexdigest(), 16) % (2**32)

    def _find_vulnerable_functions(self, tree, source: str) -> List[FunctionInfo]:
        """
        Find functions that are likely vulnerable (candidates for splitting).

        Looks for functions with external calls, state modifications, etc.
        """
        functions = get_all_functions(tree, source)
        candidates = []

        for func in functions:
            # Skip constructors and receive/fallback
            if not func.name or func.name in ['constructor', 'receive', 'fallback']:
                continue

            # Get body text
            body_node = func.node.child_by_field_name('body')
            if not body_node:
                continue

            body_text = get_node_text(body_node, source)

            # Look for patterns that suggest vulnerability
            vulnerability_patterns = [
                '.call',
                '.transfer',
                '.send',
                '.delegatecall',
            ]

            has_vulnerability_pattern = any(p in body_text for p in vulnerability_patterns)

            # Also include functions that modify state and have requires
            has_state_mod = '=' in body_text and 'require' in body_text.lower()

            if has_vulnerability_pattern or has_state_mod:
                candidates.append(func)

        return candidates

    def transform(
        self,
        source_code: str,
        function_name: Optional[str] = None
    ) -> Tuple[str, Optional[SplitResult]]:
        """
        Transform source code by splitting function(s).

        Args:
            source_code: Source code to transform
            function_name: Optional specific function to split (if None, finds candidates)

        Returns:
            (transformed_code, split_result) or (original_code, None) if no split possible
        """
        seed = self._create_seed(source_code)
        rng = Random(seed)

        tree = parse(source_code)

        # Find function to split
        func_info = None

        if function_name:
            func_info = find_function_by_name(tree, function_name, source_code)
        else:
            # If target functions specified, use first match
            if self.target_functions:
                for target in self.target_functions:
                    func_info = find_function_by_name(tree, target, source_code)
                    if func_info:
                        break
            else:
                # Find vulnerable function candidates
                candidates = self._find_vulnerable_functions(tree, source_code)
                if candidates:
                    func_info = candidates[0]  # Take first candidate

        if not func_info:
            return source_code, None

        # Apply split based on type
        if self.split_type == 'sequential':
            split_result = split_sequential(func_info, source_code, rng)
        elif self.split_type == 'internal_external':
            split_result = split_internal_external(func_info, source_code, rng)
        else:
            return source_code, None

        if not split_result:
            return source_code, None

        # Apply transformation
        transformed = apply_split_to_source(source_code, func_info, split_result)

        return transformed, split_result


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _get_source_dir(source: str) -> Path:
    """Get the source directory for a dataset."""
    if source == 'sanitized':
        return SANITIZED_DIR
    elif source == 'nocomments':
        return NOCOMMENTS_DIR
    elif source.startswith('chameleon'):
        return CHAMELEON_DIR
    else:
        raise ValueError(f"Unknown source: {source}")


def _get_file_paths(file_id: str, source: str) -> Tuple[Optional[Path], Optional[Path]]:
    """Get paths for a file ID from the source dataset."""
    source_dir = _get_source_dir(source)

    # Handle chameleon subdirectories
    if source.startswith('chameleon'):
        # Try different chameleon subdirs
        for subdir in source_dir.iterdir():
            if subdir.is_dir():
                contracts_dir = subdir / 'contracts'
                metadata_dir = subdir / 'metadata'

                for ext in ['.sol', '.rs']:
                    contract_path = contracts_dir / f"{file_id}{ext}"
                    if contract_path.exists():
                        metadata_path = metadata_dir / f"{file_id}.json"
                        return contract_path, metadata_path
    else:
        contracts_dir = source_dir / 'contracts'
        metadata_dir = source_dir / 'metadata'

        for ext in ['.sol', '.rs']:
            contract_path = contracts_dir / f"{file_id}{ext}"
            if contract_path.exists():
                metadata_path = metadata_dir / f"{file_id}.json"
                return contract_path, metadata_path

    return None, None


def _ensure_output_dirs(split_type: str, source: str):
    """Ensure output directories exist."""
    split_prefix = SPLIT_PREFIXES[split_type]
    source_prefix = SOURCE_PREFIXES.get(source, 'unk')
    output_dir = HYDRA_DIR / f"{split_prefix}_{source_prefix}"
    (output_dir / 'contracts').mkdir(parents=True, exist_ok=True)
    (output_dir / 'metadata').mkdir(parents=True, exist_ok=True)
    return output_dir


def _get_hydra_id(original_id: str, split_type: str, source: str) -> str:
    """Generate hydra ID from original ID."""
    split_prefix = SPLIT_PREFIXES[split_type]
    source_prefix = SOURCE_PREFIXES.get(source, 'unk')

    # Extract base ID
    for prefix in ['sn_', 'nc_', 'ch_']:
        if original_id.startswith(prefix):
            base_id = original_id[len(prefix):]
            break
    else:
        base_id = original_id

    return f"hy_{split_prefix}_{source_prefix}_{base_id}"


def _save_hydra(
    hydra_id: str,
    transformed_code: str,
    original_metadata_path: Optional[Path],
    extension: str,
    split_type: str,
    source: str,
    split_details: Optional[SplitResult],
    seed: int,
    original_metadata: Optional[Dict] = None
) -> Path:
    """Save hydra contract and metadata."""
    output_dir = _ensure_output_dirs(split_type, source)

    # Save transformed contract
    contract_path = output_dir / 'contracts' / f"{hydra_id}{extension}"
    contract_path.write_text(transformed_code)

    # Use provided metadata or read from path
    import copy
    if original_metadata:
        metadata = copy.deepcopy(original_metadata)
    elif original_metadata_path and original_metadata_path.exists():
        metadata = json.loads(original_metadata_path.read_text())
    else:
        metadata = {}

    # For split transformation, the vulnerable function wrapper still exists
    # so function_name in metadata stays the same. But we note that vulnerability
    # now spans multiple functions (the wrapper calls internal helpers).

    # Track the derived_from chain
    metadata['derived_from'] = metadata.get('id', '')

    # Update metadata for hydra version
    metadata['id'] = hydra_id
    metadata['contract_file'] = f"contracts/{hydra_id}{extension}"
    metadata['subset'] = 'restructure'

    # Build transformation info
    transformation = {
        'strategy': 'restructure',
        'mode': 'split',
        'split_type': split_type,
        'source': source,
        'seed': seed,
    }

    if split_details:
        transformation['split_details'] = {
            'original_function': split_details.original_function,
            'helpers_created': [h.name for h in split_details.helpers],
            'helpers_categories': [h.category for h in split_details.helpers],
            'statements_per_helper': split_details.statements_per_helper,
        }

        # Add note that vulnerability now spans functions
        # The vulnerable function is still the entry point, but the actual
        # vulnerable code is now in a helper
        if 'ground_truth' in metadata:
            gt = metadata['ground_truth']
            if 'vulnerable_location' in gt:
                # Keep the function_name as the entry point
                # Add helper info to show where the actual vulnerability moved
                gt['vulnerable_location']['helper_functions'] = [h.name for h in split_details.helpers]
                gt['vulnerable_location']['vulnerability_spans_functions'] = True

    metadata['transformation'] = transformation

    # Save metadata
    metadata_path = output_dir / 'metadata' / f"{hydra_id}.json"
    metadata_path.write_text(json.dumps(metadata, indent=2))

    return contract_path


# =============================================================================
# PUBLIC API
# =============================================================================

def transform_code(
    code: str,
    split_type: str = DEFAULT_SPLIT,
    function_name: Optional[str] = None
) -> Tuple[str, Optional[SplitResult]]:
    """
    Transform code using Hydra strategy.

    Args:
        code: Source code to transform
        split_type: Type of split to apply
        function_name: Optional specific function to split

    Returns:
        Tuple of (transformed_code, split_result)
    """
    transformer = HydraTransformer(split_type)
    return transformer.transform(code, function_name)


def transform_one(
    file_id: str,
    split_type: str = DEFAULT_SPLIT,
    source: str = 'nocomments',
    function_name: Optional[str] = None,
    save: bool = True
) -> TransformationResult:
    """
    Transform a single file by ID.

    Args:
        file_id: File ID (e.g., 'nc_ds_001', 'sn_tc_042')
        split_type: Type of split to apply
        source: Source dataset
        function_name: Optional specific function to split (if None, uses vulnerable function from metadata)
        save: Whether to save output to disk

    Returns:
        TransformationResult with details
    """
    if split_type not in SPLIT_PATTERNS:
        return TransformationResult(
            original_id=file_id,
            hydra_id='',
            split_type=split_type,
            source=source,
            success=False,
            error=f"Unknown split type: {split_type}. Available: {SPLIT_PATTERNS}"
        )

    contract_path, metadata_path = _get_file_paths(file_id, source)

    if not contract_path or not contract_path.exists():
        return TransformationResult(
            original_id=file_id,
            hydra_id='',
            split_type=split_type,
            source=source,
            success=False,
            error=f"File not found: {file_id} in {source}"
        )

    try:
        # Read metadata to get vulnerable function if not specified
        metadata = {}
        if metadata_path and metadata_path.exists():
            metadata = json.loads(metadata_path.read_text())

        # If no function specified, try to get vulnerable function from metadata
        target_function = function_name
        if not target_function:
            vuln_loc = metadata.get('ground_truth', {}).get('vulnerable_location', {})
            target_function = vuln_loc.get('function_name')

        # Read and transform
        code = contract_path.read_text()
        transformer = HydraTransformer(split_type)
        transformed, split_result = transformer.transform(code, target_function)

        if not split_result:
            return TransformationResult(
                original_id=file_id,
                hydra_id='',
                split_type=split_type,
                source=source,
                success=False,
                error="No suitable function found for splitting"
            )

        hydra_id = _get_hydra_id(file_id, split_type, source)
        seed = transformer._create_seed(code)

        # Validate
        syntax_ok, errors = check_syntax(transformed)
        validation = ValidationResult(
            valid=syntax_ok,
            syntax_ok=syntax_ok,
            helpers_callable=True,  # Assumed true if syntax is OK
            errors=errors,
            warnings=[]
        )

        if save:
            _save_hydra(
                hydra_id,
                transformed,
                metadata_path,
                contract_path.suffix,
                split_type,
                source,
                split_result,
                seed,
                metadata
            )

        return TransformationResult(
            original_id=file_id,
            hydra_id=hydra_id,
            split_type=split_type,
            source=source,
            success=True,
            code=transformed,
            split_details=split_result,
            validation=validation,
            seed=seed
        )

    except Exception as e:
        return TransformationResult(
            original_id=file_id,
            hydra_id='',
            split_type=split_type,
            source=source,
            success=False,
            error=str(e)
        )


def transform_all(
    split_type: str = DEFAULT_SPLIT,
    source: str = 'nocomments',
    function_name: Optional[str] = None
) -> TransformationReport:
    """
    Transform all files from a source dataset.

    Args:
        split_type: Type of split to apply
        source: Source dataset
        function_name: Optional specific function to target

    Returns:
        TransformationReport with all results
    """
    source_dir = _get_source_dir(source)

    # Handle different source structures
    if source.startswith('chameleon'):
        contract_files = []
        for subdir in source_dir.iterdir():
            if subdir.is_dir():
                contracts_dir = subdir / 'contracts'
                if contracts_dir.exists():
                    contract_files.extend(sorted(contracts_dir.glob('*.sol')))
    else:
        contracts_dir = source_dir / 'contracts'
        if not contracts_dir.exists():
            raise FileNotFoundError(f"Source contracts directory not found: {contracts_dir}")
        contract_files = sorted(contracts_dir.glob('*.sol'))

    results = []
    for contract_path in contract_files:
        file_id = contract_path.stem
        result = transform_one(file_id, split_type, source, function_name, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)

    report = TransformationReport(
        timestamp=datetime.now().isoformat(),
        split_type=split_type,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=len(results) - successful,
        results=results
    )

    # Save report
    output_dir = _ensure_output_dirs(split_type, source)
    report_path = output_dir / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    return report


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Hydra transformation."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Hydra transformation - split functions into helpers'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # transform one
    one_parser = subparsers.add_parser('one', help='Transform a single file')
    one_parser.add_argument('file_id', help='File ID (e.g., nc_ds_001)')
    one_parser.add_argument('--split', '-p', default=DEFAULT_SPLIT, choices=SPLIT_PATTERNS,
                           help='Split pattern (default: internal_external)')
    one_parser.add_argument('--source', '-s', default='nocomments', choices=SOURCES,
                           help='Source dataset')
    one_parser.add_argument('--function', '-f', default=None,
                           help='Specific function to split')

    # transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts from source')
    all_parser.add_argument('--split', '-p', default=DEFAULT_SPLIT, choices=SPLIT_PATTERNS,
                           help='Split pattern (default: internal_external)')
    all_parser.add_argument('--source', '-s', default='nocomments', choices=SOURCES,
                           help='Source dataset')
    all_parser.add_argument('--function', '-f', default=None,
                           help='Specific function to target')

    # transform code from stdin
    code_parser = subparsers.add_parser('code', help='Transform code from stdin')
    code_parser.add_argument('--split', '-p', default=DEFAULT_SPLIT, choices=SPLIT_PATTERNS,
                            help='Split pattern (default: internal_external)')
    code_parser.add_argument('--function', '-f', default=None,
                            help='Specific function to split')

    args = parser.parse_args()

    if args.command == 'one':
        result = transform_one(
            args.file_id,
            args.split,
            args.source,
            args.function
        )
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.hydra_id}")
            if result.split_details:
                print(f"Function split: {result.split_details.original_function}")
                print(f"Helpers created: {', '.join(h.name for h in result.split_details.helpers)}")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'all':
        print(f"Transforming all contracts from {args.source} using {args.split} split...")
        report = transform_all(args.split, args.source, args.function)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")

    elif args.command == 'code':
        import sys
        code = sys.stdin.read()
        transformed, split_result = transform_code(code, args.split, args.function)
        print(transformed)

        if split_result:
            print("\n--- Transformation Summary ---", file=sys.stderr)
            print(f"Function split: {split_result.original_function}", file=sys.stderr)
            print(f"Helpers: {', '.join(h.name for h in split_result.helpers)}", file=sys.stderr)

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
