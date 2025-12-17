"""
Guardian Shield Strategy (C1) - Protection Injection

Injects protection mechanisms that neutralize vulnerabilities while keeping
the vulnerable-looking code pattern. Tests whether models recognize that
protections are in place.

CRITICAL: This strategy CHANGES vulnerability status (true -> false)

Protection Types:
- reentrancy_guard: Import + inheritance + nonReentrant modifier
- cei_pattern: Reorder statements to Checks-Effects-Interactions
- access_control: Add owner checks and modifiers
- solidity_0_8: Update pragma for built-in overflow protection

Output naming: gs_{protection}_{source_id} (e.g., gs_reentrancy_guard_sn_ds_001)
"""

import re
import json
from pathlib import Path
from typing import Optional, Dict, List, Tuple, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import shared utilities
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from strategies.common import (
    parse,
    find_first,
    find_all,
    find_function_by_name,
    get_all_functions,
    get_contract_info,
    get_node_text,
    walk_tree,
    get_statements,
    categorize_statement,
    find_import_insertion_point,
    apply_edits,
    check_syntax,
)


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"
GUARDIANSHIELD_DIR = DATA_DIR / "guardian"  # Part of combined Guardian strategy

# Valid protection types
VALID_PROTECTIONS = ['reentrancy_guard', 'cei_pattern', 'access_control', 'solidity_0_8']

# Protection -> Vulnerability type mapping
PROTECTION_TARGETS = {
    'reentrancy_guard': ['reentrancy', 'cross_function_reentrancy'],
    'cei_pattern': ['reentrancy'],
    'access_control': ['access_control', 'unauthorized_access', 'missing_access_control'],
    'solidity_0_8': ['integer_overflow', 'integer_underflow', 'arithmetic'],
}


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class TransformResult:
    """Result of a single transformation."""
    original_id: str
    transformed_id: str
    protection_type: str
    success: bool
    original_vulnerable: bool = True
    transformed_vulnerable: bool = False
    injection_details: Dict[str, Any] = field(default_factory=dict)
    error: Optional[str] = None


@dataclass
class TransformReport:
    """Report for batch transformation."""
    timestamp: str
    protection_type: str
    source_dataset: str
    total_files: int
    successful: int
    failed: int
    results: List[TransformResult] = field(default_factory=list)

    def to_dict(self):
        return {
            'timestamp': self.timestamp,
            'protection_type': self.protection_type,
            'source_dataset': self.source_dataset,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [asdict(r) for r in self.results]
        }


# =============================================================================
# PROTECTION INJECTORS
# =============================================================================

