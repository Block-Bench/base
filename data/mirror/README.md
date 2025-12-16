# Mirror Dataset

## Overview

The Mirror dataset contains smart contracts transformed using the **Mirror strategy** - a format transformation that tests whether AI models are sensitive to code formatting and visual presentation while keeping the logic identical.

## Hypothesis

> "If a model's accuracy changes when code is reformatted, it relies on visual patterns rather than semantic understanding."

## Transformation Approach

Same logic, different whitespace/braces/indentation. The vulnerability is preserved exactly - only formatting changes.

**Before (Standard):**
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

**After (Compressed):**
```solidity
contract Vault {
mapping(address => uint256) public balances;
function withdraw(uint256 amount) external {
require(balances[msg.sender] >= amount);
(bool success,) = msg.sender.call{value: amount}("");
require(success);
balances[msg.sender] -= amount; } }
```

**After (Allman Style):**
```solidity
contract Vault
{
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) external
    {
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;
    }
}
```

## Transformation Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `compressed` | Minimal whitespace, reduced line breaks | Test compression handling |
| `expanded` | Maximum whitespace, one statement per line | Test verbosity handling |
| `allman` | Braces on new lines (Allman style) | Test brace style sensitivity |
| `knr` | Braces on same line (K&R style) | Test brace style sensitivity |
| `minified` | Remove all non-essential whitespace | Extreme compression test |

## Directory Structure

```
mirror/
├── allman/               # Allman brace style
│   ├── contracts/
│   └── metadata/
├── compressed/           # Minimal whitespace
│   ├── contracts/
│   └── metadata/
├── expanded/             # Maximum whitespace
│   ├── contracts/
│   └── metadata/
├── knr/                  # K&R brace style
│   ├── contracts/
│   └── metadata/
├── minified/             # Extreme minification
│   ├── contracts/
│   └── metadata/
└── README.md
```

## Naming Convention

`mr_{mode}_{original_id}.sol`

- `mr` - Mirror strategy prefix
- `{mode}` - Formatting mode (allman, knr, compressed, expanded, minified)
- `{original_id}` - Original contract ID

Example: `mr_allman_ds_001.sol`

## What This Tests

1. **Format invariance**: Does the model produce the same result regardless of formatting?
2. **Whitespace sensitivity**: Is the model confused by unusual spacing or indentation?
3. **Brace style independence**: Does brace placement affect vulnerability detection?

## Mode Details

### Compressed Mode
- Removes blank lines
- Collapses multiple spaces to single space
- Keeps braces on same line
- Preserves string literals and necessary whitespace

### Expanded Mode
- One statement per line
- Blank lines between functions
- Spaces around all operators
- Maximum readability

### Allman Style
- Opening braces on new lines
- Common in C/C++ codebases
- More vertical space

### K&R Style (Kernighan & Ritchie)
- Opening braces on same line as declaration
- Common in JavaScript, Java
- More compact vertically

### Minified Mode
- Removes all comments
- Removes all unnecessary whitespace
- Most aggressive compression
- Must still compile

## Key Insight

A well-designed vulnerability detection model should produce **identical results** for all Mirror variants of the same contract, since:
- The AST structure is identical
- The vulnerability is identical
- Only visual presentation differs

Variance in detection across Mirror modes indicates:
- Model sensitivity to tokenization differences
- Over-reliance on whitespace or indentation patterns
- Potential issues with code preprocessing

## Metadata

Each contract has accompanying metadata that includes:

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
    "comments_removed": true
  },
  "vulnerability_preserved": true
}
```
