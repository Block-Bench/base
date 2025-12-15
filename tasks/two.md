# Task: Temporal Contamination Probe Dataset Collection

## Objective

Create a dataset that measures whether AI models are memorizing known exploits vs genuinely reasoning about vulnerabilities. This is done by comparing performance on pre-cutoff (likely memorized) vs post-cutoff (likely novel) exploits.

## Target Output

~50 labeled vulnerability samples split between famous historical exploits and recent novel ones

---

## Why This Matters

When a model correctly identifies a vulnerability, we need to know:

- Is it **recognizing** a memorized pattern from training data?
- Or is it **reasoning** about the security flaw?

The performance gap between pre-cutoff and post-cutoff exploits answers this question empirically.

---

## Model Cutoff Dates (Reference)

| Model             | Knowledge Cutoff    |
| ----------------- | ------------------- |
| Claude Sonnet 4.5 | Jan 2025 (reliable) |
| GPT-5             | Oct 2024            |
| GPT-5.2           | Aug 2025            |
| Gemini 2.5/3      | Jan 2025            |

**Safe threshold for "post-cutoff":** September 2025 onward

---

## Dataset Structure

### Two Groups

| Group           | Count | Date Range      | Purpose                     |
| --------------- | ----- | --------------- | --------------------------- |
| **Pre-cutoff**  | 25-30 | Before Jan 2024 | Baseline (likely memorized) |
| **Post-cutoff** | 20-25 | After Sept 2025 | True test (likely novel)    |

### Expected Results

- **Large performance gap** → Model relies on memorization
- **Small gap** → Model generalizes well
- **No gap** → Either genuinely reasoning, or difficulty isn't balanced

---

## Pre-Cutoff: Famous Exploits to Include

These are well-documented exploits likely in training data:

### Solidity/EVM Exploits

| Exploit         | Date     | Amount | Vulnerability Type              | Chain    |
| --------------- | -------- | ------ | ------------------------------- | -------- |
| The DAO         | Jun 2016 | \$60M  | reentrancy                      | Ethereum |
| Parity Wallet   | Nov 2017 | \$150M | delegatecall + selfdestruct     | Ethereum |
| bZx Flash Loan  | Feb 2020 | \$350K | oracle_manipulation             | Ethereum |
| Harvest Finance | Oct 2020 | \$24M  | flash_loan + price_manipulation | Ethereum |
| Yearn yDAI      | Feb 2021 | \$11M  | flash_loan                      | Ethereum |
| Poly Network    | Aug 2021 | \$611M | access_control (cross-chain)    | Multi    |
| Cream Finance   | Oct 2021 | \$130M | flash_loan + oracle             | Ethereum |
| Badger DAO      | Dec 2021 | \$120M | front_end_attack                | Ethereum |
| Beanstalk       | Apr 2022 | \$182M | governance_flash_loan           | Ethereum |
| Nomad Bridge    | Aug 2022 | \$190M | message_validation              | Multi    |
| Euler Finance   | Mar 2023 | \$197M | donation_attack                 | Ethereum |
| Curve Finance   | Jul 2023 | \$70M  | reentrancy (Vyper)              | Ethereum |

### Solana/Rust Exploits

| Exploit       | Date     | Amount | Vulnerability Type     | Chain  |
| ------------- | -------- | ------ | ---------------------- | ------ |
| Wormhole      | Feb 2022 | \$320M | signature_verification | Solana |
| Cashio        | Mar 2022 | \$48M  | account_validation     | Solana |
| Mango Markets | Oct 2022 | \$114M | oracle_manipulation    | Solana |
| Slope Wallet  | Aug 2022 | \$4M   | key_leakage            | Solana |

### Move/Sui Exploits

| Exploit        | Date | Amount  | Vulnerability Type | Chain |
| -------------- | ---- | ------- | ------------------ | ----- |
| Cetus Protocol | 2025 | \$220M+ | oracle/logic_error | Sui   |

---

## Post-Cutoff: Recent Exploits to Find

You need to find exploits from **September 2025 onward**.

### Where to Look

| Source                   | URL                           | How to Use                         |
| ------------------------ | ----------------------------- | ---------------------------------- |
| **Rekt.news**            | https://rekt.news             | Filter by recent dates             |
| **Code4rena Reports**    | https://code4rena.com/reports | High severity findings, Sept+ 2025 |
| **Sherlock Reports**     | https://audits.sherlock.xyz   | Recent judged findings             |
| **DeFiLlama Hacks**      | https://defillama.com/hacks   | Incident tracker                   |
| **Twitter/X**            | Security researchers          | Breaking news                      |
| **Immunefi Disclosures** | https://immunefi.com          | Public writeups                    |

### Criteria for Inclusion

- Must have occurred after Sept 1, 2025
- Must have publicly available code or detailed writeup
- Must be a smart contract vulnerability (not social engineering, key compromise)
- Severity: High or Critical

---

## Variant Strategy (For Pre-Cutoff Only)

For ~10 of the most famous exploits, create variants to test depth of understanding:

