# BlockBench: Difficulty Stratified Canonical Dataset

**Version:** 1.0  
**Date:** December 15, 2025  
**Total Entries:** 235  
**Languages:** Solidity (224), Rust/Solana (11)

---

## Overview

This directory contains a curated and standardized dataset of smart contract vulnerabilities, organized by difficulty tier. The dataset is part of BlockBench, a comprehensive benchmark for evaluating AI domain expertise in blockchain security.

### Purpose

- Evaluate AI models' ability to detect and reason about smart contract vulnerabilities
- Test performance across different difficulty levels
- Support multi-language vulnerability detection research
- Provide a foundation for the larger 500-task NeurIPS benchmark

---

## Directory Structure

```
dataset/
├── raw/                              # Original cloned repositories
│   ├── smartbugs-curated/           # 143 Solidity vulnerabilities
│   ├── DeFiVulnLabs/                # 56 DeFi-specific vulnerabilities with PoCs
│   ├── not-so-smart-contracts/      # 25 educational examples
│   ├── sealevel-attacks/            # 11 Solana/Anchor vulnerabilities
│   ├── solsec/                      # Solana security resources
│   └── smart-contracts-vulns/       # Additional references
│
├── processed/                        # Standardized JSON outputs
│   └── difficulty_stratified/
│       ├── tier_1_easy/
│       │   ├── solidity/            # 87 easy Solidity samples
│       │   └── rust/                # (none at this tier)
│       ├── tier_2_medium/
│       │   ├── solidity/            # 87 medium Solidity samples
│       │   └── rust/                # 6 medium Rust/Solana samples
│       ├── tier_3_hard/
│       │   ├── solidity/            # 36 hard Solidity samples
│       │   └── rust/                # 4 hard Rust/Solana samples
│       └── tier_4_expert/
│           ├── solidity/            # 14 expert Solidity samples
│           └── rust/                # 1 expert Rust/Solana sample
│
├── metadata/                         # Master indices and summaries
│   ├── difficulty_stratified_master.json   # ⭐ MASTER INDEX (all 235 entries)
│   ├── dataset_summary.json                # Statistics summary
│   ├── smartbugs_processed.json            # By-source indices
│   ├── defivulnlabs_processed.json
│   ├── not_so_smart_processed.json
│   └── sealevel_attacks_processed.json
│
├── scripts/                          # Processing and utility scripts
│   ├── process_smartbugs.py         # SmartBugs processor
│   ├── process_defivulnlabs.py      # DeFiVulnLabs processor
│   ├── process_not_so_smart.py      # Not-So-Smart-Contracts processor
│   ├── process_sealevel_attacks.py  # Sealevel Attacks processor
│   ├── consolidate_all.py           # Master consolidation script
│   └── show_samples.py              # Display sample entries
│
├── README.md                         # This file
└── TASK_ONE_SUMMARY.md              # Detailed completion report
```

---

## Quick Start

### View Sample Entries

```bash
python3 scripts/show_samples.py
```

### Load Master Dataset (Python)

```python
import json

# Load all 235 entries
with open('metadata/difficulty_stratified_master.json', 'r') as f:
    dataset = json.load(f)

# Filter by difficulty tier
tier_3_samples = [entry for entry in dataset if entry['difficulty_tier'] == 3]

# Filter by language
solana_samples = [entry for entry in dataset if entry['language'] == 'rust']

# Filter by vulnerability type
reentrancy_samples = [entry for entry in dataset if entry['vulnerability_type'] == 'reentrancy']
```

### Reprocess a Dataset

```bash
# Reprocess SmartBugs
python3 scripts/process_smartbugs.py

# Reconsolidate all datasets
python3 scripts/consolidate_all.py
```

---

## Dataset Statistics

### Breakdown by Source

| Source                 | Entries | Description                                 |
| ---------------------- | ------- | ------------------------------------------- |
| SmartBugs Curated      | 143     | Academic dataset of labeled vulnerabilities |
| DeFiVulnLabs           | 56      | DeFi-specific with Foundry PoCs             |
| Not-So-Smart-Contracts | 25      | Trail of Bits educational examples          |
| Sealevel Attacks       | 11      | Solana/Anchor vulnerabilities               |

### Difficulty Distribution

