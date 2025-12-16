# Automated Adversarial Transformation Toolkit

## Implementation Guide for Smart Contract Code Transformations

**Purpose:** This document contains everything needed to implement automated code transformation strategies for creating adversarial test cases for smart contract AI evaluation.

**Target:** Fully automatable strategies (Chameleon, Mirror, Cross-Domain, Guardian Shield)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Strategy Specifications](#3-strategy-specifications)
4. [Data Structures](#4-data-structures)
5. [Renaming Dictionaries](#5-renaming-dictionaries)
6. [Protection Templates](#6-protection-templates)
7. [Implementation Plan](#7-implementation-plan)
8. [Testing & Validation](#8-testing--validation)

---

## 1. Project Overview

### 1.1 What We're Building

A Python toolkit that takes Solidity smart contracts and produces adversarial variants through mechanical transformations. The transformations preserve (or intentionally modify) vulnerability status while changing surface-level code features.

### 1.2 Why

We're building a benchmark to evaluate whether AI models truly understand smart contract vulnerabilities or merely pattern-match on memorized examples. These transformations test specific hypotheses:

- **Chameleon:** Does renaming "withdraw" to "releaseUnits" break detection?
- **Mirror:** Does reformatting code break detection?
- **Cross-Domain:** Does changing from DeFi to Gaming terminology break detection?
- **Guardian Shield:** Can the model recognize protection mechanisms?

### 1.3 Strategies to Implement

| Strategy                               | Automation Level | Priority |
| -------------------------------------- | ---------------- | -------- |
| Chameleon (Renaming)                   | 95%              | P0       |
| Mirror (Reformatting)                  | 100%             | P0       |
| Cross-Domain (Domain Swap)             | 90%              | P1       |
| Guardian Shield (Protection Injection) | 80%              | P1       |

### 1.4 Expected Output

For each input contract, generate:

- Transformed Solidity code (compilable)
- Metadata JSON documenting the transformation
- Verification that compilation succeeds

---

## 2. Architecture

### 2.1 High-Level Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    TRANSFORMATION PIPELINE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   INPUT                                                         │
│   ├── source.sol (original contract)                           │
│   ├── metadata.json (vulnerability info, ground truth)         │
│   └── config.yaml (transformation settings)                    │
│                                                                 │
│   PARSE                                                         │
│   ├── Solidity Parser → AST                                    │
│   ├── Extract identifiers (contracts, functions, variables)    │
│   └── Extract structure (imports, inheritance, modifiers)      │
│                                                                 │
│   TRANSFORM                                                     │
│   ├── Strategy-specific transformer                            │
│   ├── Apply transformations to AST or source                   │
│   └── Preserve/modify vulnerability as specified               │
│                                                                 │
│   GENERATE                                                      │
│   ├── Regenerate Solidity from transformed AST                 │
│   ├── Or apply string-level transformations                    │
│   └── Produce transformation metadata                          │
│                                                                 │
│   VALIDATE                                                      │
│   ├── Compile with solc                                        │
│   ├── Verify no syntax errors                                  │
│   └── Optionally run basic semantic checks                     │
│                                                                 │
│   OUTPUT                                                        │
│   ├── transformed.sol                                          │
│   ├── transformation_metadata.json                             │
│   └── compilation_result.json                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Directory Structure

```
adversarial-toolkit/
├── src/
│   ├── __init__.py
│   ├── parser.py              # Solidity parsing utilities
│   ├── transformers/
│   │   ├── __init__.py
│   │   ├── base.py            # Base transformer class
│   │   ├── chameleon.py       # Renaming transformer
│   │   ├── mirror.py          # Reformatting transformer
│   │   ├── cross_domain.py    # Domain swap transformer
│   │   └── guardian_shield.py # Protection injection transformer
│   ├── generator.py           # Code generation from AST
│   ├── validator.py           # Compilation and validation
│   └── pipeline.py            # Main orchestration
├── config/
│   ├── rename_themes/
│   │   ├── resource_management.yaml
│   │   ├── gaming.yaml
│   │   ├── abstract.yaml
│   │   └── social.yaml
│   ├── domain_mappings/
│   │   ├── defi_to_gaming.yaml
│   │   ├── defi_to_nft.yaml
│   │   └── defi_to_social.yaml
│   ├── protection_templates/
│   │   ├── reentrancy_guard.sol.template
│   │   ├── cei_pattern.yaml
│   │   └── access_control.sol.template
│   └── formatter_configs/
│       ├── compressed.json
│       ├── expanded.json
│       └── allman.json
├── tests/
│   ├── test_chameleon.py
│   ├── test_mirror.py
│   ├── test_cross_domain.py
│   ├── test_guardian_shield.py
│   └── fixtures/
│       └── sample_contracts/
├── scripts/
│   ├── batch_transform.py     # Process multiple contracts
│   └── validate_output.py     # Validate generated contracts
├── requirements.txt
└── README.md
```

### 2.3 Dependencies

```
# requirements.txt
solidity-parser-antlr>=0.1.0   # Solidity AST parsing
py-solc-x>=2.0.0               # Solidity compilation
pyyaml>=6.0                    # Config file parsing
click>=8.0                     # CLI interface
jinja2>=3.0                    # Template rendering
```

Alternative parser options:

- `slither-analyzer` (has good AST support)
- `crytic-compile` (compilation wrapper)

---

## 3. Strategy Specifications

### 3.1 Chameleon (Systematic Renaming)

#### Purpose

Rename all identifiers to test if models rely on keywords like "withdraw", "balance", "transfer".

#### Transformation Rules

| Element Type    | Transformation     | Example                                                                         |
| --------------- | ------------------ | ------------------------------------------------------------------------------- |
| Contract name   | Theme-based rename | `Vault` → `ResourceManager`                                                     |
| Function names  | Theme-based rename | `withdraw` → `releaseUnits`                                                     |
| State variables | Theme-based rename | `balances` → `allocations`                                                      |
| Local variables | Theme-based rename | `amount` → `quantity`                                                           |
| Parameters      | Theme-based rename | `user` → `account`                                                              |
| Events          | Theme-based rename | `Withdrawal` → `UnitsReleased`                                                  |
| Errors          | Theme-based rename | `InsufficientBalance` → `AllocationExceeded`                                    |
| Modifiers       | Theme-based rename | `onlyOwner` → `onlyAdmin`                                                       |
| Mappings        | Theme-based rename | `mapping(address => uint256) balances` → `mapping(address => uint256) registry` |

#### What NOT to Rename

- Solidity keywords (`require`, `revert`, `emit`, `mapping`, etc.)
- Built-in types (`uint256`, `address`, `bool`, `bytes`, etc.)
- Built-in globals (`msg.sender`, `block.timestamp`, `tx.origin`, etc.)
- External contract/interface names that must match (ERC20, IERC20, etc.)
- OpenZeppelin imports (keep as-is)

#### Algorithm

```python
def chameleon_transform(ast, theme):
    # 1. Extract all user-defined identifiers
    identifiers = extract_identifiers(ast)

    # 2. Build rename mapping from theme
    rename_map = {}
    for ident in identifiers:
        if ident.type == 'contract':
            rename_map[ident.name] = theme.contract_names.get(ident.name) or generate_name(ident, theme)
        elif ident.type == 'function':
            rename_map[ident.name] = theme.function_names.get(ident.name) or generate_name(ident, theme)
        # ... etc

    # 3. Apply renames to AST
    renamed_ast = apply_renames(ast, rename_map)

    # 4. Remove or neutralize comments
    renamed_ast = strip_security_comments(renamed_ast)

    return renamed_ast, rename_map
```

#### Output Metadata

```json
{
  "strategy": "chameleon",
  "theme": "resource_management",
  "renames": {
    "Vault": "ResourceManager",
    "withdraw": "releaseUnits",
    "balances": "allocations"
  },
  "identifiers_changed": 12,
  "comments_removed": true,
  "vulnerability_preserved": true
}
```

---

### 3.2 Mirror (Format Transformation)

#### Purpose

Change code formatting to test if models are sensitive to visual presentation.

#### Transformation Modes

**Mode 1: Compressed**

- Remove all unnecessary whitespace
- Remove blank lines
- Collapse to minimum lines possible

**Mode 2: Expanded**

- Add blank lines between all statements
- One statement per line
- Maximum whitespace

**Mode 3: Allman Style**

- Opening braces on new line
- Consistent indentation

**Mode 4: K&R Style**

- Opening braces on same line
- Compact style

#### Transformation Rules

| Element         | Compressed          | Expanded               | Allman        |
| --------------- | ------------------- | ---------------------- | ------------- |
| Blank lines     | Remove all          | Add between statements | Preserve some |
| Indentation     | Remove              | 4 spaces               | 4 spaces      |
| Braces          | Same line, no space | New lines              | New lines     |
| Operators       | No spaces           | Spaces around          | Spaces around |
| Function params | No spaces           | Aligned multi-line     | Inline        |

#### Algorithm

```python
def mirror_transform(source, mode):
    if mode == 'compressed':
        # Use regex or token-based compression
        result = remove_comments(source)
        result = remove_blank_lines(result)
        result = compress_whitespace(result)
        result = collapse_braces(result)

    elif mode == 'expanded':
        # Parse and regenerate with maximum spacing
        result = add_blank_lines_between_statements(source)
        result = expand_parameters_multiline(result)

    elif mode == 'allman':
        # Move opening braces to new lines
        result = convert_brace_style(source, 'allman')

    return result
```

#### Important

- Must preserve semantic meaning exactly
- Must still compile
- String literals must not be modified
- Comments can be removed (they're not semantic)

#### Output Metadata

```json
{
  "strategy": "mirror",
  "mode": "compressed",
  "original_lines": 45,
  "transformed_lines": 12,
  "original_chars": 1523,
  "transformed_chars": 892,
  "comments_removed": true,
  "vulnerability_preserved": true
}
```

---

### 3.3 Cross-Domain (Domain Terminology Swap)

#### Purpose

Test if understanding transfers across domain contexts. Same vulnerability pattern, different business terminology.

#### Domain Definitions

**DeFi (Source Domain)**

```yaml
entities:
  contract: Vault, Pool, Bank, Treasury
  balance: balance, collateral, stake, deposit
  user: user, depositor, staker, lender

actions:
  deposit: deposit, stake, supply, provide
  withdraw: withdraw, unstake, redeem, claim
  transfer: transfer, send, move

events:
  deposit_event: Deposit, Staked, Supplied
  withdraw_event: Withdrawal, Unstaked, Redeemed
```

**Gaming (Target Domain)**

```yaml
entities:
  contract: GameVault, LootBox, Inventory, Treasury
  balance: loot, rewards, coins, points, gems
  user: player, gamer, character, hero

actions:
  deposit: earnLoot, collectRewards, gainCoins
  withdraw: claimLoot, redeemRewards, spendCoins
  transfer: tradeLoot, giftRewards, sendCoins

events:
  deposit_event: LootEarned, RewardsCollected
  withdraw_event: LootClaimed, RewardsRedeemed
```

**NFT Marketplace (Target Domain)**

```yaml
entities:
  contract: Marketplace, Gallery, Exchange
  balance: proceeds, earnings, royalties
  user: seller, buyer, creator, collector

actions:
  deposit: listItem, createAuction
  withdraw: claimProceeds, withdrawEarnings
  transfer: transferItem, sendNFT

events:
  deposit_event: ItemListed, AuctionCreated
  withdraw_event: ProceedsClaimed, EarningsWithdrawn
```

**Social/Reputation (Target Domain)**

```yaml
entities:
  contract: ReputationHub, SocialVault, TipJar
  balance: reputation, karma, tips, influence
  user: member, creator, influencer

actions:
  deposit: earnReputation, receiveTip
  withdraw: redeemReputation, withdrawTips
  transfer: transferReputation, sendTip

events:
  deposit_event: ReputationEarned, TipReceived
  withdraw_event: ReputationRedeemed, TipsWithdrawn
```

#### Algorithm

```python
def cross_domain_transform(ast, source_domain, target_domain):
    # 1. Load domain mappings
    source_terms = load_domain(source_domain)
    target_terms = load_domain(target_domain)

    # 2. Detect which source terms are present
    detected = detect_domain_terms(ast, source_terms)

    # 3. Build mapping from detected source to target
    mapping = {}
    for term in detected:
        category = source_terms.get_category(term)
        mapping[term] = target_terms.get_equivalent(category)

    # 4. Apply like Chameleon
    transformed = apply_renames(ast, mapping)

    return transformed, mapping
```

#### Output Metadata

```json
{
  "strategy": "cross_domain",
  "source_domain": "defi",
  "target_domain": "gaming",
  "term_mappings": {
    "Vault": "GameVault",
    "withdraw": "claimLoot",
    "balances": "lootBalance",
    "Withdrawal": "LootClaimed"
  },
  "domain_terms_changed": 8,
  "vulnerability_preserved": true
}
```

---

### 3.4 Guardian Shield (Protection Injection)

#### Purpose

Inject protection mechanisms that neutralize vulnerabilities while keeping the vulnerable-looking pattern. Tests if models recognize protections.

#### Protection Types

**Type 1: ReentrancyGuard (OpenZeppelin)**

Injection steps:

1. Add import: `import "@openzeppelin/contracts/security/ReentrancyGuard.sol";`
2. Add inheritance: `contract X is ReentrancyGuard`
3. Add modifier to vulnerable function: `function withdraw(...) external nonReentrant`

**Type 2: CEI Pattern Fix**

Transformation:

1. Detect external call line
2. Detect state update line
3. Swap their order (state update before external call)

**Type 3: Access Control Addition**

Injection steps:

1. Add state variable: `address public owner;`
2. Add constructor assignment: `owner = msg.sender;`
3. Add require to function: `require(msg.sender == owner, "Not owner");`

**Type 4: Solidity 0.8+ (for overflow)**

Transformation:

1. Change pragma from `^0.7.x` to `^0.8.0`
2. Remove SafeMath usage (now built-in)

#### Templates

**ReentrancyGuard Template:**

```solidity
// INJECTION: Add at top of file
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// INJECTION: Add to contract inheritance
contract {{CONTRACT_NAME}} is ReentrancyGuard {

// INJECTION: Add modifier to function
function {{FUNCTION_NAME}}({{PARAMS}}) external nonReentrant {
```

**CEI Pattern Template:**

```yaml
# Detection pattern for vulnerable code
vulnerable_pattern:
  - type: external_call
    target: msg.sender
    method: call
  - type: state_update
    variable: balances
    operation: subtract
  - constraint: external_call.line < state_update.line

# Fix: swap the order
fix:
  action: swap_lines
  line1: external_call.line
  line2: state_update.line
```

#### Algorithm

```python
def guardian_shield_transform(ast, protection_type, vuln_info):
    if protection_type == 'reentrancy_guard':
        # Add import
        ast = add_import(ast, "openzeppelin/ReentrancyGuard.sol")
        # Add inheritance
        ast = add_inheritance(ast, vuln_info.contract_name, "ReentrancyGuard")
        # Add modifier to vulnerable function
        ast = add_modifier(ast, vuln_info.function_name, "nonReentrant")

    elif protection_type == 'cei_pattern':
        # Find external call and state update
        ext_call = find_external_call(ast, vuln_info.function_name)
        state_update = find_state_update(ast, vuln_info.function_name, vuln_info.state_var)
        # Swap if in wrong order
        if ext_call.line < state_update.line:
            ast = swap_statements(ast, ext_call, state_update)

    elif protection_type == 'access_control':
        # Add owner variable
        ast = add_state_variable(ast, "address public owner")
        # Add constructor assignment
        ast = add_to_constructor(ast, "owner = msg.sender")
        # Add require to function
        ast = add_require(ast, vuln_info.function_name,
                         'require(msg.sender == owner, "Not owner")')

    return ast
```

#### Output Metadata

```json
{
  "strategy": "guardian_shield",
  "protection_type": "reentrancy_guard",
  "injection_details": {
    "import_added": "@openzeppelin/contracts/security/ReentrancyGuard.sol",
    "inheritance_added": "ReentrancyGuard",
    "modifier_added": {
      "function": "withdraw",
      "modifier": "nonReentrant"
    }
  },
  "original_vulnerable": true,
  "transformed_vulnerable": false,
  "vulnerability_neutralized_by": "mutex_lock_prevents_reentry"
}
```

---

## 4. Data Structures

### 4.1 Input Contract Schema

```json
{
  "id": "vuln_reentrancy_001",
  "source_file": "Vault.sol",
  "solidity_version": "^0.8.0",
  "code": "// SPDX-License-Identifier...",

  "vulnerability": {
    "is_vulnerable": true,
    "type": "reentrancy",
    "location": {
      "contract": "Vault",
      "function": "withdraw",
      "lines": [15, 18]
    },
    "root_cause": "External call before state update",
    "state_variable": "balances"
  },

  "identifiers": {
    "contracts": ["Vault"],
    "functions": ["deposit", "withdraw", "getBalance"],
    "state_variables": ["balances", "owner"],
    "events": ["Deposit", "Withdrawal"],
    "modifiers": []
  }
}
```

### 4.2 Transformation Output Schema

```json
{
  "id": "vuln_reentrancy_001_chameleon_resource",
  "source_id": "vuln_reentrancy_001",
  "strategy": "chameleon",
  "strategy_params": {
    "theme": "resource_management"
  },

  "transformed_code": "// SPDX-License-Identifier...",

  "transformation_details": {
    "renames": {...},
    "lines_changed": 25,
    "comments_removed": true
  },

  "validation": {
    "compiles": true,
    "compiler_version": "0.8.19",
    "warnings": []
  },

  "ground_truth": {
    "is_vulnerable": true,
    "vulnerability_preserved": true,
    "same_vulnerability_type": "reentrancy"
  }
}
```

### 4.3 Batch Processing Schema

```json
{
  "batch_id": "batch_20251215_001",
  "source_dataset": "gold_standard_post_cutoff",
  "strategies_applied": ["chameleon", "mirror", "guardian_shield"],
  "total_inputs": 50,
  "total_outputs": 200,

  "results": {
    "successful": 195,
    "failed_compilation": 3,
    "failed_parsing": 2
  },

  "output_files": [
    {"id": "...", "path": "output/..."},
    ...
  ]
}
```

---

## 5. Renaming Dictionaries

### 5.1 Resource Management Theme

```yaml
# config/rename_themes/resource_management.yaml
theme_name: resource_management
description: Generic resource/allocation terminology

contract_names:
  Vault: ResourceManager
  Bank: AllocationController
  Treasury: AssetRegistry
  Pool: ResourcePool
  default_pattern: '{noun}Manager'

function_names:
  withdraw: releaseUnits
  deposit: allocateUnits
  transfer: reassignUnits
  claim: obtainUnits
  stake: commitUnits
  unstake: uncommitUnits
  getBalance: getAllocation
  default_pattern: '{verb}Units'

variable_names:
  balance: allocation
  balances: allocations
  amount: quantity
  user: account
  owner: administrator
  total: aggregate
  pending: queued
  default_pattern: '{noun}Value'

event_names:
  Deposit: UnitsAllocated
  Withdrawal: UnitsReleased
  Transfer: UnitsReassigned
  default_pattern: 'Units{action}'

error_names:
  InsufficientBalance: InsufficientAllocation
  Unauthorized: AccessDenied
  default_pattern: '{condition}Error'
```

### 5.2 Gaming Theme

```yaml
# config/rename_themes/gaming.yaml
theme_name: gaming
description: Gaming/rewards terminology

contract_names:
  Vault: LootVault
  Bank: TreasureHoard
  Treasury: RewardsTreasury
  Pool: LootPool
  default_pattern: '{noun}Chamber'

function_names:
  withdraw: claimLoot
  deposit: storeLoot
  transfer: tradeLoot
  claim: collectReward
  stake: wagerTokens
  unstake: retrieveWager
  getBalance: checkLoot
  default_pattern: '{verb}Loot'

variable_names:
  balance: lootBalance
  balances: playerLoot
  amount: lootAmount
  user: player
  owner: gamemaster
  total: totalLoot
  pending: unclaimedLoot
  default_pattern: '{noun}Points'

event_names:
  Deposit: LootStored
  Withdrawal: LootClaimed
  Transfer: LootTraded
  default_pattern: 'Loot{action}'
```

### 5.3 Abstract/Technical Theme

```yaml
# config/rename_themes/abstract.yaml
theme_name: abstract
description: Abstract/technical terminology (neutral)

contract_names:
  Vault: StateContainer
  Bank: DataStore
  Treasury: ValueHolder
  Pool: AggregateStore
  default_pattern: '{noun}Container'

function_names:
  withdraw: executeOutflow
  deposit: executeInflow
  transfer: executeTransition
  claim: executeRetrieval
  getBalance: queryState
  default_pattern: 'execute{action}'

variable_names:
  balance: stateValue
  balances: stateMapping
  amount: deltaValue
  user: entity
  owner: controller
  total: aggregateValue
  default_pattern: '{noun}Data'

event_names:
  Deposit: InflowExecuted
  Withdrawal: OutflowExecuted
  Transfer: TransitionExecuted
  default_pattern: '{action}Executed'
```

### 5.4 Solidity Reserved Words (Do Not Rename)

```yaml
# config/reserved_words.yaml
keywords:
  - pragma
  - solidity
  - import
  - contract
  - interface
  - library
  - function
  - modifier
  - event
  - struct
  - enum
  - mapping
  - require
  - revert
  - assert
  - return
  - if
  - else
  - for
  - while
  - do
  - break
  - continue
  - try
  - catch
  - emit
  - new
  - delete
  - true
  - false
  - this
  - super

types:
  - uint
  - uint8
  - uint16
  - uint32
  - uint64
  - uint128
  - uint256
  - int
  - int8
  - int16
  - int32
  - int64
  - int128
  - int256
  - bool
  - address
  - bytes
  - bytes1
  - bytes32
  - string
  - payable

globals:
  - msg
  - msg.sender
  - msg.value
  - msg.data
  - block
  - block.timestamp
  - block.number
  - tx
  - tx.origin
  - tx.gasprice
  - gasleft
  - abi
  - keccak256
  - sha256
  - ecrecover

visibility:
  - public
  - private
  - internal
  - external
  - view
  - pure
  - constant
  - immutable
  - override
  - virtual
```

---

## 6. Protection Templates

### 6.1 ReentrancyGuard Injection

```solidity
// templates/reentrancy_guard.sol.template

// === IMPORT TO ADD ===
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// === INHERITANCE TO ADD ===
// Before: contract {{CONTRACT_NAME}} {
// After:  contract {{CONTRACT_NAME}} is ReentrancyGuard {

// === MODIFIER TO ADD TO FUNCTION ===
// Before: function {{FUNC_NAME}}({{PARAMS}}) {{VISIBILITY}} {
// After:  function {{FUNC_NAME}}({{PARAMS}}) {{VISIBILITY}} nonReentrant {
```

### 6.2 CEI Pattern Transformation

```yaml
# templates/cei_pattern.yaml
name: checks_effects_interactions

detection:
  # Find external call pattern
  external_call_pattern: |
    (bool {{VAR}},) = {{TARGET}}.call{value: {{AMOUNT}}}("");

  # Find state update pattern
  state_update_pattern: |
    {{MAPPING}}[{{KEY}}] -= {{AMOUNT}};

  # Vulnerable if external_call comes BEFORE state_update
  vulnerable_condition: 'external_call.line_number < state_update.line_number'

transformation:
  action: swap_statements
  description: 'Move state update before external call'
  # Additional: may need to handle the variable used in call
  # If: balances[msg.sender] -= amount; ... call{value: amount}
  # The amount variable must be captured before state update
```

### 6.3 Access Control Injection

```solidity
// templates/access_control.sol.template

// === STATE VARIABLE TO ADD ===
address public owner;

// === CONSTRUCTOR ADDITION ===
constructor() {
    owner = msg.sender;
}

// === REQUIRE TO ADD AT FUNCTION START ===
require(msg.sender == owner, "Not authorized");
```

---

## 7. Implementation Plan

### 7.1 Phase 1: Core Infrastructure (Days 1-2)

**Tasks:**

1. Set up project structure
2. Implement Solidity parser wrapper
3. Implement basic AST traversal utilities
4. Set up compilation validation with solc
5. Create CLI skeleton

**Deliverables:**

- `parser.py` - Parse Solidity to AST
- `validator.py` - Compile and validate
- `cli.py` - Basic command structure
- Unit tests for parsing

**Test:**

```bash
python -m pytest tests/test_parser.py
python cli.py parse sample.sol
```

---

### 7.2 Phase 2: Chameleon Transformer (Days 3-4)

**Tasks:**

1. Implement identifier extraction from AST
2. Implement rename mapping generation
3. Implement rename application to AST
4. Implement code regeneration
5. Implement comment stripping
6. Load rename themes from YAML

**Deliverables:**

- `transformers/chameleon.py`
- `config/rename_themes/*.yaml`
- Unit tests

**Test:**

```bash
python cli.py transform chameleon --theme resource_management input.sol -o output.sol
```

---

### 7.3 Phase 3: Mirror Transformer (Days 4-5)

**Tasks:**

1. Implement whitespace compression
2. Implement whitespace expansion
3. Implement brace style conversion
4. Preserve string literals and semantic content

**Deliverables:**

- `transformers/mirror.py`
- `config/formatter_configs/*.json`
- Unit tests

**Test:**

```bash
python cli.py transform mirror --mode compressed input.sol -o output.sol
python cli.py transform mirror --mode allman input.sol -o output.sol
```

---

### 7.4 Phase 4: Cross-Domain Transformer (Days 5-6)

**Tasks:**

1. Define domain term mappings
2. Implement domain term detection
3. Implement cross-domain renaming (extends Chameleon)
4. Test across DeFi → Gaming, NFT, Social

**Deliverables:**

- `transformers/cross_domain.py`
- `config/domain_mappings/*.yaml`
- Unit tests

**Test:**

```bash
python cli.py transform cross-domain --from defi --to gaming input.sol -o output.sol
```

---

### 7.5 Phase 5: Guardian Shield Transformer (Days 6-7)

**Tasks:**

1. Implement import injection
2. Implement inheritance modification
3. Implement modifier injection
4. Implement CEI pattern swap
5. Implement access control injection

**Deliverables:**

- `transformers/guardian_shield.py`
- `config/protection_templates/*.template`
- Unit tests

**Test:**

```bash
python cli.py transform guardian-shield --protection reentrancy_guard input.sol -o output.sol
python cli.py transform guardian-shield --protection cei_pattern input.sol -o output.sol
```

---

### 7.6 Phase 6: Batch Processing & Output (Day 7)

**Tasks:**

1. Implement batch processing pipeline
2. Generate metadata JSON for each transformation
3. Generate summary reports
4. Handle errors gracefully

**Deliverables:**

- `pipeline.py`
- `scripts/batch_transform.py`
- Output schema validation

**Test:**

```bash
python scripts/batch_transform.py --input-dir contracts/ --strategies chameleon,mirror --output-dir output/
```

---

## 8. Testing & Validation

### 8.1 Unit Test Requirements

**For each transformer:**

1. Test on minimal contract (5-10 lines)
2. Test on medium contract (50-100 lines)
3. Test on complex contract (200+ lines, multiple contracts)
4. Verify output compiles
5. Verify identifiers are renamed (Chameleon)
6. Verify formatting changes applied (Mirror)
7. Verify protection mechanisms present (Guardian Shield)

### 8.2 Validation Checklist

```python
def validate_transformation(original, transformed, strategy):
    checks = {
        'compiles': compile_check(transformed),
        'no_syntax_errors': syntax_check(transformed),
        'same_structure': structure_preserved(original, transformed),  # for Chameleon/Mirror
        'protection_present': protection_check(transformed),  # for Guardian Shield
    }

    if strategy == 'chameleon':
        checks['no_original_identifiers'] = no_original_names(original, transformed)
        checks['all_renamed_consistently'] = consistent_renames(transformed)

    if strategy == 'guardian_shield':
        checks['import_present'] = has_import(transformed, 'ReentrancyGuard')
        checks['modifier_present'] = has_modifier(transformed, 'nonReentrant')

    return all(checks.values()), checks
```

### 8.3 Sample Test Contracts

Include at minimum:

1. Simple reentrancy (10 lines)
2. Access control vulnerability (15 lines)
3. Integer overflow (pre-0.8) (10 lines)
4. Multi-function contract (50 lines)
5. Contract with inheritance (30 lines)
6. Contract with events and modifiers (40 lines)

### 8.4 Edge Cases to Handle

- Contracts with no functions
- Contracts with only constructor
- Multiple contracts in one file
- Contracts with assembly blocks
- Contracts with complex inheritance
- Contracts importing external files
- Contracts with inline comments in strings

---

## Appendix A: CLI Reference

```bash
# Parse and show AST
python cli.py parse <input.sol>

# Transform single file
python cli.py transform <strategy> [options] <input.sol> -o <output.sol>

# Strategies:
#   chameleon --theme <theme_name>
#   mirror --mode <compressed|expanded|allman>
#   cross-domain --from <domain> --to <domain>
#   guardian-shield --protection <protection_type>

# Batch transform
python scripts/batch_transform.py \
    --input-dir <dir> \
    --output-dir <dir> \
    --strategies chameleon,mirror,guardian_shield \
    --chameleon-themes resource_management,gaming \
    --mirror-modes compressed,allman \
    --guardian-protections reentrancy_guard,cei_pattern

# Validate outputs
python scripts/validate_output.py --dir <output_dir>
```

---

## Appendix B: Quick Start

```bash
# 1. Clone and setup
git clone <repo>
cd adversarial-toolkit
pip install -r requirements.txt

# 2. Install solc
pip install py-solc-x
python -c "from solcx import install_solc; install_solc('0.8.19')"

# 3. Test on sample
python cli.py transform chameleon --theme gaming sample.sol -o output.sol

# 4. Verify
python cli.py validate output.sol
```

---

**Document Version:** 1.0
**Ready for Implementation**
