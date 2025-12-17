# Consolidated Adversarial Strategies: Agent Implementation Guide

## Automated Strategies v2.0 - Merged Architecture

**Purpose:** This document consolidates our adversarial transformation strategies from 10+ individual strategies down to 4 automated strategies. Your previous implementations remain valid—this document explains how they merge into a unified architecture.

---

## Executive Summary

### What Changed

We consolidated overlapping strategies to reduce redundancy and create a cleaner architecture:

| New Strategy     | Absorbs                    | Your Existing Implementation     |
| ---------------- | -------------------------- | -------------------------------- |
| **Chameleon**    | + Cross-Domain             | Keep Chameleon, add domain mode  |
| **Shapeshifter** | Mirror + Obfuscation L1-L3 | Mirror becomes Shapeshifter L1   |
| **Restructure**  | Hydra + Chimera            | New unified interface            |
| **Guardian**     | + Confidence Trap          | Add implicit protection variants |

### Final Architecture

```
adversarial/
├── strategies/
│   ├── chameleon.py      # Keyword/terminology transformation
│   ├── shapeshifter.py   # Surface/visual transformation
│   ├── restructure.py    # Structural transformation
│   └── guardian.py       # Protection injection
├── core/                  # Shared infrastructure (unchanged)
├── languages/             # Language plugins (unchanged)
└── themes/                # Dictionaries for Chameleon
```

---

## Strategy 1: Chameleon

### 1.1 Overview

**Purpose:** Transform identifiers to test whether models rely on keyword patterns rather than semantic understanding.

**Merges:** Original Chameleon + Cross-Domain

**Hypothesis:** "If accuracy drops when `withdraw` becomes `claimLoot` or `dischargeFunds`, the model is keyword-matching."

### 1.2 Two Modes

| Mode       | Description                                       | Dictionary Source                                         |
| ---------- | ------------------------------------------------- | --------------------------------------------------------- |
| **Theme**  | Random synonyms from thematic pools               | gaming, resource, abstract, medical, social               |
| **Domain** | Coherent terminology shift to new business domain | defi→gaming, defi→healthcare, defi→logistics, defi→social |

### 1.3 Key Difference Between Modes

**Theme Mode (Original Chameleon):**

- Each identifier independently mapped to random synonym
- `withdraw` → `claimLoot`, `balance` → `holdings`, `user` → `participant`
- Result: Mixed terminology, tests pure keyword independence

**Domain Mode (Absorbed Cross-Domain):**

- Entire contract shifts to coherent new domain
- DeFi vault → Gaming treasure chest (all terms shift together)
- Result: Coherent alternative domain, tests domain transfer

### 1.4 Implementation Changes

```python
class ChameleonTransformer:
    """
    Unified Chameleon transformer supporting both modes.
    """

    def __init__(
        self,
        mode: Literal["theme", "domain"],
        theme: Optional[str] = None,           # For theme mode
        source_domain: Optional[str] = None,   # For domain mode
        target_domain: Optional[str] = None,   # For domain mode
        language_plugin: LanguagePlugin,
        variation_level: str = "medium"
    ):
        self.mode = mode
        self.language = language_plugin
        self.variation_level = variation_level

        if mode == "theme":
            if not theme:
                raise ValueError("Theme mode requires 'theme' parameter")
            self.synonym_pools = load_theme_pools(theme)
            self.mapping_strategy = ThemeMappingStrategy(
                pools=self.synonym_pools,
                variation=variation_level
            )

        elif mode == "domain":
            if not source_domain or not target_domain:
                raise ValueError("Domain mode requires source_domain and target_domain")
            self.domain_mapping = load_domain_mapping(source_domain, target_domain)
            self.mapping_strategy = DomainMappingStrategy(
                mapping=self.domain_mapping,
                variation=variation_level
            )

    def transform(self, source: str) -> TransformationResult:
        """
        Apply Chameleon transformation.
        Core algorithm unchanged—only mapping strategy differs.
        """
        seed = self._create_seed(source)
        rng = Random(seed)

        tree = parse_with_treesitter(source, self.language.get_language_name())
        identifiers = self._extract_identifiers(source, tree)

        # Use appropriate mapping strategy
        rename_map = self.mapping_strategy.build_rename_map(identifiers, rng)

        transformed = apply_renames_byte_position(source, tree, rename_map, self.language)
        validation = validate_transformation(source, transformed, self.language)

        return TransformationResult(
            code=transformed,
            rename_map=rename_map,
            strategy="chameleon",
            strategy_params={
                "mode": self.mode,
                "theme": self.theme if self.mode == "theme" else None,
                "source_domain": self.source_domain if self.mode == "domain" else None,
                "target_domain": self.target_domain if self.mode == "domain" else None,
                "variation_level": self.variation_level
            },
            validation=validation
        )
```

### 1.5 Mapping Strategies

#### Theme Mapping Strategy (Existing)

```python
class ThemeMappingStrategy:
    """
    Maps identifiers to random synonyms from themed pools.
    Each identifier mapped independently.
    """

    def __init__(self, pools: dict, variation: str):
        self.pools = pools
        self.variation = variation

    def build_rename_map(self, identifiers: List[str], rng: Random) -> dict:
        rename_map = {}

        for ident in identifiers:
            # Layered lookup: direct → prefix/suffix → compound → unchanged
            new_name = self._transform_identifier(ident, rng)
            if new_name and new_name != ident:
                rename_map[ident] = new_name

        return rename_map

    def _transform_identifier(self, ident: str, rng: Random) -> Optional[str]:
        # Layer 1: Direct pool lookup
        ident_lower = ident.lower()
        for category in ['function_names', 'variable_names', 'contract_names', ...]:
            if ident_lower in self.pools.get(category, {}):
                pool = self.pools[category][ident_lower]
                return self._select_from_pool(pool, rng)

        # Layer 2: Prefix/suffix patterns
        # Layer 3: Compound decomposition
        # Layer 4: Leave unchanged

        return None

    def _select_from_pool(self, pool: List[str], rng: Random) -> str:
        """Select based on variation level."""
        if self.variation == "low":
            subset = pool[:min(3, len(pool))]
        elif self.variation == "medium":
            subset = pool[:max(1, len(pool) // 2)]
        else:  # high
            subset = pool

        return rng.choice(subset)
```

#### Domain Mapping Strategy (New)

```python
class DomainMappingStrategy:
    """
    Maps identifiers to coherent target domain terminology.
    Maintains thematic consistency across the contract.
    """

    def __init__(self, mapping: dict, variation: str):
        self.mapping = mapping  # source_term -> [target_options]
        self.variation = variation
        self.chosen = {}  # Cache choices for consistency

    def build_rename_map(self, identifiers: List[str], rng: Random) -> dict:
        rename_map = {}

        # First pass: identify domain concepts
        for ident in identifiers:
            concept = self._identify_concept(ident)
            if concept and concept in self.mapping:
                # Use cached choice or select new one
                if concept not in self.chosen:
                    self.chosen[concept] = rng.choice(self.mapping[concept])

                new_name = self._apply_concept(ident, self.chosen[concept])
                rename_map[ident] = new_name

        return rename_map

    def _identify_concept(self, ident: str) -> Optional[str]:
        """
        Identify which domain concept this identifier represents.
        E.g., 'userBalance' -> 'balance' concept
        """
        ident_lower = ident.lower()

        # Direct match
        if ident_lower in self.mapping:
            return ident_lower

        # Check if any concept is a substring
        for concept in self.mapping.keys():
            if concept in ident_lower:
                return concept

        return None
```

