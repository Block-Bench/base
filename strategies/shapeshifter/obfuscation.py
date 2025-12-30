"""
L2-L4 Obfuscation Modes for Shapeshifter Strategy

L2: Identifier obfuscation (variables, functions renamed to hex/obscure names)
L3: Control flow obfuscation (unnecessary conditionals, loop transforms)
L4: Structural obfuscation (dead code injection, function extraction)
"""

import re
import random
import string
from pathlib import Path
from typing import Tuple, Dict, Any, List, Set, Optional
from dataclasses import dataclass, field

import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from strategies.common import (
    parse,
    get_node_text,
    walk_tree,
)

# =============================================================================
# CONFIGURATION
# =============================================================================

# Solidity reserved keywords (cannot be used as identifiers)
SOLIDITY_KEYWORDS = {
    'abstract', 'after', 'alias', 'apply', 'auto', 'case', 'catch', 'copyof',
    'default', 'define', 'final', 'immutable', 'implements', 'in', 'inline',
    'let', 'macro', 'match', 'mutable', 'null', 'of', 'override', 'partial',
    'promise', 'reference', 'relocatable', 'sealed', 'sizeof', 'static',
    'supports', 'switch', 'try', 'typedef', 'typeof', 'unchecked', 'contract',
    'function', 'modifier', 'event', 'struct', 'enum', 'mapping', 'address',
    'bool', 'string', 'bytes', 'int', 'uint', 'fixed', 'ufixed', 'public',
    'private', 'internal', 'external', 'pure', 'view', 'payable', 'constant',
    'indexed', 'anonymous', 'virtual', 'returns', 'return', 'if', 'else',
    'for', 'while', 'do', 'break', 'continue', 'throw', 'emit', 'revert',
    'require', 'assert', 'new', 'delete', 'this', 'super', 'selfdestruct',
    'suicide', 'pragma', 'import', 'using', 'is', 'library', 'interface',
    'assembly', 'memory', 'storage', 'calldata', 'true', 'false', 'wei',
    'gwei', 'ether', 'seconds', 'minutes', 'hours', 'days', 'weeks', 'years',
    'msg', 'block', 'tx', 'abi', 'type', 'constructor', 'receive', 'fallback',
    'from', 'as', 'error', 'global', 'var',  # Additional keywords
    # Global object properties (msg.sender, block.timestamp, etc.)
    'sender', 'value', 'data', 'sig', 'origin', 'gasprice',  # msg/tx properties
    'timestamp', 'number', 'difficulty', 'gaslimit', 'coinbase', 'basefee', 'chainid',  # block properties
    'gas', 'blockhash', 'prevrandao', 'blobbasefee',  # More block/global
    'length', 'push', 'pop', 'concat', 'selector',  # Array/bytes properties
    'balance', 'code', 'codehash', 'transfer', 'send', 'call', 'delegatecall', 'staticcall',  # address members
    # Built-in cryptographic and math functions
    'keccak256', 'sha256', 'sha3', 'ripemd160', 'ecrecover',
    'addmod', 'mulmod',
    # ABI encoding functions
    'encode', 'encodePacked', 'encodeWithSelector', 'encodeWithSignature', 'encodeCall', 'decode',
}

# Common type names that shouldn't be obfuscated
BUILTIN_TYPES = {
    'uint8', 'uint16', 'uint32', 'uint64', 'uint128', 'uint256', 'uint',
    'int8', 'int16', 'int32', 'int64', 'int128', 'int256', 'int',
    'bytes1', 'bytes2', 'bytes4', 'bytes8', 'bytes16', 'bytes32', 'bytes',
    'address', 'bool', 'string', 'mapping', 'array',
}