| Tier       | Count | %     | Description                          |
| ---------- | ----- | ----- | ------------------------------------ |
| 1 - Easy   | 87    | 37.0% | Single function, textbook patterns   |
| 2 - Medium | 93    | 39.6% | Multiple functions, state tracking   |
| 3 - Hard   | 40    | 17.0% | Cross-contract, business logic       |
| 4 - Expert | 15    | 6.4%  | Novel exploits, multi-step reasoning |

### Severity Distribution

- **Critical:** 17 (7.2%)
- **High:** 88 (37.4%)
- **Medium:** 114 (48.5%)
- **Low:** 16 (6.8%)

### Top Vulnerability Types

1. unchecked_return (53)
2. reentrancy (40)
3. logic_error (24)
4. access_control (23)
5. integer_issues (19)
6. weak_randomness (10)
7. dos (9)
8. honeypot (6)
9. oracle_manipulation (5)
10. front_running (5)

Plus 40+ more vulnerability types...

---

## Data Schema

Each entry follows this standardized schema:

```json
{
  "id": "unique_identifier",
  "source_dataset": "dataset_name",
  "language": "solidity | rust",
  "chain": "evm | solana",
  "framework": "hardhat | anchor | foundry | null",

  "file_name": "contract.sol",
  "file_content": "<full source code>",
  "vulnerable_function": "function_name",
  "vulnerable_lines": [line_numbers],

  "vulnerability_type": "standardized_type",
  "severity": "critical | high | medium | low",
  "difficulty_tier": 1 | 2 | 3 | 4,

  "description": "vulnerability description",
  "fix_description": "remediation steps",
  "references": ["urls"],

  "is_vulnerable": true,
  "has_poc": boolean,
  "has_remediation": boolean,
  "context_level": "single_file | intra_contract | cross_contract",

  "original_source_path": "path/to/original",
  "pragma": "solidity version (if applicable)",
  "source": "original author/organization"
}
```

### Required Fields

- `id`, `language`, `vulnerability_type`, `difficulty_tier`
- `severity`, `is_vulnerable`, `file_content`

### Optional Fields

- `has_poc`, `has_remediation`, `references`
- `vulnerable_lines`, `pragma`, `framework`

---

## Difficulty Tier Criteria

### Tier 1: Easy

- ✅ Single function vulnerability
- ✅ Classic textbook pattern (e.g., basic reentrancy)
- ✅ Can be identified in isolation
- ✅ < 100 lines of code typically
- ✅ No cross-contract interactions

**Example:** Classic reentrancy in withdraw function

### Tier 2: Medium

- ✅ Multiple functions involved
- ✅ State tracking across contract required
- ✅ 100-200 lines of code
- ✅ Intra-contract complexity
- ✅ Some business logic understanding needed

**Example:** Access control bug requiring understanding of initialization flow

### Tier 3: Hard

- ✅ Cross-contract interactions
- ✅ Business logic reasoning required
- ✅ > 200 lines of code
- ✅ DeFi-specific patterns
- ✅ Multiple contracts or interfaces

**Example:** Oracle manipulation via flash loan attack

### Tier 4: Expert

- ✅ Novel attack vectors
- ✅ Multi-step reasoning
- ✅ Protocol-specific logic
- ✅ Advanced concepts (flash loans, PDAs, etc.)
- ✅ Creative exploitation required

**Example:** First depositor inflation attack, PDA seed manipulation

---

## Vulnerability Taxonomy

### Universal (Cross-Language)

- `reentrancy` - External call before state update
- `access_control` - Missing authorization checks
- `integer_issues` - Overflow/underflow
- `logic_error` - Business logic flaws
- `dos` - Denial of service
- `oracle_manipulation` - Price feed manipulation
- `unchecked_return` - Ignored return values

### Solidity-Specific

- `delegatecall_injection` - Unsafe delegatecall usage
- `storage_collision` - Proxy storage conflicts
- `tx_origin_auth` - Using tx.origin for auth
- `selfdestruct` - Unauthorized contract destruction
- `timestamp_dependency` - Block timestamp reliance
- `weak_randomness` - Predictable randomness
- `front_running` - Transaction ordering exploitation

### Solana/Rust-Specific

- `missing_signer_check` - No is_signer validation
- `missing_owner_check` - No owner validation
- `account_validation` - Insufficient account checks
- `type_cosplay` - Account type confusion
- `pda_manipulation` - PDA seed exploitation
- `cpi_injection` - Unconstrained CPI calls
- `unclosed_accounts` - Improper account closure
- `duplicate_mutable_accounts` - Same account twice as mutable

