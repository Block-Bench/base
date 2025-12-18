"""
Reserved Keywords and Built-in Identifiers for Solidity and Rust/Solana

This module provides comprehensive lists of reserved words that should NEVER
be renamed or modified by any transformation strategy (sanitize, chameleon, etc.)

These include:
- Language keywords
- Built-in global variables and their properties
- Built-in functions
- Type names
- Special variables and constants
- Standard library names
"""

# =============================================================================
# SOLIDITY RESERVED KEYWORDS AND BUILT-INS
# =============================================================================

# Solidity language keywords (cannot be used as identifiers)
SOLIDITY_KEYWORDS = {
    # Contract definition
    'contract', 'interface', 'library', 'abstract', 'is',

    # Visibility
    'public', 'private', 'internal', 'external',

    # State mutability
    'pure', 'view', 'payable', 'nonpayable',

    # Function modifiers
    'virtual', 'override', 'constant', 'immutable',

    # Control structures
    'if', 'else', 'for', 'while', 'do', 'break', 'continue', 'return',
    'try', 'catch', 'throw', 'revert', 'require', 'assert',

    # Function/modifier/event
    'function', 'modifier', 'event', 'emit', 'error',
    'constructor', 'fallback', 'receive',

    # Data structures
    'struct', 'enum', 'mapping', 'array',

    # Storage
    'storage', 'memory', 'calldata',

    # Other keywords
    'new', 'delete', 'this', 'super', 'selfdestruct', 'suicide',
    'assembly', 'pragma', 'import', 'using', 'type',
    'indexed', 'anonymous', 'unchecked',
}

# Solidity built-in type names
SOLIDITY_TYPES = {
    # Integer types
    'uint', 'uint8', 'uint16', 'uint24', 'uint32', 'uint40', 'uint48',
    'uint56', 'uint64', 'uint72', 'uint80', 'uint88', 'uint96',
    'uint104', 'uint112', 'uint120', 'uint128', 'uint136', 'uint144',
    'uint152', 'uint160', 'uint168', 'uint176', 'uint184', 'uint192',
    'uint200', 'uint208', 'uint216', 'uint224', 'uint232', 'uint240',
    'uint248', 'uint256',

    'int', 'int8', 'int16', 'int24', 'int32', 'int40', 'int48',
    'int56', 'int64', 'int72', 'int80', 'int88', 'int96',
    'int104', 'int112', 'int120', 'int128', 'int136', 'int144',
    'int152', 'int160', 'int168', 'int176', 'int184', 'int192',
    'int200', 'int208', 'int216', 'int224', 'int232', 'int240',
    'int248', 'int256',

    # Fixed-size byte arrays
    'bytes1', 'bytes2', 'bytes3', 'bytes4', 'bytes5', 'bytes6', 'bytes7',
    'bytes8', 'bytes9', 'bytes10', 'bytes11', 'bytes12', 'bytes13',
    'bytes14', 'bytes15', 'bytes16', 'bytes17', 'bytes18', 'bytes19',
    'bytes20', 'bytes21', 'bytes22', 'bytes23', 'bytes24', 'bytes25',
    'bytes26', 'bytes27', 'bytes28', 'bytes29', 'bytes30', 'bytes31',
    'bytes32',

    # Other types
    'address', 'bool', 'string', 'bytes',
    'fixed', 'ufixed',  # Not fully supported yet
}

# msg.* properties - NEVER rename these
MSG_PROPERTIES = {
    'sender',   # msg.sender - address of message sender
    'value',    # msg.value - amount of wei sent
    'data',     # msg.data - complete calldata
    'sig',      # msg.sig - first 4 bytes of calldata (function selector)
    'gas',      # msg.gas - remaining gas (deprecated, use gasleft())
}

