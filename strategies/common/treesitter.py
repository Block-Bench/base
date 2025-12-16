"""
Tree-sitter parsing utilities for Solidity smart contracts.

Provides robust AST-based parsing for all transformation strategies.
"""

import tree_sitter_solidity as ts_sol
from tree_sitter import Language, Parser, Node, Tree
from typing import List, Optional, Tuple, Dict, Any, Generator
from dataclasses import dataclass


# =============================================================================
# LANGUAGE SETUP
# =============================================================================

# Initialize Solidity language
SOL_LANGUAGE = Language(ts_sol.language())

# Global parser instance
_parser = None


def get_parser() -> Parser:
    """Get or create the Solidity parser instance."""
    global _parser
    if _parser is None:
        _parser = Parser(SOL_LANGUAGE)
    return _parser


def parse(source: str) -> Tree:
    """Parse Solidity source code and return AST tree."""
    parser = get_parser()
    return parser.parse(source.encode('utf-8'))


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class Identifier:
    """Represents an identifier found in code."""
    name: str
    start_byte: int
    end_byte: int
    start_point: Tuple[int, int]  # (row, col)
    end_point: Tuple[int, int]
    node_type: str
    parent_type: Optional[str] = None
    context: Optional[str] = None  # e.g., 'msg', 'block' for dot properties


@dataclass
class FunctionInfo:
    """Information about a function definition."""
    name: str
    node: Node
    start_byte: int
    end_byte: int
    visibility: str  # public, private, internal, external
    mutability: str  # pure, view, payable, or empty
    modifiers: List[str]
    parameters: List[Dict[str, str]]  # [{'name': 'x', 'type': 'uint256'}, ...]
    return_types: List[str]
    body_start: int
    body_end: int


@dataclass
class ContractInfo:
    """Information about a contract definition."""
    name: str
    node: Node
    start_byte: int
    end_byte: int
    inheritance: List[str]
    body_start: int
    body_end: int


# =============================================================================
# NODE TRAVERSAL UTILITIES
# =============================================================================

def walk_tree(node: Node) -> Generator[Node, None, None]:
    """Walk all nodes in the tree depth-first."""
    yield node
    for child in node.children:
        yield from walk_tree(child)


def find_first(tree: Tree, node_types: List[str]) -> Optional[Node]:
    """Find first node of any of the given types."""
    if isinstance(node_types, str):
        node_types = [node_types]

    for node in walk_tree(tree.root_node):
        if node.type in node_types:
            return node
    return None


def find_all(tree: Tree, node_types: List[str]) -> List[Node]:
    """Find all nodes of any of the given types."""
    if isinstance(node_types, str):
        node_types = [node_types]

    results = []
    for node in walk_tree(tree.root_node):
        if node.type in node_types:
            results.append(node)
    return results


def find_children(node: Node, node_types: List[str]) -> List[Node]:
    """Find direct children of specific types."""
    if isinstance(node_types, str):
        node_types = [node_types]

    return [child for child in node.children if child.type in node_types]


def get_node_text(node: Node, source: str) -> str:
    """Get the text content of a node."""
    return source[node.start_byte:node.end_byte]


def get_parent_of_type(node: Node, node_types: List[str]) -> Optional[Node]:
    """Find the nearest ancestor of given type(s)."""
    if isinstance(node_types, str):
        node_types = [node_types]

    current = node.parent
    while current:
        if current.type in node_types:
            return current
        current = current.parent
    return None


# =============================================================================
# CONTRACT EXTRACTION
# =============================================================================

def get_contract_info(tree: Tree, source: str) -> Optional[ContractInfo]:
    """Extract information about the main contract."""
    contract_node = find_first(tree, ['contract_declaration'])
    if not contract_node:
        return None

    # Get contract name
    name_node = contract_node.child_by_field_name('name')
    name = get_node_text(name_node, source) if name_node else 'Unknown'

    # Get inheritance
    inheritance = []
    inheritance_node = contract_node.child_by_field_name('inheritance_specifier')
    if inheritance_node:
        for child in walk_tree(inheritance_node):
            if child.type == 'user_defined_type':
                inheritance.append(get_node_text(child, source))

    # Get body
    body_node = contract_node.child_by_field_name('body')
    body_start = body_node.start_byte if body_node else contract_node.end_byte
    body_end = body_node.end_byte if body_node else contract_node.end_byte

    return ContractInfo(
        name=name,
        node=contract_node,
        start_byte=contract_node.start_byte,
        end_byte=contract_node.end_byte,
        inheritance=inheritance,
        body_start=body_start,
        body_end=body_end
    )


