# Task: Difficulty Stratified Canonical Dataset Collection

## Objective

Process existing curated vulnerability datasets into a standardized format, stratified by difficulty level.

## Target Output

~150-200 labeled vulnerability samples from existing datasets

---

## Source Datasets to Clone

```bash
# Solidity
git clone https://github.com/smartbugs/smartbugs-curated
git clone https://github.com/crytic/not-so-smart-contracts
git clone https://github.com/SunWeb3Sec/DeFiVulnLabs

# Rust/Solana
git clone https://github.com/sannykim/solsec
git clone https://github.com/neodyme-labs/solana-security-workshop
git clone https://github.com/elmhamed/smart-contracts-vulns
```

---

## Difficulty Tiers (Assign to Each Sample)

| Tier           | Description                                             | Example                                     |
| -------------- | ------------------------------------------------------- | ------------------------------------------- |
| **1 - Easy**   | Single function, textbook pattern, obvious bug          | Classic reentrancy in withdraw()            |
| **2 - Medium** | Requires understanding state across multiple functions  | Access control missing on internal function |
| **3 - Hard**   | Cross-contract or requires business logic understanding | Oracle manipulation via flash loan          |
| **4 - Expert** | Novel/creative exploits, multi-step reasoning           | Protocol-specific logic errors              |

**Heuristics for assignment:**

- Tier 1: Can spot by looking at one function in isolation
- Tier 2: Need to trace state variables across contract
- Tier 3: Need to understand how contracts interact
- Tier 4: Need to understand protocol economics/design

---

## Data Schema

```json
{
  "id": "smartbugs_reentrancy_001",
  "source_dataset": "smartbugs-curated | not-so-smart-contracts | defivulnlabs | solsec",
  "language": "solidity | rust | move",
  "chain": "evm | solana | sui | aptos",

  "file_name": "reentrancy_dao.sol",
  "file_content": "<full source code>",
  "vulnerable_function": "withdraw()",
  "vulnerable_lines": [15, 23],

  "vulnerability_type": "reentrancy",
  "severity": "high",
  "difficulty_tier": 1,

  "description": "Classic reentrancy - external call before state update",
  "fix_description": "Apply checks-effects-interactions pattern",

  "is_vulnerable": true,
  "context_level": "single_file",

  "original_source_path": "smartbugs-curated/dataset/reentrancy/reentrancy_dao.sol",
  "swc_id": "SWC-107"
}
```

---

## Vulnerability Type Mapping

Standardize labels across datasets:

```python
VULN_TYPE_MAPPING = {
    "reentrancy": ["reentrancy", "re-entrancy", "reentrant", "dao"],
    "access_control": ["access_control", "authorization", "tx_origin", "ownership"],
    "integer_issues": ["overflow", "underflow", "integer", "arithmetic"],
    "unchecked_return": ["unchecked", "return_value", "low_level_call"],
    "dos": ["denial_of_service", "dos", "gas_limit", "unbounded"],
    "timestamp": ["timestamp", "block_timestamp", "time_manipulation"],
    "randomness": ["randomness", "weak_randomness", "predictable"],
    "front_running": ["front_running", "frontrunning", "race_condition"],
    "logic_error": ["logic", "business_logic", "incorrect_calculation"],

    # Solana-specific
    "missing_signer_check": ["signer", "missing_signer"],
    "missing_owner_check": ["owner_check", "account_owner"],
    "pda_validation": ["pda", "program_derived"],
    "account_validation": ["account_data", "account_validation"],
}
```

---

## Dataset-Specific Notes

### SmartBugs Curated (~140 contracts)

- Location: `dataset/` folder organized by vulnerability type
- Already categorized by SWC ID
- Mostly Tier 1-2 difficulty
- Format: Individual .sol files

### Not So Smart Contracts

- Location: Root folder, each vuln type has its own directory
- Includes README explanations
- Good for Tier 1-2
- Format: .sol files with comments

### DeFiVulnLabs

- Location: `src/test/` contains PoCs
- More complex DeFi patterns
- Good for Tier 2-3
- Includes Foundry test cases

### SolSec (Solana)

- Curated list of resources and examples
- Links to Neodyme workshop for hands-on
- Tier 1-3 Solana-specific vulns

---

## Processing Steps

### Step 1: Clone and Inventory

```bash
mkdir -p dataset/raw
cd dataset/raw
# Clone all repos
```

### Step 2: Process Each Dataset

For each source:

1. List all vulnerability files
2. Extract file content
3. Identify vulnerability type (from folder name or file name)
4. Assign difficulty tier
5. Create JSON entry

### Step 3: Standardize Format

- Convert all entries to schema above
- Validate all required fields present
- Remove duplicates

### Step 4: Stratify and Balance

- Count samples per difficulty tier
- Count samples per vulnerability type
- Identify gaps

---

## Expected Output Structure

```
dataset/
├── processed/
│   └── difficulty_stratified/
│       ├── tier_1_easy/
│       │   ├── solidity/
│       │   └── rust/
│       ├── tier_2_medium/
│       ├── tier_3_hard/
│       └── tier_4_expert/
├── metadata/
│   └── difficulty_stratified.json   # Master index
└── scripts/
    ├── process_smartbugs.py
    ├── process_defivulnlabs.py
    └── assign_difficulty.py
```

---

## Quality Checks

Before finalizing:

- [ ] All files have valid syntax (compile check)
- [ ] Vulnerability type matches actual bug
- [ ] Difficulty tier is reasonable
- [ ] No duplicate entries
- [ ] Both vulnerable and description fields populated

---

## Safe Samples (Non-Vulnerable)

For balanced dataset, also extract:

- Fixed versions of vulnerabilities (if available in repos)
- Contracts that passed audits without issues
- This gives you negative samples for precision measurement

---

## Quick Start

1. Clone the repos
2. Start with SmartBugs (cleanest structure)
3. Process into JSON
4. Add DeFiVulnLabs for more complexity
5. Add Solana samples from solsec/Neodyme

---

## Context from Main Research

This is part of a larger benchmark (500 tasks) for evaluating AI domain expertise in blockchain security. The difficulty stratification enables analysis of how AI performance degrades with complexity.

**Other subsets being collected separately:**

- Ground Truth Gold Standard (Code4rena/Sherlock recent audits)
- Adversarial Contrastive Pairs (generated variants)
- Temporal Contamination Probe (famous exploits)

**Full research plan:** See `blockchain_ai_expertise_research_plan.md`
