# Automatable Adversarial Strategies: Complete Implementation Guide

## Beyond Chameleon: Mirror, Cross-Domain, Guardian Shield, Hydra, Chimera

**Version:** 1.0  
**Purpose:** Enable implementation of all automatable transformation strategies  
**Prerequisite:** Chameleon infrastructure (Tree-sitter parsing, byte-position replacement)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Strategy A2: Mirror (Format Transformation)](#2-strategy-a2-mirror-format-transformation)
3. [Strategy D3: Cross-Domain (Terminology Swap)](#3-strategy-d3-cross-domain-terminology-swap)
4. [Strategy C1: Guardian Shield (Protection Injection)](#4-strategy-c1-guardian-shield-protection-injection)
5. [Strategy B1: Hydra (Function Splitting)](#5-strategy-b1-hydra-function-splitting)
6. [Strategy B2: Chimera (Function Merging)](#6-strategy-b2-chimera-function-merging)
7. [Shared Infrastructure](#7-shared-infrastructure)
8. [Validation Requirements](#8-validation-requirements)
9. [Output Schema](#9-output-schema)

---

## 1. Overview

### 1.1 Strategy Summary

| Strategy        | Category   | Automation | Vulnerability Change | What It Tests            |
| --------------- | ---------- | ---------- | -------------------- | ------------------------ |
| Mirror          | Surface    | 100%       | Preserved            | Visual/format dependence |
| Cross-Domain    | Reasoning  | 90%        | Preserved            | Domain transfer ability  |
| Guardian Shield | Semantic   | 80%        | Neutralized          | Protection recognition   |
| Hydra           | Structural | 60%        | Preserved            | Cross-function tracing   |
| Chimera         | Structural | 60%        | Preserved            | Branch analysis          |

### 1.2 Shared Dependencies

All strategies build on the Chameleon infrastructure:

- Tree-sitter parsing
- Byte-position replacement
- Validation pipeline
- Coverage tracking

### 1.3 Key Principle: Preserve Compilability

Every transformation MUST:

1. Produce syntactically valid code
2. Compile without errors
3. Preserve semantic behavior (except Guardian Shield which intentionally changes it)

---

## 2. Strategy A2: Mirror (Format Transformation)

### 2.1 Purpose

Test whether models are sensitive to code formatting and visual presentation. Same logic, different whitespace/braces/indentation.

### 2.2 Hypothesis

> "If a model's accuracy changes when code is reformatted, it relies on visual patterns rather than semantic understanding."

### 2.3 Transformation Modes

| Mode         | Description                                    | Use Case                          |
| ------------ | ---------------------------------------------- | --------------------------------- |
| `compressed` | Minimal whitespace, single-line where possible | Test extreme compression handling |
| `expanded`   | Maximum whitespace, one statement per line     | Test verbosity handling           |
| `allman`     | Braces on new lines (Allman style)             | Test brace style sensitivity      |
| `knr`        | Braces on same line (K&R style)                | Test brace style sensitivity      |
| `minified`   | Remove all non-essential whitespace            | Extreme compression               |

### 2.4 Implementation Approach

**DO NOT use Tree-sitter for formatting.** Use external formatters:

| Language | Tool                | Modes                   |
| -------- | ------------------- | ----------------------- |
| Solidity | `forge fmt`         | Standard formatting     |
| Solidity | `prettier-solidity` | Configurable formatting |
| Rust     | `rustfmt`           | Standard formatting     |

For modes not supported by formatters, use custom transformations.

### 2.5 Mode Specifications

#### 2.5.1 Compressed Mode

```python
def apply_compressed(source: str) -> str:
    """
    Compress code to minimal whitespace while preserving correctness.

    Rules:
    1. Remove all comments (single-line and multi-line)
    2. Remove blank lines
    3. Collapse multiple spaces to single space
    4. Remove spaces around operators where safe
    5. Keep braces on same line
    6. Preserve string literals exactly
    7. Preserve necessary whitespace (keywords, types)
    """
    # Step 1: Remove comments using Tree-sitter
    source = remove_all_comments(source)

    # Step 2: Normalize line endings
    source = source.replace('\r\n', '\n')

    # Step 3: Process line by line
    lines = source.split('\n')
    compressed_lines = []

    for line in lines:
        # Strip leading/trailing whitespace
        line = line.strip()

        # Skip empty lines
        if not line:
            continue

        # Collapse internal whitespace (but preserve string literals)
        line = collapse_whitespace_preserve_strings(line)

        compressed_lines.append(line)

    # Step 4: Join with single newlines (some newlines required for Solidity)
    result = '\n'.join(compressed_lines)

    # Step 5: Collapse braces where possible
    result = collapse_braces(result)

    return result


def collapse_whitespace_preserve_strings(line: str) -> str:
    """
    Collapse multiple spaces to single space, but preserve string contents.
    """
    in_string = False
    string_char = None
    result = []
    i = 0

    while i < len(line):
        char = line[i]

        # Track string state
        if char in '"\'':
            if not in_string:
                in_string = True
                string_char = char
            elif char == string_char and (i == 0 or line[i-1] != '\\'):
                in_string = False
                string_char = None

        if in_string:
            result.append(char)
        else:
            # Collapse whitespace outside strings
            if char.isspace():
                if result and not result[-1].isspace():
                    result.append(' ')
            else:
                result.append(char)

        i += 1

    return ''.join(result).strip()


def collapse_braces(source: str) -> str:
    """
    Move opening braces to same line as declaration.
    """
    # Pattern: newline followed by opening brace
    import re

    # "function foo()\n{" -> "function foo() {"
    source = re.sub(r'\)\s*\n\s*\{', ') {', source)

    # "contract Foo\n{" -> "contract Foo {"
    source = re.sub(r'(\w)\s*\n\s*\{', r'\1 {', source)

    return source
```

#### 2.5.2 Expanded Mode

```python
def apply_expanded(source: str) -> str:
    """
    Expand code to maximum whitespace/readability.

    Rules:
    1. One statement per line
    2. Blank line between functions
    3. Blank line after opening brace
    4. Blank line before closing brace
    5. Spaces around all operators
    6. Each parameter on its own line for functions with 3+ params
    """
    # Use Tree-sitter to parse and identify structure
    tree = parse_solidity(source)

    # Collect insertions
    insertions = []

    # Add blank lines after function/contract opening braces
    for node in find_all(tree, ['function_definition', 'contract_declaration']):
        body = node.child_by_field_name('body')
        if body:
            # Insert blank line after opening brace
            insertions.append({
                'position': body.start_byte + 1,
                'text': '\n'
            })

    # Add blank lines between functions
    functions = find_all(tree, ['function_definition'])
    for i in range(len(functions) - 1):
        end_pos = functions[i].end_byte
        insertions.append({
            'position': end_pos,
            'text': '\n'
        })

    # Apply insertions
    result = apply_insertions(source, insertions)

    # Expand operators
    result = expand_operators(result)

    return result


def expand_operators(source: str) -> str:
    """
    Add spaces around operators.
    """
    import re

    # Be careful not to modify inside strings
    operators = [
        (r'([^\s])=([^\s=])', r'\1 = \2'),      # Assignment
        (r'([^\s])\+=([^\s])', r'\1 += \2'),    # Add-assign
        (r'([^\s])-=([^\s])', r'\1 -= \2'),     # Sub-assign
        (r'([^\s])\*=([^\s])', r'\1 *= \2'),    # Mul-assign
        (r'([^\s])==([^\s])', r'\1 == \2'),     # Equality
        (r'([^\s])!=([^\s])', r'\1 != \2'),     # Inequality
        (r'([^\s])>=([^\s])', r'\1 >= \2'),     # GTE
        (r'([^\s])<=([^\s])', r'\1 <= \2'),     # LTE
        (r'([^\s])&&([^\s])', r'\1 && \2'),     # Logical AND
        (r'([^\s])\|\|([^\s])', r'\1 || \2'),   # Logical OR
    ]

    result = source
    for pattern, replacement in operators:
        result = re.sub(pattern, replacement, result)

    return result
```

#### 2.5.3 Allman Style

```python
def apply_allman(source: str) -> str:
    """
    Convert to Allman brace style (braces on new lines).

    Before:
        function foo() {
            ...
        }

    After:
        function foo()
        {
            ...
        }
    """
    import re

    # Move opening braces to new lines
    # Match: ") {" or "contract X {" etc

    # Function/modifier declarations
    source = re.sub(
        r'(\))\s*\{',
        r'\1\n{',
        source
    )

    # Contract/interface/library/struct declarations
    source = re.sub(
        r'(contract\s+\w+(?:\s+is\s+[^{]+)?)\s*\{',
        r'\1\n{',
        source
    )
    source = re.sub(
        r'(interface\s+\w+)\s*\{',
        r'\1\n{',
        source
    )
    source = re.sub(
        r'(library\s+\w+)\s*\{',
        r'\1\n{',
        source
    )
    source = re.sub(
        r'(struct\s+\w+)\s*\{',
        r'\1\n{',
        source
    )

    # Control flow: if, for, while
    source = re.sub(
        r'(if\s*\([^)]+\))\s*\{',
        r'\1\n{',
        source
    )
    source = re.sub(
        r'(else)\s*\{',
        r'\1\n{',
        source
    )
    source = re.sub(
        r'(for\s*\([^)]+\))\s*\{',
        r'\1\n{',
        source
    )
    source = re.sub(
        r'(while\s*\([^)]+\))\s*\{',
        r'\1\n{',
        source
    )

    # Re-indent properly
    source = fix_indentation(source)

    return source
```

#### 2.5.4 K&R Style

```python
def apply_knr(source: str) -> str:
    """
    Convert to K&R brace style (braces on same line).

    Before:
        function foo()
        {
            ...
        }

    After:
        function foo() {
            ...
        }
    """
    import re

    # Move opening braces to same line
    # Match: ")\n{" or "X\n{"
    source = re.sub(
        r'\)\s*\n\s*\{',
        r') {',
        source
    )

    source = re.sub(
        r'(\w)\s*\n\s*\{',
        r'\1 {',
        source
    )

    return source
```

#### 2.5.5 Minified Mode

```python
def apply_minified(source: str) -> str:
    """
    Extreme minification - remove all non-essential whitespace.

    WARNING: May produce hard-to-read code, but must still compile.
    """
    # Remove comments
    source = remove_all_comments(source)

    # Normalize to single line where possible
    # Keep necessary newlines (Solidity requires some)

    lines = source.split('\n')
    result_parts = []

    for line in lines:
        stripped = line.strip()
        if stripped:
            result_parts.append(stripped)

    # Join with spaces, then selectively remove spaces
    result = ' '.join(result_parts)

    # Remove spaces around punctuation (but carefully)
    import re

    # Remove spaces before: ) ] } ; ,
    result = re.sub(r'\s+([)\]};,])', r'\1', result)

    # Remove spaces after: ( [ {
    result = re.sub(r'([(\[{])\s+', r'\1', result)

    # Collapse multiple spaces
    result = re.sub(r'\s+', ' ', result)

    # Add back necessary newlines (after ; for statements)
    # Solidity doesn't strictly require this, but helps compilation
    result = re.sub(r';([^\s])', r';\n\1', result)

    return result
```

### 2.6 Comment Handling

Mirror should optionally preserve or remove comments:

```python
def remove_all_comments(source: str) -> str:
    """
    Remove all comments using Tree-sitter for accuracy.
    """
    tree = parse_solidity(source)

    comment_nodes = []
    for node in tree.root_node.walk():
        if node.type in ['comment', 'natspec_comment', 'line_comment', 'block_comment']:
            comment_nodes.append(node)

    # Sort by position descending
    comment_nodes.sort(key=lambda n: n.start_byte, reverse=True)

    result = source
    for node in comment_nodes:
        # Replace with empty or single space to preserve structure
        result = result[:node.start_byte] + result[node.end_byte:]

    return result
```

### 2.7 Using External Formatters

```python
import subprocess
import tempfile
import os

def format_with_forge_fmt(source: str) -> str:
    """
    Use forge fmt for standard Solidity formatting.
    """
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sol', delete=False) as f:
        f.write(source)
        temp_path = f.name

    try:
        subprocess.run(
            ['forge', 'fmt', temp_path],
            check=True,
            capture_output=True
        )

        with open(temp_path, 'r') as f:
            return f.read()
    finally:
        os.unlink(temp_path)


def format_with_prettier(source: str, config: dict) -> str:
    """
    Use prettier-solidity with custom config.

    Config options:
    - printWidth: 80-120
    - tabWidth: 2 or 4
    - useTabs: true/false
    - singleQuote: true/false
    - bracketSpacing: true/false
    """
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sol', delete=False) as f:
        f.write(source)
        temp_path = f.name

    # Write config
    config_path = temp_path + '.prettierrc'
    with open(config_path, 'w') as f:
        import json
        json.dump(config, f)

    try:
        result = subprocess.run(
            ['npx', 'prettier', '--config', config_path, temp_path],
            check=True,
            capture_output=True,
            text=True
        )
        return result.stdout
    finally:
        os.unlink(temp_path)
        os.unlink(config_path)
```

### 2.8 Output Metadata

```json
{
  "strategy": "mirror",
  "mode": "compressed",
  "transformation_details": {
    "original_lines": 87,
    "transformed_lines": 34,
    "original_chars": 2543,
    "transformed_chars": 1821,
    "compression_ratio": 0.72,
    "comments_removed": true,
    "blank_lines_removed": 23
  },
  "vulnerability_preserved": true
}
```

### 2.9 Complete Example

**Input:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Vault
 * @notice A simple vault contract
 */
contract Vault {
    // User balances
    mapping(address => uint256) public balances;

    // Total deposited
    uint256 public totalDeposits;

    /**
     * @notice Deposit funds
     */
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    /**
     * @notice Withdraw funds
     * @param amount Amount to withdraw
     */
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // VULNERABLE: External call before state update
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;
    }
}
```

**Output (Compressed):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract Vault {
mapping(address => uint256) public balances;
uint256 public totalDeposits;
function deposit() external payable {
balances[msg.sender] += msg.value;
totalDeposits += msg.value; }
function withdraw(uint256 amount) external {
require(balances[msg.sender] >= amount, "Insufficient balance");
(bool success, ) = msg.sender.call{value: amount}("");
require(success, "Transfer failed");
balances[msg.sender] -= amount;
totalDeposits -= amount; } }
```

**Output (Allman):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Vault
{
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    function deposit() external payable
    {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external
    {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;
    }
}
```

---

## 3. Strategy D3: Cross-Domain (Terminology Swap)

### 3.1 Purpose

Test whether models can recognize vulnerabilities when presented in unfamiliar domain contexts. Same vulnerability pattern, completely different business terminology.

### 3.2 Hypothesis

> "If a model trained on DeFi exploits fails to detect the same vulnerability in gaming/medical/social context, it has learned domain-specific patterns rather than fundamental security concepts."

### 3.3 Key Insight

Cross-Domain is essentially Chameleon with **domain-aware dictionaries** instead of random synonym pools. The entire terminology shifts from one domain to another.

### 3.4 Domain Definitions

#### 3.4.1 Source Domain: DeFi

```yaml
domain: defi
description: 'Decentralized finance - lending, staking, trading'

terminology:
  entities:
    vault: 'Contract holding user funds'
    pool: 'Liquidity aggregation'
    token: 'Fungible asset'
    collateral: 'Security deposit'

  actions:
    deposit: 'Add funds to protocol'
    withdraw: 'Remove funds from protocol'
    stake: 'Lock tokens for rewards'
    borrow: 'Take loan against collateral'
    liquidate: 'Force-close undercollateralized position'

  actors:
    user: 'Protocol participant'
    owner: 'Admin/governance'
    liquidator: 'Bot/user closing bad positions'

  metrics:
    balance: 'Amount held'
    totalSupply: 'Total tokens in existence'
    fee: 'Protocol charge'
    rate: 'Interest/reward rate'
```

#### 3.4.2 Target Domain: Gaming

```yaml
domain: gaming
description: 'Video games - rewards, loot, quests'

terminology:
  entities:
    vault: ['LootVault', 'TreasureChest', 'RewardCache', 'GoldHoard']
    pool: ['PrizePool', 'LootPool', 'RewardPool', 'JackpotPool']
    token: ['GameCoin', 'GoldToken', 'Crystal', 'Gem', 'PowerOrb']
    collateral: ['Wager', 'Stake', 'Bet', 'Pledge']

  actions:
    deposit: ['storeLoot', 'cacheTreasure', 'bankGold', 'savePrize']
    withdraw: ['claimLoot', 'collectTreasure', 'redeemGold', 'takePrize']
    stake: ['wagerTokens', 'betCoins', 'pledgePower', 'commitGems']
    borrow: ['requestLoan', 'borrowGold', 'takeAdvance']
    liquidate: ['forfeitWager', 'loseBet', 'surrenderStake']

  actors:
    user: ['player', 'gamer', 'hero', 'adventurer', 'champion']
    owner: ['gamemaster', 'dungeonMaster', 'admin', 'guildLeader']
    liquidator: ['enforcer', 'collector', 'arbiter']

  metrics:
    balance: ['lootBalance', 'goldHolding', 'treasureCount', 'gemTotal']
    totalSupply: ['totalGold', 'allTreasure', 'combinedLoot']
    fee: ['tax', 'tribute', 'cut', 'rake']
    rate: ['multiplier', 'bonusRate', 'rewardFactor']
```

#### 3.4.3 Target Domain: Healthcare

```yaml
domain: healthcare
description: 'Medical systems - patients, treatments, coverage'

terminology:
  entities:
    vault: ['PatientFund', 'CoverageAccount', 'BenefitPool', 'HealthVault']
    pool: ['InsurancePool', 'CoveragePool', 'BenefitReserve']
    token: ['HealthCredit', 'CoveragePoint', 'BenefitUnit']
    collateral: ['Copay', 'Deductible', 'Deposit']

  actions:
    deposit: ['contributePremium', 'fundAccount', 'addCoverage']
    withdraw: ['claimBenefit', 'receivePayout', 'collectCoverage']
    stake: ['enrollCoverage', 'commitPremium', 'lockBenefit']
    borrow: ['requestAdvance', 'borrowCredit']
    liquidate: ['terminateCoverage', 'cancelPolicy', 'forfeitBenefit']

  actors:
    user: ['patient', 'member', 'beneficiary', 'enrollee']
    owner: ['administrator', 'director', 'supervisor', 'coordinator']
    liquidator: ['auditor', 'reviewer', 'adjuster']

  metrics:
    balance: ['coverage', 'benefits', 'credits', 'allowance']
    totalSupply: ['totalCoverage', 'pooledBenefits', 'reserveTotal']
    fee: ['copay', 'deductible', 'premium', 'coinsurance']
    rate: ['coverageRate', 'benefitRatio', 'reimbursementRate']
```

#### 3.4.4 Target Domain: Social/Community

```yaml
domain: social
description: 'Social platforms - reputation, tipping, communities'

terminology:
  entities:
    vault: ['CommunityFund', 'TipJar', 'CreatorVault', 'PatronPool']
    pool: ['SupportPool', 'DonationPool', 'CommunityReserve']
    token: ['KarmaPoint', 'ReputationToken', 'InfluenceCredit']
    collateral: ['Pledge', 'Commitment', 'Bond']

  actions:
    deposit: ['contribute', 'donate', 'tip', 'support', 'fund']
    withdraw: ['collect', 'cashOut', 'redeemKarma', 'withdrawTips']
    stake: ['pledge', 'commit', 'vouch', 'endorse']
    borrow: ['requestSupport', 'seekFunding']
    liquidate: ['revokePledge', 'removeBacking']

  actors:
    user: ['member', 'creator', 'supporter', 'patron', 'contributor']
    owner: ['moderator', 'admin', 'communityLead', 'founder']
    liquidator: ['moderator', 'arbiter', 'reviewer']

  metrics:
    balance: ['reputation', 'karma', 'influence', 'standing']
    totalSupply: ['totalKarma', 'communityReputation', 'pooledInfluence']
    fee: ['platformFee', 'serviceFee', 'processingFee']
    rate: ['engagementRate', 'reputationMultiplier', 'karmaRate']
```

#### 3.4.5 Target Domain: Logistics/Supply Chain

```yaml
domain: logistics
description: 'Supply chain - shipments, inventory, warehousing'

terminology:
  entities:
    vault: ['Warehouse', 'StorageFacility', 'InventoryHub', 'DepotCenter']
    pool: ['ShipmentPool', 'CargoAggregate', 'FreightCollection']
    token: ['ShipmentUnit', 'CargoCredit', 'FreightToken']
    collateral: ['SecurityDeposit', 'InsuranceBond', 'CargoGuarantee']

  actions:
    deposit: ['storeGoods', 'receiveShipment', 'checkInCargo']
    withdraw: ['releaseGoods', 'dispatchShipment', 'checkOutCargo']
    stake: ['reserveCapacity', 'commitStorage', 'allocateSpace']
    borrow: ['requestCapacity', 'borrowStorage']
    liquidate: ['auctionGoods', 'disposeInventory', 'liquidateStock']

  actors:
    user: ['shipper', 'consignee', 'merchant', 'vendor']
    owner: ['warehouseManager', 'facilityOperator', 'logisticsAdmin']
    liquidator: ['auctioneer', 'disposalAgent', 'liquidationManager']

  metrics:
    balance: ['inventory', 'stockLevel', 'cargoCount', 'goodsOnHand']
    totalSupply: ['totalInventory', 'warehouseCapacity', 'totalGoods']
    fee: ['storageFee', 'handlingFee', 'processingCharge']
    rate: ['utilizationRate', 'turnoverRate', 'throughputRate']
```

### 3.5 Implementation

Cross-Domain reuses Chameleon's infrastructure with domain-specific dictionaries:

```python
class CrossDomainTransformer:
    """
    Transform contract from source domain to target domain.
    Builds on Chameleon infrastructure.
    """

    def __init__(
        self,
        source_domain: str,
        target_domain: str,
        language_plugin: 'LanguagePlugin'
    ):
        self.source_domain = source_domain
        self.target_domain = target_domain
        self.language = language_plugin

        # Load domain mappings
        self.source_terms = load_domain_terminology(source_domain)
        self.target_terms = load_domain_terminology(target_domain)

        # Build mapping from source -> target
        self.domain_mapping = self._build_domain_mapping()

    def _build_domain_mapping(self) -> dict:
        """
        Build comprehensive source -> target mapping.
        """
        mapping = {}

        for category in ['entities', 'actions', 'actors', 'metrics']:
            source_cat = self.source_terms.get(category, {})
            target_cat = self.target_terms.get(category, {})

            for concept, source_term in source_cat.items():
                if concept in target_cat:
                    target_options = target_cat[concept]

                    # If target is a list, we'll randomly select
                    if isinstance(target_options, list):
                        mapping[source_term.lower()] = target_options
                    else:
                        mapping[source_term.lower()] = [target_options]

        return mapping

    def transform(self, source_code: str) -> 'TransformationResult':
        """
        Transform contract from source domain to target domain.
        """
        # Create seeded RNG
        seed = self._create_seed(source_code)
        rng = Random(seed)

        # Parse
        tree = parse_with_treesitter(source_code, self.language.get_language_name())

        # Build rename map using domain mapping
        rename_map = {}
        identifiers = extract_identifiers(source_code, tree, self.language)

        for ident in identifiers:
            new_name = self._transform_identifier(ident.name, rng)
            if new_name and new_name != ident.name:
                rename_map[ident.name] = new_name

        # Apply renames (reuse Chameleon's byte-position replacement)
        transformed = apply_renames_byte_position(source_code, tree, rename_map, self.language)

        # Validate
        validation = validate_transformation(source_code, transformed, self.language)

        return TransformationResult(
            code=transformed,
            rename_map=rename_map,
            strategy='cross_domain',
            strategy_params={
                'source_domain': self.source_domain,
                'target_domain': self.target_domain
            },
            validation=validation
        )

    def _transform_identifier(self, identifier: str, rng: Random) -> Optional[str]:
        """
        Transform identifier from source to target domain.

        Uses layered lookup:
        1. Direct domain mapping
        2. Compound word decomposition
        3. Leave unchanged if no mapping
        """
        ident_lower = identifier.lower()

        # Layer 1: Direct mapping
        if ident_lower in self.domain_mapping:
            options = self.domain_mapping[ident_lower]
            selected = rng.choice(options)
            # Preserve casing
            if identifier[0].isupper():
                return selected[0].upper() + selected[1:]
            return selected

        # Layer 2: Compound decomposition
        words, style = split_identifier(identifier)
        transformed_words = []
        any_transformed = False

        for word in words:
            word_lower = word.lower()
            if word_lower in self.domain_mapping:
                options = self.domain_mapping[word_lower]
                new_word = rng.choice(options)
                if word[0].isupper():
                    new_word = new_word[0].upper() + new_word[1:]
                transformed_words.append(new_word)
                any_transformed = True
            else:
                transformed_words.append(word)

        if any_transformed:
            return recombine_identifier(transformed_words, style)

        # Layer 3: No mapping found
        return None
```

### 3.6 Domain Detection (Optional)

Optionally auto-detect source domain:

```python
def detect_domain(source_code: str) -> str:
    """
    Attempt to detect the domain of a contract based on terminology.
    """
    source_lower = source_code.lower()

    domain_signals = {
        'defi': ['deposit', 'withdraw', 'stake', 'collateral', 'liquidity',
                 'borrow', 'lend', 'vault', 'pool', 'token', 'yield'],
        'gaming': ['player', 'game', 'loot', 'reward', 'quest', 'level',
                   'score', 'achievement', 'item', 'inventory'],
        'healthcare': ['patient', 'treatment', 'coverage', 'benefit',
                       'premium', 'claim', 'medical', 'health'],
        'social': ['reputation', 'karma', 'tip', 'creator', 'supporter',
                   'community', 'member', 'influence'],
    }

    scores = {}
    for domain, signals in domain_signals.items():
        score = sum(1 for signal in signals if signal in source_lower)
        scores[domain] = score

    # Return domain with highest score, default to 'defi'
    if max(scores.values()) == 0:
        return 'defi'

    return max(scores, key=scores.get)
```

### 3.7 Output Metadata

```json
{
  "strategy": "cross_domain",
  "transformation_details": {
    "source_domain": "defi",
    "target_domain": "gaming",
    "domain_mappings_applied": 23,
    "unmapped_identifiers": 5
  },
  "rename_map": {
    "Vault": "LootVault",
    "deposit": "storeLoot",
    "withdraw": "claimLoot",
    "balance": "goldHolding",
    "user": "player",
    "owner": "gamemaster"
  },
  "vulnerability_preserved": true
}
```

### 3.8 Complete Example

**Input (DeFi):**

```solidity
contract Vault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;
    }
}
```

**Output (Gaming Domain):**

```solidity
contract TreasureChest {
    mapping(address => uint256) public goldHoldings;

    function cacheTreasure() external payable {
        goldHoldings[msg.sender] += msg.value;
    }

    function claimLoot(uint256 amount) external {
        require(goldHoldings[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        goldHoldings[msg.sender] -= amount;
    }
}
```

**Output (Healthcare Domain):**

```solidity
contract BenefitPool {
    mapping(address => uint256) public coverageBalances;

    function contributePremium() external payable {
        coverageBalances[msg.sender] += msg.value;
    }

    function claimBenefit(uint256 amount) external {
        require(coverageBalances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        coverageBalances[msg.sender] -= amount;
    }
}
```

---

## 4. Strategy C1: Guardian Shield (Protection Injection)

### 4.1 Purpose

Inject protection mechanisms that **neutralize vulnerabilities** while keeping the vulnerable-looking code pattern. Tests whether models recognize that protections are in place.

### 4.2 Hypothesis

> "If a model flags protected code as vulnerable, it's pattern-matching on code structure rather than understanding whether the vulnerability is actually exploitable."

### 4.3 Critical Difference from Other Strategies

**Guardian Shield changes vulnerability status:**

- Input: Vulnerable contract
- Output: Safe contract (protection neutralizes vulnerability)
- Ground truth changes: `is_vulnerable: true` → `is_vulnerable: false`

### 4.4 Protection Types

| Protection       | Targets             | Injection Method                |
| ---------------- | ------------------- | ------------------------------- |
| ReentrancyGuard  | Reentrancy          | Import + inheritance + modifier |
| CEI Pattern      | Reentrancy          | Reorder statements              |
| SafeMath         | Integer overflow    | Import + replace operators      |
| Solidity 0.8+    | Integer overflow    | Update pragma                   |
| Access Control   | Unauthorized access | Add require/modifier            |
| Pausable         | Multiple            | Import + inheritance + modifier |
| Input Validation | Multiple            | Add require statements          |

### 4.5 Protection Implementations

#### 4.5.1 ReentrancyGuard Injection

```python
class ReentrancyGuardInjector:
    """
    Inject OpenZeppelin ReentrancyGuard to neutralize reentrancy.
    """

    IMPORT_STATEMENT = 'import "@openzeppelin/contracts/security/ReentrancyGuard.sol";'
    INHERITANCE_NAME = "ReentrancyGuard"
    MODIFIER_NAME = "nonReentrant"

    def inject(
        self,
        source: str,
        tree,
        vulnerable_functions: List[str]
    ) -> Tuple[str, dict]:
        """
        Inject ReentrancyGuard protection.

        Steps:
        1. Add import statement at top (after pragma)
        2. Add ReentrancyGuard to contract inheritance
        3. Add nonReentrant modifier to vulnerable functions
        """
        edits = []
        injection_details = {
            'import_added': False,
            'inheritance_added': False,
            'functions_protected': []
        }

        # Step 1: Find position for import (after last import or after pragma)
        import_position = self._find_import_position(tree, source)
        edits.append({
            'position': import_position,
            'text': f'\n{self.IMPORT_STATEMENT}\n'
        })
        injection_details['import_added'] = True

        # Step 2: Add inheritance
        contract_node = find_first(tree, 'contract_declaration')
        if contract_node:
            inheritance_edit = self._create_inheritance_edit(contract_node, source)
            if inheritance_edit:
                edits.append(inheritance_edit)
                injection_details['inheritance_added'] = True

        # Step 3: Add modifier to vulnerable functions
        for func_name in vulnerable_functions:
            func_node = find_function_by_name(tree, func_name)
            if func_node:
                modifier_edit = self._create_modifier_edit(func_node, source)
                if modifier_edit:
                    edits.append(modifier_edit)
                    injection_details['functions_protected'].append(func_name)

        # Apply edits back-to-front
        result = apply_insertions(source, edits)

        return result, injection_details

    def _find_import_position(self, tree, source: str) -> int:
        """Find position to insert import statement."""
        # Find last existing import
        imports = find_all(tree, ['import_directive'])
        if imports:
            last_import = max(imports, key=lambda n: n.end_byte)
            return last_import.end_byte

        # Otherwise, after pragma
        pragma = find_first(tree, 'pragma_directive')
        if pragma:
            return pragma.end_byte

        # Fallback: start of file
        return 0

    def _create_inheritance_edit(self, contract_node, source: str) -> Optional[dict]:
        """
        Create edit to add ReentrancyGuard inheritance.

        Before: contract Vault {
        After:  contract Vault is ReentrancyGuard {

        Before: contract Vault is Ownable {
        After:  contract Vault is Ownable, ReentrancyGuard {
        """
        # Check if already has inheritance
        inheritance = contract_node.child_by_field_name('inheritance_specifier')

        if inheritance:
            # Add to existing inheritance list
            # Find position just before closing of inheritance (before '{')
            body = contract_node.child_by_field_name('body')
            if body:
                insert_pos = body.start_byte
                # Back up to find 'is ... ' part
                text_before = source[:insert_pos]
                # Insert before the '{'
                return {
                    'position': insert_pos,
                    'text': f', {self.INHERITANCE_NAME} '
                }
        else:
            # No existing inheritance, add "is ReentrancyGuard"
            # Find contract name end position
            name_node = contract_node.child_by_field_name('name')
            if name_node:
                return {
                    'position': name_node.end_byte,
                    'text': f' is {self.INHERITANCE_NAME}'
                }

        return None

    def _create_modifier_edit(self, func_node, source: str) -> Optional[dict]:
        """
        Add nonReentrant modifier to function.

        Before: function withdraw() external {
        After:  function withdraw() external nonReentrant {
        """
        # Find position after function modifiers but before body
        body = func_node.child_by_field_name('body')
        if body:
            # Insert just before the opening brace
            return {
                'position': body.start_byte,
                'text': f'{self.MODIFIER_NAME} '
            }

        return None
```

#### 4.5.2 CEI Pattern Fix

```python
class CEIPatternFixer:
    """
    Fix reentrancy by reordering to Checks-Effects-Interactions pattern.

    Before (vulnerable):
        function withdraw(uint256 amount) external {
            require(balances[msg.sender] >= amount);
            (bool success,) = msg.sender.call{value: amount}("");  // Interaction
            require(success);
            balances[msg.sender] -= amount;  // Effect
        }

    After (safe):
        function withdraw(uint256 amount) external {
            require(balances[msg.sender] >= amount);  // Check
            balances[msg.sender] -= amount;  // Effect (moved up)
            (bool success,) = msg.sender.call{value: amount}("");  // Interaction
            require(success);
        }
    """

    def fix(
        self,
        source: str,
        tree,
        function_name: str,
        state_variable: str
    ) -> Tuple[str, dict]:
        """
        Reorder statements in function to CEI pattern.
        """
        func_node = find_function_by_name(tree, function_name)
        if not func_node:
            return source, {'error': f'Function {function_name} not found'}

        body = func_node.child_by_field_name('body')
        if not body:
            return source, {'error': 'Function has no body'}

        # Find the external call and state update
        external_call = self._find_external_call(body, source)
        state_update = self._find_state_update(body, source, state_variable)

        if not external_call or not state_update:
            return source, {'error': 'Could not identify external call or state update'}

        # Check if reordering is needed (external call before state update)
        if external_call.start_byte >= state_update.start_byte:
            return source, {'already_safe': True, 'reason': 'Already in CEI order'}

        # Extract the statement texts
        call_text = source[external_call.start_byte:external_call.end_byte]
        update_text = source[state_update.start_byte:state_update.end_byte]

        # Also capture any require after the call
        require_after_call = self._find_require_after_call(body, external_call, source)
        require_text = ""
        if require_after_call:
            require_text = source[require_after_call.start_byte:require_after_call.end_byte]

        # Build the swapped version
        # Remove old positions and insert at new positions
        edits = []

        # We need to:
        # 1. Remove the state update from its current position
        # 2. Insert it before the external call

        # Get leading whitespace for proper indentation
        line_start = source.rfind('\n', 0, state_update.start_byte) + 1
        indentation = source[line_start:state_update.start_byte]

        # Remove state update
        edits.append({
            'type': 'delete',
            'start': state_update.start_byte,
            'end': state_update.end_byte + 1  # +1 for newline
        })

        # Insert before external call
        edits.append({
            'type': 'insert',
            'position': external_call.start_byte,
            'text': update_text + '\n' + indentation
        })

        # Apply edits
        result = self._apply_edits(source, edits)

        return result, {
            'reordered': True,
            'moved_statement': update_text.strip(),
            'before_statement': call_text.strip()[:50] + '...'
        }

    def _find_external_call(self, body_node, source: str):
        """Find external call (address.call, etc.)"""
        for node in body_node.walk():
            if node.type == 'call_expression':
                call_text = source[node.start_byte:node.end_byte]
                if '.call' in call_text or '.transfer' in call_text or '.send' in call_text:
                    # Return the statement containing this call
                    return self._get_parent_statement(node)
        return None

    def _find_state_update(self, body_node, source: str, state_var: str):
        """Find state variable update (balances[x] -= y, etc.)"""
        for node in body_node.walk():
            if node.type in ['assignment_expression', 'augmented_assignment']:
                assign_text = source[node.start_byte:node.end_byte]
                if state_var in assign_text:
                    return self._get_parent_statement(node)
        return None

    def _get_parent_statement(self, node):
        """Get the statement node containing this expression."""
        current = node
        while current.parent:
            if current.type in ['expression_statement', 'variable_declaration_statement']:
                return current
            current = current.parent
        return node

    def _apply_edits(self, source: str, edits: list) -> str:
        """Apply a mix of insertions and deletions."""
        # Sort by position descending
        edits.sort(key=lambda e: e.get('position', e.get('start', 0)), reverse=True)

        result = source
        for edit in edits:
            if edit['type'] == 'delete':
                result = result[:edit['start']] + result[edit['end']:]
            elif edit['type'] == 'insert':
                result = result[:edit['position']] + edit['text'] + result[edit['position']:]

        return result
```

#### 4.5.3 Access Control Injection

```python
class AccessControlInjector:
    """
    Inject access control to restrict function access.
    """

    def inject_owner_check(
        self,
        source: str,
        tree,
        functions: List[str]
    ) -> Tuple[str, dict]:
        """
        Add owner-only restriction to specified functions.

        Adds:
        1. State variable: address public owner;
        2. Constructor: owner = msg.sender;
        3. Modifier: modifier onlyOwner() { require(msg.sender == owner); _; }
        4. Modifier usage on functions
        """
        edits = []
        details = {
            'state_var_added': False,
            'constructor_modified': False,
            'modifier_added': False,
            'functions_protected': []
        }

        contract_node = find_first(tree, 'contract_declaration')
        if not contract_node:
            return source, {'error': 'No contract found'}

        body = contract_node.child_by_field_name('body')

        # Check if owner already exists
        if 'owner' not in source:
            # Add state variable at start of contract body
            edits.append({
                'position': body.start_byte + 1,
                'text': '\n    address public owner;\n'
            })
            details['state_var_added'] = True

        # Check if constructor exists
        constructor = find_first(tree, 'constructor_definition')
        if constructor:
            # Add owner assignment to existing constructor
            constructor_body = constructor.child_by_field_name('body')
            if constructor_body:
                edits.append({
                    'position': constructor_body.start_byte + 1,
                    'text': '\n        owner = msg.sender;'
                })
                details['constructor_modified'] = True
        else:
            # Add new constructor
            edits.append({
                'position': body.start_byte + 1,
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
                'position': body.end_byte - 1,
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
            func_node = find_function_by_name(tree, func_name)
            if func_node:
                func_body = func_node.child_by_field_name('body')
                if func_body:
                    edits.append({
                        'position': func_body.start_byte,
                        'text': 'onlyOwner '
                    })
                    details['functions_protected'].append(func_name)

        result = apply_insertions(source, edits)

        return result, details

    def inject_require_check(
        self,
        source: str,
        tree,
        function_name: str,
        condition: str,
        message: str
    ) -> Tuple[str, dict]:
        """
        Add a require statement at the start of a function.

        Example: require(amount > 0, "Amount must be positive");
        """
        func_node = find_function_by_name(tree, function_name)
        if not func_node:
            return source, {'error': f'Function {function_name} not found'}

        func_body = func_node.child_by_field_name('body')
        if not func_body:
            return source, {'error': 'Function has no body'}

        # Insert require at start of function body
        require_statement = f'\n        require({condition}, "{message}");'

        result = source[:func_body.start_byte + 1] + require_statement + source[func_body.start_byte + 1:]

        return result, {
            'require_added': True,
            'function': function_name,
            'condition': condition
        }
```

#### 4.5.4 Solidity Version Update (Overflow Protection)

```python
class SolidityVersionUpdater:
    """
    Update Solidity version to 0.8+ for built-in overflow protection.
    """

    def update_to_0_8(self, source: str) -> Tuple[str, dict]:
        """
        Update pragma to 0.8+ and remove SafeMath usage.

        Changes:
        1. Update pragma version
        2. Remove SafeMath import
        3. Remove 'using SafeMath for uint256'
        4. Replace .add(), .sub(), .mul(), .div() with operators
        """
        import re

        result = source
        details = {
            'pragma_updated': False,
            'safemath_removed': False,
            'operators_replaced': 0
        }

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

        # Remove 'using SafeMath for uint256'
        using_safemath = r'using\s+SafeMath\s+for\s+uint256;\n?'
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
```

### 4.6 Guardian Shield Orchestrator

```python
class GuardianShieldTransformer:
    """
    Orchestrate protection injection based on vulnerability type.
    """

    PROTECTION_MAP = {
        'reentrancy': ['reentrancy_guard', 'cei_pattern'],
        'integer_overflow': ['solidity_0_8', 'safemath'],
        'integer_underflow': ['solidity_0_8', 'safemath'],
        'access_control': ['owner_check', 'require_check'],
        'unchecked_return': ['require_success'],
    }

    def __init__(self, language_plugin: 'LanguagePlugin'):
        self.language = language_plugin
        self.reentrancy_guard = ReentrancyGuardInjector()
        self.cei_fixer = CEIPatternFixer()
        self.access_control = AccessControlInjector()
        self.version_updater = SolidityVersionUpdater()

    def transform(
        self,
        source: str,
        vulnerability_type: str,
        protection_type: str,
        vulnerability_info: dict
    ) -> 'TransformationResult':
        """
        Apply specified protection to neutralize vulnerability.

        Args:
            source: Original vulnerable contract
            vulnerability_type: Type of vulnerability (reentrancy, etc.)
            protection_type: Specific protection to apply
            vulnerability_info: Details about the vulnerability location
        """
        tree = parse_with_treesitter(source, self.language.get_language_name())

        if protection_type == 'reentrancy_guard':
            result, details = self.reentrancy_guard.inject(
                source, tree,
                vulnerable_functions=[vulnerability_info.get('function_name', 'withdraw')]
            )

        elif protection_type == 'cei_pattern':
            result, details = self.cei_fixer.fix(
                source, tree,
                function_name=vulnerability_info.get('function_name', 'withdraw'),
                state_variable=vulnerability_info.get('state_variable', 'balances')
            )

        elif protection_type == 'owner_check':
            result, details = self.access_control.inject_owner_check(
                source, tree,
                functions=[vulnerability_info.get('function_name')]
            )

        elif protection_type == 'solidity_0_8':
            result, details = self.version_updater.update_to_0_8(source)

        else:
            return TransformationResult(
                code=source,
                error=f"Unknown protection type: {protection_type}"
            )

        # Validate
        validation = validate_transformation(source, result, self.language)

        return TransformationResult(
            code=result,
            strategy='guardian_shield',
            strategy_params={
                'protection_type': protection_type,
                'vulnerability_type': vulnerability_type,
                'injection_details': details
            },
            validation=validation,
            # IMPORTANT: Vulnerability status changes!
            ground_truth_change={
                'original_vulnerable': True,
                'transformed_vulnerable': False,
                'neutralized_by': protection_type
            }
        )
```

### 4.7 Complete Example

**Input (Vulnerable to Reentrancy):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Vault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);

        (bool success,) = msg.sender.call{value: amount}("");
        require(success);

        balances[msg.sender] -= amount;
    }
}
```

**Output (Protected with ReentrancyGuard):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount);

        (bool success,) = msg.sender.call{value: amount}("");
        require(success);

        balances[msg.sender] -= amount;
    }
}
```

**Output (Protected with CEI Pattern):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Vault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);

        balances[msg.sender] -= amount;  // Effect moved before Interaction

        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
    }
}
```

### 4.8 Output Metadata

```json
{
  "strategy": "guardian_shield",
  "protection_type": "reentrancy_guard",
  "transformation_details": {
    "import_added": "@openzeppelin/contracts/security/ReentrancyGuard.sol",
    "inheritance_added": "ReentrancyGuard",
    "functions_protected": ["withdraw"],
    "modifier_added": "nonReentrant"
  },
  "ground_truth_change": {
    "original_vulnerable": true,
    "transformed_vulnerable": false,
    "vulnerability_type": "reentrancy",
    "neutralized_by": "reentrancy_guard",
    "neutralization_reason": "Mutex lock prevents recursive calls"
  }
}
```

---

## 5. Strategy B1: Hydra (Function Splitting)

### 5.1 Purpose

Split a single function into multiple helper functions. Tests whether models can trace vulnerability patterns across function boundaries.

### 5.2 Hypothesis

> "If a model fails to detect a vulnerability when the vulnerable pattern is split across multiple functions, it cannot perform cross-function dataflow analysis."

### 5.3 Splitting Patterns

| Pattern             | Description                     | Complexity |
| ------------------- | ------------------------------- | ---------- |
| `sequential`        | Split into sequential calls     | Low        |
| `helper_extraction` | Extract logic into helpers      | Medium     |
| `modifier_body`     | Split between modifier and body | Medium     |
| `internal_external` | Public calls internal           | Low        |

### 5.4 Implementation

#### 5.4.1 Sequential Split

```python
class HydraSequentialSplit:
    """
    Split function into sequential helper calls.

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
            _updateBalance(amount);
        }

        function _validateWithdraw(uint256 amount) internal view {
            require(balances[msg.sender] >= amount);
        }

        function _executeTransfer(uint256 amount) internal {
            (bool success,) = msg.sender.call{value: amount}("");
            require(success);
        }

        function _updateBalance(uint256 amount) internal {
            balances[msg.sender] -= amount;
        }
    """

    def split(
        self,
        source: str,
        tree,
        function_name: str,
        rng: Random
    ) -> Tuple[str, dict]:
        """
        Split function into sequential helpers.
        """
        func_node = find_function_by_name(tree, function_name)
        if not func_node:
            return source, {'error': f'Function {function_name} not found'}

        body = func_node.child_by_field_name('body')
        if not body:
            return source, {'error': 'Function has no body'}

        # Get function parameters
        params = self._get_parameters(func_node, source)

        # Get statements in body
        statements = self._get_statements(body, source)

        if len(statements) < 2:
            return source, {'error': 'Function too small to split'}

        # Group statements into logical chunks
        chunks = self._group_statements(statements, source)

        # Generate helper function names
        helper_names = self._generate_helper_names(function_name, len(chunks), rng)

        # Build helper functions
        helpers = []
        calls = []

        for i, (chunk, helper_name) in enumerate(zip(chunks, helper_names)):
            # Determine which parameters this chunk needs
            chunk_params = self._extract_used_params(chunk, params)

            # Determine visibility and mutability
            visibility = 'internal'
            mutability = self._determine_mutability(chunk)

            # Build helper function
            helper = self._build_helper(
                helper_name,
                chunk_params,
                visibility,
                mutability,
                chunk
            )
            helpers.append(helper)

            # Build call to helper
            call = self._build_call(helper_name, chunk_params)
            calls.append(call)

        # Build new main function
        new_main = self._build_main_function(func_node, source, calls)

        # Assemble result
        result = self._assemble(source, func_node, new_main, helpers)

        return result, {
            'split_type': 'sequential',
            'original_function': function_name,
            'helpers_created': helper_names,
            'statement_groups': len(chunks)
        }

    def _generate_helper_names(self, base_name: str, count: int, rng: Random) -> List[str]:
        """Generate names for helper functions."""
        prefixes = ['_do', '_execute', '_perform', '_handle', '_process']
        suffixes = ['Step', 'Part', 'Phase', 'Stage', 'Action']

        names = []
        for i in range(count):
            prefix = rng.choice(prefixes)
            suffix = rng.choice(suffixes)
            names.append(f'{prefix}{base_name.capitalize()}{suffix}{i+1}')

        return names

    def _group_statements(self, statements: List, source: str) -> List[List[str]]:
        """
        Group statements into logical chunks.

        Strategy: Group by category (checks, effects, interactions)
        """
        chunks = []
        current_chunk = []

        for stmt in statements:
            stmt_text = source[stmt.start_byte:stmt.end_byte]

            # Start new chunk on category change
            category = self._categorize_statement(stmt_text)

            if current_chunk and self._should_split(current_chunk[-1], stmt_text):
                chunks.append(current_chunk)
                current_chunk = []

            current_chunk.append(stmt_text)

        if current_chunk:
            chunks.append(current_chunk)

        return chunks

    def _categorize_statement(self, stmt: str) -> str:
        """Categorize statement as check, effect, or interaction."""
        if 'require' in stmt or 'assert' in stmt or 'if' in stmt:
            return 'check'
        elif '.call' in stmt or '.transfer' in stmt or '.send' in stmt:
            return 'interaction'
        else:
            return 'effect'

    def _should_split(self, prev_stmt: str, curr_stmt: str) -> bool:
        """Determine if we should start a new chunk."""
        prev_cat = self._categorize_statement(prev_stmt)
        curr_cat = self._categorize_statement(curr_stmt)
        return prev_cat != curr_cat

    def _build_helper(
        self,
        name: str,
        params: List[dict],
        visibility: str,
        mutability: str,
        statements: List[str]
    ) -> str:
        """Build a helper function string."""
        params_str = ', '.join(f"{p['type']} {p['name']}" for p in params)
        mutability_str = f' {mutability}' if mutability else ''
        body = '\n        '.join(statements)

        return f'''
    function {name}({params_str}) {visibility}{mutability_str} {{
        {body}
    }}'''

    def _build_call(self, helper_name: str, params: List[dict]) -> str:
        """Build a call to a helper function."""
        args = ', '.join(p['name'] for p in params)
        return f'{helper_name}({args});'

    def _build_main_function(self, func_node, source: str, calls: List[str]) -> str:
        """Build the new main function with helper calls."""
        # Get original signature
        sig_end = func_node.child_by_field_name('body').start_byte
        signature = source[func_node.start_byte:sig_end].strip()

        # Build body with calls
        body = '\n        '.join(calls)

        return f'''{signature} {{
        {body}
    }}'''

    def _assemble(self, source: str, func_node, new_main: str, helpers: List[str]) -> str:
        """Assemble the final result."""
        # Replace original function with new main + helpers
        before = source[:func_node.start_byte]
        after = source[func_node.end_byte:]

        helpers_str = '\n'.join(helpers)

        return before + new_main + helpers_str + after
```

#### 5.4.2 Internal/External Pattern

```python
class HydraInternalExternal:
    """
    Split into public wrapper + internal implementation.

    Before:
        function withdraw(uint256 amount) external {
            // ... implementation
        }

    After:
        function withdraw(uint256 amount) external {
            _withdrawInternal(msg.sender, amount);
        }

        function _withdrawInternal(address user, uint256 amount) internal {
            // ... implementation
        }
    """

    def split(
        self,
        source: str,
        tree,
        function_name: str,
        rng: Random
    ) -> Tuple[str, dict]:
        """
        Split function into external wrapper + internal implementation.
        """
        func_node = find_function_by_name(tree, function_name)
        if not func_node:
            return source, {'error': f'Function {function_name} not found'}

        # Get function details
        params = self._get_parameters(func_node, source)
        body = func_node.child_by_field_name('body')
        body_text = source[body.start_byte + 1:body.end_byte - 1].strip()

        # Generate internal function name
        internal_suffixes = ['Internal', 'Impl', 'Core', 'Logic', 'Handler']
        internal_name = f'_{function_name}{rng.choice(internal_suffixes)}'

        # Check if function uses msg.sender - if so, pass as parameter
        uses_msg_sender = 'msg.sender' in body_text

        # Build internal function
        internal_params = params.copy()
        if uses_msg_sender:
            internal_params.insert(0, {'type': 'address', 'name': 'user'})
            # Replace msg.sender with user in body
            body_text = body_text.replace('msg.sender', 'user')

        internal_params_str = ', '.join(f"{p['type']} {p['name']}" for p in internal_params)

        internal_func = f'''
    function {internal_name}({internal_params_str}) internal {{
        {body_text}
    }}'''

        # Build external wrapper
        call_args = []
        if uses_msg_sender:
            call_args.append('msg.sender')
        call_args.extend(p['name'] for p in params)
        call_args_str = ', '.join(call_args)

        # Get original signature parts
        visibility = self._get_visibility(func_node, source)
        external_params_str = ', '.join(f"{p['type']} {p['name']}" for p in params)

        external_func = f'''function {function_name}({external_params_str}) {visibility} {{
        {internal_name}({call_args_str});
    }}'''

        # Assemble
        result = self._replace_function(source, func_node, external_func + internal_func)

        return result, {
            'split_type': 'internal_external',
            'original_function': function_name,
            'wrapper_function': function_name,
            'internal_function': internal_name,
            'msg_sender_parameterized': uses_msg_sender
        }
```

### 5.5 Output Metadata

```json
{
  "strategy": "hydra",
  "split_type": "sequential",
  "transformation_details": {
    "original_function": "withdraw",
    "helpers_created": [
      "_doWithdrawStep1",
      "_executeWithdrawStep2",
      "_handleWithdrawStep3"
    ],
    "statement_groups": 3,
    "parameters_propagated": ["amount"],
    "vulnerability_spans_functions": true
  },
  "vulnerability_preserved": true,
  "vulnerability_location_change": {
    "original": "withdraw() lines 10-15",
    "transformed": "spread across withdraw(), _executeWithdrawStep2()"
  }
}
```

---

## 6. Strategy B2: Chimera (Function Merging)

### 6.1 Purpose

Merge multiple functions into a single function with conditional branches. Tests whether models can analyze complex branching logic.

### 6.2 Hypothesis

> "If a model fails to detect a vulnerability when multiple operations are merged into one function with mode parameters, it struggles with branch analysis."

### 6.3 Merging Patterns

| Pattern             | Description                                  |
| ------------------- | -------------------------------------------- |
| `mode_parameter`    | Single function with enum/uint mode selector |
| `action_parameter`  | String/bytes4 action selector                |
| `conditional_merge` | If-else based on parameters                  |

### 6.4 Implementation

```python
class ChimeraMerger:
    """
    Merge multiple functions into one with conditional logic.

    Before:
        function deposit() external payable {
            balances[msg.sender] += msg.value;
        }

        function withdraw(uint256 amount) external {
            require(balances[msg.sender] >= amount);
            (bool success,) = msg.sender.call{value: amount}("");
            require(success);
            balances[msg.sender] -= amount;
        }

    After:
        enum Action { Deposit, Withdraw }

        function execute(Action action, uint256 amount) external payable {
            if (action == Action.Deposit) {
                balances[msg.sender] += msg.value;
            } else if (action == Action.Withdraw) {
                require(balances[msg.sender] >= amount);
                (bool success,) = msg.sender.call{value: amount}("");
                require(success);
                balances[msg.sender] -= amount;
            }
        }
    """

    def merge(
        self,
        source: str,
        tree,
        functions_to_merge: List[str],
        merge_style: str,
        rng: Random
    ) -> Tuple[str, dict]:
        """
        Merge multiple functions into one.

        Args:
            functions_to_merge: List of function names to merge
            merge_style: 'mode_parameter', 'action_parameter', or 'conditional'
        """
        # Collect function info
        func_infos = []
        for func_name in functions_to_merge:
            func_node = find_function_by_name(tree, func_name)
            if func_node:
                func_infos.append({
                    'name': func_name,
                    'node': func_node,
                    'params': self._get_parameters(func_node, source),
                    'body': self._get_body_text(func_node, source),
                    'visibility': self._get_visibility(func_node, source),
                    'is_payable': 'payable' in source[func_node.start_byte:func_node.end_byte]
                })

        if len(func_infos) < 2:
            return source, {'error': 'Need at least 2 functions to merge'}

        # Generate merged function based on style
        if merge_style == 'mode_parameter':
            merged, enum_def = self._merge_with_mode(func_infos, rng)
        elif merge_style == 'action_parameter':
            merged, enum_def = self._merge_with_action_bytes(func_infos, rng)
        else:  # conditional
            merged, enum_def = self._merge_conditional(func_infos, rng)

        # Remove original functions
        result = source
        for info in reversed(func_infos):  # Reverse to maintain positions
            result = self._remove_function(result, info['node'])

        # Add enum and merged function
        contract_body_start = self._find_contract_body_start(tree, source)

        insertion = ''
        if enum_def:
            insertion += f'\n    {enum_def}\n'
        insertion += f'\n{merged}\n'

        result = result[:contract_body_start + 1] + insertion + result[contract_body_start + 1:]

        return result, {
            'merge_style': merge_style,
            'functions_merged': functions_to_merge,
            'merged_function_name': self._extract_merged_name(merged),
            'enum_added': enum_def is not None
        }

    def _merge_with_mode(self, func_infos: List[dict], rng: Random) -> Tuple[str, str]:
        """
        Merge using enum mode parameter.
        """
        # Generate enum
        enum_name_options = ['Action', 'Operation', 'Mode', 'Command', 'Task']
        enum_name = rng.choice(enum_name_options)

        enum_values = [info['name'].capitalize() for info in func_infos]
        enum_def = f"enum {enum_name} {{ {', '.join(enum_values)} }}"

        # Combine all parameters (deduplicated)
        all_params = self._combine_parameters(func_infos)

        # Check if any function is payable
        is_payable = any(info['is_payable'] for info in func_infos)

        # Generate merged function name
        merged_names = ['execute', 'perform', 'process', 'handle', 'dispatch']
        merged_name = rng.choice(merged_names)

        # Build parameter list
        params_list = [f'{enum_name} action'] + [f"{p['type']} {p['name']}" for p in all_params]
        params_str = ', '.join(params_list)

        # Build visibility
        visibility = 'external'
        if is_payable:
            visibility += ' payable'

        # Build body with conditions
        body_parts = []
        for i, info in enumerate(func_infos):
            condition = f"{enum_name}.{enum_values[i]}"
            if i == 0:
                body_parts.append(f'if (action == {condition}) {{')
            else:
                body_parts.append(f'}} else if (action == {condition}) {{')

            # Indent body
            body_lines = info['body'].strip().split('\n')
            for line in body_lines:
                body_parts.append(f'    {line.strip()}')

        body_parts.append('}')
        body = '\n        '.join(body_parts)

        merged = f'''    function {merged_name}({params_str}) {visibility} {{
        {body}
    }}'''

        return merged, enum_def

    def _merge_with_action_bytes(self, func_infos: List[dict], rng: Random) -> Tuple[str, str]:
        """
        Merge using bytes4 action selector (like function signatures).
        """
        # Generate selectors
        selectors = {}
        for info in func_infos:
            selector = f"bytes4(keccak256('{info['name']}'))"
            selectors[info['name']] = selector

        # Build merged function
        all_params = self._combine_parameters(func_infos)
        is_payable = any(info['is_payable'] for info in func_infos)

        params_list = ['bytes4 action'] + [f"{p['type']} {p['name']}" for p in all_params]
        params_str = ', '.join(params_list)

        visibility = 'external'
        if is_payable:
            visibility += ' payable'

        # Build body
        body_parts = []
        for i, info in enumerate(func_infos):
            selector = selectors[info['name']]
            if i == 0:
                body_parts.append(f'if (action == {selector}) {{')
            else:
                body_parts.append(f'}} else if (action == {selector}) {{')

            body_lines = info['body'].strip().split('\n')
            for line in body_lines:
                body_parts.append(f'    {line.strip()}')

        body_parts.append('} else { revert("Unknown action"); }')
        body = '\n        '.join(body_parts)

        merged_name = rng.choice(['executeAction', 'performAction', 'dispatch', 'invoke'])

        merged = f'''    function {merged_name}({params_str}) {visibility} {{
        {body}
    }}'''

        return merged, None

    def _merge_conditional(self, func_infos: List[dict], rng: Random) -> Tuple[str, str]:
        """
        Merge using simple uint mode parameter.
        """
        all_params = self._combine_parameters(func_infos)
        is_payable = any(info['is_payable'] for info in func_infos)

        params_list = ['uint8 mode'] + [f"{p['type']} {p['name']}" for p in all_params]
        params_str = ', '.join(params_list)

        visibility = 'external'
        if is_payable:
            visibility += ' payable'

        body_parts = []
        for i, info in enumerate(func_infos):
            if i == 0:
                body_parts.append(f'if (mode == {i}) {{')
            else:
                body_parts.append(f'}} else if (mode == {i}) {{')

            body_lines = info['body'].strip().split('\n')
            for line in body_lines:
                body_parts.append(f'    {line.strip()}')

        body_parts.append('}')
        body = '\n        '.join(body_parts)

        merged_name = rng.choice(['execute', 'process', 'handleRequest', 'performOperation'])

        merged = f'''    function {merged_name}({params_str}) {visibility} {{
        {body}
    }}'''

        return merged, None

    def _combine_parameters(self, func_infos: List[dict]) -> List[dict]:
        """Combine parameters from all functions, deduplicating by name."""
        seen = set()
        combined = []

        for info in func_infos:
            for param in info['params']:
                if param['name'] not in seen:
                    seen.add(param['name'])
                    combined.append(param)

        return combined
```

### 6.5 Complete Example

**Input:**

```solidity
contract Vault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
```

**Output (Mode Parameter Merge):**

```solidity
contract Vault {
    mapping(address => uint256) public balances;

    enum Operation { Deposit, Withdraw, Transfer }

    function execute(Operation op, address to, uint256 amount) external payable {
        if (op == Operation.Deposit) {
            balances[msg.sender] += msg.value;
        } else if (op == Operation.Withdraw) {
            require(balances[msg.sender] >= amount);
            (bool success,) = msg.sender.call{value: amount}("");
            require(success);
            balances[msg.sender] -= amount;
        } else if (op == Operation.Transfer) {
            require(balances[msg.sender] >= amount);
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
    }
}
```

### 6.6 Output Metadata

```json
{
  "strategy": "chimera",
  "merge_style": "mode_parameter",
  "transformation_details": {
    "functions_merged": ["deposit", "withdraw", "transfer"],
    "merged_function_name": "execute",
    "enum_added": "Operation",
    "enum_values": ["Deposit", "Withdraw", "Transfer"],
    "combined_parameters": ["to", "amount"]
  },
  "vulnerability_preserved": true,
  "vulnerability_location_change": {
    "original": "withdraw() function",
    "transformed": "execute() function, Operation.Withdraw branch"
  }
}
```

---

## 7. Shared Infrastructure

### 7.1 Common Utilities

```python
# shared/utilities.py

def find_first(tree, node_types: Union[str, List[str]]):
    """Find first node of given type(s)."""
    if isinstance(node_types, str):
        node_types = [node_types]

    for node in tree.root_node.walk():
        if node.type in node_types:
            return node
    return None


def find_all(tree, node_types: Union[str, List[str]]) -> List:
    """Find all nodes of given type(s)."""
    if isinstance(node_types, str):
        node_types = [node_types]

    results = []
    for node in tree.root_node.walk():
        if node.type in node_types:
            results.append(node)
    return results


def find_function_by_name(tree, name: str):
    """Find function node by name."""
    for node in tree.root_node.walk():
        if node.type == 'function_definition':
            name_node = node.child_by_field_name('name')
            if name_node and name_node.text.decode() == name:
                return node
    return None


def apply_insertions(source: str, insertions: List[dict]) -> str:
    """
    Apply text insertions at specific positions.
    Insertions are applied back-to-front to maintain position validity.

    Each insertion: {'position': int, 'text': str}
    """
    # Sort by position descending
    insertions.sort(key=lambda i: i['position'], reverse=True)

    result = source
    for ins in insertions:
        result = result[:ins['position']] + ins['text'] + result[ins['position']:]

    return result


def apply_deletions(source: str, deletions: List[dict]) -> str:
    """
    Apply text deletions.

    Each deletion: {'start': int, 'end': int}
    """
    # Sort by position descending
    deletions.sort(key=lambda d: d['start'], reverse=True)

    result = source
    for deletion in deletions:
        result = result[:deletion['start']] + result[deletion['end']:]

    return result


def fix_indentation(source: str, indent_size: int = 4) -> str:
    """Re-indent code properly."""
    lines = source.split('\n')
    result = []
    indent_level = 0

    for line in lines:
        stripped = line.strip()

        # Decrease indent before closing brace
        if stripped.startswith('}'):
            indent_level = max(0, indent_level - 1)

        if stripped:
            result.append(' ' * (indent_level * indent_size) + stripped)
        else:
            result.append('')

        # Increase indent after opening brace
        if stripped.endswith('{'):
            indent_level += 1

    return '\n'.join(result)
```

### 7.2 Base Transformer Class

```python
# strategies/base.py

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional, Dict, Any

@dataclass
class TransformationResult:
    code: str
    strategy: str
    strategy_params: Dict[str, Any]
    validation: 'ValidationResult'
    transformation_details: Dict[str, Any] = None
    ground_truth_change: Optional[Dict[str, Any]] = None
    error: Optional[str] = None


class BaseTransformer(ABC):
    """Base class for all transformation strategies."""

    def __init__(self, language_plugin: 'LanguagePlugin'):
        self.language = language_plugin

    @abstractmethod
    def transform(self, source: str, **kwargs) -> TransformationResult:
        """Apply the transformation."""
        pass

    @property
    @abstractmethod
    def strategy_name(self) -> str:
        """Return the strategy name."""
        pass

    @property
    @abstractmethod
    def preserves_vulnerability(self) -> bool:
        """Return whether this strategy preserves vulnerability status."""
        pass
```

---

## 8. Validation Requirements

### 8.1 Per-Strategy Validation

| Strategy        | Compilation Check | Semantic Preservation    | Structure Check             |
| --------------- | ----------------- | ------------------------ | --------------------------- |
| Mirror          | ✅ Required       | ✅ Must be identical     | N/A                         |
| Cross-Domain    | ✅ Required       | ✅ Must be identical     | N/A                         |
| Guardian Shield | ✅ Required       | ❌ Intentionally changed | ✅ Check protection present |
| Hydra           | ✅ Required       | ✅ Must be identical     | ✅ Check helpers callable   |
| Chimera         | ✅ Required       | ✅ Must be identical     | ✅ Check branches reachable |

### 8.2 Validation Functions

```python
def validate_mirror(original: str, transformed: str, language) -> ValidationResult:
    """Validate Mirror transformation."""
    # Must compile
    compiles, error = check_compilation(transformed, language)
    if not compiles:
        return ValidationResult(valid=False, errors=[error])

    # AST structure should be identical (just formatting changed)
    orig_tree = parse(original, language)
    trans_tree = parse(transformed, language)

    if not ast_structure_matches(orig_tree, trans_tree):
        return ValidationResult(
            valid=False,
            errors=["AST structure changed - transformation may have broken code"]
        )

    return ValidationResult(valid=True)


def validate_guardian_shield(transformed: str, protection_type: str, language) -> ValidationResult:
    """Validate Guardian Shield transformation."""
    # Must compile
    compiles, error = check_compilation(transformed, language)
    if not compiles:
        return ValidationResult(valid=False, errors=[error])

    # Check protection is actually present
    if protection_type == 'reentrancy_guard':
        if 'ReentrancyGuard' not in transformed:
            return ValidationResult(
                valid=False,
                errors=["ReentrancyGuard inheritance not found"]
            )
        if 'nonReentrant' not in transformed:
            return ValidationResult(
                valid=False,
                errors=["nonReentrant modifier not found"]
            )

    elif protection_type == 'cei_pattern':
        # Would need dataflow analysis to verify CEI order
        # For now, just check it compiles
        pass

    return ValidationResult(valid=True)


def validate_hydra(transformed: str, helper_names: List[str], language) -> ValidationResult:
    """Validate Hydra transformation."""
    # Must compile
    compiles, error = check_compilation(transformed, language)
    if not compiles:
        return ValidationResult(valid=False, errors=[error])

    # All helper functions must exist
    for helper in helper_names:
        if f'function {helper}' not in transformed:
            return ValidationResult(
                valid=False,
                errors=[f"Helper function {helper} not found"]
            )

    return ValidationResult(valid=True)


def validate_chimera(transformed: str, merged_name: str, language) -> ValidationResult:
    """Validate Chimera transformation."""
    # Must compile
    compiles, error = check_compilation(transformed, language)
    if not compiles:
        return ValidationResult(valid=False, errors=[error])

    # Merged function must exist
    if f'function {merged_name}' not in transformed:
        return ValidationResult(
            valid=False,
            errors=[f"Merged function {merged_name} not found"]
        )

    return ValidationResult(valid=True)
```

---

## 9. Output Schema

### 9.1 Unified Transformation Output

```json
{
  "id": "ac_001_mirror_compressed",
  "source_id": "gs_001",

  "transformation": {
    "strategy": "mirror|cross_domain|guardian_shield|hydra|chimera",
    "strategy_category": "surface|semantic|structural",
    "timestamp": "2025-12-15T14:30:00Z"
  },

  "strategy_params": {
    // Strategy-specific parameters
  },

  "transformation_details": {
    // Strategy-specific details about what changed
  },

  "ground_truth": {
    "is_vulnerable": true,
    "vulnerability_type": "reentrancy",
    "vulnerability_preserved": true,
    "vulnerability_location_changed": false
  },

  "validation": {
    "valid": true,
    "syntax_ok": true,
    "compiles": true,
    "errors": [],
    "warnings": []
  }
}
```

### 9.2 Strategy-Specific Params

**Mirror:**

```json
{
  "mode": "compressed|expanded|allman|knr|minified",
  "comments_removed": true,
  "original_lines": 87,
  "transformed_lines": 34
}
```

**Cross-Domain:**

```json
{
  "source_domain": "defi",
  "target_domain": "gaming",
  "mappings_applied": 23,
  "unmapped_identifiers": ["veToken", "bribe"]
}
```

**Guardian Shield:**

```json
{
  "protection_type": "reentrancy_guard|cei_pattern|access_control|solidity_0_8",
  "vulnerability_type": "reentrancy",
  "injection_details": {
    "import_added": "...",
    "inheritance_added": "...",
    "functions_protected": ["withdraw"]
  }
}
```

**Hydra:**

```json
{
  "split_type": "sequential|helper_extraction|internal_external",
  "original_function": "withdraw",
  "helpers_created": [
    "_validateWithdraw",
    "_executeTransfer",
    "_updateBalance"
  ],
  "vulnerability_spans_functions": true
}
```

**Chimera:**

```json
{
  "merge_style": "mode_parameter|action_parameter|conditional",
  "functions_merged": ["deposit", "withdraw", "transfer"],
  "merged_function_name": "execute",
  "enum_added": "Operation"
}
```

---

## 10. Testing Checklist

### 10.1 Mirror Tests

- [ ] Compressed mode produces valid code
- [ ] Expanded mode produces valid code
- [ ] Allman style produces valid code
- [ ] K&R style produces valid code
- [ ] Comments are properly stripped when requested
- [ ] String literals are never modified
- [ ] All modes compile successfully

### 10.2 Cross-Domain Tests

- [ ] DeFi → Gaming produces valid code
- [ ] DeFi → Healthcare produces valid code
- [ ] DeFi → Social produces valid code
- [ ] All domain mappings are consistent
- [ ] Unmapped identifiers are tracked
- [ ] Standard interfaces preserved

### 10.3 Guardian Shield Tests

- [ ] ReentrancyGuard injection compiles
- [ ] CEI pattern fix compiles
- [ ] Access control injection compiles
- [ ] Solidity 0.8 upgrade works
- [ ] Protection actually neutralizes vulnerability
- [ ] Original vulnerability pattern still visible

### 10.4 Hydra Tests

- [ ] Sequential split produces valid code
- [ ] Internal/external split produces valid code
- [ ] Helper functions are callable
- [ ] Parameters propagated correctly
- [ ] Vulnerability still detectable across helpers

### 10.5 Chimera Tests

- [ ] Mode parameter merge produces valid code
- [ ] Action parameter merge produces valid code
- [ ] All branches are reachable
- [ ] Parameters combined correctly
- [ ] Vulnerability still detectable in branch

---

## Quick Reference

### Strategy Selection Guide

| Need to Test            | Use Strategy    |
| ----------------------- | --------------- |
| Format sensitivity      | Mirror          |
| Domain transfer         | Cross-Domain    |
| Protection recognition  | Guardian Shield |
| Cross-function analysis | Hydra           |
| Branch analysis         | Chimera         |

### Automation Confidence

| Strategy        | Confidence | Manual Review Needed    |
| --------------- | ---------- | ----------------------- |
| Mirror          | 100%       | None                    |
| Cross-Domain    | 90%        | Check unmapped terms    |
| Guardian Shield | 80%        | Verify protection works |
| Hydra           | 60%        | Check helper logic      |
| Chimera         | 60%        | Check branch logic      |

---

**Document Version:** 1.0  
**Strategies Covered:** Mirror, Cross-Domain, Guardian Shield, Hydra, Chimera  
**Status:** Ready for Implementation