def get_all_contracts(tree: Tree, source: str) -> List[ContractInfo]:
    """Extract information about all contracts in the source."""
    contracts = []
    for node in find_all(tree, ['contract_declaration']):
        name_node = node.child_by_field_name('name')
        name = get_node_text(name_node, source) if name_node else 'Unknown'

        inheritance = []
        inheritance_node = node.child_by_field_name('inheritance_specifier')
        if inheritance_node:
            for child in walk_tree(inheritance_node):
                if child.type == 'user_defined_type':
                    inheritance.append(get_node_text(child, source))

        body_node = node.child_by_field_name('body')
        body_start = body_node.start_byte if body_node else node.end_byte
        body_end = body_node.end_byte if body_node else node.end_byte

        contracts.append(ContractInfo(
            name=name,
            node=node,
            start_byte=node.start_byte,
            end_byte=node.end_byte,
            inheritance=inheritance,
            body_start=body_start,
            body_end=body_end
        ))

    return contracts


# =============================================================================
# FUNCTION EXTRACTION
# =============================================================================

def get_function_info(func_node: Node, source: str) -> FunctionInfo:
    """Extract detailed information about a function."""
    # Get function name
    name_node = func_node.child_by_field_name('name')
    name = get_node_text(name_node, source) if name_node else ''

    # Get visibility and mutability
    visibility = 'internal'  # default
    mutability = ''
    modifiers = []

    for child in func_node.children:
        if child.type == 'visibility':
            visibility = get_node_text(child, source)
        elif child.type == 'state_mutability':
            mutability = get_node_text(child, source)
        elif child.type == 'modifier_invocation':
            mod_name = child.child_by_field_name('name')
            if mod_name:
                modifiers.append(get_node_text(mod_name, source))

    # Get parameters
    parameters = []
    params_node = func_node.child_by_field_name('parameters')
    if params_node:
        param_nodes = find_children(params_node, ['parameter'])
    else:
        # Fallback: parameters may be direct children of function_definition
        param_nodes = find_children(func_node, ['parameter'])

    for param in param_nodes:
        param_type_node = param.child_by_field_name('type')
        param_name_node = param.child_by_field_name('name')

        # If field names don't work, try to parse from text
        param_text = get_node_text(param, source).strip()
        if param_type_node and param_name_node:
            param_type = get_node_text(param_type_node, source)
            param_name = get_node_text(param_name_node, source)
        else:
            # Parse from text: "uint256 amount" -> type="uint256", name="amount"
            parts = param_text.split()
            if len(parts) >= 2:
                param_type = ' '.join(parts[:-1])  # Handle "address payable" etc
                param_name = parts[-1]
            elif len(parts) == 1:
                param_type = parts[0]
                param_name = ''
            else:
                continue

        if param_type:
            parameters.append({'type': param_type, 'name': param_name})

    # Get return types
    return_types = []
    returns_node = func_node.child_by_field_name('return_type')
    if returns_node:
        for param in walk_tree(returns_node):
            if param.type in ['type_name', 'elementary_type_name', 'user_defined_type']:
                return_types.append(get_node_text(param, source))

    # Get body
    body_node = func_node.child_by_field_name('body')
    body_start = body_node.start_byte if body_node else func_node.end_byte
    body_end = body_node.end_byte if body_node else func_node.end_byte

    return FunctionInfo(
        name=name,
        node=func_node,
        start_byte=func_node.start_byte,
        end_byte=func_node.end_byte,
        visibility=visibility,
        mutability=mutability,
        modifiers=modifiers,
        parameters=parameters,
        return_types=return_types,
        body_start=body_start,
        body_end=body_end
    )


