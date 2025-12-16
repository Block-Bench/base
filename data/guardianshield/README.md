# Guardian Shield Dataset

## Overview

The Guardian Shield dataset contains smart contracts transformed using the **Guardian Shield strategy** - a protection injection transformation that tests whether AI models can recognize when vulnerabilities have been neutralized by security measures.

## Hypothesis

> "If a model flags protected code as vulnerable, it's pattern-matching on code structure rather than understanding whether the vulnerability is actually exploitable."

## Critical Difference from Other Strategies

**Guardian Shield intentionally changes vulnerability status:**

- Input: Vulnerable contract
- Output: Safe contract (protection neutralizes vulnerability)
- Ground truth changes: `is_vulnerable: true` → `is_vulnerable: false`

This is the only strategy that produces contracts that are NOT vulnerable despite containing code patterns that look vulnerable.

## Transformation Types

| Protection | Targets | Description |
|------------|---------|-------------|
| `reentrancy_guard` | Reentrancy | Inject OpenZeppelin ReentrancyGuard + `nonReentrant` modifier |
| `cei_pattern` | Reentrancy | Reorder statements to Checks-Effects-Interactions pattern |
| `access_control` | Unauthorized access | Add owner-only restriction with `onlyOwner` modifier |
| `solidity_0_8` | Integer overflow/underflow | Update pragma to 0.8+ for built-in overflow protection |

## Transformation Examples

### ReentrancyGuard Injection

**Before (Vulnerable):**
```solidity
contract Vault {
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;  // State update AFTER external call
    }
}
```

**After (Protected):**
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;  // Mutex prevents reentrancy
    }
}
```

### CEI Pattern Fix

**Before (Vulnerable):**
```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);  // Check
    (bool success,) = msg.sender.call{value: amount}("");  // Interaction
    require(success);
    balances[msg.sender] -= amount;  // Effect (wrong order!)
}
```

**After (Protected):**
```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);  // Check
    balances[msg.sender] -= amount;  // Effect (moved before interaction)
    (bool success,) = msg.sender.call{value: amount}("");  // Interaction
    require(success);
}
```

## Directory Structure

```
guardianshield/
├── access_control_sa/    # Access control protection from sanitized source
│   ├── contracts/
│   └── metadata/
├── cei_pattern_sa/       # CEI pattern reordering
│   ├── contracts/
│   └── metadata/
├── reentrancy_guard_sa/  # ReentrancyGuard injection
│   ├── contracts/
│   └── metadata/
├── solidity_0_8_sa/      # Solidity 0.8 upgrade
│   ├── contracts/
│   └── metadata/
└── README.md
```

## Naming Convention

`gs_{protection}_{source}_{original_id}.sol`

- `gs` - Guardian Shield strategy prefix
- `{protection}` - Protection type (rg=reentrancy_guard, cei=cei_pattern, ac=access_control, v8=solidity_0_8)
- `{source}` - Source dataset prefix
- `{original_id}` - Original contract ID

Example: `gs_rg_sa_ds_001.sol`

## What This Tests

1. **Protection recognition**: Can models identify that a vulnerability has been neutralized?
2. **False positive reduction**: Will models stop flagging protected code as vulnerable?
3. **Understanding vs pattern matching**: Does the model understand WHY code is secure?

## Key Insight for Evaluation

A model that scores well on Guardian Shield:
- Recognizes that `nonReentrant` modifier prevents reentrancy exploitation
- Understands that CEI-ordered code is not vulnerable to reentrancy
- Identifies that Solidity 0.8+ has built-in overflow protection
- Does NOT flag protected code as vulnerable

A model that fails on Guardian Shield:
- Pattern-matches on code structure (sees external call, flags as reentrancy)
- Ignores protection mechanisms
- Cannot reason about why code is or isn't exploitable

## Ground Truth Changes

Unlike other strategies, Guardian Shield contracts have modified ground truth:

```json
{
  "ground_truth": {
    "is_vulnerable": false,
    "original_vulnerability": "reentrancy",
    "neutralized_by": "reentrancy_guard",
    "protection_details": {
      "import_added": "@openzeppelin/contracts/security/ReentrancyGuard.sol",
      "inheritance_added": "ReentrancyGuard",
      "modifier_added": "nonReentrant"
    }
  }
}
```
