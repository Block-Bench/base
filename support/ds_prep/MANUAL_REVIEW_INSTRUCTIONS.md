# Manual Review Instructions for Difficulty-Stratified Dataset

## Overview

This document provides instructions for manually reviewing the difficulty-stratified smart contract dataset to verify:

1. **Original contracts contain the documented vulnerabilities**
2. **Cleaned contracts preserve the vulnerabilities**
3. **Cleaned contracts have no leakage** (no hints revealing vulnerability type)
4. **Cleaning is not overdone** (code logic unchanged)
5. **Contracts are correctly grouped by difficulty tier**

## Dataset Location

```
dataset/difficulty_stratified/
├── original/          # Contracts WITH vulnerability hints
│   ├── tier1/         # 87 contracts (Easy)
│   ├── tier2/         # 87 contracts (Medium)
│   ├── tier3/         # 36 contracts (Hard)
│   └── tier4/         # 14 contracts (Expert)
└── cleaned/           # Contracts WITHOUT vulnerability hints
    ├── tier1/
    ├── tier2/
    ├── tier3/
    └── tier4/
```

## Difficulty Tier Definitions

| Tier | Level | Description | Examples |
|------|-------|-------------|----------|
| 1 | Easy | Basic vulnerabilities with clear patterns | Simple reentrancy, obvious access control issues, basic integer overflow |
| 2 | Medium | Moderate complexity requiring understanding of contract interactions | DoS patterns, timestamp dependency, unchecked return values |
| 3 | Hard | Complex vulnerabilities involving multiple contracts or subtle logic | Honeypots, cross-function reentrancy, storage manipulation |
| 4 | Expert | Advanced vulnerabilities requiring deep protocol knowledge | Flash loan attacks, oracle manipulation, storage collision, signature replay |

### How Difficulty Tiers Were Assigned

**IMPORTANT:** Difficulty tiers are **NOT from the original data sources**. They were **automatically assigned by our processing scripts** using heuristics.

The original sources (SmartBugs-Curated, Not-So-Smart-Contracts, DeFiVulnLabs) do **not** provide difficulty ratings.

#### Assignment Logic by Source

**SmartBugs-Curated** (`support/dataset/scripts/process_smartbugs.py`):
- Tier 1: Simple reentrancy, basic access control (1-2 functions, <50 lines)
- Tier 2: Integer overflow, unchecked return, DoS (moderate complexity)
- Tier 3: Complex logic, multiple functions, cross-contract patterns
- Tier 4: Rarely assigned (very complex edge cases)

**Not-So-Smart-Contracts** (`support/dataset/scripts/process_not_so_smart.py`):
- Tier 1: Basic vulnerabilities with simple patterns
- Tier 2: Default for most standard vulnerabilities
- Tier 3: Honeypots, complex multi-contract scenarios
- Tier 4: Not typically assigned

**DeFiVulnLabs** (`support/dataset/scripts/process_defivulnlabs.py`):
- Tier 2: Default for standard vulnerabilities
- Tier 3: Callback, delegatecall, unsafe patterns (filename indicators)
- Tier 4: Flash loan, oracle manipulation, price manipulation (filename indicators)

#### Heuristic Factors Used

1. **Vulnerability type**: Reentrancy → easier, Oracle manipulation → harder
2. **Code complexity**: Lines of code, function count, modifier count
3. **Filename indicators**: "flash", "oracle", "callback" suggest higher difficulty
4. **Pattern type**: Single function vs. cross-function vs. cross-contract

#### Reviewer Action Required

Since tiers are heuristically assigned, **reviewers should verify and potentially adjust** tier assignments based on:

- **Detection complexity**: How hard is it to identify the vulnerability pattern?
- **Context required**: Single file vs. multi-contract understanding needed?
- **Domain knowledge**: Does it require DeFi/protocol-specific expertise?
- **Pattern clarity**: Is the vulnerability pattern obvious or obfuscated?

The tiers are NOT based on severity of impact, but on **difficulty of detection**.

### Tier Distribution by Source

| Source Dataset | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|----------------|--------|--------|--------|--------|
| smartbugs-curated | 81 | 50 | 9 | 3 |
| not-so-smart-contracts | 6 | 12 | 7 | 0 |
| DeFiVulnLabs | 0 | 25 | 20 | 11 |

---

## Review Checklist

### For Each Contract, Verify:

#### 1. Original Contains Vulnerability ✓

Open the **original** version and confirm:
- [ ] The vulnerability described in metadata actually exists in code
- [ ] The vulnerable function/lines match metadata `vulnerable_function` and `vulnerable_lines`
- [ ] The vulnerability type in metadata matches the actual vulnerability

**Location of metadata:** `original/tierN/metadata/ds_tN_XXX.json`

**Key metadata fields to check:**
```json
{
  "vulnerability_type": "reentrancy",
  "vulnerable_function": "withdraw",
  "vulnerable_lines": [18, 21],
  "description": "..."
}
```

#### 2. Cleaned Preserves Vulnerability ✓

Compare **original** vs **cleaned** version:
- [ ] The vulnerable code pattern is still present
- [ ] No functional changes to the vulnerable logic
- [ ] Same number of contracts and functions (approximately)

