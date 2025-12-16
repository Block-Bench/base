# Chameleon Transformation Strategy v2.0

## Complete Implementation Guide with Flexible Randomized Replacements

**Version:** 2.0  
**Updated:** December 2025  
**Key Changes from v1:** Tree-sitter architecture, randomized synonym pools, byte-position replacement, validation pipeline

---

## Table of Contents

1. [Strategy Overview](#1-strategy-overview)
2. [Architecture](#2-architecture)
3. [Tree-sitter Integration](#3-tree-sitter-integration)
4. [Flexible Replacement System](#4-flexible-replacement-system)
5. [Synonym Pools (Complete)](#5-synonym-pools-complete)
6. [Pattern Rules](#6-pattern-rules)
7. [Compound Word Decomposition](#7-compound-word-decomposition)
8. [Transformation Algorithm](#8-transformation-algorithm)
9. [Byte-Position Replacement](#9-byte-position-replacement)
10. [Reserved Words](#10-reserved-words)
11. [Validation Pipeline](#11-validation-pipeline)
12. [Coverage Tracking](#12-coverage-tracking)
13. [Output Schema](#13-output-schema)
14. [Complete Examples](#14-complete-examples)
15. [Testing Requirements](#15-testing-requirements)

---

## 1. Strategy Overview

### 1.1 What is Chameleon?

Chameleon systematically renames all user-defined identifiers in a smart contract while preserving exact functionality and vulnerability status. The goal is to test whether AI models rely on keyword patterns rather than understanding code semantics.

### 1.2 Critical Design Principle: Avoid Learnable Patterns

**Problem with deterministic mapping:**

```
If withdraw → claimLoot (always)
Then models learn: "claimLoot" = vulnerability signal
We've just created a new keyword to detect.
```

**Solution: Randomized synonym pools**

```
withdraw → randomly select from [claimLoot, retrieveRewards, collectBounty,
           gatherTreasure, obtainPrize, extractWinnings, harvestGold, ...]

Each contract gets different selections.
Models cannot learn a fixed mapping.
```

### 1.3 Key Properties

| Property             | Requirement                          |
| -------------------- | ------------------------------------ |
| Functionality        | MUST be identical                    |
| Compilation          | MUST succeed                         |
| Vulnerability status | MUST be preserved                    |
| Identifier coverage  | SHOULD be ≥75%                       |
| Naturalness          | MUST look like real code             |
| Determinism          | MUST be reproducible (seeded random) |
| Variation            | MUST vary across contracts           |

### 1.4 Hypothesis Being Tested

> "If a model's accuracy drops significantly when identifiers are renamed to semantically-neutral alternatives, the model is pattern-matching on keywords rather than understanding the vulnerability."

---

## 2. Architecture

### 2.1 High-Level Pipeline

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CHAMELEON PIPELINE v2                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  INPUT                                                                  │
│  ├── source.sol                                                         │
│  ├── theme (gaming | resource | abstract | medical | social)            │
│  ├── seed (contract hash for reproducibility)                           │
│  └── options {strip_comments, coverage_threshold, variation_level}      │
│                                                                         │
│  PHASE 1: PARSE (Tree-sitter)                                           │
│  ├── Parse source → AST                                                 │
│  ├── Query all identifier declarations                                  │
│  ├── Query all identifier references                                    │
│  ├── Filter reserved words / standard interfaces                        │
│  └── Build identifier registry with byte positions                      │
│                                                                         │
│  PHASE 2: MAP (Randomized Selection)                                    │
│  ├── Initialize RNG with contract-specific seed                         │
│  ├── For each unique identifier:                                        │
│  │   ├── Layer 1: Synonym pool lookup → random selection                │
│  │   ├── Layer 2: Pattern rules → generate + random suffix              │
│  │   ├── Layer 3: Compound decomposition → random part combinations     │
│  │   └── Layer 4: Leave unchanged, track as untransformed               │
│  ├── Check for collisions → resolve with random suffixes                │
│  └── Build final rename map                                             │
│                                                                         │
│  PHASE 3: TRANSFORM                                                     │
│  ├── Optionally strip/neutralize comments                               │
│  ├── Collect all byte positions for each identifier                     │
│  ├── Sort edits by position (descending)                                │
│  └── Apply replacements back-to-front                                   │
│                                                                         │
│  PHASE 4: VALIDATE                                                      │
│  ├── Parse transformed code (syntax check)                              │
│  ├── Compile with solc (compilation check)                              │
│  ├── Verify no reserved words renamed                                   │
│  ├── Verify no identifier leakage                                       │
│  └── Calculate coverage metrics                                         │
│                                                                         │
│  OUTPUT                                                                 │
│  ├── transformed.sol                                                    │
│  ├── metadata.json (rename_map, coverage, validation)                   │
│  └── seed used (for reproducibility)                                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Project Structure

```
adversarial/
├── core/
│   ├── __init__.py
│   ├── parser.py              # Tree-sitter wrapper
│   ├── replacer.py            # Byte-position replacement logic
│   └── validator.py           # Compilation & consistency checks
├── strategies/
│   ├── __init__.py
│   ├── base.py                # Abstract strategy interface
│   ├── chameleon.py           # Randomized renaming strategy
│   ├── mirror.py              # Formatting (uses external tools)
│   ├── cross_domain.py        # Domain terminology swap
│   └── guardian_shield.py     # Protection injection
├── languages/
│   ├── __init__.py
│   ├── base.py                # Abstract language plugin
│   ├── solidity.py            # Solidity keywords, queries
│   └── rust_solana.py         # Rust/Anchor keywords, queries
├── themes/
│   ├── __init__.py
│   ├── loader.py              # Synonym pool loader + random selector
│   ├── gaming.yaml            # Gaming theme pools
│   ├── resource.yaml          # Resource management pools
│   ├── abstract.yaml          # Abstract/technical pools
│   ├── medical.yaml           # Medical theme pools
│   └── social.yaml            # Social/community pools
├── cli.py                     # Command-line interface
├── batch.py                   # Batch processing pipeline
└── requirements.txt
```

### 2.3 Dependencies

```
# requirements.txt
tree-sitter>=0.21.0
tree-sitter-solidity>=0.1.0
tree-sitter-rust>=0.21.0
pyyaml>=6.0
click>=8.0
```

---

## 3. Tree-sitter Integration

### 3.1 Why Tree-sitter?

| Feature          | Tree-sitter  | Regex                 | Language-specific |
| ---------------- | ------------ | --------------------- | ----------------- |
| Multi-language   | ✅ Same API  | ❌ Different patterns | ❌ Different libs |
| Accuracy         | ✅ Full AST  | ❌ Edge cases fail    | ✅ Full AST       |
| Speed            | ✅ Very fast | ✅ Fast               | ⚠️ Varies         |
| String handling  | ✅ Correct   | ❌ False matches      | ✅ Correct        |
| Comment handling | ✅ Correct   | ❌ False matches      | ✅ Correct        |

### 3.2 Language Plugin Interface

```python
# languages/base.py
from abc import ABC, abstractmethod
from typing import Set, Dict, List

class LanguagePlugin(ABC):
    @abstractmethod
    def get_language_name(self) -> str:
        """Return 'solidity' or 'rust'"""
        pass

    @abstractmethod
    def get_file_extensions(self) -> List[str]:
        """Return ['.sol'] or ['.rs']"""
        pass

    @abstractmethod
    def get_keywords(self) -> Set[str]:
        """Reserved words that should never be renamed"""
        pass

    @abstractmethod
    def get_builtin_types(self) -> Set[str]:
        """Built-in types that should never be renamed"""
        pass

    @abstractmethod
    def get_builtin_globals(self) -> Set[str]:
        """Global variables/functions that should never be renamed"""
        pass

    @abstractmethod
    def get_standard_interfaces(self) -> Dict[str, Set[str]]:
        """Standard interface names and their required functions"""
        pass

    @abstractmethod
    def get_identifier_queries(self) -> Dict[str, str]:
        """Tree-sitter queries for different identifier types"""
        pass

    @abstractmethod
    def get_comment_query(self) -> str:
        """Tree-sitter query to find all comments"""
        pass
```

### 3.3 Solidity Plugin

```python
# languages/solidity.py
from .base import LanguagePlugin

class SolidityPlugin(LanguagePlugin):
    def get_language_name(self) -> str:
        return "solidity"

    def get_file_extensions(self) -> list[str]:
        return [".sol"]

    def get_keywords(self) -> set[str]:
        return {
            # Declaration keywords
            "pragma", "solidity", "import", "contract", "interface", "library",
            "abstract", "is", "using", "for", "struct", "enum", "event", "error",
            "function", "modifier", "constructor", "fallback", "receive",

            # Type keywords
            "mapping", "bool", "string", "bytes", "address", "payable",
            "uint", "uint8", "uint16", "uint32", "uint64", "uint128", "uint256",
            "int", "int8", "int16", "int32", "int64", "int128", "int256",
            "bytes1", "bytes2", "bytes4", "bytes8", "bytes16", "bytes32",

            # Visibility & mutability
            "public", "private", "internal", "external",
            "view", "pure", "constant", "immutable",
            "virtual", "override", "indexed", "anonymous",
            "memory", "storage", "calldata",

            # Control flow
            "if", "else", "for", "while", "do", "break", "continue", "return",
            "try", "catch", "throw", "revert", "require", "assert",

            # Other
            "new", "delete", "emit", "assembly", "true", "false",
            "wei", "gwei", "ether", "seconds", "minutes", "hours", "days", "weeks",
        }

    def get_builtin_types(self) -> set[str]:
        return {
            "uint", "uint8", "uint16", "uint32", "uint64", "uint128", "uint256",
            "int", "int8", "int16", "int32", "int64", "int128", "int256",
            "bytes", "bytes1", "bytes2", "bytes4", "bytes8", "bytes16", "bytes32",
            "bool", "string", "address", "mapping",
        }

    def get_builtin_globals(self) -> set[str]:
        return {
            # Block properties
            "block", "blockhash",
            # Message properties
            "msg",
            # Transaction properties
            "tx",
            # Global functions
            "gasleft", "addmod", "mulmod", "keccak256", "sha256", "ripemd160",
            "ecrecover", "selfdestruct",
            # ABI functions
            "abi",
            # Type functions
            "type",
            # Address members
            "balance", "code", "codehash", "transfer", "send", "call",
            "delegatecall", "staticcall",
            # Contract related
            "this", "super",
            # Error handling
            "Error", "Panic",
        }

    def get_standard_interfaces(self) -> dict[str, set[str]]:
        return {
            "IERC20": {"totalSupply", "balanceOf", "transfer", "allowance",
                       "approve", "transferFrom", "name", "symbol", "decimals"},
            "ERC20": {"totalSupply", "balanceOf", "transfer", "allowance",
                      "approve", "transferFrom", "name", "symbol", "decimals"},
            "IERC721": {"balanceOf", "ownerOf", "safeTransferFrom", "transferFrom",
                        "approve", "setApprovalForAll", "getApproved", "isApprovedForAll"},
            "Ownable": {"owner", "renounceOwnership", "transferOwnership", "onlyOwner"},
            "ReentrancyGuard": {"nonReentrant"},
            "Pausable": {"paused", "whenNotPaused", "whenPaused"},
        }

    def get_identifier_queries(self) -> dict[str, str]:
        return {
            # Declarations
            "contract_decl": "(contract_declaration name: (identifier) @name)",
            "interface_decl": "(interface_declaration name: (identifier) @name)",
            "library_decl": "(library_declaration name: (identifier) @name)",
            "function_decl": "(function_definition name: (identifier) @name)",
            "modifier_decl": "(modifier_definition name: (identifier) @name)",
            "event_decl": "(event_definition name: (identifier) @name)",
            "error_decl": "(error_declaration name: (identifier) @name)",
            "struct_decl": "(struct_declaration name: (identifier) @name)",
            "enum_decl": "(enum_declaration name: (identifier) @name)",
            "state_var": "(state_variable_declaration name: (identifier) @name)",
            "local_var": "(variable_declaration name: (identifier) @name)",
            "parameter": "(parameter name: (identifier) @name)",

            # References (all identifier usages)
            "all_identifiers": "(identifier) @id",
        }

    def get_comment_query(self) -> str:
        return """
            (comment) @comment
            (natspec_comment) @natspec
        """
```

### 3.4 Rust/Solana Plugin

```python
# languages/rust_solana.py
from .base import LanguagePlugin

class RustSolanaPlugin(LanguagePlugin):
    def get_language_name(self) -> str:
        return "rust"

    def get_file_extensions(self) -> list[str]:
        return [".rs"]

    def get_keywords(self) -> set[str]:
        return {
            # Rust keywords
            "as", "async", "await", "break", "const", "continue", "crate",
            "dyn", "else", "enum", "extern", "false", "fn", "for", "if",
            "impl", "in", "let", "loop", "match", "mod", "move", "mut",
            "pub", "ref", "return", "self", "Self", "static", "struct",
            "super", "trait", "true", "type", "unsafe", "use", "where", "while",
        }

    def get_builtin_types(self) -> set[str]:
        return {
            "bool", "char", "str", "u8", "u16", "u32", "u64", "u128", "usize",
            "i8", "i16", "i32", "i64", "i128", "isize", "f32", "f64",
            "String", "Vec", "Option", "Result", "Box", "Rc", "Arc",
        }

    def get_builtin_globals(self) -> set[str]:
        return {
            # Anchor types
            "Context", "Program", "Account", "Signer", "SystemAccount",
            "UncheckedAccount", "AccountInfo", "Pubkey", "Result",
            # Anchor macros
            "msg", "require", "require_keys_eq", "emit",
            # Common derives
            "Accounts", "AnchorSerialize", "AnchorDeserialize",
            # SPL
            "TokenAccount", "Mint", "Token",
        }

    def get_standard_interfaces(self) -> dict[str, set[str]]:
        return {
            # Anchor patterns
            "Accounts": set(),  # Derive macro
        }

    def get_identifier_queries(self) -> dict[str, str]:
        return {
            # Standard Rust
            "function_decl": "(function_item name: (identifier) @name)",
            "struct_decl": "(struct_item name: (type_identifier) @name)",
            "enum_decl": "(enum_item name: (type_identifier) @name)",
            "trait_decl": "(trait_item name: (type_identifier) @name)",
            "impl_decl": "(impl_item type: (type_identifier) @name)",
            "let_binding": "(let_declaration pattern: (identifier) @name)",
            "parameter": "(parameter pattern: (identifier) @name)",
            "field": "(field_declaration name: (field_identifier) @name)",

            # Anchor-specific
            "program_module": """
                (attribute_item (attribute (identifier) @attr))
                (#eq? @attr "program")
                . (mod_item name: (identifier) @name)
            """,
            "accounts_struct": """
                (attribute_item
                    (attribute
                        arguments: (token_tree (identifier) @derive_type)))
                (#eq? @derive_type "Accounts")
                . (struct_item name: (type_identifier) @name)
            """,

            # All identifiers
            "all_identifiers": "(identifier) @id",
            "all_type_identifiers": "(type_identifier) @id",
        }

    def get_comment_query(self) -> str:
        return """
            (line_comment) @comment
            (block_comment) @comment
        """
```

---

## 4. Flexible Replacement System

### 4.1 Core Principle: Synonym Pools with Random Selection

Instead of 1-to-1 mappings, each identifier concept maps to a **pool of synonyms**. At transformation time, we **randomly select** from the pool using a seeded RNG.

```python
# WRONG: Deterministic mapping (models will learn this)
mapping = {"withdraw": "claimLoot"}

# RIGHT: Synonym pool with random selection
pools = {
    "withdraw": [
        "claimLoot", "retrieveRewards", "collectBounty", "gatherTreasure",
        "obtainPrize", "extractWinnings", "harvestGold", "redeemTokens",
        "withdrawFunds", "pullAssets", "reclaimValue", "liberateFunds"
    ]
}

def get_replacement(identifier: str, rng: Random) -> str:
    pool = pools.get(identifier.lower())
    if pool:
        return rng.choice(pool)
    return None
```

### 4.2 Seeded Randomness for Reproducibility

```python
import hashlib
from random import Random

def create_contract_rng(source_code: str, theme: str) -> Random:
    """
    Create a seeded RNG unique to this contract + theme combination.
    Same input always produces same output (reproducible).
    Different contracts get different random selections.
    """
    seed_input = f"{theme}:{hashlib.sha256(source_code.encode()).hexdigest()}"
    seed = int(hashlib.md5(seed_input.encode()).hexdigest(), 16) % (2**32)
    return Random(seed)
```

### 4.3 Variation Levels

Support different levels of variation for different use cases:

```python
class VariationLevel:
    """
    Controls how much variation is applied.
    """
    # LOW: Consistent within theme, some variation between contracts
    # Each identifier always maps to top 3 choices
    LOW = "low"

    # MEDIUM: Moderate variation, top 50% of pool
    # Good balance of naturalness and variation
    MEDIUM = "medium"

    # HIGH: Full pool randomization
    # Maximum variation, may occasionally produce unusual combinations
    HIGH = "high"

    # EXTREME: Full pool + random suffixes + compound shuffling
    # For stress testing, may look less natural
    EXTREME = "extreme"


def get_replacement(
    identifier: str,
    pool: list[str],
    rng: Random,
    variation: VariationLevel
) -> str:
    if not pool:
        return None

    if variation == VariationLevel.LOW:
        # Pick from top 3 only
        subset = pool[:min(3, len(pool))]
    elif variation == VariationLevel.MEDIUM:
        # Pick from top 50%
        subset = pool[:max(1, len(pool) // 2)]
    elif variation == VariationLevel.HIGH:
        # Full pool
        subset = pool
    elif variation == VariationLevel.EXTREME:
        # Full pool + might add random suffix
        choice = rng.choice(pool)
        if rng.random() < 0.2:  # 20% chance of suffix
            choice += str(rng.randint(1, 99))
        return choice

    return rng.choice(subset)
```

### 4.4 Thematic Consistency

Within a single contract, maintain thematic consistency:

```python
class ThematicContext:
    """
    Tracks choices made within a contract to maintain consistency.
    """
    def __init__(self, theme: str, rng: Random):
        self.theme = theme
        self.rng = rng
        self.chosen_style = {}  # Cache of choices made

        # Pick a sub-style at the start (for themes with variants)
        self.sub_style = self._pick_sub_style()

    def _pick_sub_style(self) -> str:
        """
        Some themes have sub-variants for even more diversity.
        E.g., gaming might be: rpg, casino, arcade, sports
        """
        sub_styles = {
            "gaming": ["rpg", "casino", "arcade", "sports", "mmo"],
            "resource": ["corporate", "industrial", "logistics", "utilities"],
            "abstract": ["mathematical", "systematic", "procedural"],
            "medical": ["hospital", "pharmacy", "research"],
            "social": ["community", "influencer", "nonprofit"],
        }
        return self.rng.choice(sub_styles.get(self.theme, ["default"]))
```

---

## 5. Synonym Pools (Complete)

### 5.1 Pool Structure

```yaml
# themes/gaming.yaml
theme_name: gaming
description: 'Video game / rewards / loot terminology'

# Sub-styles for additional variation
sub_styles:
  rpg: 'Role-playing game terminology'
  casino: 'Casino/gambling terminology'
  arcade: 'Arcade/classic game terminology'
  sports: 'Sports game terminology'
  mmo: 'MMO game terminology'

# Each concept has a pool of synonyms
# First items are "more natural", later items add variety
pools:
  # ============================================
  # CONTRACT NAMES
  # ============================================
  contract_names:
    vault:
      - LootVault
      - TreasureHold
      - RewardCache
      - GoldRepository
      - PrizeVault
      - BountyStorage
      - WinningsBank
      - JackpotVault
      - CoinTreasury
      - GemStorage
      - TokenHoard
      - AssetChest

    bank:
      - TreasureHoard
      - GoldBank
      - CoinReserve
      - WealthStorage
      - FortuneVault
      - RichesKeeper
      - ValueStore
      - AssetBank
      - WinningsHold
      - PrizeBank

    pool:
      - LootPool
      - RewardPool
      - PrizePool
      - BountyPool
      - JackpotPool
      - WinningsPool
      - StakePool
      - GoldPool
      - TreasurePool
      - CommunityPot

    treasury:
      - GuildTreasury
      - RewardsTreasury
      - PrizeFund
      - BountyFund
      - GoldReserve
      - TeamTreasury
      - ClanVault
      - AllianceFund

    token:
      - GameCoin
      - GoldToken
      - RewardToken
      - PrizeToken
      - LootToken
      - GemToken
      - CrystalToken
      - PowerToken
      - EnergyToken

    protocol:
      - GameEngine
      - QuestSystem
      - RewardEngine
      - LootSystem
      - PrizeEngine
      - BountySystem
      - AchievementEngine

    manager:
      - QuestManager
      - RewardManager
      - LootMaster
      - PrizeController
      - BountyHandler
      - GameMaster
      - DungeonMaster

    staking:
      - PowerStaking
      - EnergyLock
      - StrengthCommit
      - LevelStaking
      - XPStaking
      - SkillLock

  # ============================================
  # FUNCTION NAMES - Value Extraction
  # ============================================
  function_names:
    withdraw:
      - claimLoot
      - retrieveRewards
      - collectBounty
      - gatherTreasure
      - obtainPrize
      - extractWinnings
      - harvestGold
      - redeemTokens
      - pullAssets
      - reclaimValue
      - liberateFunds
      - unlockTreasure
      - seizePrize
      - grabLoot
      - takeBounty

    withdrawall:
      - claimAllLoot
      - collectAllRewards
      - gatherAllTreasure
      - sweepWinnings
      - harvestAllGold
      - redeemAllTokens
      - emptyVault
      - clearBounty

    redeem:
      - exchangeTokens
      - convertPrize
      - cashOutRewards
      - tradeLoot
      - swapTokens
      - claimReward
      - collectPrize

    claim:
      - collectBounty
      - obtainReward
      - receivePrize
      - getPayout
      - grabWinnings
      - takeLoot
      - acceptReward
      - earnBounty

    harvest:
      - gatherYield
      - collectGrowth
      - reapRewards
      - farmBounty
      - mineGold
      - extractValue
      - harvestCrops

    unstake:
      - releasePower
      - unlockEnergy
      - freeStrength
      - withdrawStake
      - removeCommitment
      - liberatePower
      - unbindEnergy

    exit:
      - leaveGame
      - quitQuest
      - abandonMission
      - departDungeon
      - escapeZone
      - withdrawFromGame

    # ============================================
    # FUNCTION NAMES - Value Deposit
    # ============================================
    deposit:
      - storeLoot
      - addTreasure
      - depositGold
      - cachePrize
      - bankWinnings
      - stashRewards
      - secureFunds
      - lockValue
      - saveTreasure
      - contributeGold

    stake:
      - commitPower
      - lockEnergy
      - pledgeStrength
      - investPower
      - bindEnergy
      - stakePower
      - chargeUp

    supply:
      - provideResources
      - contributeAssets
      - fundPool
      - addLiquidity
      - supplyGold
      - fillTreasury

    enter:
      - joinGame
      - enterQuest
      - startMission
      - beginAdventure
      - engageLevel

    lock:
      - secureTreasure
      - bindAssets
      - freezeGold
      - holdValue
      - imprisonFunds

    # ============================================
    # FUNCTION NAMES - Transfer
    # ============================================
    transfer:
      - sendLoot
      - moveTreasure
      - tradeFunds
      - shiftGold
      - relocateAssets
      - passRewards
      - giveTokens
      - shareBounty

    send:
      - dispatchLoot
      - transmitGold
      - forwardRewards
      - deliverPrize
      - shipTreasure

    swap:
      - exchangeLoot
      - tradeTreasure
      - barterGoods
      - switchAssets
      - convertTokens

    # ============================================
    # FUNCTION NAMES - Query
    # ============================================
    getbalance:
      - checkLoot
      - viewTreasure
      - inspectGold
      - queryRewards
      - showHoldings
      - displayWealth
      - fetchBalance
      - readAssets

    balanceof:
      - lootOf
      - treasureOf
      - goldOf
      - holdingsOf
      - wealthOf
      - assetsOf
      - rewardsOf

    totalsupply:
      - totalGold
      - totalTreasure
      - allLoot
      - completeHoard
      - fullTreasury
      - entireSupply

    pendingreward:
      - queuedBounty
      - awaitingPrize
      - unclaimedLoot
      - pendingGold
      - earnedRewards
      - accruedBounty

    # ============================================
    # FUNCTION NAMES - Admin
    # ============================================
    setfee:
      - configureTax
      - adjustCut
      - updateCharge
      - modifyFee
      - setTribute

    pause:
      - freezeGame
      - haltOperations
      - suspendQuest
      - stopEngine
      - pauseAdventure

    unpause:
      - unfreezeGame
      - resumeOperations
      - continueQuest
      - restartEngine
      - resumeAdventure

    initialize:
      - startGame
      - beginQuest
      - launchAdventure
      - initializeMission
      - setupEngine

  # ============================================
  # VARIABLE NAMES
  # ============================================
  variable_names:
    balance:
      - lootBalance
      - treasureAmount
      - goldHolding
      - rewardLevel
      - prizeCount
      - bountyTotal
      - assetValue
      - wealthAmount

    balances:
      - playerLoot
      - heroTreasure
      - characterGold
      - userRewards
      - participantPrizes
      - memberBounties
      - accountHoldings

    amount:
      - quantity
      - count
      - sum
      - total
      - measure
      - volume
      - portion
      - share

    value:
      - worth
      - price
      - cost
      - magnitude
      - weight
      - significance

    total:
      - aggregate
      - combined
      - complete
      - full
      - entire
      - overall
      - cumulative

    fee:
      - tax
      - cut
      - tribute
      - charge
      - toll
      - commission
      - rake

    rate:
      - multiplier
      - factor
      - ratio
      - coefficient
      - percentage
      - modifier

    reward:
      - bounty
      - prize
      - bonus
      - payout
      - treasure
      - loot
      - earnings
      - winnings

    user:
      - player
      - hero
      - character
      - adventurer
      - participant
      - gamer
      - challenger

    owner:
      - guildMaster
      - gameAdmin
      - dungeonMaster
      - chieftain
      - overlord
      - commander

    pending:
      - queued
      - waiting
      - upcoming
      - scheduled
      - deferred
      - standby

    locked:
      - frozen
      - bound
      - sealed
      - secured
      - imprisoned
      - held

    token:
      - coin
      - gem
      - crystal
      - medal
      - badge
      - point

    share:
      - portion
      - slice
      - piece
      - fraction
      - cut
      - stake

    debt:
      - obligation
      - liability
      - owing
      - deficit
      - shortfall

    collateral:
      - pledge
      - security
      - deposit
      - guarantee
      - backing

    timestamp:
      - gameTime
      - questTime
      - adventureTime
      - missionClock
      - eventTime

    duration:
      - questLength
      - missionTime
      - adventurePeriod
      - gameDuration
      - sessionLength

    deadline:
      - timeLimit
      - expiryTime
      - cutoffTime
      - questDeadline
      - missionEnd

  # ============================================
  # EVENT NAMES
  # ============================================
  event_names:
    deposit:
      - LootStored
      - TreasureAdded
      - GoldDeposited
      - RewardsReceived
      - PrizeCached
      - BountyBanked
      - FundsSecured

    withdrawal:
      - LootClaimed
      - TreasureWithdrawn
      - GoldExtracted
      - RewardsCollected
      - PrizeObtained
      - BountyPaid
      - FundsReleased

    transfer:
      - LootMoved
      - TreasureTransferred
      - GoldSent
      - RewardsShifted
      - AssetsMoved

    stake:
      - PowerCommitted
      - EnergyLocked
      - StrengthPledged
      - StakeCreated

    unstake:
      - PowerReleased
      - EnergyUnlocked
      - StrengthFreed
      - StakeRemoved

  # ============================================
  # ERROR NAMES
  # ============================================
  error_names:
    insufficientbalance:
      - InsufficientLoot
      - NotEnoughGold
      - TreasureShortfall
      - LowRewards
      - PrizeMissing
      - BountyLacking

    unauthorized:
      - NotAuthorized
      - AccessDenied
      - PermissionDenied
      - Forbidden
      - NotAllowed
      - Rejected

    invalidamount:
      - InvalidQuantity
      - BadAmount
      - WrongValue
      - IllegalSum
      - IncorrectTotal

    zeroamount:
      - ZeroQuantity
      - EmptyAmount
      - NoValue
      - NothingProvided

    transferfailed:
      - SendFailed
      - MovementError
      - DeliveryFailed
      - TransactionError

  # ============================================
  # MODIFIER NAMES
  # ============================================
  modifier_names:
    onlyowner:
      - onlyGuildMaster
      - onlyGameAdmin
      - onlyDungeonMaster
      - onlyCommander
      - onlyChief

    whennotpaused:
      - whenGameActive
      - whenRunning
      - whenLive
      - whenOperational

    nonreentrant:
      - singleEntry
      - oneAtATime
      - noReentry
      - lockedExecution

  # ============================================
  # STRUCT NAMES
  # ============================================
  struct_names:
    userinfo:
      - PlayerStats
      - HeroData
      - CharacterInfo
      - AdventurerRecord
      - GamerProfile

    poolinfo:
      - QuestData
      - MissionInfo
      - AdventureRecord
      - GamePoolInfo

    stakeinfo:
      - PowerRecord
      - EnergyData
      - CommitmentInfo
      - StakeRecord
```

### 5.2 Resource Management Theme

```yaml
# themes/resource.yaml
theme_name: resource
description: 'Generic resource allocation / business terminology'

pools:
  contract_names:
    vault:
      - ResourceManager
      - AssetController
      - AllocationVault
      - UnitRepository
      - ValueStore
      - HoldingsFacility
      - CapitalManager
      - ReserveController

    bank:
      - AllocationCenter
      - ResourceBank
      - AssetReserve
      - CapitalStore
      - UnitBank
      - ValueRepository

    pool:
      - ResourcePool
      - AllocationPool
      - UnitAggregate
      - AssetCollection
      - CapitalPool
      - SharedReserve

    treasury:
      - CentralReserve
      - MasterAllocation
      - PrimaryVault
      - CoreTreasury
      - MainRepository

  function_names:
    withdraw:
      - releaseUnits
      - extractResources
      - deallocate
      - disburseFunds
      - liberateAssets
      - withdrawAllocation
      - pullResources
      - retrieveUnits
      - reclaimAssets
      - obtainAllocation

    deposit:
      - allocateUnits
      - contributeResources
      - assignFunds
      - provisionAssets
      - submitAllocation
      - addResources
      - insertUnits
      - placeAssets

    transfer:
      - reassignUnits
      - reallocateResources
      - shiftAllocation
      - moveAssets
      - redirectFunds
      - relocateUnits

    getbalance:
      - queryAllocation
      - checkUnits
      - viewResources
      - inspectHoldings
      - fetchAllocation

    balanceof:
      - allocationOf
      - unitsOf
      - resourcesOf
      - holdingsOf

  variable_names:
    balance:
      - allocation
      - units
      - holdings
      - resources
      - position

    balances:
      - allocations
      - unitMappings
      - resourceRecords
      - holdingsMap

    amount:
      - quantity
      - units
      - magnitude
      - measure
      - count

    user:
      - entity
      - account
      - participant
      - stakeholder
      - member

    owner:
      - administrator
      - controller
      - supervisor
      - manager

    fee:
      - serviceCharge
      - processingFee
      - handlingCost
      - operationalCharge

    reward:
      - incentive
      - yield
      - return
      - proceeds
      - earnings
```

### 5.3 Abstract/Technical Theme

```yaml
# themes/abstract.yaml
theme_name: abstract
description: 'Domain-neutral technical terminology'

pools:
  contract_names:
    vault:
      - StateContainer
      - DataHolder
      - ValueStore
      - EntityManager
      - RecordKeeper
      - StorageUnit

    bank:
      - DataRepository
      - RecordStore
      - EntityBank
      - ValueRegistry

    pool:
      - AggregateStore
      - CollectionManager
      - SetContainer
      - GroupHolder

  function_names:
    withdraw:
      - executeOutflow
      - processExtraction
      - performRetrieval
      - initiateRelease
      - triggerOutbound
      - runExtract
      - doRelease

    deposit:
      - executeInflow
      - processInsertion
      - performAddition
      - initiateDeposit
      - triggerInbound
      - runInsert

    transfer:
      - executeTransition
      - processMovement
      - performShift
      - initiateTransfer
      - triggerReassignment

    getbalance:
      - queryState
      - fetchValue
      - retrieveData
      - readRecord
      - getStatus

    balanceof:
      - stateOf
      - valueOf
      - recordOf
      - dataOf

  variable_names:
    balance:
      - stateValue
      - recordedAmount
      - storedQuantity
      - heldValue

    amount:
      - delta
      - magnitude
      - quantity
      - measure

    user:
      - entity
      - subject
      - actor
      - principal

    owner:
      - controller
      - authority
      - administrator
      - supervisor
```

### 5.4 Medical Theme

```yaml
# themes/medical.yaml
theme_name: medical
description: 'Healthcare and medical terminology'

pools:
  contract_names:
    vault:
      - PatientRecords
      - MedicalStorage
      - CareRepository
      - HealthVault
      - TreatmentRegistry

    bank:
      - MedicationBank
      - SupplyStorage
      - ResourceCenter
      - CareBank

    pool:
      - DonorPool
      - ResourcePool
      - TreatmentPool
      - CarePool

  function_names:
    withdraw:
      - dischargeFunds
      - releaseTreatment
      - dispenseMedication
      - extractResources
      - retrieveSupplies
      - obtainCare

    deposit:
      - admitFunds
      - submitResources
      - provideSupplies
      - contributeCare
      - registerPayment

    transfer:
      - referPatient
      - relocateResources
      - moveSupplies
      - shiftCare

    getbalance:
      - checkStatus
      - queryRecords
      - viewCoverage
      - inspectAccount

  variable_names:
    balance:
      - coverage
      - benefits
      - credits
      - allocation

    amount:
      - dosage
      - quantity
      - measure
      - units

    user:
      - patient
      - member
      - beneficiary
      - enrollee

    owner:
      - administrator
      - director
      - supervisor
      - coordinator

    fee:
      - copay
      - deductible
      - premium
      - charge
```

### 5.5 Social Theme

```yaml
# themes/social.yaml
theme_name: social
description: 'Social media and community platform terminology'

pools:
  contract_names:
    vault:
      - CommunityFund
      - CreatorVault
      - SupporterPool
      - TipJar
      - PatronageVault

    bank:
      - ReputationBank
      - KarmaStorage
      - InfluenceVault
      - SocialBank

    pool:
      - SupportPool
      - CommunityPool
      - CreatorPool
      - FanPool

  function_names:
    withdraw:
      - claimTips
      - withdrawSupport
      - collectDonations
      - redeemKarma
      - cashOutEarnings
      - retrieveContributions

    deposit:
      - sendTip
      - supportCreator
      - contributeFunds
      - donateKarma
      - addSupport

    transfer:
      - shareKarma
      - passInfluence
      - giveSupport
      - transferReputation

  variable_names:
    balance:
      - reputation
      - karma
      - influence
      - support
      - standing

    amount:
      - contribution
      - donation
      - tip
      - gift

    user:
      - member
      - creator
      - supporter
      - fan
      - patron

    owner:
      - moderator
      - admin
      - communityLead
      - founder
```

---

## 6. Pattern Rules

### 6.1 Prefix Pattern Pools

```yaml
# patterns/prefixes.yaml
# Each prefix has multiple replacement options per theme

prefix_pools:
  get:
    gaming: [check, view, inspect, query, show, display, fetch, read, lookup]
    resource: [query, fetch, retrieve, obtain, access, read, lookup]
    abstract: [query, fetch, retrieve, read, access, obtain]
    medical: [check, examine, inspect, review, lookup]
    social: [view, check, see, lookup, fetch]

  set:
    gaming: [configure, adjust, modify, update, change, alter]
    resource: [configure, update, modify, adjust, establish]
    abstract: [assign, configure, establish, define, set]
    medical: [prescribe, configure, establish, set]
    social: [update, change, modify, configure]

  is:
    gaming: [check, verify, test, confirm, validate]
    resource: [verify, validate, check, confirm, test]
    abstract: [test, verify, check, validate]
    medical: [diagnose, verify, check, confirm]
    social: [verify, confirm, check, validate]

  has:
    gaming: [owns, possesses, holds, contains, includes]
    resource: [contains, includes, holds, possesses]
    abstract: [contains, includes, holds]
    medical: [contains, shows, exhibits]
    social: [owns, has, holds, possesses]

  calculate:
    gaming: [compute, determine, derive, figure, estimate]
    resource: [compute, determine, derive, evaluate]
    abstract: [derive, compute, evaluate, determine]
    medical: [assess, evaluate, determine, compute]
    social: [compute, figure, determine, calculate]

  update:
    gaming: [modify, adjust, change, alter, revise]
    resource: [modify, revise, adjust, amend]
    abstract: [modify, revise, alter, change]
    medical: [revise, modify, adjust, update]
    social: [change, modify, update, adjust]

  # Internal function prefixes (preserve underscore)
  _:
    all: ['_'] # Always preserve, transform the rest

  __:
    all: ['__'] # Always preserve, transform the rest
```

### 6.2 Suffix Pattern Pools

```yaml
# patterns/suffixes.yaml
suffix_pools:
  amount:
    gaming: [Quantity, Count, Sum, Total, Volume, Measure]
    resource: [Units, Quantity, Measure, Count]
    abstract: [Delta, Magnitude, Quantity, Value]
    medical: [Dosage, Quantity, Measure, Units]
    social: [Count, Amount, Total, Quantity]

  balance:
    gaming: [Loot, Gold, Treasure, Holdings, Wealth]
    resource: [Allocation, Holdings, Units, Position]
    abstract: [State, Value, Record, Data]
    medical: [Coverage, Credits, Benefits]
    social: [Reputation, Karma, Standing, Influence]

  rate:
    gaming: [Multiplier, Factor, Modifier, Bonus]
    resource: [Coefficient, Factor, Ratio, Rate]
    abstract: [Factor, Coefficient, Ratio]
    medical: [Frequency, Rate, Ratio]
    social: [Rate, Ratio, Factor]

  time:
    gaming: [Moment, Tick, GameTime, EventTime]
    resource: [Timestamp, Instant, Time]
    abstract: [Instant, TimeValue, Moment]
    medical: [Time, Timestamp, Schedule]
    social: [Time, Moment, Timestamp]

  info:
    gaming: [Stats, Data, Record, Details]
    resource: [Record, Data, Details, Profile]
    abstract: [Data, Record, Info, Details]
    medical: [Chart, Record, Profile, History]
    social: [Profile, Details, Stats, Info]

  count:
    gaming: [Tally, Total, Number, Sum]
    resource: [Total, Count, Number, Sum]
    abstract: [Number, Count, Quantity]
    medical: [Count, Total, Number]
    social: [Count, Tally, Number, Total]
```

### 6.3 Pattern Application with Randomization

```python
def apply_prefix_pattern(
    identifier: str,
    prefix_pools: dict,
    theme: str,
    rng: Random
) -> Optional[str]:
    """
    Check if identifier starts with a known prefix pattern.
    If so, randomly select a replacement prefix.
    """
    identifier_lower = identifier.lower()

    for prefix, theme_pools in prefix_pools.items():
        if identifier_lower.startswith(prefix):
            pool = theme_pools.get(theme, theme_pools.get('all', []))
            if pool:
                new_prefix = rng.choice(pool)
                rest = identifier[len(prefix):]

                # Preserve casing pattern
                if identifier[0].isupper():
                    new_prefix = new_prefix.capitalize()

                return new_prefix + rest

    return None


def apply_suffix_pattern(
    identifier: str,
    suffix_pools: dict,
    theme: str,
    rng: Random
) -> Optional[str]:
    """
    Check if identifier ends with a known suffix pattern.
    If so, randomly select a replacement suffix.
    """
    identifier_lower = identifier.lower()

    for suffix, theme_pools in suffix_pools.items():
        if identifier_lower.endswith(suffix):
            pool = theme_pools.get(theme, [])
            if pool:
                new_suffix = rng.choice(pool)
                rest = identifier[:-len(suffix)]

                # Preserve casing of suffix
                if identifier[-len(suffix)].isupper():
                    new_suffix = new_suffix.capitalize()

                return rest + new_suffix

    return None
```

---

## 7. Compound Word Decomposition

### 7.1 Splitting Algorithm

```python
import re
from typing import List, Tuple

def split_identifier(identifier: str) -> Tuple[List[str], str]:
    """
    Split a camelCase or snake_case identifier into words.
    Returns (words, style) where style is 'camelCase', 'PascalCase', or 'snake_case'.

    Examples:
        "getUserBalance" -> (["get", "User", "Balance"], "camelCase")
        "user_balance" -> (["user", "balance"], "snake_case")
        "GetUserBalance" -> (["Get", "User", "Balance"], "PascalCase")
    """
    # Detect style
    if '_' in identifier:
        style = "snake_case"
        # Handle leading underscores
        leading = len(identifier) - len(identifier.lstrip('_'))
        clean = identifier[leading:]
        parts = [p for p in clean.split('_') if p]
        return parts, style
    elif identifier[0].isupper():
        style = "PascalCase"
    else:
        style = "camelCase"

    # Split camelCase/PascalCase
    words = []
    current = ""

    for i, char in enumerate(identifier):
        if char.isupper() and current:
            # Check for acronyms (consecutive uppercase)
            if current[-1].isupper():
                # Continue acronym or start new word?
                if i + 1 < len(identifier) and identifier[i + 1].islower():
                    # This uppercase starts a new word
                    words.append(current)
                    current = char
                else:
                    # Continue acronym
                    current += char
            else:
                # Regular camelCase split
                words.append(current)
                current = char
        else:
            current += char

    if current:
        words.append(current)

    return words, style


def recombine_identifier(words: List[str], style: str, leading_underscores: int = 0) -> str:
    """
    Recombine words into identifier with original style.
    """
    prefix = '_' * leading_underscores

    if style == "snake_case":
        return prefix + '_'.join(w.lower() for w in words)
    elif style == "PascalCase":
        return prefix + ''.join(w.capitalize() for w in words)
    else:  # camelCase
        if not words:
            return prefix
        result = words[0].lower()
        for word in words[1:]:
            result += word.capitalize()
        return prefix + result
```

### 7.2 Compound Transformation with Randomization

```python
def transform_compound(
    identifier: str,
    synonym_pools: dict,
    rng: Random,
    theme: str
) -> Tuple[str, bool, List[str]]:
    """
    Transform a compound identifier by transforming each part.

    Returns:
        (transformed_identifier, any_part_transformed, untransformed_parts)
    """
    # Count and strip leading underscores
    leading_underscores = len(identifier) - len(identifier.lstrip('_'))
    clean_identifier = identifier[leading_underscores:]

    # Split into words
    words, style = split_identifier(clean_identifier)

    if not words:
        return identifier, False, [identifier]

    transformed_words = []
    untransformed = []
    any_transformed = False

    for word in words:
        word_lower = word.lower()

        # Try to find in synonym pools
        pool = None
        for category in ['variable_names', 'function_names', 'contract_names']:
            if word_lower in synonym_pools.get(category, {}):
                pool = synonym_pools[category][word_lower]
                break

        if pool:
            # Randomly select from pool
            new_word = rng.choice(pool)
            # Preserve original casing pattern
            if word[0].isupper():
                new_word = new_word[0].upper() + new_word[1:]
            else:
                new_word = new_word[0].lower() + new_word[1:]
            transformed_words.append(new_word)
            any_transformed = True
        else:
            # Keep original, track as untransformed
            transformed_words.append(word)
            untransformed.append(word)

    # Recombine
    result = recombine_identifier(transformed_words, style, leading_underscores)

    return result, any_transformed, untransformed
```

---

## 8. Transformation Algorithm

### 8.1 Main Transformer Class

```python
import hashlib
from random import Random
from dataclasses import dataclass, field
from typing import Dict, List, Set, Optional, Tuple

@dataclass
class TransformationResult:
    code: str
    rename_map: Dict[str, str]
    coverage: 'CoverageReport'
    validation: 'ValidationResult'
    seed: int
    theme: str

@dataclass
class CoverageReport:
    total_identifiers: int
    transformed: int
    untransformed: int
    skipped_reserved: int
    skipped_interface: int
    coverage_percent: float
    untransformed_details: List[Dict]
    meets_threshold: bool

class ChameleonTransformer:
    def __init__(
        self,
        theme: str,
        language_plugin: 'LanguagePlugin',
        options: Optional[Dict] = None
    ):
        self.theme = theme
        self.language = language_plugin
        self.options = options or {}

        # Load pools
        self.synonym_pools = load_synonym_pools(theme)
        self.prefix_pools = load_prefix_pools()
        self.suffix_pools = load_suffix_pools()

        # Build reserved word sets
        self.reserved = self._build_reserved_set()

        # Options with defaults
        self.strip_comments = self.options.get('strip_comments', True)
        self.coverage_threshold = self.options.get('coverage_threshold', 75.0)
        self.variation_level = self.options.get('variation_level', 'medium')

    def _build_reserved_set(self) -> Set[str]:
        """Combine all reserved words from language plugin."""
        reserved = set()
        reserved.update(self.language.get_keywords())
        reserved.update(self.language.get_builtin_types())
        reserved.update(self.language.get_builtin_globals())

        # Add standard interface function names
        for interface, functions in self.language.get_standard_interfaces().items():
            reserved.update(functions)

        return reserved

    def transform(self, source_code: str) -> TransformationResult:
        """
        Main transformation entry point.
        """
        # Create reproducible RNG from source + theme
        seed = self._create_seed(source_code)
        rng = Random(seed)

        # Phase 1: Parse and extract identifiers
        tree = parse_with_treesitter(source_code, self.language.get_language_name())
        identifiers = self._extract_identifiers(source_code, tree)

        # Phase 2: Build rename map with randomized selection
        rename_map, coverage_stats = self._build_rename_map(identifiers, rng)

        # Phase 3: Apply transformations
        transformed_code = source_code

        # Optionally strip comments first
        if self.strip_comments:
            transformed_code = self._strip_comments(transformed_code, tree)
            # Re-parse after stripping comments
            tree = parse_with_treesitter(transformed_code, self.language.get_language_name())

        # Apply renames using byte-position replacement
        transformed_code = self._apply_renames(transformed_code, tree, rename_map)

        # Phase 4: Validate
        validation = self._validate(source_code, transformed_code)

        # Build coverage report
        coverage = coverage_stats.to_report(self.coverage_threshold)

        return TransformationResult(
            code=transformed_code,
            rename_map=rename_map,
            coverage=coverage,
            validation=validation,
            seed=seed,
            theme=self.theme
        )

    def _create_seed(self, source_code: str) -> int:
        """Create deterministic seed from source + theme."""
        seed_input = f"{self.theme}:{hashlib.sha256(source_code.encode()).hexdigest()}"
        return int(hashlib.md5(seed_input.encode()).hexdigest(), 16) % (2**32)

    def _extract_identifiers(self, source: str, tree) -> List['IdentifierInfo']:
        """Extract all user-defined identifiers with their positions."""
        identifiers = []

        for query_name, query_str in self.language.get_identifier_queries().items():
            if query_name == 'all_identifiers':
                continue  # Handle separately for references

            matches = run_query(tree, query_str)
            for match in matches:
                name_node = match.get('name') or match.get('id')
                if name_node:
                    name = source[name_node.start_byte:name_node.end_byte]
                    identifiers.append(IdentifierInfo(
                        name=name,
                        type=query_name.replace('_decl', ''),
                        start_byte=name_node.start_byte,
                        end_byte=name_node.end_byte,
                        node=name_node
                    ))

        return identifiers

    def _build_rename_map(
        self,
        identifiers: List['IdentifierInfo'],
        rng: Random
    ) -> Tuple[Dict[str, str], 'CoverageStats']:
        """
        Build the rename map using layered lookup with randomization.
        """
        stats = CoverageStats()
        rename_map = {}
        used_names = set()  # Track to avoid collisions

        # Get unique identifier names
        unique_names = set(ident.name for ident in identifiers)

        for name in unique_names:
            # Skip reserved words
            if name in self.reserved or name.lower() in self.reserved:
                stats.skipped_reserved.append(name)
                continue

            # Skip if starts with reserved (like msg, block, tx)
            if any(name.startswith(r + '.') for r in ['msg', 'block', 'tx', 'abi']):
                stats.skipped_reserved.append(name)
                continue

            # Try to transform
            new_name, transformed, untransformed_parts = self._transform_identifier(
                name, rng
            )

            if transformed and new_name != name:
                # Handle collisions
                final_name = self._resolve_collision(new_name, used_names, rng)
                rename_map[name] = final_name
                used_names.add(final_name)
                stats.transformed.append(name)
            else:
                stats.untransformed.append({
                    'name': name,
                    'parts': untransformed_parts
                })

        return rename_map, stats

    def _transform_identifier(
        self,
        identifier: str,
        rng: Random
    ) -> Tuple[str, bool, List[str]]:
        """
        Apply layered transformation with randomization.

        Layer 1: Direct synonym pool lookup
        Layer 2: Pattern rules (prefix/suffix)
        Layer 3: Compound word decomposition
        Layer 4: Leave unchanged (track for coverage)
        """
        identifier_lower = identifier.lower()

        # Layer 1: Direct lookup in synonym pools
        for category in ['function_names', 'variable_names', 'contract_names',
                         'event_names', 'error_names', 'modifier_names', 'struct_names']:
            pools = self.synonym_pools.get(category, {})
            if identifier_lower in pools:
                pool = pools[identifier_lower]
                selected = self._select_from_pool(pool, rng)
                # Preserve casing
                if identifier[0].isupper():
                    selected = selected[0].upper() + selected[1:]
                return selected, True, []

        # Layer 2: Pattern matching (prefix/suffix)
        # Try prefix patterns
        result = apply_prefix_pattern(identifier, self.prefix_pools, self.theme, rng)
        if result:
            return result, True, []

        # Try suffix patterns
        result = apply_suffix_pattern(identifier, self.suffix_pools, self.theme, rng)
        if result:
            return result, True, []

        # Layer 3: Compound decomposition
        result, transformed, untransformed_parts = transform_compound(
            identifier, self.synonym_pools, rng, self.theme
        )
        if transformed:
            return result, True, untransformed_parts

        # Layer 4: Leave unchanged
        return identifier, False, [identifier]

    def _select_from_pool(self, pool: List[str], rng: Random) -> str:
        """
        Select from pool based on variation level.
        """
        if not pool:
            return None

        if self.variation_level == 'low':
            # Top 3 only
            subset = pool[:min(3, len(pool))]
        elif self.variation_level == 'medium':
            # Top 50%
            subset = pool[:max(1, len(pool) // 2)]
        elif self.variation_level == 'high':
            # Full pool
            subset = pool
        elif self.variation_level == 'extreme':
            # Full pool with possible suffix
            choice = rng.choice(pool)
            if rng.random() < 0.15:
                choice += str(rng.randint(1, 99))
            return choice
        else:
            subset = pool

        return rng.choice(subset)

    def _resolve_collision(
        self,
        proposed: str,
        used: Set[str],
        rng: Random
    ) -> str:
        """
        Resolve naming collision by adding random suffix.
        """
        if proposed not in used:
            return proposed

        # Try random suffixes
        for _ in range(100):
            suffix = rng.randint(1, 999)
            candidate = f"{proposed}{suffix}"
            if candidate not in used:
                return candidate

        # Fallback (shouldn't happen)
        return f"{proposed}_{rng.randint(1000, 9999)}"

    def _strip_comments(self, source: str, tree) -> str:
        """
        Remove all comments from source code.
        """
        comment_query = self.language.get_comment_query()
        matches = run_query(tree, comment_query)

        # Collect all comment positions
        edits = []
        for match in matches:
            for node in match.values():
                edits.append({
                    'start': node.start_byte,
                    'end': node.end_byte,
                    'replacement': ''
                })

        # Apply back-to-front
        edits.sort(key=lambda e: e['start'], reverse=True)

        result = source
        for edit in edits:
            result = result[:edit['start']] + edit['replacement'] + result[edit['end']:]

        return result

    def _apply_renames(self, source: str, tree, rename_map: Dict[str, str]) -> str:
        """
        Apply renames using byte-position replacement.
        See Section 9 for details.
        """
        return apply_renames_byte_position(source, tree, rename_map, self.language)

    def _validate(self, original: str, transformed: str) -> 'ValidationResult':
        """
        Validate the transformation.
        See Section 11 for details.
        """
        return validate_transformation(original, transformed, self.language)
```

---

## 9. Byte-Position Replacement

### 9.1 Why Back-to-Front?

When replacing text, earlier replacements shift the positions of later text:

```
Original: "function withdraw() { balances[user] -= amount; }"
                 ^ pos 9                        ^ pos 40

If we replace "withdraw" first (pos 9), "balances" moves!
The position 40 is now wrong.

Solution: Replace back-to-front (highest position first).
Position 40 stays valid because we haven't touched earlier text yet.
```

### 9.2 Implementation

```python
from dataclasses import dataclass
from typing import Dict, List

@dataclass
class Edit:
    start: int
    end: int
    old_text: str
    new_text: str

def apply_renames_byte_position(
    source: str,
    tree,
    rename_map: Dict[str, str],
    language: 'LanguagePlugin'
) -> str:
    """
    Apply all renames using byte-position replacement.
    Edits are applied back-to-front to maintain position validity.
    """
    # Query ALL identifier occurrences (declarations + references)
    all_identifiers_query = language.get_identifier_queries().get('all_identifiers')
    if not all_identifiers_query:
        raise ValueError("Language plugin must provide 'all_identifiers' query")

    matches = run_query(tree, all_identifiers_query)

    # Collect edits
    edits: List[Edit] = []

    for match in matches:
        node = match.get('id')
        if not node:
            continue

        old_text = source[node.start_byte:node.end_byte]

        # Check if this identifier should be renamed
        if old_text in rename_map:
            edits.append(Edit(
                start=node.start_byte,
                end=node.end_byte,
                old_text=old_text,
                new_text=rename_map[old_text]
            ))

    # Sort by position DESCENDING (back-to-front)
    edits.sort(key=lambda e: e.start, reverse=True)

    # Apply edits
    result = source
    for edit in edits:
        result = result[:edit.start] + edit.new_text + result[edit.end:]

    return result


def apply_insertions(source: str, insertions: List[Dict]) -> str:
    """
    Apply text insertions at specific positions.
    Used by Guardian Shield for injecting protections.

    Each insertion: {'position': int, 'text': str}
    """
    # Sort by position descending
    insertions.sort(key=lambda i: i['position'], reverse=True)

    result = source
    for ins in insertions:
        result = result[:ins['position']] + ins['text'] + result[ins['position']:]

    return result
```

### 9.3 Handling Member Access

Special care needed for member access (e.g., `user.balance`):

```python
def should_rename_member_access(node, tree, rename_map, language) -> bool:
    """
    Determine if a member access should be renamed.

    Rename: this.withdraw() -> this.claimLoot()  (internal)
    DON'T rename: token.transfer() -> token.transfer()  (external ERC20)
    """
    if node.type != 'member_expression':
        return True

    # Get the object being accessed
    object_node = node.child_by_field_name('object')
    member_node = node.child_by_field_name('property')

    if not object_node or not member_node:
        return True

    object_text = get_node_text(object_node)
    member_text = get_node_text(member_node)

    # If object is 'this', it's internal - OK to rename
    if object_text == 'this':
        return True

    # If member is a standard interface function, DON'T rename
    for interface, functions in language.get_standard_interfaces().items():
        if member_text in functions:
            return False

    # Otherwise, rename
    return True
```

---

## 10. Reserved Words

### 10.1 Complete Solidity Reserved Set

```python
# This is generated from the language plugin, but here's the complete reference

SOLIDITY_RESERVED = {
    # Keywords
    "pragma", "solidity", "import", "contract", "interface", "library",
    "abstract", "is", "using", "for", "struct", "enum", "event", "error",
    "function", "modifier", "constructor", "fallback", "receive",
    "mapping", "bool", "string", "bytes", "address", "payable",
    "uint", "uint8", "uint16", "uint32", "uint64", "uint128", "uint256",
    "int", "int8", "int16", "int32", "int64", "int128", "int256",
    "bytes1", "bytes2", "bytes4", "bytes8", "bytes16", "bytes32",
    "public", "private", "internal", "external",
    "view", "pure", "constant", "immutable",
    "virtual", "override", "indexed", "anonymous",
    "memory", "storage", "calldata",
    "if", "else", "for", "while", "do", "break", "continue", "return",
    "try", "catch", "throw", "revert", "require", "assert",
    "new", "delete", "emit", "assembly", "true", "false",
    "wei", "gwei", "ether", "seconds", "minutes", "hours", "days", "weeks",

    # Globals
    "block", "blockhash", "msg", "tx", "gasleft",
    "addmod", "mulmod", "keccak256", "sha256", "ripemd160",
    "ecrecover", "selfdestruct", "abi", "type",
    "balance", "code", "codehash", "transfer", "send", "call",
    "delegatecall", "staticcall", "this", "super", "Error", "Panic",

    # Standard interface functions (when implementing)
    "totalSupply", "balanceOf", "transfer", "allowance", "approve",
    "transferFrom", "name", "symbol", "decimals",
    "ownerOf", "safeTransferFrom", "setApprovalForAll",
    "getApproved", "isApprovedForAll",
    "owner", "renounceOwnership", "transferOwnership",
    "onlyOwner", "nonReentrant", "whenNotPaused", "whenPaused",

    # Assembly opcodes (when in assembly blocks)
    "stop", "add", "sub", "mul", "div", "sdiv", "mod", "smod", "exp",
    "not", "lt", "gt", "slt", "sgt", "eq", "iszero", "and", "or", "xor",
    "byte", "shl", "shr", "sar", "addmod", "mulmod", "signextend",
    "keccak256", "pc", "pop", "mload", "mstore", "mstore8", "sload", "sstore",
    "msize", "gas", "address", "balance", "selfbalance", "caller",
    "callvalue", "calldataload", "calldatasize", "calldatacopy",
    "codesize", "codecopy", "extcodesize", "extcodecopy", "returndatasize",
    "returndatacopy", "extcodehash", "create", "create2", "call",
    "callcode", "delegatecall", "staticcall", "return", "revert",
    "selfdestruct", "invalid", "log0", "log1", "log2", "log3", "log4",
    "chainid", "basefee", "origin", "gasprice", "blockhash", "coinbase",
    "timestamp", "number", "difficulty", "prevrandao", "gaslimit",
}
```

---

## 11. Validation Pipeline

### 11.1 Validation Steps

```python
from dataclasses import dataclass
from typing import List, Optional
import subprocess
import tempfile
import os

@dataclass
class ValidationResult:
    valid: bool
    syntax_ok: bool
    compiles: bool
    no_leakage: bool
    errors: List[str]
    warnings: List[str]
    compiler_output: Optional[str] = None

def validate_transformation(
    original: str,
    transformed: str,
    language: 'LanguagePlugin'
) -> ValidationResult:
    """
    Comprehensive validation of transformation.
    """
    errors = []
    warnings = []

    # 1. Syntax check - does it parse?
    syntax_ok = True
    try:
        tree = parse_with_treesitter(transformed, language.get_language_name())
        if tree.root_node.has_error:
            syntax_ok = False
            errors.append("Syntax error in transformed code")
    except Exception as e:
        syntax_ok = False
        errors.append(f"Parse error: {e}")

    # 2. Compilation check (Solidity)
    compiles = True
    compiler_output = None
    if language.get_language_name() == 'solidity':
        compiles, compiler_output = check_solidity_compilation(transformed)
        if not compiles:
            errors.append(f"Compilation failed: {compiler_output}")

    # 3. Identifier leakage check
    no_leakage = True
    original_ids = extract_all_identifiers(original, language)
    transformed_ids = extract_all_identifiers(transformed, language)

    # Get the set of identifiers that should have been renamed
    # (present in original, not reserved)
    reserved = set()
    reserved.update(language.get_keywords())
    reserved.update(language.get_builtin_types())
    reserved.update(language.get_builtin_globals())

    should_rename = original_ids - reserved
    leaked = should_rename & transformed_ids

    if leaked:
        # Some identifiers weren't renamed - this might be intentional (coverage < 100%)
        # Only warn, don't fail
        warnings.append(f"Identifiers not renamed: {leaked}")

    # 4. Check for accidental reserved word renaming
    for word in reserved:
        if word in transformed and word not in original:
            # A renamed identifier collided with a reserved word
            errors.append(f"Renamed identifier collides with reserved word: {word}")

    valid = len(errors) == 0 and syntax_ok and compiles

    return ValidationResult(
        valid=valid,
        syntax_ok=syntax_ok,
        compiles=compiles,
        no_leakage=len(leaked) == 0 if leaked else True,
        errors=errors,
        warnings=warnings,
        compiler_output=compiler_output
    )


def check_solidity_compilation(source: str) -> tuple[bool, str]:
    """
    Attempt to compile Solidity code with solc.
    """
    # Check if solc is available
    if not shutil.which('solc'):
        return True, "solc not found, skipping compilation check"

    # Write to temp file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sol', delete=False) as f:
        f.write(source)
        temp_path = f.name

    try:
        result = subprocess.run(
            ['solc', '--bin', temp_path],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            return True, result.stdout
        else:
            return False, result.stderr
    except subprocess.TimeoutExpired:
        return False, "Compilation timed out"
    except Exception as e:
        return False, str(e)
    finally:
        os.unlink(temp_path)
```

---

## 12. Coverage Tracking

### 12.1 Coverage Statistics

```python
from dataclasses import dataclass, field
from typing import List, Dict

@dataclass
class CoverageStats:
    transformed: List[str] = field(default_factory=list)
    untransformed: List[Dict] = field(default_factory=list)
    skipped_reserved: List[str] = field(default_factory=list)
    skipped_interface: List[str] = field(default_factory=list)

    def to_report(self, threshold: float) -> 'CoverageReport':
        total = len(self.transformed) + len(self.untransformed)

        if total == 0:
            coverage_percent = 100.0
        else:
            coverage_percent = (len(self.transformed) / total) * 100

        return CoverageReport(
            total_identifiers=total,
            transformed=len(self.transformed),
            untransformed=len(self.untransformed),
            skipped_reserved=len(self.skipped_reserved),
            skipped_interface=len(self.skipped_interface),
            coverage_percent=round(coverage_percent, 2),
            untransformed_details=self.untransformed,
            meets_threshold=coverage_percent >= threshold
        )


@dataclass
class CoverageReport:
    total_identifiers: int
    transformed: int
    untransformed: int
    skipped_reserved: int
    skipped_interface: int
    coverage_percent: float
    untransformed_details: List[Dict]
    meets_threshold: bool

    def to_dict(self) -> Dict:
        return {
            'total_identifiers': self.total_identifiers,
            'transformed': self.transformed,
            'untransformed': self.untransformed,
            'skipped_reserved': self.skipped_reserved,
            'skipped_interface': self.skipped_interface,
            'coverage_percent': self.coverage_percent,
            'meets_threshold': self.meets_threshold,
            'untransformed_details': self.untransformed_details
        }
```

### 12.2 Aggregating Across Dataset

```python
from collections import Counter
from typing import List

@dataclass
class AggregatedCoverage:
    num_contracts: int
    total_identifiers: int
    total_transformed: int
    overall_coverage: float
    contracts_meeting_threshold: int
    most_common_untransformed: List[tuple]
    suggested_additions: List[str]

def aggregate_coverage(reports: List[CoverageReport]) -> AggregatedCoverage:
    """
    Aggregate coverage stats across multiple transformations.
    Useful for identifying gaps in the synonym pools.
    """
    total_identifiers = sum(r.total_identifiers for r in reports)
    total_transformed = sum(r.transformed for r in reports)

    # Collect all untransformed words
    untransformed_words = Counter()
    for report in reports:
        for detail in report.untransformed_details:
            for part in detail.get('parts', [detail['name']]):
                untransformed_words[part.lower()] += 1

    overall_coverage = (total_transformed / total_identifiers * 100) if total_identifiers > 0 else 100

    return AggregatedCoverage(
        num_contracts=len(reports),
        total_identifiers=total_identifiers,
        total_transformed=total_transformed,
        overall_coverage=round(overall_coverage, 2),
        contracts_meeting_threshold=sum(1 for r in reports if r.meets_threshold),
        most_common_untransformed=untransformed_words.most_common(50),
        suggested_additions=[word for word, count in untransformed_words.most_common(20)]
    )
```

---

## 13. Output Schema

### 13.1 Transformation Metadata

```json
{
  "transformation": {
    "strategy": "chameleon",
    "theme": "gaming",
    "variation_level": "medium",
    "seed": 2847593021,
    "timestamp": "2025-12-15T14:30:00Z",
    "tool_version": "2.0.0"
  },

  "source": {
    "id": "gs_001",
    "file": "Vault.sol",
    "hash": "sha256:abc123..."
  },

  "output": {
    "id": "ac_001_chameleon_gaming",
    "file": "ac_001_chameleon_gaming.sol",
    "hash": "sha256:def456..."
  },

  "rename_map": {
    "Vault": "TreasureHold",
    "withdraw": "collectBounty",
    "deposit": "cachePrize",
    "balances": "heroTreasure",
    "amount": "sum",
    "user": "adventurer",
    "Withdrawal": "BountyPaid",
    "Deposit": "PrizeCached"
  },

  "coverage": {
    "total_identifiers": 52,
    "transformed": 47,
    "untransformed": 5,
    "skipped_reserved": 15,
    "skipped_interface": 3,
    "coverage_percent": 90.38,
    "meets_threshold": true,
    "untransformed_details": [
      { "name": "veToken", "parts": ["ve", "Token"] },
      { "name": "bribeAmount", "parts": ["bribe", "Amount"] }
    ]
  },

  "validation": {
    "valid": true,
    "syntax_ok": true,
    "compiles": true,
    "no_leakage": true,
    "errors": [],
    "warnings": []
  },

  "options_used": {
    "strip_comments": true,
    "coverage_threshold": 75.0,
    "variation_level": "medium"
  }
}
```

---

## 14. Complete Examples

### 14.1 Input Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Vault
 * @notice Simple vault with reentrancy vulnerability
 */
contract Vault {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;
    address public owner;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    error InsufficientBalance(uint256 requested, uint256 available);
    error ZeroAmount();

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        if (msg.value == 0) revert ZeroAmount();

        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    // VULNERABLE: External call before state update
    function withdraw(uint256 amount) external {
        uint256 userBalance = balances[msg.sender];

        if (amount > userBalance) {
            revert InsufficientBalance(amount, userBalance);
        }

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        emit Withdrawal(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
```

### 14.2 Output Contract (Gaming Theme, One Possible Output)

Note: Due to randomization, different runs produce different outputs!

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TreasureHold {
    mapping(address => uint256) public heroTreasure;
    uint256 public totalStoredLoot;
    address public guildMaster;

    event PrizeCached(address indexed adventurer, uint256 quantity);
    event BountyPaid(address indexed adventurer, uint256 quantity);

    error InsufficientLoot(uint256 requested, uint256 accessible);
    error EmptyAmount();

    modifier onlyGuildMaster() {
        require(msg.sender == guildMaster, "Not owner");
        _;
    }

    constructor() {
        guildMaster = msg.sender;
    }

    function cachePrize() external payable {
        if (msg.value == 0) revert EmptyAmount();

        heroTreasure[msg.sender] += msg.value;
        totalStoredLoot += msg.value;

        emit PrizeCached(msg.sender, msg.value);
    }

    function collectBounty(uint256 quantity) external {
        uint256 characterGold = heroTreasure[msg.sender];

        if (quantity > characterGold) {
            revert InsufficientLoot(quantity, characterGold);
        }

        (bool success, ) = msg.sender.call{value: quantity}("");
        require(success, "Transfer failed");

        heroTreasure[msg.sender] -= quantity;
        totalStoredLoot -= quantity;

        emit BountyPaid(msg.sender, quantity);
    }

    function inspectGold(address adventurer) external view returns (uint256) {
        return heroTreasure[adventurer];
    }
}
```

### 14.3 Alternative Output (Same Input, Different Seed)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract RewardCache {
    mapping(address => uint256) public playerLoot;
    uint256 public completeHoard;
    address public dungeonMaster;

    event GoldDeposited(address indexed hero, uint256 measure);
    event TreasureWithdrawn(address indexed hero, uint256 measure);

    error TreasureShortfall(uint256 requested, uint256 unlocked);
    error ZeroQuantity();

    modifier onlyDungeonMaster() {
        require(msg.sender == dungeonMaster, "Not owner");
        _;
    }

    constructor() {
        dungeonMaster = msg.sender;
    }

    function stashRewards() external payable {
        if (msg.value == 0) revert ZeroQuantity();

        playerLoot[msg.sender] += msg.value;
        completeHoard += msg.value;

        emit GoldDeposited(msg.sender, msg.value);
    }

    function gatherTreasure(uint256 measure) external {
        uint256 heroLoot = playerLoot[msg.sender];

        if (measure > heroLoot) {
            revert TreasureShortfall(measure, heroLoot);
        }

        (bool success, ) = msg.sender.call{value: measure}("");
        require(success, "Transfer failed");

        playerLoot[msg.sender] -= measure;
        completeHoard -= measure;

        emit TreasureWithdrawn(msg.sender, measure);
    }

    function viewTreasure(address hero) external view returns (uint256) {
        return playerLoot[hero];
    }
}
```

This demonstrates the variation - same input, same theme, but different outputs due to seeded randomization.

---

## 15. Testing Requirements

### 15.1 Unit Tests

```python
# tests/test_chameleon.py

def test_basic_rename():
    """Test basic identifier renaming."""
    source = '''
    contract Vault {
        function withdraw() external {}
    }
    '''

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())
    result = transformer.transform(source)

    # Should not contain original names
    assert 'Vault' not in result.code
    assert 'withdraw' not in result.code

    # Should compile
    assert result.validation.compiles


def test_reserved_words_preserved():
    """Test that reserved words are not renamed."""
    source = '''
    contract Test {
        function foo() external {
            require(msg.sender != address(0));
            uint256 x = block.timestamp;
        }
    }
    '''

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())
    result = transformer.transform(source)

    # Reserved words must still be present
    assert 'require' in result.code
    assert 'msg.sender' in result.code
    assert 'address' in result.code
    assert 'block.timestamp' in result.code
    assert 'uint256' in result.code


def test_reproducibility():
    """Test that same input + theme produces same output."""
    source = '''contract Vault { function withdraw() external {} }'''

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())

    result1 = transformer.transform(source)
    result2 = transformer.transform(source)

    assert result1.code == result2.code
    assert result1.rename_map == result2.rename_map
    assert result1.seed == result2.seed


def test_variation_across_contracts():
    """Test that different contracts get different replacements."""
    source1 = '''contract Vault1 { function withdraw() external {} }'''
    source2 = '''contract Vault2 { function withdraw() external {} }'''

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())

    result1 = transformer.transform(source1)
    result2 = transformer.transform(source2)

    # Different sources should (usually) get different replacements
    # Note: There's a small chance they're the same, so this is probabilistic
    assert result1.seed != result2.seed


def test_variation_across_themes():
    """Test that different themes produce different outputs."""
    source = '''contract Vault { function withdraw() external {} }'''

    gaming_result = ChameleonTransformer(theme='gaming', language=SolidityPlugin()).transform(source)
    resource_result = ChameleonTransformer(theme='resource', language=SolidityPlugin()).transform(source)

    # Different themes should produce different code
    assert gaming_result.code != resource_result.code


def test_coverage_tracking():
    """Test that coverage is tracked correctly."""
    source = '''
    contract Vault {
        uint256 public balance;
        function withdraw(uint256 amount) external {
            balance -= amount;
        }
    }
    '''

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())
    result = transformer.transform(source)

    # Coverage should be calculated
    assert result.coverage.total_identifiers > 0
    assert result.coverage.coverage_percent >= 0
    assert result.coverage.coverage_percent <= 100


def test_compound_decomposition():
    """Test that compound identifiers are handled."""
    source = '''
    contract Test {
        function getUserBalance(address user) external view returns (uint256) {
            return userBalances[user];
        }
    }
    '''

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())
    result = transformer.transform(source)

    # Compound identifiers should be transformed
    assert 'getUserBalance' not in result.code
    assert 'userBalances' not in result.code


def test_comments_stripped():
    """Test that comments are removed when option is set."""
    source = '''
    // This is a comment
    contract Vault {
        /// @notice Withdraw funds
        function withdraw() external {}
    }
    '''

    transformer = ChameleonTransformer(
        theme='gaming',
        language=SolidityPlugin(),
        options={'strip_comments': True}
    )
    result = transformer.transform(source)

    # Comments should be removed
    assert 'This is a comment' not in result.code
    assert '@notice' not in result.code


def test_collision_resolution():
    """Test that name collisions are resolved."""
    source = '''
    contract Test {
        uint256 public amount;
        uint256 public amount2;
        function getAmount() external view returns (uint256) {
            return amount + amount2;
        }
    }
    '''

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())
    result = transformer.transform(source)

    # Should compile (no duplicate identifiers)
    assert result.validation.compiles

    # All identifiers should be unique in output
    output_identifiers = extract_all_identifiers(result.code, SolidityPlugin())
    assert len(output_identifiers) == len(set(output_identifiers))
```

### 15.2 Integration Tests

```python
def test_full_pipeline_real_contract():
    """Test on a real vulnerable contract."""
    source = load_contract("fixtures/reentrancy_vulnerable.sol")

    transformer = ChameleonTransformer(theme='gaming', language=SolidityPlugin())
    result = transformer.transform(source)

    assert result.validation.valid
    assert result.coverage.coverage_percent >= 70


def test_all_themes():
    """Test all themes produce valid output."""
    source = load_contract("fixtures/sample.sol")

    for theme in ['gaming', 'resource', 'abstract', 'medical', 'social']:
        transformer = ChameleonTransformer(theme=theme, language=SolidityPlugin())
        result = transformer.transform(source)

        assert result.validation.valid, f"Theme {theme} failed validation"
        assert result.coverage.coverage_percent >= 60, f"Theme {theme} low coverage"
```

### 15.3 Validation Checklist

```yaml
validation_checklist:
  compilation:
    - [ ] Transformed code compiles without errors
    - [ ] No new warnings introduced
    - [ ] Same Solidity version works

  correctness:
    - [ ] All user-defined identifiers considered
    - [ ] Reserved words NOT renamed
    - [ ] Standard interface functions preserved
    - [ ] External call targets NOT renamed
    - [ ] String literals NOT modified
    - [ ] Assembly keywords NOT renamed

  randomization:
    - [ ] Same input + theme → same output (reproducible)
    - [ ] Different inputs → different outputs (variation)
    - [ ] Different themes → different outputs (thematic)
    - [ ] Synonym pools used, not fixed mappings

  coverage:
    - [ ] Coverage calculated correctly
    - [ ] Untransformed identifiers logged
    - [ ] Threshold checking works

  output:
    - [ ] Metadata JSON complete
    - [ ] Rename map accurate
    - [ ] Seed recorded for reproducibility
```

---

## Quick Reference

### CLI Usage

```bash
# Transform single file
python -m adversarial transform \
    --input contract.sol \
    --strategy chameleon \
    --theme gaming \
    --variation medium \
    --output transformed.sol

# Batch transform
python -m adversarial batch \
    --input-dir gold_standard/contracts/ \
    --strategy chameleon \
    --themes gaming,resource,abstract \
    --variation medium \
    --output-dir adversarial_contrastive/contracts/

# Validate transformations
python -m adversarial validate \
    --dir adversarial_contrastive/
```

### Key Configuration Options

| Option             | Values                                      | Default  | Description         |
| ------------------ | ------------------------------------------- | -------- | ------------------- |
| theme              | gaming, resource, abstract, medical, social | required | Terminology theme   |
| variation          | low, medium, high, extreme                  | medium   | Randomization level |
| strip_comments     | true, false                                 | true     | Remove comments     |
| coverage_threshold | 0-100                                       | 75.0     | Minimum coverage %  |

### Variation Levels

| Level   | Pool Usage | Suffixes | Use Case            |
| ------- | ---------- | -------- | ------------------- |
| low     | Top 3      | No       | Consistent, natural |
| medium  | Top 50%    | No       | Balanced variation  |
| high    | Full pool  | No       | Maximum variety     |
| extreme | Full pool  | Random   | Stress testing      |

---

**Document Version:** 2.0  
**Key Changes:** Tree-sitter integration, randomized synonym pools, byte-position replacement, validation pipeline, seeded reproducibility  
**Status:** Ready for Implementation