class ReentrancyGuardInjector:
    """
    Inject OpenZeppelin ReentrancyGuard to neutralize reentrancy.

    Adds:
    1. Import statement
    2. Contract inheritance
    3. nonReentrant modifier to vulnerable functions
    """

    IMPORT_STATEMENT = 'import "@openzeppelin/contracts/security/ReentrancyGuard.sol";'
    INHERITANCE_NAME = "ReentrancyGuard"
    MODIFIER_NAME = "nonReentrant"

    def inject(
        self,
        source: str,
        vulnerable_functions: List[str] = None
    ) -> Tuple[str, Dict[str, Any]]:
        """
        Inject ReentrancyGuard protection.

        Args:
            source: Original source code
            vulnerable_functions: Functions to protect (default: withdraw, call, send)
        """
        if vulnerable_functions is None:
            vulnerable_functions = self._detect_vulnerable_functions(source)

        tree = parse(source)
        details = {
            'import_added': False,
            'inheritance_added': False,
            'functions_protected': []
        }

        edits = []

        # Step 1: Add import after pragma/existing imports
        import_pos = find_import_insertion_point(tree, source)
        edits.append({
            'type': 'insert',
            'position': import_pos,
            'text': f'\n{self.IMPORT_STATEMENT}\n'
        })
        details['import_added'] = True

        # Step 2: Add inheritance
        contract_info = get_contract_info(tree, source)
        if contract_info:
            inherit_edit = self._create_inheritance_edit(contract_info, source)
            if inherit_edit:
                edits.append(inherit_edit)
                details['inheritance_added'] = True

        # Step 3: Add modifier to vulnerable functions
        for func_name in vulnerable_functions:
            func_info = find_function_by_name(tree, func_name, source)
            if func_info:
                modifier_edit = self._create_modifier_edit(func_info, source)
                if modifier_edit:
                    edits.append(modifier_edit)
                    details['functions_protected'].append(func_name)

        # Apply edits
        result = apply_edits(source, edits)

        return result, details

    def _detect_vulnerable_functions(self, source: str) -> List[str]:
        """Detect functions that might need reentrancy protection."""
        tree = parse(source)
        vulnerable = []

        for func_info in get_all_functions(tree, source):
            func_text = source[func_info.start_byte:func_info.end_byte]

            # Look for external calls
            if any(pattern in func_text for pattern in ['.call', '.transfer', '.send']):
                if func_info.name and func_info.name not in vulnerable:
                    vulnerable.append(func_info.name)

        return vulnerable if vulnerable else ['withdraw']

    def _create_inheritance_edit(self, contract_info, source: str) -> Optional[Dict]:
        """Create edit to add ReentrancyGuard inheritance."""
        # Check if already has inheritance
        if contract_info.inheritance:
            # Add to existing inheritance list
            # Find the opening brace of the contract body
            return {
                'type': 'insert',
                'position': contract_info.body_start,
                'text': f', {self.INHERITANCE_NAME} '
            }
        else:
            # No existing inheritance, add "is ReentrancyGuard"
            # Insert before the opening brace
            brace_pos = source.find('{', contract_info.start_byte)
            if brace_pos > 0:
                return {
                    'type': 'insert',
                    'position': brace_pos,
                    'text': f' is {self.INHERITANCE_NAME} '
                }

        return None

    def _create_modifier_edit(self, func_info, source: str) -> Optional[Dict]:
        """Add nonReentrant modifier to function."""
        # Check if already has nonReentrant
        if self.MODIFIER_NAME in func_info.modifiers:
            return None

        # Insert modifier before opening brace
        return {
            'type': 'insert',
            'position': func_info.body_start,
            'text': f'{self.MODIFIER_NAME} '
        }


class CEIPatternFixer:
    """
    Fix reentrancy by reordering to Checks-Effects-Interactions pattern.

    Moves state updates before external calls.
    """

    def fix(
        self,
        source: str,
        function_name: str = None,
        state_variable: str = None
    ) -> Tuple[str, Dict[str, Any]]:
        """
        Reorder statements in function to CEI pattern.
        """
        tree = parse(source)
        details = {
            'reordered': False,
            'function': function_name,
            'reason': ''
        }

        # Auto-detect function if not specified
        if not function_name:
            function_name = self._detect_vulnerable_function(tree, source)

        if not function_name:
            details['reason'] = 'No vulnerable function found'
            return source, details

        func_info = find_function_by_name(tree, function_name, source)
        if not func_info:
            details['reason'] = f'Function {function_name} not found'
            return source, details

        # Get function body content
        body_start = func_info.body_start + 1  # Skip opening brace
        body_end = func_info.body_end - 1  # Skip closing brace
        body_text = source[body_start:body_end]

        # Find external call and state update positions
        call_match = re.search(r'(.*?\.call\{[^}]*\}\([^)]*\)[^;]*;)', body_text, re.DOTALL)
        if not call_match:
            call_match = re.search(r'(.*?\.(transfer|send)\([^)]*\)[^;]*;)', body_text, re.DOTALL)

        if not call_match:
            details['reason'] = 'No external call found'
            return source, details

        # Find state update after the call
        call_end = call_match.end()
        after_call = body_text[call_end:]

        # Look for state variable updates (x -= y, x = y, etc.)
        state_pattern = r'(\s*\w+\[[^\]]+\]\s*[-+*/]?=\s*[^;]+;)'
        state_match = re.search(state_pattern, after_call)

        if not state_match:
            details['reason'] = 'No state update after call found'
            return source, details

        # Extract the state update statement
        state_stmt = state_match.group(1).strip()

        # Build reordered body
        # 1. Everything before the call
        before_call = body_text[:call_match.start()]
        # 2. The external call
        call_stmt = call_match.group(1)
        # 3. Everything after state update
        remaining = after_call[state_match.end():]

        # Insert state update before external call
        new_body = before_call + state_stmt + '\n        ' + call_stmt + remaining

        # Replace function body
        result = source[:body_start] + new_body + source[body_end:]

        details['reordered'] = True
        details['moved_statement'] = state_stmt[:50] + '...' if len(state_stmt) > 50 else state_stmt

        return result, details

    def _detect_vulnerable_function(self, tree, source: str) -> Optional[str]:
        """Detect function with CEI violation."""
        for func_info in get_all_functions(tree, source):
            func_text = source[func_info.start_byte:func_info.end_byte]

            # Look for external call followed by state update
            if re.search(r'\.call\{[^}]*\}.*\w+\[[^\]]+\]\s*[-+*/]?=', func_text, re.DOTALL):
                return func_info.name

        return None