def find_function_by_name(tree: Tree, name: str, source: str) -> Optional[FunctionInfo]:
    """Find a function by name and return its info."""
    for func_node in find_all(tree, ['function_definition']):
        name_node = func_node.child_by_field_name('name')
        if name_node and get_node_text(name_node, source) == name:
            return get_function_info(func_node, source)
    return None


def get_all_functions(tree: Tree, source: str) -> List[FunctionInfo]:
    """Get information about all functions in the contract."""
    functions = []
    for func_node in find_all(tree, ['function_definition']):
        functions.append(get_function_info(func_node, source))
    return functions


# =============================================================================
# IDENTIFIER EXTRACTION
# =============================================================================

def extract_identifiers(tree: Tree, source: str) -> List[Identifier]:
    """
    Extract all identifiers from the AST with position information.

    This is more accurate than regex as it uses the actual AST.
    """
    identifiers = []

    for node in walk_tree(tree.root_node):
        if node.type == 'identifier':
            # Get parent to understand context
            parent = node.parent
            parent_type = parent.type if parent else None

            # Check for dot property context (e.g., msg.sender)
            context = None
            if parent and parent.type == 'member_expression':
                # Check if this identifier is the property part
                object_node = parent.child_by_field_name('object')
                if object_node and node != object_node:
                    context = get_node_text(object_node, source)

            identifiers.append(Identifier(
                name=get_node_text(node, source),
                start_byte=node.start_byte,
                end_byte=node.end_byte,
                start_point=node.start_point,
                end_point=node.end_point,
                node_type=node.type,
                parent_type=parent_type,
                context=context
            ))

    return identifiers


# =============================================================================
# COMMENT HANDLING
# =============================================================================

def find_all_comments(tree: Tree, source: str) -> List[Tuple[int, int, str]]:
    """
    Find all comments in the source.

    Returns list of (start_byte, end_byte, comment_text) tuples.
    """
    comments = []

    # Tree-sitter captures comments as specific node types
    comment_types = ['comment', 'line_comment', 'block_comment', 'natspec_comment']

    for node in walk_tree(tree.root_node):
        if node.type in comment_types:
            comments.append((
                node.start_byte,
                node.end_byte,
                get_node_text(node, source)
            ))

    return comments


def remove_comments(source: str) -> str:
    """Remove all comments from source code."""
    tree = parse(source)
    comments = find_all_comments(tree, source)

    # Sort by position descending to maintain byte positions
    comments.sort(key=lambda c: c[0], reverse=True)

    result = source
    for start, end, _ in comments:
        result = result[:start] + result[end:]

    # Clean up multiple blank lines
    import re
    result = re.sub(r'\n\s*\n\s*\n', '\n\n', result)

    return result


# =============================================================================
# STATEMENT EXTRACTION
# =============================================================================

def get_statements(body_node: Node, source: str) -> List[Tuple[Node, str]]:
    """
    Get all statements from a function body.

    Returns list of (node, statement_text) tuples.
    """
    statements = []

    if not body_node or body_node.type != 'function_body':
        return statements

    # Function body is a block statement containing statements
    for child in body_node.children:
        if child.type not in ['{', '}']:
            statements.append((child, get_node_text(child, source)))

    return statements


def categorize_statement(stmt_text: str) -> str:
    """
    Categorize a statement as check, effect, or interaction.

    Useful for CEI pattern analysis.
    """
    stmt_lower = stmt_text.lower()

    # Checks (conditions/validations)
    if any(kw in stmt_lower for kw in ['require', 'assert', 'if ', 'revert']):
        return 'check'

    # Interactions (external calls)
    if any(kw in stmt_lower for kw in ['.call', '.transfer', '.send', '.delegatecall', '.staticcall']):
        return 'interaction'

    # Everything else is an effect (state change)
    return 'effect'


# =============================================================================
# POSITION UTILITIES
# =============================================================================

def find_pragma_end(tree: Tree, source: str) -> int:
    """Find the end position of the pragma directive."""
    pragma = find_first(tree, ['pragma_directive'])
    if pragma:
        return pragma.end_byte
    return 0


def find_last_import_end(tree: Tree, source: str) -> int:
    """Find the end position of the last import statement."""
    imports = find_all(tree, ['import_directive'])
    if imports:
        last_import = max(imports, key=lambda n: n.end_byte)
        return last_import.end_byte
    return find_pragma_end(tree, source)