### 1.6 Domain Dictionaries

**Structure:**

```yaml
# domains/defi_to_gaming.yaml
source_domain: defi
target_domain: gaming

mappings:
  # Entities
  vault: [TreasureChest, LootVault, GoldHoard, RewardCache]
  pool: [PrizePool, LootPool, JackpotPool, BountyPool]
  token: [GameCoin, GoldToken, Crystal, PowerGem]

  # Actions
  deposit: [storeLoot, cacheTreasure, bankGold, stashPrize]
  withdraw: [claimLoot, collectTreasure, redeemGold, takePrize]
  stake: [wagerTokens, pledgePower, commitGems, lockStrength]

  # Actors
  user: [player, gamer, hero, adventurer, champion]
  owner: [gamemaster, dungeonMaster, guildLeader]

  # Metrics
  balance: [lootBalance, goldHolding, treasureCount]
  totalSupply: [totalGold, allTreasure, combinedLoot]
  fee: [tax, tribute, cut, rake]
```

**Available Domain Pairs:**

- `defi` → `gaming`
- `defi` → `healthcare`
- `defi` → `logistics`
- `defi` → `social`

### 1.7 CLI Interface

```bash
# Theme mode (original Chameleon)
python -m adversarial transform \
    --strategy chameleon \
    --mode theme \
    --theme gaming \
    --variation medium \
    --input contract.sol \
    --output transformed.sol

# Domain mode (absorbed Cross-Domain)
python -m adversarial transform \
    --strategy chameleon \
    --mode domain \
    --source-domain defi \
    --target-domain healthcare \
    --input contract.sol \
    --output transformed.sol
```

### 1.8 Output Metadata

```json
{
  "strategy": "chameleon",
  "mode": "theme|domain",
  "params": {
    "theme": "gaming",
    "source_domain": null,
    "target_domain": null,
    "variation_level": "medium"
  },
  "rename_map": {
    "Vault": "TreasureChest",
    "withdraw": "claimLoot",
    "balances": "goldHoldings"
  },
  "coverage": {
    "total_identifiers": 45,
    "transformed": 38,
    "coverage_percent": 84.4
  }
}
```

---

## Strategy 2: Shapeshifter

### 2.1 Overview

**Purpose:** Transform code surface/visual presentation to test whether models rely on formatting, naming conventions, or code appearance.

**Merges:** Mirror + Obfuscation L1-L3

**Hypothesis:** "If accuracy changes when code is reformatted or lightly obfuscated, the model relies on visual patterns."

### 2.2 Four Levels

| Level  | Name              | What Changes                                | Automation |
| ------ | ----------------- | ------------------------------------------- | ---------- |
| **L1** | Format            | Whitespace, braces, indentation             | 100%       |
| **L2** | Surface           | L1 + variable shortening, comment stripping | 95%        |
| **L3** | Light Obfuscation | L2 + control flow restructuring             | 85%        |
| **L4** | Heavy Obfuscation | L3 + assembly, expression obfuscation       | 70%        |

### 2.3 Level Specifications

#### Level 1: Format (Original Mirror)

Formatting transformations using external tools or rules:

```python
class ShapeshifterL1:
    """
    Level 1: Pure formatting transformations.
    Absorbed from original Mirror strategy.
    """

    MODES = ["compressed", "expanded", "allman", "knr", "minified", "standard"]

    def __init__(self, mode: str):
        if mode not in self.MODES:
            raise ValueError(f"Unknown L1 mode: {mode}")
        self.mode = mode

    def transform(self, source: str) -> str:
        if self.mode == "compressed":
            return self._compress(source)
        elif self.mode == "expanded":
            return self._expand(source)
        elif self.mode == "allman":
            return self._to_allman(source)
        elif self.mode == "knr":
            return self._to_knr(source)
        elif self.mode == "minified":
            return self._minify(source)
        elif self.mode == "standard":
            return self._use_forge_fmt(source)

    def _compress(self, source: str) -> str:
        """Remove excess whitespace, keep on fewer lines."""
        source = remove_comments(source)
        source = collapse_blank_lines(source)
        source = collapse_whitespace(source)
        return source

    def _expand(self, source: str) -> str:
        """Maximum whitespace, one statement per line."""
        source = add_blank_lines_between_functions(source)
        source = expand_operators(source)  # Spaces around operators
        return source

    def _to_allman(self, source: str) -> str:
        """Braces on new lines."""
        # ") {" -> ")\n{"
        source = re.sub(r'\)\s*\{', ')\n{', source)
        source = re.sub(r'(\w)\s*\{', r'\1\n{', source)
        return fix_indentation(source)

    def _to_knr(self, source: str) -> str:
        """Braces on same line."""
        source = re.sub(r'\)\s*\n\s*\{', ') {', source)
        source = re.sub(r'(\w)\s*\n\s*\{', r'\1 {', source)
        return source

    def _minify(self, source: str) -> str:
        """Extreme compression."""
        source = remove_comments(source)
        lines = [line.strip() for line in source.split('\n') if line.strip()]
        return ' '.join(lines)

    def _use_forge_fmt(self, source: str) -> str:
        """Use forge fmt for standard formatting."""
        return run_forge_fmt(source)
```

#### Level 2: Surface

L1 + variable shortening and comment removal:

```python
class ShapeshifterL2(ShapeshifterL1):
    """
    Level 2: Surface transformations.
    L1 + variable shortening + comment stripping.
    """

    def __init__(self, format_mode: str = "compressed", shorten_names: bool = True):
        super().__init__(format_mode)
        self.shorten_names = shorten_names

    def transform(self, source: str, tree=None) -> str:
        # First apply L1 formatting
        source = super().transform(source)

        # Strip all comments
        source = remove_all_comments(source)

        # Shorten variable names
        if self.shorten_names:
            source = self._shorten_names(source, tree)

        return source

    def _shorten_names(self, source: str, tree) -> str:
        """
        Shorten identifiers to minimal unique names.

        balances -> b
        totalSupply -> ts
        withdraw -> w
        userBalance -> ub
        """
        if tree is None:
            tree = parse_solidity(source)

        identifiers = extract_user_identifiers(source, tree)

        # Generate short names
        short_names = {}
        used = set()

        for ident in sorted(identifiers, key=len, reverse=True):
            short = self._generate_short_name(ident, used)
            short_names[ident] = short
            used.add(short)

        # Apply renames
        return apply_renames_byte_position(source, tree, short_names)

    def _generate_short_name(self, ident: str, used: set) -> str:
        """Generate shortest unique name."""
        # Try first letter
        candidate = ident[0].lower()
        if candidate not in used:
            return candidate

        # Try first two letters
        if len(ident) >= 2:
            candidate = ident[:2].lower()
            if candidate not in used:
                return candidate

        # Try initials of camelCase/snake_case
        parts = split_identifier(ident)
        if len(parts) > 1:
            candidate = ''.join(p[0].lower() for p in parts)
            if candidate not in used:
                return candidate

        # Add number suffix
        base = ident[0].lower()
        i = 1
        while f"{base}{i}" in used:
            i += 1
        return f"{base}{i}"
```