class AccessControlInjector:
    """
    Inject access control to restrict function access.
    """

    def inject(
        self,
        source: str,
        functions: List[str] = None
    ) -> Tuple[str, Dict[str, Any]]:
        """
        Add owner-only restriction to specified functions.

        Adds:
        1. State variable: address public owner;
        2. Constructor: owner = msg.sender;
        3. Modifier: modifier onlyOwner()
        4. Modifier usage on functions
        """
        tree = parse(source)
        details = {
            'state_var_added': False,
            'constructor_modified': False,
            'modifier_added': False,
            'functions_protected': []
        }

        # Auto-detect functions if not specified
        if not functions:
            functions = self._detect_admin_functions(tree, source)

        edits = []
        contract_info = get_contract_info(tree, source)

        if not contract_info:
            return source, {'error': 'No contract found'}

        # Check if owner already exists
        if 'owner' not in source:
            # Add state variable at start of contract body
            edits.append({
                'type': 'insert',
                'position': contract_info.body_start + 1,
                'text': '\n    address public owner;\n'
            })
            details['state_var_added'] = True

        # Check if constructor exists
        constructor_found = False
        for func_info in get_all_functions(tree, source):
            if func_info.name == '' or 'constructor' in source[func_info.start_byte:func_info.start_byte + 20]:
                constructor_found = True
                # Add owner assignment to existing constructor
                edits.append({
                    'type': 'insert',
                    'position': func_info.body_start + 1,
                    'text': '\n        owner = msg.sender;'
                })
                details['constructor_modified'] = True
                break

        if not constructor_found:
            # Add new constructor
            edits.append({
                'type': 'insert',
                'position': contract_info.body_start + 1,
                'text': '''
    constructor() {
        owner = msg.sender;
    }
'''
            })
            details['constructor_modified'] = True

        # Add onlyOwner modifier if not exists
        if 'onlyOwner' not in source:
            edits.append({
                'type': 'insert',
                'position': contract_info.body_end - 1,
                'text': '''
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
'''
            })
            details['modifier_added'] = True

        # Add modifier to functions
        for func_name in functions:
            func_info = find_function_by_name(tree, func_name, source)
            if func_info and 'onlyOwner' not in func_info.modifiers:
                edits.append({
                    'type': 'insert',
                    'position': func_info.body_start,
                    'text': 'onlyOwner '
                })
                details['functions_protected'].append(func_name)

        result = apply_edits(source, edits)

        return result, details

    def _detect_admin_functions(self, tree, source: str) -> List[str]:
        """Detect functions that should have access control."""
        admin_keywords = ['admin', 'owner', 'set', 'update', 'change', 'modify', 'pause', 'unpause']
        admin_functions = []

        for func_info in get_all_functions(tree, source):
            if func_info.name:
                name_lower = func_info.name.lower()
                if any(kw in name_lower for kw in admin_keywords):
                    admin_functions.append(func_info.name)

        return admin_functions if admin_functions else []


