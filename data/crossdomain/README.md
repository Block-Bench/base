# Cross-Domain Dataset

## Overview

The Cross-Domain dataset contains smart contracts transformed using the **Cross-Domain strategy** - a terminology swap transformation that tests whether AI models can recognize vulnerabilities when presented in unfamiliar domain contexts.

## Hypothesis

> "If a model trained on DeFi exploits fails to detect the same vulnerability in gaming/medical/social context, it has learned domain-specific patterns rather than fundamental security concepts."

## Transformation Approach

The entire terminology shifts from DeFi (the source domain) to an alternative domain while preserving the underlying vulnerability pattern.

**Before (DeFi):**
```solidity
contract Vault {
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;
    }
}
```

**After (Gaming Domain):**
```solidity
contract TreasureChest {
    mapping(address => uint256) public goldHoldings;

    function claimLoot(uint256 gems) external {
        require(goldHoldings[msg.sender] >= gems);
        (bool success,) = msg.sender.call{value: gems}("");
        require(success);
        goldHoldings[msg.sender] -= gems;
    }
}
```

The reentrancy vulnerability remains identical, but the domain context has completely changed.

## Available Domains

| Domain | Description | Example Terms |
|--------|-------------|---------------|
| `gaming` | Video games, RPGs, loot systems | vault→TreasureChest, withdraw→claimLoot, balance→goldHolding |
| `healthcare` | Medical records, insurance | vault→PatientFund, withdraw→claimBenefit, balance→coverage |
| `social` | Reputation, tipping, communities | vault→CommunityFund, withdraw→collectTips, balance→karma |
| `logistics` | Supply chain, warehousing | vault→Warehouse, withdraw→releaseGoods, balance→inventory |

## Directory Structure

```
crossdomain/
├── gaming_sa/           # Gaming domain from sanitized source
│   ├── contracts/
│   ├── metadata/
│   └── index.json
├── healthcare_sa/       # Healthcare domain
├── logistics_sa/        # Logistics/supply chain domain
├── social_sa/           # Social/community domain
└── README.md
```

## Naming Convention

`cd_{domain}_{source}_{original_id}.sol`

- `cd` - Cross-Domain strategy prefix
- `{domain}` - Target domain (gaming, healthcare, social, logistics)
- `{source}` - Source dataset prefix
- `{original_id}` - Original contract ID

Example: `cd_gaming_sa_ds_001.sol`

## What This Tests

1. **Domain transfer**: Can models recognize the same vulnerability pattern in different contexts?
2. **Terminology independence**: Does the model rely on DeFi-specific terms like "withdraw", "vault", "balance"?
3. **Semantic understanding**: Does the model understand what makes code vulnerable regardless of naming?

## Key Difference from Chameleon

- **Chameleon**: Random synonym substitution within same domain
- **Cross-Domain**: Systematic domain-wide terminology shift to completely different context

Cross-Domain is more aggressive - it doesn't just rename `withdraw` to something generic, it renames it to domain-appropriate terminology like `claimLoot` (gaming) or `dischargePatient` (healthcare).