#### Level 3: Light Obfuscation

L2 + control flow restructuring:

```python
class ShapeshifterL3(ShapeshifterL2):
    """
    Level 3: Light obfuscation.
    L2 + control flow restructuring + expression splitting.
    """

    def __init__(
        self,
        format_mode: str = "compressed",
        shorten_names: bool = True,
        obfuscate_control_flow: bool = True
    ):
        super().__init__(format_mode, shorten_names)
        self.obfuscate_control_flow = obfuscate_control_flow

    def transform(self, source: str) -> str:
        tree = parse_solidity(source)

        # Apply L2 transformations
        source = super().transform(source, tree)

        # Re-parse after L2 changes
        tree = parse_solidity(source)

        # Obfuscate control flow
        if self.obfuscate_control_flow:
            source = self._obfuscate_control_flow(source, tree)

        return source

    def _obfuscate_control_flow(self, source: str, tree) -> str:
        """
        Convert sequential code to state machine pattern.

        Before:
            require(a);
            doX();
            doY();

        After:
            uint256 _s = 0;
            while (_s < 3) {
                if (_s == 0) { require(a); _s++; }
                else if (_s == 1) { doX(); _s++; }
                else { doY(); _s++; }
            }
        """
        # Find function bodies with sequential statements
        functions = find_all(tree, ['function_definition'])

        edits = []
        for func in functions:
            body = func.child_by_field_name('body')
            if body:
                statements = get_direct_statements(body, source)
                if len(statements) >= 3:  # Worth obfuscating
                    new_body = self._to_state_machine(statements, source)
                    edits.append({
                        'start': body.start_byte + 1,
                        'end': body.end_byte - 1,
                        'replacement': new_body
                    })

        return apply_edits(source, edits)

    def _to_state_machine(self, statements: List, source: str) -> str:
        """Convert statements to state machine."""
        parts = []
        parts.append("\n        uint256 _s = 0;")
        parts.append(f"\n        while (_s < {len(statements)}) {{")

        for i, stmt in enumerate(statements):
            stmt_text = source[stmt.start_byte:stmt.end_byte].strip()
            if i == 0:
                parts.append(f"\n            if (_s == 0) {{ {stmt_text} _s++; }}")
            elif i == len(statements) - 1:
                parts.append(f"\n            else {{ {stmt_text} _s++; }}")
            else:
                parts.append(f"\n            else if (_s == {i}) {{ {stmt_text} _s++; }}")

        parts.append("\n        }")

        return ''.join(parts)
```

#### Level 4: Heavy Obfuscation

L3 + assembly wrapping + expression obfuscation:

```python
class ShapeshifterL4(ShapeshifterL3):
    """
    Level 4: Heavy obfuscation.
    L3 + inline assembly + expression obfuscation + opaque predicates.

    Use sparingly - high effort, may produce unnatural code.
    """

    def __init__(
        self,
        format_mode: str = "compressed",
        shorten_names: bool = True,
        obfuscate_control_flow: bool = True,
        use_assembly: bool = True,
        obfuscate_expressions: bool = True
    ):
        super().__init__(format_mode, shorten_names, obfuscate_control_flow)
        self.use_assembly = use_assembly
        self.obfuscate_expressions = obfuscate_expressions

    def transform(self, source: str) -> str:
        # Apply L3 transformations
        source = super().transform(source)

        tree = parse_solidity(source)

        # Wrap storage operations in assembly
        if self.use_assembly:
            source = self._wrap_in_assembly(source, tree)

        # Obfuscate arithmetic expressions
        if self.obfuscate_expressions:
            source = self._obfuscate_expressions(source)

        return source

    def _wrap_in_assembly(self, source: str, tree) -> str:
        """
        Wrap storage reads/writes in inline assembly.

        Before: balances[user] -= amount;
        After:  assembly {
                    let slot := keccak256(user, balances.slot)
                    let val := sload(slot)
                    sstore(slot, sub(val, amount))
                }
        """
        # Find state variable assignments
        assignments = find_all(tree, ['assignment_expression', 'augmented_assignment'])

        edits = []
        for assign in assignments:
            if self._is_storage_write(assign, source):
                assembly_code = self._to_assembly(assign, source)
                edits.append({
                    'start': assign.start_byte,
                    'end': assign.end_byte,
                    'replacement': assembly_code
                })

        return apply_edits(source, edits)

    def _obfuscate_expressions(self, source: str) -> str:
        """
        Replace simple arithmetic with complex equivalents.

        x * 3  ->  (x << 1) + x
        x / 4  ->  x >> 2
        x * 100 / 1000  ->  x / 10
        """
        patterns = [
            (r'\* 2\b', '<< 1'),
            (r'\* 4\b', '<< 2'),
            (r'\* 8\b', '<< 3'),
            (r'/ 2\b', '>> 1'),
            (r'/ 4\b', '>> 2'),
            (r'/ 8\b', '>> 3'),
            (r'\* 3\b', '* 2 + '),  # Needs special handling
        ]

        for pattern, replacement in patterns:
            source = re.sub(pattern, replacement, source)

        return source
```

### 2.4 Unified Shapeshifter Interface

```python
class ShapeshifterTransformer:
    """
    Unified Shapeshifter transformer.
    Selects appropriate level based on configuration.
    """

    def __init__(
        self,
        level: int,  # 1, 2, 3, or 4
        language_plugin: LanguagePlugin,
        **kwargs
    ):
        if level not in [1, 2, 3, 4]:
            raise ValueError("Level must be 1, 2, 3, or 4")

        self.level = level
        self.language = language_plugin

        # Create appropriate transformer
        if level == 1:
            self.transformer = ShapeshifterL1(
                mode=kwargs.get('format_mode', 'compressed')
            )
        elif level == 2:
            self.transformer = ShapeshifterL2(
                format_mode=kwargs.get('format_mode', 'compressed'),
                shorten_names=kwargs.get('shorten_names', True)
            )
        elif level == 3:
            self.transformer = ShapeshifterL3(
                format_mode=kwargs.get('format_mode', 'compressed'),
                shorten_names=kwargs.get('shorten_names', True),
                obfuscate_control_flow=kwargs.get('obfuscate_control_flow', True)
            )
        elif level == 4:
            self.transformer = ShapeshifterL4(
                format_mode=kwargs.get('format_mode', 'compressed'),
                shorten_names=kwargs.get('shorten_names', True),
                obfuscate_control_flow=kwargs.get('obfuscate_control_flow', True),
                use_assembly=kwargs.get('use_assembly', True),
                obfuscate_expressions=kwargs.get('obfuscate_expressions', True)
            )

    def transform(self, source: str) -> TransformationResult:
        transformed = self.transformer.transform(source)
        validation = validate_transformation(source, transformed, self.language)

        return TransformationResult(
            code=transformed,
            strategy="shapeshifter",
            strategy_params={
                "level": self.level,
                "options": self._get_options()
            },
            validation=validation
        )
```