---

## Usage Examples

### Example 1: Train a Vulnerability Detector

```python
import json
from sklearn.model_selection import train_test_split

# Load dataset
with open('metadata/difficulty_stratified_master.json', 'r') as f:
    data = json.load(f)

# Split by difficulty for stratified evaluation
train_data = [e for e in data if e['difficulty_tier'] <= 2]
test_data = [e for e in data if e['difficulty_tier'] >= 3]

# Your training code here...
```

### Example 2: Benchmark LLM on Specific Vulnerability Type

```python
import json
from openai import OpenAI

client = OpenAI()

# Load reentrancy samples
with open('metadata/difficulty_stratified_master.json', 'r') as f:
    data = json.load(f)

reentrancy_samples = [e for e in data if e['vulnerability_type'] == 'reentrancy']

for sample in reentrancy_samples:
    prompt = f"Analyze this smart contract for vulnerabilities:\n\n{sample['file_content']}"
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    # Evaluate response...
```

### Example 3: Analyze Performance by Difficulty

```python
import json
from collections import defaultdict

with open('metadata/difficulty_stratified_master.json', 'r') as f:
    data = json.load(f)

results_by_tier = defaultdict(lambda: {"correct": 0, "total": 0})

for sample in data:
    tier = sample['difficulty_tier']
    # Your evaluation logic here
    is_correct = evaluate_model_response(sample)

    results_by_tier[tier]["total"] += 1
    if is_correct:
        results_by_tier[tier]["correct"] += 1

for tier in sorted(results_by_tier.keys()):
    stats = results_by_tier[tier]
    accuracy = stats["correct"] / stats["total"]
    print(f"Tier {tier}: {accuracy:.2%} ({stats['correct']}/{stats['total']})")
```

---

## Quality Assurance

### Validation Checks

All entries pass the following validation:

- ✅ Required fields present
- ✅ Unique IDs (no duplicates)
- ✅ Valid difficulty tier (1-4)
- ✅ Valid severity (critical/high/medium/low)
- ✅ File content not empty
- ✅ Vulnerability type standardized

### Manual Review

- Difficulty assignments reviewed by heuristics
- Vulnerability classifications based on established taxonomies
- Fix descriptions verified against security best practices

---

## Citations

### Source Repositories

```bibtex
@misc{smartbugs2020,
  title={SmartBugs: A Framework to Analyze Solidity Smart Contracts},
  author={Ferreira Torres, Christof and Baden, Mathis and Norvill, Robert and State, Radu},
  year={2020},
  url={https://github.com/smartbugs/smartbugs-curated}
}

@misc{defivulnlabs2023,
  title={DeFi Vulnerability Labs},
  author={XREX},
  year={2023},
  url={https://github.com/SunWeb3Sec/DeFiVulnLabs}
}

@misc{notsosmartcontracts,
  title={Not So Smart Contracts},
  author={Trail of Bits},
  url={https://github.com/crytic/not-so-smart-contracts}
}

@misc{sealevelattacks,
  title={Sealevel Attacks},
  author={Coral XYZ},
  url={https://github.com/coral-xyz/sealevel-attacks}
}
```

---

## Future Enhancements

Planned additions to reach 500-task benchmark:

1. **Ground Truth Gold Standard** (150-200 samples)

   - Code4rena audits (Sept 2025+)
   - Sherlock post-cutoff findings
   - Solodit aggregated reports

2. **Adversarial Contrastive Pairs** (150-200 samples)

   - Patched versions (safe)
   - Cosmetic variants (still vulnerable)
   - Decoy patterns (looks bad, actually safe)

3. **Move/Sui/Aptos** (60 samples)

   - MoveBit audit reports
   - Move-specific vulnerabilities

4. **Temporal Contamination Probes** (50 samples)
   - Famous exploits with variants
   - Test memorization vs reasoning

---

## License

This dataset aggregates multiple sources with their respective licenses:

- SmartBugs: Apache 2.0
- DeFiVulnLabs: MIT
- Not-So-Smart-Contracts: Apache 2.0
- Sealevel Attacks: Apache 2.0

Please respect the original licenses when using this dataset.

---

## Contact

For questions, issues, or contributions:

- Project: BlockBench - AI Domain Expertise Evaluation
- Research Goal: NeurIPS Datasets & Benchmarks Track
- See main repository README for contact information

---

**Last Updated:** December 15, 2025