| Variant Type   | What Changes                        | What It Tests                 |
| -------------- | ----------------------------------- | ----------------------------- |
| **original**   | Exact code from exploit             | Pure memorization             |
| **renamed**    | Different variable/function names   | Surface pattern matching      |
| **simplified** | Stripped to core vulnerability only | Can identify essence          |
| **obfuscated** | Same bug, restructured code         | Deep structural understanding |

### Example: DAO Reentrancy Variants

```solidity
// ORIGINAL (id: temporal_dao_001)
// Exact code from The DAO hack
function splitDAO(uint _proposalID, address _newCurator) {
    ...
    uint fundsToBeMoved = balances[msg.sender];
    withdrawRewardFor(msg.sender);  // <-- External call
    totalSupply -= balances[msg.sender];
    balances[msg.sender] = 0;
    ...
}

// RENAMED (id: temporal_dao_001_renamed)
function claimUserFunds(uint _requestId, address _recipient) {
    ...
    uint userBalance = deposits[msg.sender];
    processRefund(msg.sender);  // <-- External call
    totalDeposits -= deposits[msg.sender];
    deposits[msg.sender] = 0;
    ...
}

// SIMPLIFIED (id: temporal_dao_001_simplified)
function withdraw() public {
    uint amount = balances[msg.sender];
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] = 0;
}

// OBFUSCATED (id: temporal_dao_001_obfuscated)
contract FundManager {
    function processUserRequest(address user) external {
        uint bal = _getUserBalance(user);
        _executeTransfer(user, bal);
        _updateLedger(user, 0);
    }

    function _executeTransfer(address to, uint amt) internal {
        (bool ok,) = to.call{value: amt}("");
        require(ok, "Transfer failed");
    }

    function _updateLedger(address user, uint newBal) internal {
        userBalances[user] = newBal;
    }
}
```

### Variant Analysis Goal

```
Model performance on DAO hack:
- Original:    ✓ (memorized)
- Renamed:     ✓ (pattern still recognizable)
- Simplified:  ✓ (core pattern intact)
- Obfuscated:  ✗ (structure changed, model fails)

→ Conclusion: Model recognizes surface patterns but not deep structure
```

---

## Data Schema

### Main Entry

```json
{
  "id": "temporal_dao_001",
  "subset": "temporal_contamination_probe",

  "exploit_name": "The DAO Hack",
  "exploit_date": "2016-06-17",
  "amount_lost_usd": 60000000,
  "amount_lost_display": "$60M",

  "temporal_category": "pre_cutoff",
  "likely_in_training": true,
  "cutoff_notes": "Extensively documented, definitely in all models pre-2024",

  "language": "solidity",
  "chain": "ethereum",
  "protocol_type": "dao",

  "file_name": "dao_vulnerable.sol",
  "file_content": "<full vulnerable code>",
  "vulnerable_function": "splitDAO",
  "vulnerable_lines": [45, 52],

  "vulnerability_type": "reentrancy",
  "vulnerability_subtype": "cross_function_reentrancy",
  "severity": "critical",

  "description": "The withdraw pattern allows recursive calls before balance update. Attacker contract calls splitDAO, receives ETH via withdrawRewardFor, then re-enters before balance is zeroed.",
  "fix_description": "Apply checks-effects-interactions: update balance before external call",
  "attack_vector": "Deploy malicious contract with fallback that re-calls splitDAO",

  "is_variant": false,
  "variant_type": null,
  "variant_parent_id": null,

  "source_url": "https://www.coindesk.com/understanding-dao-hack-journalists",
  "code_source": "DeFiHackLabs",
  "has_poc": true,
  "poc_url": "https://github.com/SunWeb3Sec/DeFiHackLabs/..."
}
```

### Variant Entry

```json
{
  "id": "temporal_dao_001_renamed",
  "subset": "temporal_contamination_probe",

  "exploit_name": "The DAO Hack",
  "exploit_date": "2016-06-17",

  "temporal_category": "pre_cutoff",
  "likely_in_training": true,

  "language": "solidity",
  "chain": "ethereum",

  "file_name": "dao_renamed_variant.sol",
  "file_content": "<renamed version of vulnerable code>",
  "vulnerable_function": "claimUserFunds",

  "vulnerability_type": "reentrancy",
  "severity": "critical",

  "description": "Same vulnerability as DAO hack but with renamed functions and variables",

  "is_variant": true,
  "variant_type": "renamed",
  "variant_parent_id": "temporal_dao_001",
  "variant_changes": "Function names, variable names changed; logic identical"
}
```

### Post-Cutoff Entry

```json
{
  "id": "temporal_post_001",
  "subset": "temporal_contamination_probe",

  "exploit_name": "<Recent Exploit Name>",
  "exploit_date": "2025-10-15",
  "amount_lost_usd": 5000000,

  "temporal_category": "post_cutoff",
  "likely_in_training": false,
  "cutoff_notes": "Occurred after Sept 2025, not in any model's training data",

  "language": "solidity",
  "chain": "ethereum",

  "file_content": "<vulnerable code>",
  "vulnerability_type": "logic_error",
  "severity": "high",

  "description": "<detailed explanation>",

  "is_variant": false,
  "source_url": "<link to writeup or Code4rena finding>"
}
```