### 2.5 CLI Interface

```bash
# Level 1: Format only (original Mirror)
python -m adversarial transform \
    --strategy shapeshifter \
    --level 1 \
    --format-mode compressed \
    --input contract.sol \
    --output transformed.sol

# Level 2: Surface transformations
python -m adversarial transform \
    --strategy shapeshifter \
    --level 2 \
    --format-mode compressed \
    --shorten-names \
    --input contract.sol \
    --output transformed.sol

# Level 3: Light obfuscation
python -m adversarial transform \
    --strategy shapeshifter \
    --level 3 \
    --input contract.sol \
    --output transformed.sol

# Level 4: Heavy obfuscation
python -m adversarial transform \
    --strategy shapeshifter \
    --level 4 \
    --input contract.sol \
    --output transformed.sol
```

### 2.6 Output Metadata

```json
{
  "strategy": "shapeshifter",
  "level": 3,
  "params": {
    "format_mode": "compressed",
    "shorten_names": true,
    "obfuscate_control_flow": true
  },
  "transformations_applied": [
    "comment_removal",
    "whitespace_compression",
    "name_shortening",
    "control_flow_state_machine"
  ],
  "metrics": {
    "original_lines": 87,
    "transformed_lines": 34,
    "original_chars": 2543,
    "transformed_chars": 1821,
    "identifiers_shortened": 23
  }
}
```

### 2.7 Complete Example

**Original:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Vault - A simple vault for deposits and withdrawals
contract Vault {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        emit Withdrawal(msg.sender, amount);
    }
}
```

**Level 1 (Compressed):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract Vault {
mapping(address => uint256) public balances;
uint256 public totalDeposits;
event Deposit(address indexed user, uint256 amount);
event Withdrawal(address indexed user, uint256 amount);
function deposit() external payable { balances[msg.sender] += msg.value; totalDeposits += msg.value; emit Deposit(msg.sender, msg.value); }
function withdraw(uint256 amount) external { require(balances[msg.sender] >= amount, "Insufficient"); (bool success, ) = msg.sender.call{value: amount}(""); require(success, "Failed"); balances[msg.sender] -= amount; totalDeposits -= amount; emit Withdrawal(msg.sender, amount); } }
```

**Level 2 (Surface):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract V {
mapping(address => uint256) public b;
uint256 public td;
event D(address indexed u, uint256 a);
event W(address indexed u, uint256 a);
function d() external payable { b[msg.sender] += msg.value; td += msg.value; emit D(msg.sender, msg.value); }
function w(uint256 a) external { require(b[msg.sender] >= a, "Insufficient"); (bool s, ) = msg.sender.call{value: a}(""); require(s, "Failed"); b[msg.sender] -= a; td -= a; emit W(msg.sender, a); } }
```

**Level 3 (Light Obfuscation):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract V {
mapping(address => uint256) public b;
uint256 public td;
event D(address indexed u, uint256 a);
event W(address indexed u, uint256 a);
function d() external payable {
    uint256 _s = 0;
    while (_s < 3) {
        if (_s == 0) { b[msg.sender] += msg.value; _s++; }
        else if (_s == 1) { td += msg.value; _s++; }
        else { emit D(msg.sender, msg.value); _s++; }
    }
}
function w(uint256 a) external {
    uint256 _s = 0;
    while (_s < 5) {
        if (_s == 0) { require(b[msg.sender] >= a, "Insufficient"); _s++; }
        else if (_s == 1) { (bool s, ) = msg.sender.call{value: a}(""); require(s, "Failed"); _s++; }
        else if (_s == 2) { b[msg.sender] -= a; _s++; }
        else if (_s == 3) { td -= a; _s++; }
        else { emit W(msg.sender, a); _s++; }
    }
} }
```

---

## Strategy 3: Restructure

### 3.1 Overview

**Purpose:** Transform code structure to test whether models can analyze vulnerabilities across function boundaries or through complex branching.

**Merges:** Hydra (split) + Chimera (merge)

**Hypothesis:** "If accuracy drops when vulnerable logic is split across helpers or merged with branching, the model lacks structural analysis capability."

### 3.2 Two Modes

| Mode      | Direction | Description                                           |
| --------- | --------- | ----------------------------------------------------- |
| **Split** | 1 → N     | Break one function into multiple helpers              |
| **Merge** | N → 1     | Combine multiple functions with conditional branching |

### 3.3 Split Mode (Hydra)

#### Split Patterns