# Standard interfaces/contracts that shouldn't be renamed
STANDARD_NAMES = {
    'IERC20', 'IERC721', 'IERC1155', 'IERC165', 'ERC20', 'ERC721', 'ERC1155',
    'Ownable', 'ReentrancyGuard', 'SafeMath', 'SafeERC20', 'Address',
    'Context', 'Pausable', 'AccessControl', 'Initializable',
}


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class ObfuscationResult:
    """Result of obfuscation transformation."""
    success: bool
    code: str = ""
    level: int = 2
    rename_map: Dict[str, str] = field(default_factory=dict)
    changes_made: List[str] = field(default_factory=list)
    error: Optional[str] = None


# =============================================================================
# L2: IDENTIFIER OBFUSCATION
# =============================================================================

class IdentifierObfuscator:
    """
    L2 Obfuscation - Rename identifiers to obscure names.

    Preserves:
    - Solidity keywords
    - Built-in types
    - Standard interface names
    - External calls (msg.sender, block.timestamp, etc.)
    """

    def __init__(self, style: str = 'hex', seed: Optional[int] = None):
        """
        Initialize obfuscator.

        Args:
            style: Naming style ('hex', 'short', 'underscore')
            seed: Random seed for reproducibility
        """
        self.style = style
        self.rename_map: Dict[str, str] = {}
        self.counter = 0

        if seed is not None:
            random.seed(seed)

    def _generate_name(self, original: str) -> str:
        """Generate obfuscated name based on style."""
        self.counter += 1

        if self.style == 'hex':
            # _0x1a2b3c style
            hex_part = format(random.randint(0, 0xFFFFFF), '06x')
            return f"_0x{hex_part}"
        elif self.style == 'short':
            # a, b, c, ... aa, ab, ...
            return self._index_to_name(self.counter)
        elif self.style == 'underscore':
            # _v1, _v2, _f1, etc.
            prefix = '_v' if original[0].islower() else '_T'
            return f"{prefix}{self.counter}"
        else:
            return f"_var{self.counter}"

    def _index_to_name(self, index: int) -> str:
        """Convert index to short variable name (a-z, aa-zz, etc.)."""
        result = ""
        while index > 0:
            index -= 1
            result = chr(ord('a') + (index % 26)) + result
            index //= 26
        return result or 'a'

    def _should_obfuscate(self, name: str) -> bool:
        """Check if identifier should be obfuscated."""
        # Skip keywords
        if name.lower() in SOLIDITY_KEYWORDS:
            return False
        # Skip built-in types
        if name in BUILTIN_TYPES:
            return False
        # Skip standard names
        if name in STANDARD_NAMES:
            return False
        # Skip very short names (likely special)
        if len(name) <= 1:
            return False
        # Skip names starting with _ (often special)
        if name.startswith('__'):
            return False
        # Skip interface names (start with I + capital)
        if len(name) > 1 and name[0] == 'I' and name[1].isupper():
            return False
        # Skip names starting with capital (likely contract/struct/event names)
        if name[0].isupper():
            return False
        # Skip common error/event prefixes
        if name.endswith('Error') or name.endswith('Event'):
            return False
        # Skip common library names
        if name.endswith('Library') or name.endswith('Utils'):
            return False
        return True

    def _extract_identifiers(self, source: str) -> Set[str]:
        """Extract all user-defined identifiers from source."""
        identifiers = set()

        # Parse the source
        tree = parse(source)
        if not tree:
            return identifiers

        # Walk the tree looking for identifiers
        for node in walk_tree(tree.root_node):
            if node.type == 'identifier':
                name = get_node_text(node, source)
                if self._should_obfuscate(name):
                    identifiers.add(name)

        return identifiers

    def obfuscate(self, source: str) -> Tuple[str, Dict[str, str]]:
        """
        Obfuscate all identifiers in source code.

        Returns:
            Tuple of (obfuscated_code, rename_map)
        """
        # Extract identifiers
        identifiers = self._extract_identifiers(source)

        # Sort by length (longest first) to avoid partial replacements
        sorted_ids = sorted(identifiers, key=len, reverse=True)

        # Generate rename map
        self.rename_map = {}
        for ident in sorted_ids:
            if ident not in self.rename_map:
                self.rename_map[ident] = self._generate_name(ident)

        # Protect string literals and comments from replacement
        protected = []
        placeholder_idx = [0]

        def protect_match(match):
            protected.append(match.group(0))
            placeholder = f"__PROTECTED_{placeholder_idx[0]}__"
            placeholder_idx[0] += 1
            return placeholder

        # Protect comments and strings - ORDER MATTERS
        result = source
        # Match multi-line comments FIRST
        result = re.sub(r'/\*[\s\S]*?\*/', protect_match, result)
        # Match single-line comments SECOND
        result = re.sub(r'//[^\n]*', protect_match, result)
        # Match double-quoted strings
        result = re.sub(r'"[^"\\]*(?:\\.[^"\\]*)*"', protect_match, result)
        # Match single-quoted strings (char literals) - only match valid char literals
        result = re.sub(r"'[^'\\]'|'\\.'", protect_match, result)

        # Apply replacements
        for original, replacement in self.rename_map.items():
            # Use word boundary matching to avoid partial replacements
            pattern = r'\b' + re.escape(original) + r'\b'
            result = re.sub(pattern, replacement, result)

        # Restore protected content
        for i, content in enumerate(protected):
            result = result.replace(f"__PROTECTED_{i}__", content)

        return result, self.rename_map