def find_import_insertion_point(tree: Tree, source: str) -> int:
    """Find the best position to insert a new import statement."""
    # After last existing import, or after pragma
    last_import_end = find_last_import_end(tree, source)
    if last_import_end > 0:
        return last_import_end

    pragma_end = find_pragma_end(tree, source)
    return pragma_end


# =============================================================================
# CODE MODIFICATION UTILITIES
# =============================================================================

def apply_edits(source: str, edits: List[Dict[str, Any]]) -> str:
    """
    Apply a list of edits to source code.

    Each edit is a dict with:
    - 'type': 'insert', 'delete', or 'replace'
    - 'position': byte position for inserts
    - 'start', 'end': byte range for deletes/replaces
    - 'text': text to insert/replace with

    Edits are applied back-to-front to maintain position validity.
    """
    # Sort by position descending
    def get_pos(edit):
        if edit['type'] == 'insert':
            return edit['position']
        return edit['start']

    edits_sorted = sorted(edits, key=get_pos, reverse=True)

    result = source
    for edit in edits_sorted:
        if edit['type'] == 'insert':
            pos = edit['position']
            result = result[:pos] + edit['text'] + result[pos:]
        elif edit['type'] == 'delete':
            result = result[:edit['start']] + result[edit['end']:]
        elif edit['type'] == 'replace':
            result = result[:edit['start']] + edit['text'] + result[edit['end']:]

    return result


def replace_node(source: str, node: Node, new_text: str) -> str:
    """Replace a node with new text."""
    return source[:node.start_byte] + new_text + source[node.end_byte:]


def insert_after_node(source: str, node: Node, text: str) -> str:
    """Insert text after a node."""
    return source[:node.end_byte] + text + source[node.end_byte:]


def insert_before_node(source: str, node: Node, text: str) -> str:
    """Insert text before a node."""
    return source[:node.start_byte] + text + source[node.start_byte:]


# =============================================================================
# VALIDATION UTILITIES
# =============================================================================

def check_syntax(source: str) -> Tuple[bool, List[str]]:
    """
    Check if source has syntax errors using Tree-sitter.

    Returns (is_valid, list_of_errors).
    """
    tree = parse(source)
    errors = []

    for node in walk_tree(tree.root_node):
        if node.type == 'ERROR' or node.is_missing:
            line = node.start_point[0] + 1
            col = node.start_point[1] + 1
            errors.append(f"Syntax error at line {line}, column {col}")

    return len(errors) == 0, errors


def compare_ast_structure(source1: str, source2: str) -> bool:
    """
    Compare if two sources have the same AST structure.

    Useful for validating that formatting changes don't affect semantics.
    """
    tree1 = parse(source1)
    tree2 = parse(source2)

    def get_structure(node):
        """Get a simplified structure representation."""
        if node.type in ['comment', 'line_comment', 'block_comment', 'natspec_comment']:
            return None  # Ignore comments

        children = [get_structure(c) for c in node.children]
        children = [c for c in children if c is not None]

        return (node.type, tuple(children))

    return get_structure(tree1.root_node) == get_structure(tree2.root_node)


# =============================================================================
# CONVENIENCE EXPORTS
# =============================================================================

__all__ = [
    # Parsing
    'parse',
    'get_parser',
    'SOL_LANGUAGE',

    # Data classes
    'Identifier',
    'FunctionInfo',
    'ContractInfo',

    # Node traversal
    'walk_tree',
    'find_first',
    'find_all',
    'find_children',
    'get_node_text',
    'get_parent_of_type',

    # Contract extraction
    'get_contract_info',
    'get_all_contracts',

    # Function extraction
    'get_function_info',
    'find_function_by_name',
    'get_all_functions',

    # Identifier extraction
    'extract_identifiers',

    # Comment handling
    'find_all_comments',
    'remove_comments',

    # Statement handling
    'get_statements',
    'categorize_statement',

    # Position utilities
    'find_pragma_end',
    'find_last_import_end',
    'find_import_insertion_point',

    # Code modification
    'apply_edits',
    'replace_node',
    'insert_after_node',
    'insert_before_node',

    # Validation
    'check_syntax',
    'compare_ast_structure',
]