class SolidityVersionUpdater:
    """
    Update Solidity version to 0.8+ for built-in overflow protection.
    """

    def update(self, source: str) -> Tuple[str, Dict[str, Any]]:
        """
        Update pragma to 0.8+ and remove SafeMath usage.
        """
        details = {
            'pragma_updated': False,
            'safemath_removed': False,
            'operators_replaced': 0
        }

        result = source

        # Update pragma
        pragma_pattern = r'pragma\s+solidity\s+[\^~]?0\.[0-7]\.\d+;'
        if re.search(pragma_pattern, result):
            result = re.sub(pragma_pattern, 'pragma solidity ^0.8.19;', result)
            details['pragma_updated'] = True

        # Remove SafeMath import
        safemath_import = r'import\s+["\']@openzeppelin/contracts/utils/math/SafeMath\.sol["\'];?\n?'
        if re.search(safemath_import, result):
            result = re.sub(safemath_import, '', result)
            details['safemath_removed'] = True

        # Remove legacy SafeMath import patterns
        safemath_import2 = r'import\s+["\'].*SafeMath.*["\'];?\n?'
        result = re.sub(safemath_import2, '', result)

        # Remove 'using SafeMath for uint256'
        using_safemath = r'using\s+SafeMath\s+for\s+uint\d*;\s*\n?'
        result = re.sub(using_safemath, '', result)

        # Replace SafeMath calls with operators
        replacements = [
            (r'\.add\(([^)]+)\)', r' + \1'),
            (r'\.sub\(([^)]+)\)', r' - \1'),
            (r'\.mul\(([^)]+)\)', r' * \1'),
            (r'\.div\(([^)]+)\)', r' / \1'),
            (r'\.mod\(([^)]+)\)', r' % \1'),
        ]

        for pattern, replacement in replacements:
            matches = re.findall(pattern, result)
            details['operators_replaced'] += len(matches)
            result = re.sub(pattern, replacement, result)

        return result, details


# =============================================================================
# MAIN TRANSFORMER
# =============================================================================

class GuardianShieldTransformer:
    """Orchestrate protection injection based on type."""

    def __init__(self):
        self.reentrancy_guard = ReentrancyGuardInjector()
        self.cei_fixer = CEIPatternFixer()
        self.access_control = AccessControlInjector()
        self.version_updater = SolidityVersionUpdater()

    def transform(
        self,
        source: str,
        protection_type: str,
        **kwargs
    ) -> Tuple[str, Dict[str, Any]]:
        """
        Apply specified protection.

        Args:
            source: Original source code
            protection_type: Type of protection to apply
            **kwargs: Protection-specific arguments
        """
        if protection_type == 'reentrancy_guard':
            result, details = self.reentrancy_guard.inject(
                source,
                vulnerable_functions=kwargs.get('functions')
            )

        elif protection_type == 'cei_pattern':
            result, details = self.cei_fixer.fix(
                source,
                function_name=kwargs.get('function_name'),
                state_variable=kwargs.get('state_variable')
            )

        elif protection_type == 'access_control':
            result, details = self.access_control.inject(
                source,
                functions=kwargs.get('functions')
            )

        elif protection_type == 'solidity_0_8':
            result, details = self.version_updater.update(source)

        else:
            raise ValueError(f"Unknown protection type: {protection_type}")

        details['protection_type'] = protection_type

        return result, details


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _ensure_output_dirs(protection_type: str, source_dataset: str):
    """Ensure output directories exist."""
    out_dir = GUARDIANSHIELD_DIR / f"{protection_type}_{source_dataset[:2]}"
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


def _get_gs_id(source_id: str, protection_type: str) -> str:
    """Generate Guardian Shield file ID."""
    return f"gs_{protection_type}_{source_id}"