```python
class RestructureSplit:
    """
    Split mode: One function -> multiple helpers.

    Patterns:
    - sequential: Each statement group becomes a helper
    - internal_external: Public wrapper + internal implementation
    - by_concern: Split by CEI (checks, effects, interactions)
    """

    PATTERNS = ["sequential", "internal_external", "by_concern"]

    def __init__(self, pattern: str, language_plugin: LanguagePlugin):
        if pattern not in self.PATTERNS:
            raise ValueError(f"Unknown split pattern: {pattern}")
        self.pattern = pattern
        self.language = language_plugin

    def transform(
        self,
        source: str,
        function_name: str,
        rng: Random
    ) -> TransformationResult:
        tree = parse_solidity(source)
        func_node = find_function_by_name(tree, function_name)

        if not func_node:
            raise ValueError(f"Function {function_name} not found")

        if self.pattern == "sequential":
            result = self._split_sequential(source, func_node, rng)
        elif self.pattern == "internal_external":
            result = self._split_internal_external(source, func_node, rng)
        elif self.pattern == "by_concern":
            result = self._split_by_concern(source, func_node, rng)

        return result

    def _split_sequential(self, source: str, func_node, rng: Random) -> str:
        """
        Split into sequential helper calls.

        Before:
            function withdraw(uint256 amount) external {
                require(balances[msg.sender] >= amount);
                (bool success,) = msg.sender.call{value: amount}("");
                require(success);
                balances[msg.sender] -= amount;
            }

        After:
            function withdraw(uint256 amount) external {
                _validateWithdraw(amount);
                _executeTransfer(amount);
                _updateState(amount);
            }

            function _validateWithdraw(uint256 amount) internal view {
                require(balances[msg.sender] >= amount);
            }

            function _executeTransfer(uint256 amount) internal {
                (bool success,) = msg.sender.call{value: amount}("");
                require(success);
            }

            function _updateState(uint256 amount) internal {
                balances[msg.sender] -= amount;
            }
        """
        body = func_node.child_by_field_name('body')
        statements = get_direct_statements(body, source)

        # Group statements
        groups = self._group_statements(statements, source)

        # Generate helper names
        func_name = get_function_name(func_node, source)
        helper_names = self._generate_helper_names(func_name, len(groups), rng)

        # Get function parameters
        params = get_function_params(func_node, source)

        # Build helpers
        helpers = []
        calls = []

        for group, helper_name in zip(groups, helper_names):
            # Determine which params this group uses
            group_text = '\n'.join(source[s.start_byte:s.end_byte] for s in group)
            used_params = [p for p in params if p['name'] in group_text]

            # Build helper
            helper = self._build_helper(
                helper_name,
                used_params,
                group,
                source,
                rng
            )
            helpers.append(helper)

            # Build call
            call_args = ', '.join(p['name'] for p in used_params)
            calls.append(f"{helper_name}({call_args});")

        # Build new main function
        new_main = self._rebuild_main(func_node, source, calls)

        # Assemble
        return self._assemble(source, func_node, new_main, helpers)

    def _split_internal_external(self, source: str, func_node, rng: Random) -> str:
        """
        Split into external wrapper + internal implementation.

        Before:
            function withdraw(uint256 amount) external {
                // ... implementation using msg.sender
            }

        After:
            function withdraw(uint256 amount) external {
                _withdrawInternal(msg.sender, amount);
            }

            function _withdrawInternal(address user, uint256 amount) internal {
                // ... implementation using 'user' instead of msg.sender
            }
        """
        func_name = get_function_name(func_node, source)
        body = func_node.child_by_field_name('body')
        body_text = source[body.start_byte + 1:body.end_byte - 1]

        # Check for msg.sender usage
        uses_msg_sender = 'msg.sender' in body_text

        # Generate internal name
        suffixes = ['Internal', 'Impl', 'Core', 'Handler', 'Logic']
        internal_name = f"_{func_name}{rng.choice(suffixes)}"

        # Build internal function params
        params = get_function_params(func_node, source)
        internal_params = params.copy()

        if uses_msg_sender:
            internal_params.insert(0, {'type': 'address', 'name': 'user'})
            body_text = body_text.replace('msg.sender', 'user')

        # Build internal function
        internal_params_str = ', '.join(f"{p['type']} {p['name']}" for p in internal_params)
        internal_func = f"""
    function {internal_name}({internal_params_str}) internal {{
        {body_text.strip()}
    }}"""

        # Build wrapper
        call_args = []
        if uses_msg_sender:
            call_args.append('msg.sender')
        call_args.extend(p['name'] for p in params)

        visibility = get_function_visibility(func_node, source)
        wrapper_params_str = ', '.join(f"{p['type']} {p['name']}" for p in params)

        wrapper = f"""function {func_name}({wrapper_params_str}) {visibility} {{
        {internal_name}({', '.join(call_args)});
    }}"""

        # Replace original with wrapper + internal
        before = source[:func_node.start_byte]
        after = source[func_node.end_byte:]

        return before + wrapper + internal_func + after

    def _split_by_concern(self, source: str, func_node, rng: Random) -> str:
        """
        Split by CEI pattern: Checks, Effects, Interactions.

        Creates separate helpers for:
        - _check*: require/assert statements
        - _apply*: state modifications
        - _interact*: external calls
        """
        body = func_node.child_by_field_name('body')
        statements = get_direct_statements(body, source)

        # Categorize statements
        checks = []
        effects = []
        interactions = []

        for stmt in statements:
            stmt_text = source[stmt.start_byte:stmt.end_byte]

            if self._is_check(stmt_text):
                checks.append(stmt)
            elif self._is_interaction(stmt_text):
                interactions.append(stmt)
            else:
                effects.append(stmt)

        # Build helpers for each category
        func_name = get_function_name(func_node, source)
        params = get_function_params(func_node, source)

        helpers = []
        calls = []

        if checks:
            helper = self._build_category_helper(
                f"_check{func_name.capitalize()}",
                checks, params, source, 'view'
            )
            helpers.append(helper)
            calls.append(f"_check{func_name.capitalize()}({self._build_call_args(params)});")

        if effects:
            helper = self._build_category_helper(
                f"_apply{func_name.capitalize()}",
                effects, params, source, ''
            )
            helpers.append(helper)
            calls.append(f"_apply{func_name.capitalize()}({self._build_call_args(params)});")

        if interactions:
            helper = self._build_category_helper(
                f"_interact{func_name.capitalize()}",
                interactions, params, source, ''
            )
            helpers.append(helper)
            calls.append(f"_interact{func_name.capitalize()}({self._build_call_args(params)});")

        # Rebuild
        new_main = self._rebuild_main(func_node, source, calls)
        return self._assemble(source, func_node, new_main, helpers)

    def _is_check(self, stmt: str) -> bool:
        return 'require' in stmt or 'assert' in stmt or stmt.strip().startswith('if')

    def _is_interaction(self, stmt: str) -> bool:
        return '.call' in stmt or '.transfer' in stmt or '.send' in stmt

    def _generate_helper_names(self, base: str, count: int, rng: Random) -> List[str]:
        prefixes = ['_do', '_execute', '_perform', '_handle', '_process', '_run']
        suffixes = ['Step', 'Part', 'Phase', 'Stage', '']

        names = []
        for i in range(count):
            prefix = rng.choice(prefixes)
            suffix = rng.choice(suffixes)
            names.append(f"{prefix}{base.capitalize()}{suffix}{i + 1}")

        return names
```

### 3.4 Merge Mode (Chimera)