def apply_l2_obfuscation(source: str, style: str = 'hex', seed: int = None) -> ObfuscationResult:
    """Apply L2 identifier obfuscation."""
    try:
        obfuscator = IdentifierObfuscator(style=style, seed=seed)
        code, rename_map = obfuscator.obfuscate(source)

        return ObfuscationResult(
            success=True,
            code=code,
            level=2,
            rename_map=rename_map,
            changes_made=[f"Renamed {len(rename_map)} identifiers using {style} style"]
        )
    except Exception as e:
        return ObfuscationResult(
            success=False,
            level=2,
            error=str(e)
        )


# =============================================================================
# L3: CONTROL FLOW OBFUSCATION
# =============================================================================

class ControlFlowObfuscator:
    """
    L3 Obfuscation - Add control flow complexity.

    Techniques:
    - Wrap expressions in always-true conditionals
    - Convert if-else to ternary and back
    - Add redundant loop iterations
    """

    def __init__(self, intensity: str = 'medium', seed: Optional[int] = None):
        """
        Initialize obfuscator.

        Args:
            intensity: How much obfuscation ('low', 'medium', 'high')
            seed: Random seed for reproducibility
        """
        self.intensity = intensity
        if seed is not None:
            random.seed(seed)

        # Probability of applying each technique
        self.probs = {
            'low': 0.1,
            'medium': 0.3,
            'high': 0.5
        }.get(intensity, 0.3)

    def _wrap_in_conditional(self, statement: str) -> str:
        """Wrap a statement in an always-true conditional."""
        # Various always-true conditions
        true_conditions = [
            'true',
            '1 == 1',
            'block.timestamp > 0',
            'msg.sender != address(0) || msg.sender == address(0)',
            'gasleft() > 0',
        ]
        condition = random.choice(true_conditions)

        # Wrap the statement
        return f"if ({condition}) {{ {statement} }}"

    def _add_dead_branch(self, if_statement: str) -> str:
        """Add a dead else branch to an if statement."""
        # Check if already has else
        if ' else ' in if_statement:
            return if_statement

        # Find the end of the if block
        # This is simplified - real implementation would use AST
        brace_count = 0
        end_idx = -1
        in_block = False

        for i, char in enumerate(if_statement):
            if char == '{':
                in_block = True
                brace_count += 1
            elif char == '}':
                brace_count -= 1
                if brace_count == 0 and in_block:
                    end_idx = i
                    break

        if end_idx > 0:
            dead_code = "else { /* dead branch */ }"
            return if_statement[:end_idx+1] + f" {dead_code}" + if_statement[end_idx+1:]

        return if_statement

    def obfuscate(self, source: str) -> Tuple[str, List[str]]:
        """
        Apply control flow obfuscation.

        Returns:
            Tuple of (obfuscated_code, changes_made)
        """
        changes = []
        result = source

        # Find simple assignment statements inside functions
        # ONLY wrap local variable assignments (not state variables, constants, etc.)
        # Pattern: indented simple assignment without type keywords
        lines = result.split('\n')
        new_lines = []
        in_function = False
        brace_depth = 0

        for line in lines:
            stripped = line.strip()

            # Track function context
            if re.match(r'\s*function\s+', line) or re.match(r'\s*constructor\s*\(', line):
                in_function = True

            # Track brace depth
            brace_depth += line.count('{') - line.count('}')

            # Reset function context when we exit to contract level
            if brace_depth <= 1:
                in_function = False

            # Only process inside functions (depth > 1)
            if in_function and brace_depth > 1:
                # Check if it's a simple local assignment (no type declaration)
                # Pattern: identifier = value; (without type keywords at start)
                if re.match(r'^\s+\w+\s*=\s*[^;]+;\s*$', line):
                    # Make sure it's NOT a state var or declaration
                    if not re.search(r'\b(uint|int|bool|address|bytes|string|mapping|constant|immutable|public|private|internal|external)\b', line):
                        if random.random() < self.probs:
                            indent = len(line) - len(line.lstrip())
                            indent_str = ' ' * indent
                            statement = stripped
                            wrapped = self._wrap_in_conditional(statement)
                            new_lines.append(f"{indent_str}{wrapped}")
                            changes.append("Wrapped assignment in conditional")
                            continue

            new_lines.append(line)

        return '\n'.join(new_lines), changes