def transform_one(
    source_id: str,
    protection_type: str,
    source_dataset: str = 'sanitized',
    save: bool = True,
    **kwargs
) -> TransformResult:
    """
    Transform a single file with the specified protection.

    Args:
        source_id: Source file ID
        protection_type: Protection to apply
        source_dataset: Which dataset to read from
        save: Whether to save the result
        **kwargs: Protection-specific arguments
    """
    if protection_type not in VALID_PROTECTIONS:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            protection_type=protection_type,
            success=False,
            error=f"Invalid protection: {protection_type}. Valid: {VALID_PROTECTIONS}"
        )

    source_path = _get_source_path(source_id, source_dataset)
    if not source_path:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            protection_type=protection_type,
            success=False,
            error=f"Source file not found: {source_id}"
        )

    try:
        source = source_path.read_text()

        # Transform
        transformer = GuardianShieldTransformer()
        transformed, details = transformer.transform(source, protection_type, **kwargs)

        # Validate syntax
        is_valid, errors = check_syntax(transformed)
        if not is_valid:
            return TransformResult(
                original_id=source_id,
                transformed_id='',
                protection_type=protection_type,
                success=False,
                error=f"Syntax errors: {errors[:3]}"
            )

        gs_id = _get_gs_id(source_id, protection_type)

        if save:
            _ensure_output_dirs(protection_type, source_dataset)
            out_dir = GUARDIANSHIELD_DIR / f"{protection_type}_{source_dataset[:2]}"

            # Save transformed contract
            output_path = out_dir / 'contracts' / f"{gs_id}{source_path.suffix}"
            output_path.write_text(transformed)

            # Load and update metadata
            meta_path = _get_metadata_path(source_id, source_dataset)
            if meta_path:
                metadata = json.loads(meta_path.read_text())
            else:
                metadata = {'id': source_id}

            # IMPORTANT: Update ground truth - vulnerability is neutralized!
            original_ground_truth = metadata.get('ground_truth', {})
            original_vulnerable = original_ground_truth.get('is_vulnerable', True)

            metadata['id'] = gs_id
            metadata['contract_file'] = f"contracts/{gs_id}{source_path.suffix}"
            metadata['derived_from'] = source_id
            metadata['subset'] = 'guardianshield'
            metadata['transformation'] = {
                'strategy': 'guardian_shield',
                'protection_type': protection_type,
                'injection_details': details
            }

            # Update ground truth
            metadata['ground_truth'] = {
                'is_vulnerable': False,  # Protection neutralizes vulnerability
                'original_vulnerable': original_vulnerable,
                'vulnerability_type': original_ground_truth.get('vulnerability_type', 'unknown'),
                'neutralized_by': protection_type,
                'neutralization_reason': _get_neutralization_reason(protection_type)
            }

            # Save metadata
            meta_output = out_dir / 'metadata' / f"{gs_id}.json"
            meta_output.write_text(json.dumps(metadata, indent=2))

        return TransformResult(
            original_id=source_id,
            transformed_id=gs_id,
            protection_type=protection_type,
            success=True,
            original_vulnerable=True,
            transformed_vulnerable=False,
            injection_details=details
        )

    except Exception as e:
        return TransformResult(
            original_id=source_id,
            transformed_id='',
            protection_type=protection_type,
            success=False,
            error=str(e)
        )


def _get_neutralization_reason(protection_type: str) -> str:
    """Get explanation of how protection neutralizes vulnerability."""
    reasons = {
        'reentrancy_guard': 'Mutex lock prevents recursive calls during execution',
        'cei_pattern': 'State updates before external calls prevent reentrancy',
        'access_control': 'Only authorized addresses can call protected functions',
        'solidity_0_8': 'Built-in overflow/underflow checks prevent arithmetic vulnerabilities'
    }
    return reasons.get(protection_type, 'Protection mechanism neutralizes vulnerability')