```python
class RestructureMerge:
    """
    Merge mode: Multiple functions -> one with branching.

    Patterns:
    - enum_mode: Use enum for action selection
    - uint_mode: Use uint8 for action selection
    - bytes4_mode: Use function selector pattern
    """

    PATTERNS = ["enum_mode", "uint_mode", "bytes4_mode"]

    def __init__(self, pattern: str, language_plugin: LanguagePlugin):
        if pattern not in self.PATTERNS:
            raise ValueError(f"Unknown merge pattern: {pattern}")
        self.pattern = pattern
        self.language = language_plugin

    def transform(
        self,
        source: str,
        functions_to_merge: List[str],
        rng: Random
    ) -> TransformationResult:
        tree = parse_solidity(source)

        # Collect function info
        func_infos = []
        for name in functions_to_merge:
            node = find_function_by_name(tree, name)
            if node:
                func_infos.append({
                    'name': name,
                    'node': node,
                    'params': get_function_params(node, source),
                    'body': get_function_body(node, source),
                    'visibility': get_function_visibility(node, source),
                    'is_payable': 'payable' in source[node.start_byte:node.end_byte]
                })

        if len(func_infos) < 2:
            raise ValueError("Need at least 2 functions to merge")

        if self.pattern == "enum_mode":
            merged, additions = self._merge_with_enum(func_infos, rng)
        elif self.pattern == "uint_mode":
            merged, additions = self._merge_with_uint(func_infos, rng)
        elif self.pattern == "bytes4_mode":
            merged, additions = self._merge_with_bytes4(func_infos, rng)

        # Remove original functions and add merged
        result = source
        for info in reversed(func_infos):
            result = remove_function(result, info['node'])

        # Add enum (if any) and merged function
        contract_body_start = find_contract_body_start(tree, source)
        result = (
            result[:contract_body_start + 1] +
            additions +
            '\n' + merged +
            result[contract_body_start + 1:]
        )

        return result

    def _merge_with_enum(self, func_infos: List[dict], rng: Random) -> Tuple[str, str]:
        """
        Merge using enum action parameter.

        Before:
            function deposit() external payable { ... }
            function withdraw(uint256 amount) external { ... }

        After:
            enum Action { Deposit, Withdraw }

            function execute(Action action, uint256 amount) external payable {
                if (action == Action.Deposit) { ... }
                else if (action == Action.Withdraw) { ... }
            }
        """
        # Generate enum
        enum_names = ['Action', 'Operation', 'Command', 'Task', 'Mode']
        enum_name = rng.choice(enum_names)

        enum_values = [info['name'].capitalize() for info in func_infos]
        enum_def = f"\n    enum {enum_name} {{ {', '.join(enum_values)} }}\n"

        # Combine parameters
        all_params = self._combine_params(func_infos)
        is_payable = any(info['is_payable'] for info in func_infos)

        # Generate merged function name
        merged_names = ['execute', 'perform', 'process', 'dispatch', 'handle']
        merged_name = rng.choice(merged_names)

        # Build params string
        params_list = [f"{enum_name} action"] + [
            f"{p['type']} {p['name']}" for p in all_params
        ]
        params_str = ', '.join(params_list)

        # Build visibility
        visibility = 'external'
        if is_payable:
            visibility += ' payable'

        # Build body with conditions
        body_parts = []
        for i, info in enumerate(func_infos):
            condition = f"action == {enum_name}.{enum_values[i]}"

            if i == 0:
                body_parts.append(f"if ({condition}) {{")
            else:
                body_parts.append(f"}} else if ({condition}) {{")

            body_parts.append(f"    {info['body'].strip()}")

        body_parts.append("}")
        body = '\n        '.join(body_parts)

        merged = f"""    function {merged_name}({params_str}) {visibility} {{
        {body}
    }}"""

        return merged, enum_def

    def _combine_params(self, func_infos: List[dict]) -> List[dict]:
        """Combine parameters from all functions, deduplicating."""
        seen = set()
        combined = []

        for info in func_infos:
            for param in info['params']:
                if param['name'] not in seen:
                    seen.add(param['name'])
                    combined.append(param)

        return combined
```

### 3.5 Unified Restructure Interface

```python
class RestructureTransformer:
    """
    Unified Restructure transformer.
    Supports both split and merge modes.
    """

    def __init__(
        self,
        mode: Literal["split", "merge"],
        pattern: str,
        language_plugin: LanguagePlugin
    ):
        self.mode = mode
        self.pattern = pattern
        self.language = language_plugin

        if mode == "split":
            self.transformer = RestructureSplit(pattern, language_plugin)
        elif mode == "merge":
            self.transformer = RestructureMerge(pattern, language_plugin)

    def transform(
        self,
        source: str,
        targets: Union[str, List[str]],  # function name(s)
        seed: Optional[int] = None
    ) -> TransformationResult:
        rng = Random(seed or hash(source))

        if self.mode == "split":
            if not isinstance(targets, str):
                raise ValueError("Split mode requires single function name")
            transformed = self.transformer.transform(source, targets, rng)

        elif self.mode == "merge":
            if isinstance(targets, str):
                raise ValueError("Merge mode requires list of function names")
            transformed = self.transformer.transform(source, targets, rng)

        validation = validate_transformation(source, transformed, self.language)

        return TransformationResult(
            code=transformed,
            strategy="restructure",
            strategy_params={
                "mode": self.mode,
                "pattern": self.pattern,
                "targets": targets
            },
            validation=validation
        )
```

### 3.6 CLI Interface

```bash
# Split mode
python -m adversarial transform \
    --strategy restructure \
    --mode split \
    --pattern sequential \
    --target-function withdraw \
    --input contract.sol \
    --output transformed.sol

# Merge mode
python -m adversarial transform \
    --strategy restructure \
    --mode merge \
    --pattern enum_mode \
    --target-functions deposit,withdraw,transfer \
    --input contract.sol \
    --output transformed.sol
```

### 3.7 Output Metadata

```json
{
  "strategy": "restructure",
  "mode": "split",
  "pattern": "sequential",
  "transformation_details": {
    "original_function": "withdraw",
    "helpers_created": [
      "_doWithdrawStep1",
      "_executeWithdrawStep2",
      "_handleWithdrawStep3"
    ],
    "vulnerability_now_spans": ["withdraw", "_executeWithdrawStep2"]
  }
}
```

---

## Strategy 4: Guardian

### 4.1 Overview

**Purpose:** Inject protection mechanisms to test whether models recognize when vulnerabilities are neutralized.

**Merges:** Guardian Shield (explicit protection) + Confidence Trap (implicit protection)

**Hypothesis:** "If a model flags protected code as vulnerable, it pattern-matches on structure rather than understanding exploitability."

**Critical:** This strategy **changes vulnerability status** from vulnerable → safe.

### 4.2 Two Variants

| Variant      | Protection Type                              | Visibility | Detection Difficulty |
| ------------ | -------------------------------------------- | ---------- | -------------------- |
| **Explicit** | ReentrancyGuard, CEI reorder, access control | Obvious    | Easy                 |
| **Implicit** | Hidden mutex, block checks, gas limits       | Subtle     | Hard                 |

### 4.3 Explicit Protections