**Example - Reentrancy should still have:**
```solidity
// External call BEFORE state update (vulnerable pattern)
msg.sender.call.value(balance)();  // Line A
userBalance[msg.sender] = 0;       // Line B (after call = vulnerable)
```

#### 3. No Leakage in Cleaned ✓

Check cleaned version for absence of:
- [ ] Contract names containing: `Vulnerable`, `Exploit`, `Attack`, `Insecure`, `Bug`
- [ ] Variable names containing: `vulnerable_`, `attack`, `exploit`
- [ ] Comments with: `@vulnerable_at_lines`, `// <yes> <report>`, `VULNERABILITY`, `EXPLOIT`
- [ ] Documentation blocks with: `Name:`, `Description:`, `Mitigation:` (DeFiVulnLabs format)
- [ ] Challenge hints: `#spotthebug`, `immunefi`

**Acceptable in cleaned:**
- Generic names like `TokenVault`, `Ledger`, `SimpleBank`
- Normal code comments explaining logic (not vulnerability)
- String literals in revert messages (e.g., `"Transfer failed"`)

#### 4. Not Over-Sanitized ✓

Verify cleaning didn't remove too much:
- [ ] Line count difference < 50% (comments removed is OK)
- [ ] All original functions still present
- [ ] All original contracts still present
- [ ] Code logic unchanged (only names/comments changed)

#### 5. Correct Difficulty Tier ✓

Based on your security expertise, verify the tier assignment:
- [ ] Tier 1: Should be detectable by basic static analysis
- [ ] Tier 2: Requires understanding contract flow
- [ ] Tier 3: Requires multi-contract or subtle logic analysis
- [ ] Tier 4: Requires advanced DeFi/protocol knowledge

---

## Review Process

### Quick Review (Sampling)

For time-limited review, sample at least:
- 10 contracts from Tier 1
- 10 contracts from Tier 2
- 10 contracts from Tier 3
- All 14 contracts from Tier 4

### Full Review

Review all 224 contracts systematically:

```bash
# List all contracts in a tier
ls dataset/difficulty_stratified/original/tier1/contracts/

# View original and cleaned side-by-side
diff dataset/difficulty_stratified/original/tier1/contracts/ds_t1_001.sol \
     dataset/difficulty_stratified/cleaned/tier1/contracts/ds_t1_001.sol

# Check metadata
cat dataset/difficulty_stratified/original/tier1/metadata/ds_t1_001.json | python3 -m json.tool
```

---

## Common Vulnerability Patterns to Verify

### Tier 1 - Easy

| Type | What to Look For |
|------|------------------|
| Reentrancy | `call.value()` before state update |
| Integer Overflow | Arithmetic without SafeMath (Solidity <0.8) |
| Access Control | Missing `onlyOwner` or similar modifier |
| Unchecked Return | `.send()` or `.call()` without checking return |

### Tier 2 - Medium

| Type | What to Look For |
|------|------------------|
| DoS | Loops with external calls, unbounded arrays |
| Timestamp Dependency | `block.timestamp` in critical logic |
| Front-running | Predictable state changes |
| Weak Randomness | `block.timestamp`, `blockhash` for randomness |

### Tier 3 - Hard

| Type | What to Look For |
|------|------------------|
| Honeypot | Hidden logic that prevents withdrawal |
| Cross-function Reentrancy | Reentrancy across multiple functions |
| Delegatecall Issues | Storage collision, context confusion |
| Logic Errors | Subtle calculation/condition mistakes |

### Tier 4 - Expert

| Type | What to Look For |
|------|------------------|
| Oracle Manipulation | Price feed without TWAP/deviation checks |
| Flash Loan Attack | Single-transaction price manipulation |
| Storage Collision | Proxy pattern slot conflicts |
| Signature Replay | Missing nonce/chainId in signatures |

---

## Reporting Issues

If you find issues during review, document them:

```markdown
## Issue Report

**Contract:** ds_t2_015
**Issue Type:** [Leakage / Over-sanitized / Wrong tier / Missing vulnerability]
**Description:**
Contract name still contains "Vulnerable" prefix in cleaned version.

**Evidence:**
Line 5: `contract VulnerableBank {`

**Suggested Fix:**
Rename to `BasicBank` or `SimpleBank`
```

---

## Scripts for Automated Checks

The following scripts were used for automated verification (located in `support/ds_prep/`):

| Script | Purpose |
|--------|---------|
| `organize_by_tier.py` | Organizes contracts by difficulty tier |
| `rename_by_tier.py` | Applies tier-based naming (ds_t1_001, etc.) |
| `populate_cleaned.py` | Copies sanitized versions to cleaned folder |
| `verify_cleaned.py` | Automated leakage and over-sanitization check |

Run automated verification:
```bash
python3 support/ds_prep/verify_cleaned.py
```

---

## Sign-Off

After completing review, sign off:

```
Reviewer: [Name]
Date: [Date]
Contracts Reviewed: [All / Sampled (N)]
Issues Found: [None / See attached report]
Recommendation: [Approve / Needs fixes]
```