def transform_all(
    protection_type: str,
    source_dataset: str = 'sanitized'
) -> TransformReport:
    """Transform all contracts with specified protection."""
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
        result = transform_one(source_id, protection_type, source_dataset, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    report = TransformReport(
        timestamp=datetime.now().isoformat(),
        protection_type=protection_type,
        source_dataset=source_dataset,
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )

    # Save report
    _ensure_output_dirs(protection_type, source_dataset)
    out_dir = GUARDIANSHIELD_DIR / f"{protection_type}_{source_dataset[:2]}"
    report_path = out_dir / "transformation_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    # Generate index
    _generate_index(protection_type, source_dataset)

    return report


def _generate_index(protection_type: str, source_dataset: str):
    """Generate index.json for a guardian shield dataset."""
    out_dir = GUARDIANSHIELD_DIR / f"{protection_type}_{source_dataset[:2]}"
    metadata_dir = out_dir / 'metadata'

    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'originally_vulnerable': 0,
        'now_protected': 0,
        'by_original_vulnerability': {},
    }

    for meta_file in sorted(metadata_dir.glob('*.json')):
        try:
            metadata = json.loads(meta_file.read_text())
            sample = {
                'id': metadata.get('id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
                'derived_from': metadata.get('derived_from'),
            }

            ground_truth = metadata.get('ground_truth', {})
            sample['is_vulnerable'] = ground_truth.get('is_vulnerable', False)
            sample['original_vulnerable'] = ground_truth.get('original_vulnerable', True)
            sample['vulnerability_type'] = ground_truth.get('vulnerability_type', 'unknown')
            sample['neutralized_by'] = ground_truth.get('neutralized_by', protection_type)

            samples.append(sample)

            stats['total_samples'] += 1
            if sample['original_vulnerable']:
                stats['originally_vulnerable'] += 1
            if not sample['is_vulnerable']:
                stats['now_protected'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_original_vulnerability'][vuln_type] = \
                stats['by_original_vulnerability'].get(vuln_type, 0) + 1

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")

    index = {
        'dataset_name': f'guardianshield_{protection_type}',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'description': f'Contracts protected with {protection_type}. '
                       'Original vulnerabilities have been neutralized.',
        'transformation': {
            'strategy': 'guardian_shield',
            'protection_type': protection_type,
            'changes_vulnerability_status': True,
            'original_vulnerable': True,
            'transformed_vulnerable': False
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = out_dir / 'index.json'
    index_path.write_text(json.dumps(index, indent=2))


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for Guardian Shield strategy."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Guardian Shield Strategy - Protection Injection'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Transform all
    all_parser = subparsers.add_parser('all', help='Transform all contracts')
    all_parser.add_argument('--protection', required=True, choices=VALID_PROTECTIONS,
                           help='Protection type')
    all_parser.add_argument('--source', default='sanitized',
                           choices=['sanitized', 'nocomments'],
                           help='Source dataset')

    # Transform one
    one_parser = subparsers.add_parser('one', help='Transform single contract')
    one_parser.add_argument('file_id', help='Source file ID')
    one_parser.add_argument('--protection', required=True, choices=VALID_PROTECTIONS,
                           help='Protection type')
    one_parser.add_argument('--source', default='sanitized',
                           choices=['sanitized', 'nocomments'],
                           help='Source dataset')

    # Preview
    preview_parser = subparsers.add_parser('preview', help='Preview transformation')
    preview_parser.add_argument('file_id', help='Source file ID')
    preview_parser.add_argument('--protection', required=True, choices=VALID_PROTECTIONS,
                               help='Protection type')
    preview_parser.add_argument('--source', default='sanitized',
                               choices=['sanitized', 'nocomments'],
                               help='Source dataset')

    # List protections
    subparsers.add_parser('protections', help='List available protections')

    args = parser.parse_args()

    if args.command == 'all':
        print(f"Applying '{args.protection}' protection to all contracts...")
        report = transform_all(args.protection, args.source)
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")

        if report.failed > 0:
            print(f"\nFailed files ({report.failed}):")
            for r in report.results[:10]:
                if not r.success:
                    print(f"  {r.original_id}: {r.error}")

    elif args.command == 'one':
        result = transform_one(args.file_id, args.protection, args.source)
        if result.success:
            print(f"Transformed: {result.original_id} -> {result.transformed_id}")
            print(f"Protection: {result.protection_type}")
            print(f"Vulnerability status: {result.original_vulnerable} -> {result.transformed_vulnerable}")
            print(f"Injection details: {result.injection_details}")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'preview':
        source_path = _get_source_path(args.file_id, args.source)
        if source_path:
            source = source_path.read_text()
            transformer = GuardianShieldTransformer()
            transformed, details = transformer.transform(source, args.protection)

            print(f"Preview for {args.file_id} (protection: {args.protection}):")
            print(f"  Details: {details}")
            print("\n--- Transformed Code (first 2000 chars) ---")
            print(transformed[:2000])
            if len(transformed) > 2000:
                print(f"\n... ({len(transformed) - 2000} more chars)")
        else:
            print(f"Error: Source file not found: {args.file_id}")

    elif args.command == 'protections':
        print("Available protections:")
        for prot in VALID_PROTECTIONS:
            targets = PROTECTION_TARGETS.get(prot, [])
            print(f"  - {prot}: targets {', '.join(targets)}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