---

## Sources for Code

### Pre-Cutoff Exploits

| Source                | URL                                | What You Get                           |
| --------------------- | ---------------------------------- | -------------------------------------- |
| **DeFiHackLabs**      | github.com/SunWeb3Sec/DeFiHackLabs | Reproducible PoCs with vulnerable code |
| **Rekt.news**         | rekt.news                          | Detailed writeups, sometimes code      |
| **SlowMist Hacked**   | hacked.slowmist.io                 | Incident database                      |
| **Immunefi Writeups** | Various blog posts                 | Technical breakdowns                   |
| **BlockSec**          | blocksec.com/blog                  | Incident analyses                      |

### Post-Cutoff Exploits

| Source        | URL                       | What You Get                |
| ------------- | ------------------------- | --------------------------- |
| **Code4rena** | code4rena.com/reports     | Findings + GitHub repos     |
| **Sherlock**  | audits.sherlock.xyz       | Judged findings + repos     |
| **Rekt.news** | rekt.news (filter recent) | New incidents               |
| **DeFiLlama** | defillama.com/hacks       | Tracks all hacks with dates |

---

## Processing Steps

### Step 1: Compile Pre-Cutoff List (2-3 hours)

1. Start with the famous exploits table above
2. For each, find the vulnerable code (DeFiHackLabs is best)
3. Document: date, amount, vuln type, chain
4. Create JSON entries

### Step 2: Create Variants (3-4 hours)

1. Select 10 most famous/well-documented exploits
2. For each, create 2-3 variants:
   - Renamed version
   - Simplified version
   - Optionally: obfuscated version
3. Verify variants still contain the same vulnerability

### Step 3: Find Post-Cutoff Exploits (3-4 hours)

1. Check Rekt.news for Sept-Dec 2025 incidents
2. Check recent Code4rena/Sherlock reports
3. Need ~20-25 samples
4. Get code from GitHub repos or reconstruct from writeups

### Step 4: Standardize (2-3 hours)

1. Convert all to JSON schema
2. Validate all required fields
3. Verify temporal categories are correct

---

## Quality Checks

### For Pre-Cutoff Samples

- [ ] Exploit is well-documented (multiple sources confirm)
- [ ] Code is accurate representation of the vulnerability
- [ ] Date is correct
- [ ] Vulnerability type label is accurate

### For Variants

- [ ] Variant still contains the same vulnerability
- [ ] Changes are only what's documented (renamed, simplified, etc.)
- [ ] Ground truth label is same as original

### For Post-Cutoff Samples

- [ ] Date is definitely after Sept 2025
- [ ] Not covered in any earlier writeups (check dates carefully)
- [ ] Code is accurate
- [ ] Severity matches actual impact

---

## Expected Output Structure

```
dataset/
├── processed/
│   └── temporal_contamination/
│       ├── pre_cutoff/
│       │   ├── originals/
│       │   └── variants/
│       └── post_cutoff/
├── metadata/
│   └── temporal_contamination.json   # Master index
└── scripts/
    ├── process_defi_hack_labs.py
    └── create_variants.py
```

---

## Analysis You'll Enable

### 1. Pre vs Post Accuracy Gap

```python
pre_accuracy = correct_pre / total_pre
post_accuracy = correct_post / total_post
memorization_gap = pre_accuracy - post_accuracy
```

### 2. Variant Performance Matrix

```
              Original  Renamed  Simplified  Obfuscated
DAO Hack      ✓         ✓        ✓           ✗
Wormhole      ✓         ✓        ✗           ✗
Euler         ✓         ✗        ✗           ✗
```

### 3. Cross-Model Comparison

```
Model         Pre-Cutoff    Post-Cutoff   Gap
Claude 4.5    92%           78%           14%
GPT-5         94%           71%           23%
Gemini 3      89%           74%           15%
```

---

## Timeline

| Step                                     | Time        |
| ---------------------------------------- | ----------- |
| Compile pre-cutoff list (25-30 exploits) | 2-3 hours   |
| Find code for each (DeFiHackLabs)        | 3-4 hours   |
| Create variants for ~10 exploits         | 3-4 hours   |
| Find post-cutoff exploits (20-25)        | 3-4 hours   |
| Standardize all into JSON                | 2-3 hours   |
| **Total**                                | ~1 full day |

---

## Context from Main Research

This is part of a 500-task benchmark for evaluating AI domain expertise in blockchain security.

**Other subsets:**

- Difficulty Stratified Canonical (existing datasets, ~150-200 samples)
- Ground Truth Gold Standard (Code4rena/Sherlock recent, ~150-200 samples)
- Adversarial Contrastive Pairs (generated variants, ~120-150 samples)

**Full research plan:** See `blockchain_ai_expertise_research_plan.md`

---

## Quick Start

1. Clone DeFiHackLabs: `git clone https://github.com/SunWeb3Sec/DeFiHackLabs`
2. Start with the top 10 exploits by amount lost
3. Find their code in DeFiHackLabs or reconstruct from writeups
4. Create JSON entries
5. Then move to variants and post-cutoff samples
