# Gold Standard Dataset

## Overview

The Gold Standard dataset contains **35 curated vulnerability samples** from professional security audits conducted by top-tier audit firms. These represent real-world vulnerabilities discovered in production smart contracts.

## Purpose

This dataset serves as:
1. **Ground truth for evaluation** - High-confidence vulnerabilities verified by expert auditors
2. **Benchmark for detection accuracy** - Test whether tools can find what human experts found
3. **Multi-file vulnerability testing** - Many items include context files for cross-contract analysis

## Dataset Statistics

| Metric | Value |
|--------|-------|
| Total Items | 35 |
| Items with Context Files | 18 |
| Severity: High | 6 |
| Severity: Medium | 29 |

### By Source Platform

| Platform | Count |
|----------|-------|
| Code4rena | 16 |
| Spearbit | 10 |
| MixBytes | 9 |

### By Difficulty Tier

- Tier 1 (Easy): Basic patterns
- Tier 2 (Medium): Requires understanding of contract logic
- Tier 3 (Hard): Complex multi-file or multi-step vulnerabilities

## Directory Structure

```
gold_standard/
├── contracts/           # Primary vulnerable contract files
│   ├── gs_001.sol
│   ├── gs_002.sol
│   └── ...
├── context/             # Context files for multi-file vulnerabilities
│   ├── gs_011/
│   │   ├── context_01_LockToVotePlugin.sol
│   │   └── context_02_LockManagerBase.sol
│   ├── gs_012/
│   │   └── ...
│   └── ...
├── metadata/            # Rich metadata for each vulnerability
│   ├── gs_001.json
│   ├── gs_002.json
│   └── ...
├── index.json           # Dataset index with summary
└── README.md
```

## Naming Convention

`gs_{number}.sol`

- `gs` - Gold Standard prefix
- `{number}` - Sequential ID (001-035)

## Metadata Schema

Each metadata file contains:

```json
{
  "id": "gs_011",
  "original_id": "gs_spearbit_aragon-lock-to-vote_H01",
  "source_dataset": "gold_standard",

  // Source information
  "source_platform": "spearbit",
  "source_report": "Aragon DAO Gov Plugin Security Review",
  "source_finding_id": "H-01",
  "report_url": "https://...",
  "github_repo_url": "https://...",
  "contest_date": "2025-09-11",

  // Vulnerability classification
  "vulnerability_type": "flash_loan",
  "severity": "high",
  "difficulty_tier": 3,
  "context_level": "multi_file",
  "is_vulnerable": true,

  // Finding details
  "finding_title": "MinVotingPowerCondition logic can be bypassed via flashloans",
  "finding_description": "...",
  "attack_scenario": "1. Flashloan...",
  "fix_description": "...",
  "call_flow": "Attacker.flashloan() -> ...",
  "context_hint": "...",

  // File information
  "primary_file_path": "src/conditions/MinVotingPowerCondition.sol",
  "vulnerable_lines": [36, 37, 38, ...],
  "vulnerable_functions": ["isGranted"],

  // Context files
  "context_files": [
    {
      "filename": "context_01_LockToVotePlugin.sol",
      "original_path": "src/LockToVotePlugin.sol",
      "relevance": "Contains createProposal which is the target..."
    }
  ],
  "has_context": true
}
```

## Context Files

Many vulnerabilities require understanding multiple contracts to detect. Context files provide:

1. **Cross-contract call targets** - The contracts that interact with the vulnerable code
2. **Interface implementations** - How the vulnerable contract fits into the larger system
3. **State dependencies** - Contracts that share state with the vulnerable code

When evaluating a tool, provide both the primary contract and its context files for accurate assessment.

## Usage

### Basic Detection Test
```python
# Test if tool detects vulnerability in primary file
result = tool.analyze("contracts/gs_011.sol")
assert result.has_vulnerability("flash_loan")
```

### Multi-File Detection Test
```python
# Test if tool detects vulnerability with context
files = [
    "contracts/gs_011.sol",
    "context/gs_011/context_01_LockToVotePlugin.sol",
    "context/gs_011/context_02_LockManagerBase.sol"
]
result = tool.analyze_multi(files)
assert result.has_vulnerability("flash_loan")
```

## Vulnerability Types Covered

- Flash loan attacks
- Access control issues
- Reentrancy vulnerabilities
- Oracle manipulation
- Signature replay attacks
- First depositor attacks
- Governance manipulation
- Reward calculation errors
- Emergency function abuse

## Source Audits

The vulnerabilities are sourced from professional audits of:

- **Aragon** - DAO governance plugins
- **Gearbox** - DeFi lending protocol
- **Kyber** - DEX and liquidity protocol
- **Mantle** - L2 staking system
- **Sequence** - Smart wallet infrastructure
- **Velodrome** - AMM and DEX
- **Hybrafin** - DeFi protocol

## Quality Assurance

Each item has been:
1. Verified by professional auditors
2. Documented with attack scenarios
3. Linked to original audit reports
4. Tagged with vulnerability type and severity

## Regeneration

To regenerate from source JSON files:

```bash
python3 dataset/scripts/transform_goldstandard.py
```

Source files are located in `dataset/goldstandard/`.