def apply_l3_obfuscation(source: str, intensity: str = 'medium', seed: int = None) -> ObfuscationResult:
    """Apply L3 control flow obfuscation."""
    try:
        obfuscator = ControlFlowObfuscator(intensity=intensity, seed=seed)
        code, changes = obfuscator.obfuscate(source)

        return ObfuscationResult(
            success=True,
            code=code,
            level=3,
            changes_made=changes
        )
    except Exception as e:
        return ObfuscationResult(
            success=False,
            level=3,
            error=str(e)
        )


# =============================================================================
# L4: STRUCTURAL OBFUSCATION
# =============================================================================

class StructuralObfuscator:
    """
    L4 Obfuscation - Modify code structure.

    Techniques:
    - Inject dead code (never executed)
    - Extract expressions into helper functions
    - Add unused variables
    """

    def __init__(self, intensity: str = 'medium', seed: Optional[int] = None):
        """
        Initialize obfuscator.

        Args:
            intensity: How much obfuscation ('low', 'medium', 'high')
            seed: Random seed for reproducibility
        """
        self.intensity = intensity
        if seed is not None:
            random.seed(seed)

        self.helper_counter = 0
        self.var_counter = 0

    def _generate_dead_code(self) -> str:
        """Generate dead code that never executes."""
        self.var_counter += 1

        dead_code_templates = [
            f"uint256 _unused{self.var_counter} = 0;",
            f"bool _flag{self.var_counter} = false;",
            f"if (false) {{ revert(); }}",
            f"// Placeholder for future logic",
        ]

        return random.choice(dead_code_templates)

    def _generate_helper_function(self, name: str, body_type: str = 'identity') -> str:
        """Generate a helper function."""
        self.helper_counter += 1
        func_name = f"_helper{self.helper_counter}"

        if body_type == 'identity':
            return f"""
    function {func_name}(uint256 x) internal pure returns (uint256) {{
        return x;
    }}"""
        elif body_type == 'bool':
            return f"""
    function {func_name}(bool x) internal pure returns (bool) {{
        return x;
    }}"""

        return ""

    def obfuscate(self, source: str) -> Tuple[str, List[str], List[str]]:
        """
        Apply structural obfuscation.

        Returns:
            Tuple of (obfuscated_code, changes_made, helper_functions)
        """
        changes = []
        helpers = []
        result = source

        # Inject dead code after function declarations with implementation
        # Only match functions that have visibility (public/external/internal/private)
        # This avoids interface declarations and abstract functions
        func_pattern = r'(function\s+\w+\s*\([^)]*\)\s+(?:public|external|internal|private)[^{]*\{)'

        inject_count = {'low': 1, 'medium': 2, 'high': 3}.get(self.intensity, 2)
        injected = [0]  # Track how many we've injected

        def inject_dead_code(match):
            if injected[0] >= 2:  # Limit to 2 functions
                return match.group(0)
            func_header = match.group(1)
            dead = '\n        '.join([self._generate_dead_code() for _ in range(inject_count)])
            changes.append("Injected dead code after function start")
            injected[0] += 1
            return f"{func_header}\n        {dead}"

        result = re.sub(func_pattern, inject_dead_code, result)

        return result, changes, helpers