# block.* properties - NEVER rename these
BLOCK_PROPERTIES = {
    'basefee',      # block.basefee - current block's base fee
    'chainid',      # block.chainid - current chain id
    'coinbase',     # block.coinbase - current block miner's address
    'difficulty',   # block.difficulty - current block difficulty (deprecated post-merge)
    'gaslimit',     # block.gaslimit - current block gaslimit
    'number',       # block.number - current block number
    'timestamp',    # block.timestamp - current block timestamp (seconds since unix epoch)
    'prevrandao',   # block.prevrandao - random value from beacon chain (replaces difficulty post-merge)
    'blockhash',    # blockhash(uint blockNumber) - hash of given block
}

# tx.* properties - NEVER rename these
TX_PROPERTIES = {
    'gasprice',  # tx.gasprice - gas price of the transaction
    'origin',    # tx.origin - sender of the transaction (full call chain)
}

# abi.* functions - NEVER rename these
ABI_FUNCTIONS = {
    'encode',              # abi.encode(...)
    'encodePacked',        # abi.encodePacked(...)
    'encodeWithSelector',  # abi.encodeWithSelector(bytes4, ...)
    'encodeWithSignature', # abi.encodeWithSignature(string, ...)
    'encodeCall',          # abi.encodeCall(function, args)
    'decode',              # abi.decode(bytes, (types))
}

# type(...) expression properties
TYPE_PROPERTIES = {
    'name',         # type(C).name - contract name
    'creationCode', # type(C).creationCode - creation bytecode
    'runtimeCode',  # type(C).runtimeCode - runtime bytecode
    'interfaceId',  # type(I).interfaceId - EIP-165 interface identifier
    'min',          # type(T).min - minimum value
    'max',          # type(T).max - maximum value
}

# Built-in global functions
SOLIDITY_GLOBAL_FUNCTIONS = {
    # Error handling
    'require', 'assert', 'revert',

    # Mathematical
    'addmod', 'mulmod',

    # Cryptographic
    'keccak256', 'sha256', 'ripemd160', 'ecrecover',
    'sha3',  # Deprecated alias for keccak256

    # Address related
    'blockhash',

    # Contract related
    'selfdestruct', 'suicide',  # suicide is deprecated

    # Gas/resource
    'gasleft',

    # ABI encoding/decoding (also available as abi.*)
    'encode', 'encodePacked', 'encodeWithSelector', 'encodeWithSignature', 'decode',
}

# Address type members
ADDRESS_MEMBERS = {
    'balance',       # address.balance - balance in wei
    'code',          # address.code - bytecode at address
    'codehash',      # address.codehash - keccak256 of code
    'transfer',      # address.transfer(uint256) - send wei, revert on failure
    'send',          # address.send(uint256) - send wei, return bool
    'call',          # address.call(bytes) - low-level call
    'delegatecall',  # address.delegatecall(bytes) - low-level delegatecall
    'staticcall',    # address.staticcall(bytes) - low-level staticcall
}

# Array/Bytes/String properties - NEVER rename these when after ANY dot
# These are universal and apply to arrays/bytes regardless of variable name
UNIVERSAL_DOT_PROPERTIES = {
    'length',        # array.length, bytes.length, string.length
    'push',          # dynamic array push
    'pop',           # dynamic array pop
    'selector',      # function.selector - 4-byte selector
}

# Context-specific properties - only skip when following known built-in parents
# These should NOT be skipped for user-defined struct field access
CONTEXT_SPECIFIC_PROPERTIES = {
    'value',         # msg.value, .call.value() - but NOT struct.value
    'gas',           # msg.gas, .call.gas() - but NOT struct.gas
}

# Units (ether and time)
SOLIDITY_UNITS = {
    # Ether units
    'wei', 'gwei', 'ether',
    'szabo', 'finney',  # Deprecated

    # Time units
    'seconds', 'minutes', 'hours', 'days', 'weeks',
    'years',  # Deprecated
}

