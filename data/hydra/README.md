# Hydra Dataset

## Overview

The Hydra dataset contains smart contracts transformed using the **Hydra strategy** - a function splitting transformation that tests whether AI models can trace vulnerability patterns across function boundaries.

## Hypothesis

> "If a model fails to detect a vulnerability when the vulnerable pattern is split across multiple functions, it cannot perform cross-function dataflow analysis."

## Transformation Types

### Internal/External Split (Primary)

The main transformation creates a thin wrapper function that delegates to an internal implementation:

**Before:**
```solidity
function withdraw(uint256 amount) public {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount;
}
```

**After:**
```solidity
function withdraw(uint256 amount) public {
    _withdrawInternal(msg.sender, amount);
}

function _withdrawInternal(address _sender, uint256 amount) internal {
    require(balances[_sender] >= amount);
    (bool success, ) = _sender.call{value: amount}("");
    require(success);
    balances[_sender] -= amount;
}
```

Key transformations:
- `msg.sender` is passed as a parameter `_sender`
- All logic moves to an internal helper function
- The vulnerability pattern is preserved but spans two functions

### Sequential Split (Experimental)

Splits function body into multiple helpers based on statement categories (check/effect/interaction). Currently experimental due to local variable scoping challenges.

## Directory Structure

```
hydra/
├── int_nc/              # Internal/external split from nocomments
│   ├── contracts/       # Transformed .sol files
│   ├── metadata/        # JSON metadata for each contract
│   └── transformation_report.json
├── int_sn/              # Internal/external split from sanitized
│   ├── contracts/
│   ├── metadata/
│   └── transformation_report.json
└── README.md
```

## Naming Convention

`hy_{split_type}_{source}_{original_id}.sol`

- `hy` - Hydra strategy prefix
- `{split_type}` - `int` (internal/external) or `seq` (sequential)
- `{source}` - `nc` (nocomments) or `sn` (sanitized)
- `{original_id}` - Original contract ID (e.g., `ds_001`, `tc_042`)

Example: `hy_int_nc_ds_001.sol`

## Usage

```bash
# Transform a single file
python3 -m strategies.hydra.hydra one nc_ds_001

# Transform all files from a source
python3 -m strategies.hydra.hydra all --source nocomments

# Transform with specific function target
python3 -m strategies.hydra.hydra one nc_ds_001 --function withdraw
```

## What This Tests

1. **Cross-function tracing**: Can the model follow a vulnerability pattern that spans multiple functions?
2. **Parameter abstraction**: Does renaming `msg.sender` to `_sender` confuse pattern-matching models?
3. **Call graph analysis**: Does the model understand that `withdraw()` calls `_withdrawInternal()`?

## Success Rate

- nocomments: 245/274 (89%)
- sanitized: 246/274 (90%)

Failures typically occur when:
- No suitable function found for splitting (e.g., only view functions)
- Functions have no body (interfaces, abstract contracts)
