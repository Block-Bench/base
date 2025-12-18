"""
Common utilities for BlockBench transformation strategies.
"""

from .reserved import (
    # Solidity
    SOLIDITY_RESERVED,
    SOLIDITY_DOT_PROPERTIES,
    SOLIDITY_KEYWORDS,
    SOLIDITY_TYPES,
    SOLIDITY_GLOBAL_FUNCTIONS,
    SOLIDITY_GLOBAL_OBJECTS,
    MSG_PROPERTIES,
    BLOCK_PROPERTIES,
    TX_PROPERTIES,
    ABI_FUNCTIONS,
    ADDRESS_MEMBERS,
    UNIVERSAL_DOT_PROPERTIES,
    CONTEXT_SPECIFIC_PROPERTIES,
    BUILTIN_PARENTS,

    # Rust/Solana
    RUST_RESERVED,
    RUST_KEYWORDS,
    RUST_TYPES,
    ANCHOR_KEYWORDS,
    SOLANA_SPL,

    # Helper functions
    is_solidity_reserved,
    is_solidity_dot_property,
    is_rust_reserved,
    should_skip_rename,
    get_all_reserved,

    # Patterns
    SOLIDITY_BUILTIN_PREFIX_PATTERN,
    SOLIDITY_RESERVED_PATTERN,
    RUST_RESERVED_PATTERN,
)

from .treesitter import (
    # Parsing
    parse,
    get_parser,
    SOL_LANGUAGE,

    # Data classes
    Identifier,
    FunctionInfo,
    ContractInfo,

    # Node traversal
    walk_tree,
    find_first,
    find_all,
    find_children,
    get_node_text,
    get_parent_of_type,

    # Contract extraction
    get_contract_info,
    get_all_contracts,

    # Function extraction
    get_function_info,
    find_function_by_name,
    get_all_functions,

    # Identifier extraction
    extract_identifiers,

    # Comment handling
    find_all_comments,
    remove_comments,

    # Statement handling
    get_statements,
    categorize_statement,

    # Position utilities
    find_pragma_end,
    find_last_import_end,
    find_import_insertion_point,

    # Code modification
    apply_edits,
    replace_node,
    insert_after_node,
    insert_before_node,

    # Validation
    check_syntax,
    compare_ast_structure,
)

__all__ = [
    # Reserved keywords
    'SOLIDITY_RESERVED',
    'SOLIDITY_DOT_PROPERTIES',
    'SOLIDITY_KEYWORDS',
    'SOLIDITY_TYPES',
    'SOLIDITY_GLOBAL_FUNCTIONS',
    'SOLIDITY_GLOBAL_OBJECTS',
    'MSG_PROPERTIES',
    'BLOCK_PROPERTIES',
    'TX_PROPERTIES',
    'ABI_FUNCTIONS',
    'ADDRESS_MEMBERS',
    'UNIVERSAL_DOT_PROPERTIES',
    'CONTEXT_SPECIFIC_PROPERTIES',
    'BUILTIN_PARENTS',
    'RUST_RESERVED',
    'RUST_KEYWORDS',
    'RUST_TYPES',
    'ANCHOR_KEYWORDS',
    'SOLANA_SPL',
    'is_solidity_reserved',
    'is_solidity_dot_property',
    'is_rust_reserved',
    'should_skip_rename',
    'get_all_reserved',
    'SOLIDITY_BUILTIN_PREFIX_PATTERN',
    'SOLIDITY_RESERVED_PATTERN',
    'RUST_RESERVED_PATTERN',

    # Tree-sitter utilities
    'parse',
    'get_parser',
    'SOL_LANGUAGE',
    'Identifier',
    'FunctionInfo',
    'ContractInfo',
    'walk_tree',
    'find_first',
    'find_all',
    'find_children',
    'get_node_text',
    'get_parent_of_type',
    'get_contract_info',
    'get_all_contracts',
    'get_function_info',
    'find_function_by_name',
    'get_all_functions',
    'extract_identifiers',
    'find_all_comments',
    'remove_comments',
    'get_statements',
    'categorize_statement',
    'find_pragma_end',
    'find_last_import_end',
    'find_import_insertion_point',
    'apply_edits',
    'replace_node',
    'insert_after_node',
    'insert_before_node',
    'check_syntax',
    'compare_ast_structure',
]