# Special variables
SOLIDITY_SPECIAL_VARS = {
    'now',  # Deprecated alias for block.timestamp
    'this', # Current contract instance
    'super', # Parent contract
}

# Built-in global objects (the object names themselves)
SOLIDITY_GLOBAL_OBJECTS = {
    'msg',    # Message object
    'block',  # Block object
    'tx',     # Transaction object
    'abi',    # ABI encoding/decoding
    'type',   # Type information
}

# Standard interfaces and contracts
SOLIDITY_STANDARD_INTERFACES = {
    # ERC standards
    'IERC20', 'ERC20', 'IERC721', 'ERC721', 'IERC1155', 'ERC1155',
    'IERC165', 'ERC165', 'IERC721Receiver', 'IERC1155Receiver',
    'IERC20Permit', 'IERC4626',

    # OpenZeppelin
    'Ownable', 'Pausable', 'ReentrancyGuard', 'AccessControl',
    'SafeERC20', 'SafeMath', 'Address', 'Context', 'Strings',
    'EnumerableSet', 'EnumerableMap',

    # Common patterns
    'Initializable', 'Proxy', 'TransparentUpgradeableProxy',
}

# =============================================================================
# ALL SOLIDITY RESERVED (combined for easy checking)
# =============================================================================

# Properties that should never be renamed when following a dot
# e.g., msg.sender, block.timestamp, address.balance, array.length
SOLIDITY_DOT_PROPERTIES = (
    MSG_PROPERTIES |
    BLOCK_PROPERTIES |
    TX_PROPERTIES |
    ABI_FUNCTIONS |
    TYPE_PROPERTIES |
    ADDRESS_MEMBERS |
    UNIVERSAL_DOT_PROPERTIES
)

# Parents whose properties should be protected (includes call chain methods)
BUILTIN_PARENTS = {
    'msg', 'block', 'tx', 'abi', 'type',
    'call', 'delegatecall', 'staticcall', 'send', 'transfer',
}

# All Solidity reserved words (keywords + types + built-ins)
SOLIDITY_RESERVED = (
    SOLIDITY_KEYWORDS |
    SOLIDITY_TYPES |
    SOLIDITY_GLOBAL_FUNCTIONS |
    SOLIDITY_UNITS |
    SOLIDITY_SPECIAL_VARS |
    SOLIDITY_GLOBAL_OBJECTS
)


# =============================================================================
# RUST / SOLANA RESERVED KEYWORDS AND BUILT-INS
# =============================================================================

# Rust language keywords
RUST_KEYWORDS = {
    # Function and module
    'fn', 'mod', 'pub', 'crate', 'self', 'Self', 'super',
    'use', 'as', 'extern', 'impl', 'trait', 'dyn',

    # Types and data
    'struct', 'enum', 'type', 'const', 'static', 'let', 'mut',
    'ref', 'move', 'box', 'where',

    # Control flow
    'if', 'else', 'match', 'loop', 'while', 'for', 'in',
    'break', 'continue', 'return', 'yield',

    # Error handling
    'unsafe', 'async', 'await', 'try',

    # Other
    'true', 'false', 'macro_rules',
}

# Rust primitive types
RUST_TYPES = {
    # Integer types
    'u8', 'u16', 'u32', 'u64', 'u128', 'usize',
    'i8', 'i16', 'i32', 'i64', 'i128', 'isize',

    # Float types
    'f32', 'f64',

    # Other primitives
    'bool', 'char', 'str',

    # Common types
    'String', 'Vec', 'Option', 'Result', 'Box', 'Rc', 'Arc',
    'HashMap', 'HashSet', 'BTreeMap', 'BTreeSet',
}