```python
class GuardianExplicit:
    """
    Explicit protection injection.
    Obvious, standard security patterns.
    """

    PROTECTION_TYPES = [
        "reentrancy_guard",    # OpenZeppelin ReentrancyGuard
        "cei_pattern",         # Reorder to Checks-Effects-Interactions
        "access_control",      # Add onlyOwner/require checks
        "pausable",            # Add pause mechanism
        "solidity_0_8"         # Upgrade to 0.8+ for overflow protection
    ]

    def inject_reentrancy_guard(
        self,
        source: str,
        tree,
        functions: List[str]
    ) -> Tuple[str, dict]:
        """
        Add OpenZeppelin ReentrancyGuard.

        Changes:
        1. Add import
        2. Add inheritance
        3. Add nonReentrant modifier to functions
        """
        edits = []
        details = {'protections_added': []}

        # Add import after pragma
        import_pos = find_import_position(tree, source)
        edits.append({
            'position': import_pos,
            'text': '\nimport "@openzeppelin/contracts/security/ReentrancyGuard.sol";\n'
        })
        details['protections_added'].append('ReentrancyGuard import')

        # Add inheritance
        contract_node = find_first(tree, 'contract_declaration')
        inheritance_edit = create_inheritance_edit(contract_node, source, 'ReentrancyGuard')
        if inheritance_edit:
            edits.append(inheritance_edit)
            details['protections_added'].append('ReentrancyGuard inheritance')

        # Add modifier to functions
        for func_name in functions:
            func_node = find_function_by_name(tree, func_name)
            if func_node:
                modifier_edit = create_modifier_edit(func_node, source, 'nonReentrant')
                if modifier_edit:
                    edits.append(modifier_edit)
                    details['protections_added'].append(f'nonReentrant on {func_name}')

        result = apply_insertions(source, edits)
        return result, details

    def apply_cei_pattern(
        self,
        source: str,
        tree,
        function_name: str,
        state_variable: str
    ) -> Tuple[str, dict]:
        """
        Reorder statements to follow CEI pattern.
        Move state updates before external calls.
        """
        func_node = find_function_by_name(tree, function_name)
        body = func_node.child_by_field_name('body')

        # Find external call and state update
        external_call = find_external_call(body, source)
        state_update = find_state_update(body, source, state_variable)

        if not external_call or not state_update:
            return source, {'error': 'Could not identify statements'}

        # Check if already in correct order
        if state_update.start_byte < external_call.start_byte:
            return source, {'already_protected': True}

        # Swap order
        result = swap_statements(source, state_update, external_call)

        return result, {
            'protections_added': ['CEI pattern reordering'],
            'moved_before': source[state_update.start_byte:state_update.end_byte].strip()[:40]
        }

    def add_access_control(
        self,
        source: str,
        tree,
        functions: List[str]
    ) -> Tuple[str, dict]:
        """
        Add owner-only access control.
        """
        edits = []
        details = {'protections_added': []}

        contract_node = find_first(tree, 'contract_declaration')
        body = contract_node.child_by_field_name('body')

        # Add owner state variable if not exists
        if 'owner' not in source:
            edits.append({
                'position': body.start_byte + 1,
                'text': '\n    address public owner;\n'
            })
            details['protections_added'].append('owner state variable')

        # Add/modify constructor
        constructor = find_first(tree, 'constructor_definition')
        if constructor:
            constructor_body = constructor.child_by_field_name('body')
            edits.append({
                'position': constructor_body.start_byte + 1,
                'text': '\n        owner = msg.sender;'
            })
        else:
            edits.append({
                'position': body.start_byte + 1,
                'text': '''
    constructor() {
        owner = msg.sender;
    }
'''
            })
        details['protections_added'].append('owner initialization in constructor')

        # Add modifier if not exists
        if 'onlyOwner' not in source:
            edits.append({
                'position': body.end_byte - 1,
                'text': '''
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
'''
            })
            details['protections_added'].append('onlyOwner modifier')

        # Add modifier to functions
        for func_name in functions:
            func_node = find_function_by_name(tree, func_name)
            if func_node:
                modifier_edit = create_modifier_edit(func_node, source, 'onlyOwner')
                if modifier_edit:
                    edits.append(modifier_edit)
                    details['protections_added'].append(f'onlyOwner on {func_name}')

        result = apply_insertions(source, edits)
        return result, details
```

### 4.4 Implicit Protections (Absorbed from Confidence Trap)

```python
class GuardianImplicit:
    """
    Implicit protection injection.
    Subtle patterns that prevent exploitation without obvious guards.

    These are designed to look like they serve other purposes
    while actually preventing the vulnerability.
    """

    PROTECTION_TYPES = [
        "hidden_mutex",      # Mapping-based lock disguised as rate limiter
        "block_number",      # Block number check prevents same-tx reentrancy
        "balance_limit",     # Balance too small to exploit profitably
        "gas_limit",         # Use transfer() instead of call()
        "timestamp_lock"     # Timestamp-based cooldown
    ]

    def inject_hidden_mutex(
        self,
        source: str,
        tree,
        function_name: str,
        rng: Random
    ) -> Tuple[str, dict]:
        """
        Add a hidden mutex disguised as rate limiting.

        Adds:
        - mapping(address => uint256) private _lastAction;
        - require(_lastAction[msg.sender] < block.number, "Rate limited");
        - _lastAction[msg.sender] = block.number;

        This prevents reentrancy because block.number doesn't change mid-transaction.
        But it looks like spam prevention, not security.
        """
        edits = []

        # Generate innocuous variable name
        var_names = ['_lastAction', '_lastBlock', '_userCooldown', '_rateLimit']
        var_name = rng.choice(var_names)

        contract_node = find_first(tree, 'contract_declaration')
        body = contract_node.child_by_field_name('body')

        # Add state variable (looks like rate limiting)
        edits.append({
            'position': body.start_byte + 1,
            'text': f'\n    mapping(address => uint256) private {var_name};\n'
        })

        # Add check and update to function
        func_node = find_function_by_name(tree, function_name)
        func_body = func_node.child_by_field_name('body')

        # Add check at start of function
        check_messages = [
            "Rate limited",
            "Please wait",
            "Too frequent",
            "Cooldown active"
        ]

        edits.append({
            'position': func_body.start_byte + 1,
            'text': f'''
        require({var_name}[msg.sender] < block.number, "{rng.choice(check_messages)}");
        {var_name}[msg.sender] = block.number;'''
        })

        result = apply_insertions(source, edits)

        return result, {
            'protection_type': 'hidden_mutex',
            'appears_as': 'rate_limiter',
            'actually_prevents': 'reentrancy',
            'mechanism': 'block.number check prevents same-tx reentry'
        }

    def inject_block_number_check(
        self,
        source: str,
        tree,
        function_name: str,
        rng: Random
    ) -> Tuple[str, dict]:
        """
        Add block number tracking that prevents same-block operations.
        Disguised as a front-running protection.
        """
        var_name = rng.choice(['_lastDepositBlock', '_operationBlock', '_txBlock'])

        # Similar implementation to hidden_mutex
        # but framed as front-running protection

        return result, {
            'protection_type': 'block_number_check',
            'appears_as': 'front_running_protection',
            'actually_prevents': 'reentrancy'
        }

    def inject_balance_limit(
        self,
        source: str,
        tree,
        max_balance: str,  # e.g., "0.1 ether"
        rng: Random
    ) -> Tuple[str, dict]:
        """
        Add balance limit that makes attack unprofitable.
        Disguised as a beta/testing limit.
        """
        contract_node = find_first(tree, 'contract_declaration')
        body = contract_node.child_by_field_name('body')

        # Add constant
        constant_names = ['MAX_DEPOSIT', 'BETA_LIMIT', 'USER_CAP', 'BALANCE_LIMIT']
        const_name = rng.choice(constant_names)

        edits = [{
            'position': body.start_byte + 1,
            'text': f'\n    uint256 public constant {const_name} = {max_balance};\n'
        }]

        # Add check in deposit function
        deposit_func = find_function_by_name(tree, 'deposit')
        if deposit_func:
            deposit_body = deposit_func.child_by_field_name('body')

            check_messages = [
                "Exceeds beta limit",
                "Balance cap reached",
                "Maximum deposit exceeded"
            ]

            edits.append({
                'position': deposit_body.start_byte + 1,
                'text': f'''
        require(balances[msg.sender] + msg.value <= {const_name}, "{rng.choice(check_messages)}");'''
            })

        result = apply_insertions(source, edits)

        return result, {
            'protection_type': 'balance_limit',
            'appears_as': 'beta_testing_limit',
            'actually_prevents': 'profitable_reentrancy',
            'mechanism': f'Max {max_balance} per user makes gas cost exceed potential gain'
        }

    def convert_to_transfer(
        self,
        source: str,
        tree,
        function_name: str
    ) -> Tuple[str, dict]:
        """
        Replace msg.sender.call{value: X}("") with payable(msg.sender).transfer(X).
        transfer() only forwards 2300 gas, preventing reentrancy.
        """
        func_node = find_function_by_name(tree, function_name)

        # Find call pattern
        call_pattern = r'msg\.sender\.call\{value:\s*(\w+)\}\s*\(""\)'
        replacement = r'payable(msg.sender).transfer(\1)'

        func_text = source[func_node.start_byte:func_node.end_byte]
        new_func_text = re.sub(call_pattern, replacement, func_text)

        # Also remove the success check if present
        new_func_text = re.sub(
            r'\(bool\s+\w+,\s*\)\s*=\s*payable\(msg\.sender\)\.transfer\((\w+)\);\s*require\(\w+.*?\);',
            r'payable(msg.sender).transfer(\1);',
            new_func_text
        )

        result = source[:func_node.start_byte] + new_func_text + source[func_node.end_byte:]

        return result, {
            'protection_type': 'gas_limit',
            'mechanism': 'transfer() only forwards 2300 gas',
            'note': 'Weak protection due to gas repricing, but still valid'
        }
```