def apply_l4_obfuscation(source: str, intensity: str = 'medium', seed: int = None) -> ObfuscationResult:
    """Apply L4 structural obfuscation."""
    try:
        obfuscator = StructuralObfuscator(intensity=intensity, seed=seed)
        code, changes, helpers = obfuscator.obfuscate(source)

        return ObfuscationResult(
            success=True,
            code=code,
            level=4,
            changes_made=changes
        )
    except Exception as e:
        return ObfuscationResult(
            success=False,
            level=4,
            error=str(e)
        )


# =============================================================================
# COMBINED OBFUSCATION
# =============================================================================

def apply_obfuscation(
    source: str,
    level: int = 2,
    style: str = 'hex',
    intensity: str = 'medium',
    seed: int = None
) -> ObfuscationResult:
    """
    Apply obfuscation at specified level (cumulative).

    L2: Identifier obfuscation only
    L3: L2 + Control flow obfuscation
    L4: L3 + Structural obfuscation

    Args:
        source: Source code to obfuscate
        level: Obfuscation level (2, 3, or 4)
        style: Identifier naming style ('hex', 'short', 'underscore')
        intensity: Obfuscation intensity ('low', 'medium', 'high')
        seed: Random seed for reproducibility

    Returns:
        ObfuscationResult with transformed code
    """
    if level < 2 or level > 4:
        return ObfuscationResult(
            success=False,
            level=level,
            error=f"Invalid level: {level}. Must be 2, 3, or 4"
        )

    result = source
    all_changes = []
    rename_map = {}

    try:
        # L2: Identifier obfuscation
        if level >= 2:
            l2_result = apply_l2_obfuscation(result, style=style, seed=seed)
            if not l2_result.success:
                return l2_result
            result = l2_result.code
            rename_map = l2_result.rename_map
            all_changes.extend(l2_result.changes_made)

        # L3: Control flow obfuscation
        if level >= 3:
            l3_result = apply_l3_obfuscation(result, intensity=intensity, seed=seed)
            if not l3_result.success:
                return l3_result
            result = l3_result.code
            all_changes.extend(l3_result.changes_made)

        # L4: Structural obfuscation
        if level >= 4:
            l4_result = apply_l4_obfuscation(result, intensity=intensity, seed=seed)
            if not l4_result.success:
                return l4_result
            result = l4_result.code
            all_changes.extend(l4_result.changes_made)

        return ObfuscationResult(
            success=True,
            code=result,
            level=level,
            rename_map=rename_map,
            changes_made=all_changes
        )

    except Exception as e:
        return ObfuscationResult(
            success=False,
            level=level,
            error=str(e)
        )


# =============================================================================
# EXPORTS
# =============================================================================

__all__ = [
    'IdentifierObfuscator',
    'ControlFlowObfuscator',
    'StructuralObfuscator',
    'apply_l2_obfuscation',
    'apply_l3_obfuscation',
    'apply_l4_obfuscation',
    'apply_obfuscation',
    'ObfuscationResult',
]