# Anchor/Solana specific keywords
ANCHOR_KEYWORDS = {
    # Account attributes
    'Account', 'Signer', 'Program', 'System', 'UncheckedAccount',
    'AccountInfo', 'ProgramAccount', 'Loader', 'AccountLoader',

    # Macros and derives
    'program', 'account', 'derive', 'Accounts', 'AnchorDeserialize',
    'AnchorSerialize', 'InitSpace',

    # Constraints
    'init', 'mut', 'seeds', 'bump', 'payer', 'space', 'constraint',
    'has_one', 'close', 'address', 'owner', 'executable',

    # Error handling
    'error_code', 'require', 'require_eq', 'require_keys_eq',
    'require_gt', 'require_gte',

    # Context
    'Context', 'CpiContext',
}

# Solana program library keywords
SOLANA_SPL = {
    # Token program
    'Token', 'TokenAccount', 'Mint', 'token',
    'transfer', 'mint_to', 'burn', 'approve', 'revoke',
    'initialize_mint', 'initialize_account',

    # Associated token
    'AssociatedToken', 'associated_token',

    # System program
    'system_program', 'create_account', 'allocate', 'assign',

    # Rent
    'Rent', 'rent',
}

# Solana SDK commonly used items
SOLANA_SDK = {
    'Pubkey', 'Keypair', 'AccountMeta', 'Instruction',
    'clock', 'Clock', 'epoch_schedule', 'rent',
    'sysvar', 'Sysvar',
    'lamports_to_sol', 'sol_to_lamports',
    'LAMPORTS_PER_SOL',
}

# All Rust/Solana reserved
RUST_RESERVED = (
    RUST_KEYWORDS |
    RUST_TYPES |
    ANCHOR_KEYWORDS |
    SOLANA_SPL |
    SOLANA_SDK
)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def is_solidity_reserved(identifier: str) -> bool:
    """Check if an identifier is a Solidity reserved word."""
    return identifier.lower() in {s.lower() for s in SOLIDITY_RESERVED}


def is_solidity_dot_property(property_name: str) -> bool:
    """Check if a property name (after a dot) is a Solidity built-in property."""
    return property_name.lower() in {s.lower() for s in SOLIDITY_DOT_PROPERTIES}


def is_rust_reserved(identifier: str) -> bool:
    """Check if an identifier is a Rust/Solana reserved word."""
    return identifier in RUST_RESERVED  # Rust is case-sensitive


def should_skip_rename(identifier: str, context: str = None) -> bool:
    """
    Determine if an identifier should NOT be renamed.

    Args:
        identifier: The identifier to check
        context: Optional context like 'msg.' or 'block.' if preceded by a dot

    Returns:
        True if the identifier should NOT be renamed (it's reserved)
    """
    # Check if it's a dot property (e.g., sender in msg.sender)
    if context in ('msg', 'block', 'tx', 'abi', 'type', 'address'):
        return is_solidity_dot_property(identifier)

    # Check general reserved words
    return is_solidity_reserved(identifier) or is_rust_reserved(identifier)


def get_all_reserved() -> set:
    """Get all reserved words across all languages."""
    return SOLIDITY_RESERVED | RUST_RESERVED | SOLIDITY_DOT_PROPERTIES


# =============================================================================
# PATTERNS FOR REGEX MATCHING
# =============================================================================

# Pattern to match msg.X, block.X, tx.X, abi.X where X should not be renamed
# Usage: Use negative lookbehind in transformations
SOLIDITY_BUILTIN_PREFIX_PATTERN = r'(?:msg|block|tx|abi|type|address)\.'

# Pattern to match any reserved word as a whole word
def get_reserved_pattern(reserved_set: set) -> str:
    """Generate a regex pattern that matches any word in the reserved set."""
    sorted_words = sorted(reserved_set, key=len, reverse=True)  # Longest first
    escaped = [r'\b' + word + r'\b' for word in sorted_words]
    return '|'.join(escaped)


SOLIDITY_RESERVED_PATTERN = get_reserved_pattern(SOLIDITY_RESERVED)
RUST_RESERVED_PATTERN = get_reserved_pattern(RUST_RESERVED)