### 4.5 Unified Guardian Interface

```python
class GuardianTransformer:
    """
    Unified Guardian transformer.
    Supports both explicit and implicit protection injection.
    """

    def __init__(
        self,
        variant: Literal["explicit", "implicit"],
        protection_type: str,
        language_plugin: LanguagePlugin
    ):
        self.variant = variant
        self.protection_type = protection_type
        self.language = language_plugin

        if variant == "explicit":
            self.protector = GuardianExplicit()
        elif variant == "implicit":
            self.protector = GuardianImplicit()

    def transform(
        self,
        source: str,
        vulnerability_info: dict,
        seed: Optional[int] = None
    ) -> TransformationResult:
        """
        Apply protection to neutralize vulnerability.

        Args:
            source: Vulnerable contract code
            vulnerability_info: {
                'type': 'reentrancy',
                'function': 'withdraw',
                'state_variable': 'balances'  # optional
            }
        """
        tree = parse_solidity(source)
        rng = Random(seed or hash(source))

        vuln_type = vulnerability_info.get('type')
        func_name = vulnerability_info.get('function')

        if self.variant == "explicit":
            if self.protection_type == "reentrancy_guard":
                result, details = self.protector.inject_reentrancy_guard(
                    source, tree, [func_name]
                )
            elif self.protection_type == "cei_pattern":
                result, details = self.protector.apply_cei_pattern(
                    source, tree, func_name,
                    vulnerability_info.get('state_variable', 'balances')
                )
            elif self.protection_type == "access_control":
                result, details = self.protector.add_access_control(
                    source, tree, [func_name]
                )

        elif self.variant == "implicit":
            if self.protection_type == "hidden_mutex":
                result, details = self.protector.inject_hidden_mutex(
                    source, tree, func_name, rng
                )
            elif self.protection_type == "block_number":
                result, details = self.protector.inject_block_number_check(
                    source, tree, func_name, rng
                )
            elif self.protection_type == "balance_limit":
                result, details = self.protector.inject_balance_limit(
                    source, tree,
                    vulnerability_info.get('max_balance', '0.1 ether'),
                    rng
                )
            elif self.protection_type == "gas_limit":
                result, details = self.protector.convert_to_transfer(
                    source, tree, func_name
                )

        validation = validate_transformation(source, result, self.language)

        return TransformationResult(
            code=result,
            strategy="guardian",
            strategy_params={
                "variant": self.variant,
                "protection_type": self.protection_type,
                "vulnerability_info": vulnerability_info
            },
            transformation_details=details,
            validation=validation,
            # CRITICAL: Ground truth changes
            ground_truth_change={
                "original_vulnerable": True,
                "transformed_vulnerable": False,
                "neutralized_by": self.protection_type,
                "protection_visibility": self.variant
            }
        )
```

### 4.6 CLI Interface

```bash
# Explicit protection
python -m adversarial transform \
    --strategy guardian \
    --variant explicit \
    --protection-type reentrancy_guard \
    --vuln-function withdraw \
    --input contract.sol \
    --output protected.sol

# Implicit protection
python -m adversarial transform \
    --strategy guardian \
    --variant implicit \
    --protection-type hidden_mutex \
    --vuln-function withdraw \
    --input contract.sol \
    --output protected.sol
```

### 4.7 Output Metadata

```json
{
  "strategy": "guardian",
  "variant": "implicit",
  "protection_type": "hidden_mutex",
  "transformation_details": {
    "protection_type": "hidden_mutex",
    "appears_as": "rate_limiter",
    "actually_prevents": "reentrancy",
    "mechanism": "block.number check prevents same-tx reentry"
  },
  "ground_truth_change": {
    "original_vulnerable": true,
    "transformed_vulnerable": false,
    "neutralized_by": "hidden_mutex",
    "protection_visibility": "implicit"
  }
}
```

---

## Summary: Implementation Checklist

### What to Update

| Component               | Action                                               | Priority |
| ----------------------- | ---------------------------------------------------- | -------- |
| `chameleon.py`          | Add `mode` parameter, create `DomainMappingStrategy` | High     |
| `mirror.py`             | Rename to `shapeshifter.py`, add levels              | High     |
| Create `restructure.py` | Unify Hydra + Chimera                                | Medium   |
| `guardian_shield.py`    | Rename to `guardian.py`, add implicit variant        | High     |
| CLI                     | Update argument parsing for new structure            | Medium   |
| Tests                   | Update for new unified interfaces                    | High     |

### New Files Needed

```
adversarial/
├── strategies/
│   ├── chameleon.py      # Updated with domain mode
│   ├── shapeshifter.py   # New (absorbs mirror)
│   ├── restructure.py    # New (hydra + chimera)
│   └── guardian.py       # Updated with implicit variant
└── themes/
    └── domains/          # New domain mapping files
        ├── defi_to_gaming.yaml
        ├── defi_to_healthcare.yaml
        ├── defi_to_logistics.yaml
        └── defi_to_social.yaml
```

### Final 4 Automated Strategies

| Strategy         | Modes/Variants     | Automation |
| ---------------- | ------------------ | ---------- |
| **Chameleon**    | theme, domain      | 90%        |
| **Shapeshifter** | L1, L2, L3, L4     | 85%        |
| **Restructure**  | split, merge       | 60%        |
| **Guardian**     | explicit, implicit | 70%        |

---

**Document Version:** 2.0 (Consolidated)  
**Previous Implementations:** Chameleon, Mirror, Hydra, Chimera, Guardian Shield remain valid—this document shows how they merge  
**Status:** Ready for Implementation
