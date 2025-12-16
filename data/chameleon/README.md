# Chameleon Dataset

## Overview

The Chameleon dataset contains smart contracts transformed using the **Chameleon strategy** - a systematic identifier renaming transformation that tests whether AI models rely on keyword patterns rather than understanding code semantics.

## Hypothesis

> "If a model's detection accuracy drops significantly when financial/security terminology is replaced with domain-specific synonyms, the model relies on superficial keyword matching rather than semantic understanding."

## Transformation Approach

All user-defined identifiers (functions, variables, events, contracts) are renamed using themed synonym pools:

**Before (DeFi terminology):**
```solidity
contract Vault {
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
}
```

**After (Gaming theme):**
```solidity
contract TreasureChest {
    mapping(address => uint256) public lootBalances;

    function claimReward(uint256 gems) public {
        require(lootBalances[msg.sender] >= gems);
        lootBalances[msg.sender] -= gems;
        msg.sender.transfer(gems);
    }
}
```

The vulnerability (reentrancy risk) remains identical, but the keywords that pattern-matching models might rely on are removed.

## Available Themes

| Theme | Description | Example Renames |
|-------|-------------|-----------------|
| `gaming` | Video game / RPG terminology | withdraw→claimLoot, balance→treasureCount, deposit→storeLoot |
| `medical` | Healthcare / medical records | withdraw→dischargePatient, balance→vitalSigns, transfer→referPatient |

## Directory Structure

```
chameleon/
├── gaming_nc/           # Gaming theme from nocomments source
│   ├── contracts/       # Transformed .sol files
│   ├── metadata/        # JSON metadata with rename maps
│   ├── index.json       # Dataset index
│   └── transformation_report.json
├── gaming_sn/           # Gaming theme from sanitized source
│   ├── contracts/
│   ├── metadata/
│   └── ...
├── medical_nc/          # Medical theme from nocomments
├── medical_sn/          # Medical theme from sanitized
└── README.md
```

## Naming Convention

`ch_{theme}_{source}_{original_id}.sol`

- `ch` - Chameleon strategy prefix
- `{theme}` - Theme name (gaming, medical, etc.)
- `{source}` - `nc` (nocomments) or `sn` (sanitized)
- `{original_id}` - Original contract ID

Example: `ch_gaming_nc_ds_001.sol`

## Metadata

Each contract has accompanying metadata that includes:
- Original ground truth (vulnerability info preserved)
- Complete rename map showing all identifier substitutions
- Coverage statistics (% of identifiers transformed)
- Transformation seed for reproducibility

## Usage

```bash
# Transform all contracts with gaming theme
python3 -m strategies.chameleon.chameleon all --theme gaming --source nocomments

# Transform a single file
python3 -m strategies.chameleon.chameleon one nc_ds_001 --theme gaming

# Transform from stdin
echo "contract Foo { ... }" | python3 -m strategies.chameleon.chameleon code --theme gaming
```

## What This Tests

1. **Keyword dependence**: Does the model rely on terms like "withdraw", "balance", "transfer"?
2. **Semantic understanding**: Can the model recognize vulnerability patterns regardless of naming?
3. **Domain transfer**: Does training on DeFi contracts generalize to other domains?

## Coverage Statistics

The transformation aims for >75% identifier coverage. Untransformed identifiers include:
- Solidity reserved words (`require`, `msg`, `block`, etc.)
- Standard interface functions (ERC20, ERC721 if preserved)
- Very short identifiers (single letters, loop variables)
