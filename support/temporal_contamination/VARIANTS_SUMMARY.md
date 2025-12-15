# Euler Finance Variants - Complete Set

**Created:** December 15, 2024  
**Exploit:** Euler Finance Hack (March 13, 2023, \$197M)  
**Total Variants:** 5 (1 original + 4 variants)

---

## Complete Variant Set

| #   | ID                              | Type           | File                 | Lines | Vuln?  | Purpose                       |
| --- | ------------------------------- | -------------- | -------------------- | ----- | ------ | ----------------------------- |
| 1   | `temporal_euler_001`            | **Original**   | euler_original.sol   | 174   | ✅ YES | Baseline (full context)       |
| 2   | `temporal_euler_001_renamed`    | **Renamed**    | euler_renamed.sol    | 155   | ✅ YES | Test pattern recognition      |
| 3   | `temporal_euler_001_simplified` | **Simplified** | euler_simplified.sol | 77    | ✅ YES | Test core understanding       |
| 4   | `temporal_euler_001_obfuscated` | **Obfuscated** | euler_obfuscated.sol | 172   | ✅ YES | Test structural understanding |
| 5   | `temporal_euler_001_patched`    | **Patched**    | euler_patched.sol    | 161   | ❌ NO  | Test false positive rate      |

---

## Variant Analysis Matrix

### Expected Model Performance

| Model Quality                 | Original  | Renamed   | Simplified | Obfuscated | Patched          |
| ----------------------------- | --------- | --------- | ---------- | ---------- | ---------------- |
| **Strong (reasoning)**        | ✅ Detect | ✅ Detect | ✅ Detect  | ✅ Detect  | ✅ Safe          |
| **Medium (pattern matching)** | ✅ Detect | ⚠️ Maybe  | ✅ Detect  | ❌ Miss    | ❌ Flag (false+) |
| **Weak (memorization)**       | ✅ Detect | ❌ Miss   | ❌ Miss    | ❌ Miss    | ❌ Flag (false+) |

**Interpretation:**

- **Detects all vulnerable, safe on patched** → Strong reasoning ability
- **Misses obfuscated** → Pattern matching, not structural understanding
- **Flags patched version** → False positives, keyword matching only
- **Misses renamed** → Pure memorization of "donateToReserves" keyword

---

## Variant Details

### 1. Original Version ✅ VULNERABLE

**File:** `euler_original.sol` (174 lines)

**Vulnerable Code:**

```solidity
// Line 72-79
function donateToReserves(uint256 amount) external {
    require(deposits[msg.sender] >= amount, "Insufficient balance");

    deposits[msg.sender] -= amount;
    totalDeposits -= amount;
    totalReserves += amount;  // <-- VULNERABILITY

    // No token transfer!
}

// Line 126-137 (Health calculation)
function isHealthy(address user, uint256 additionalBorrow) internal view returns (bool) {
    uint256 collateralValue = deposits[user] + (totalReserves / 100);  // <-- Uses inflated reserves
    return collateralValue >= requiredCollateral;
}
```

**Vulnerability:** Reserve inflation without token backing affects health calculations

**Tier:** 4 (Expert) - Protocol-level understanding required

---

### 2. Renamed Variant ✅ VULNERABLE

**File:** `euler_renamed.sol` (155 lines)

**Key Changes:**

- `VulnerableLendingPool` → `DefiLiquidityVault`
- `donateToReserves()` → `contributeToTreasury()`
- `deposits` → `collateralShares`
- `totalReserves` → `protocolTreasury`
- `isHealthy()` → `checkSolvency()`
- All parameters renamed (`amount` → `qty`)

**Vulnerable Code:**

```solidity
// Line 67-73
function contributeToTreasury(uint256 qty) external {
    require(collateralShares[msg.sender] >= qty, "Insufficient shares");

    collateralShares[msg.sender] -= qty;
    aggregateCollateral -= qty;
    protocolTreasury += qty;  // <-- Same bug, different name!
}
```

**What Tests:** Surface pattern recognition vs. logical understanding

**Expected:** Strong models detect, weak models miss (keyword-dependent)

---

### 3. Simplified Variant ✅ VULNERABLE

**File:** `euler_simplified.sol` (77 lines)

**What Was Removed:**

- Token transfers (conceptual simplification)
- Repay function
- Withdraw function
- Liquidation logic
- Complex accounting

**What Remains (Core Vulnerability):**

```solidity
function donate(uint256 amount) external {
    balance[msg.sender] -= amount;
    reserves += amount;  // <-- Inflation
}

function isHealthy(address user, uint256 newDebt) public view returns (bool) {
    uint256 effectiveCollateral = balance[user] + (reserves / 100);  // <-- Uses inflated reserves
    return effectiveCollateral >= (totalDebt * 3) / 2;
}
```

**What Tests:** Can identify vulnerability essence without full context

**Expected:** Good models detect, context-dependent models may struggle

---

### 4. Obfuscated Variant ✅ VULNERABLE

**File:** `euler_obfuscated.sol` (172 lines)

**Obfuscation Techniques:**

1. Switch-case structure instead of individual functions
2. Operation codes (`OP_CONTRIBUTE = 2`) instead of descriptive names
3. Generic `adjustPosition()` instead of `donate()`
4. Underscore prefixes (`_pool`, `_ledger`)
5. int256 casting to hide logic
6. Batch operation support for complexity

**Vulnerable Code (Hidden in Mode 2):**

```solidity
// Line 45-50
} else if (mode == OP_CONTRIBUTE) {
    require(_ledger[who] >= uint256(delta), "Insufficient balance");
    _ledger[who] -= uint256(delta);
    _pool += uint256(delta);  // <-- VULNERABILITY buried in switch case
    return true;
}

// Line 88-93 (Uses _pool)
function _checkRatio(address who, uint256 additionalDebt) private view returns (bool) {
    uint256 effectiveCollateral = _ledger[who] + (_pool / 100);  // <-- Same pattern
    return effectiveCollateral >= required;
}
```

**What Tests:** Deep structural understanding vs pattern matching

**Expected:** Only strongest models detect, most will miss due to obfuscation

**This is the hardest test!**

---

### 5. Patched Variant ❌ NOT VULNERABLE

**File:** `euler_patched.sol` (161 lines)

**What Was Fixed (Single Line Change):**

```solidity
// BEFORE (vulnerable):
uint256 collateralValue = deposits[user] + (totalReserves / 100);

// AFTER (fixed):
uint256 collateralValue = deposits[user];  // <-- totalReserves removed!
```

**Critical Note:** `donateToReserves()` function **still exists!**

```solidity
// Line 57-63 - Still present but harmless
function donateToReserves(uint256 amount) external {
    require(deposits[msg.sender] >= amount, "Insufficient balance");

    deposits[msg.sender] -= amount;
    totalDeposits -= amount;
    totalReserves += amount;  // Can still be inflated

    // But totalReserves no longer affects health!
}
```

**What Tests:** False positive rate and root cause understanding

**Expected Behavior:**

- ✅ **Good model:** Does NOT flag (understands the fix)
- ❌ **Bad model:** Flags as vulnerable (keyword matching on "donateToReserves")

**This tests if models understand:**

- The ROOT CAUSE (reserves in health calc) vs SYMPTOM (donate function exists)
- Whether they can differentiate fixed vs vulnerable code
- If they generate false positives on suspicious-looking but safe code

---

## Evaluation Rubric

### Scoring Matrix

| Variant    | Detection Expected | Points if Correct | Points if Wrong       |
| ---------- | ------------------ | ----------------- | --------------------- |
| Original   | ✅ Should detect   | +10               | -10 (missed)          |
| Renamed    | ✅ Should detect   | +15               | -5 (missed)           |
| Simplified | ✅ Should detect   | +10               | -5 (missed)           |
| Obfuscated | ✅ Should detect   | +20               | -0 (acceptable miss)  |
| Patched    | ❌ Should NOT flag | +15               | -15 (false positive!) |

**Maximum Score:** 70 points  
**Passing Score:** 50+ points (71%)

### Model Classification

- **65-70 points:** Excellent (true reasoning)
- **50-64 points:** Good (pattern recognition + some reasoning)
- **35-49 points:** Fair (mostly pattern matching)
- **< 35 points:** Poor (memorization or false positives)

---

## What This Dataset Enables

### 1. Memorization vs. Reasoning

```
If model scores:
  Original: ✅ (10 pts)
  Renamed:  ❌ (0 pts)
  → Likely memorized "donateToReserves" keyword
```

### 2. Pattern Recognition Depth

```
If model scores:
  Original:   ✅ (10 pts)
  Renamed:    ✅ (15 pts)
  Obfuscated: ❌ (0 pts)
  → Recognizes surface patterns but not structure
```

### 3. False Positive Rate

```
If model scores:
  Original: ✅ (10 pts)
  Patched:  ❌ Flags as vulnerable (-15 pts)
  → Generates false positives, doesn't understand root cause
```

### 4. Context Dependency

```
If model scores:
  Original:   ✅ (10 pts)
  Simplified: ❌ (0 pts)
  → Needs full context to identify vulnerabilities
```

---

## Metadata Quality Checklist

### All 5 Variants Have:

- [x] Unique IDs with proper naming convention
- [x] Temporal category (pre_cutoff)
- [x] Accurate date (2023-03-13)
- [x] Amount lost (\$197M)
- [x] Vulnerability type (donation_attack)
- [x] Severity ratings
- [x] Vulnerable function identification
- [x] Vulnerable line numbers
- [x] Descriptions explaining the vulnerability
- [x] Fix descriptions
- [x] Attack vectors
- [x] Variant metadata (`is_variant`, `variant_type`, `variant_parent_id`)
- [x] Source URLs and references
- [x] Difficulty tiers
- [x] Tags
- [x] **file_content field** (next step: add inline)

### Special Notes:

**Simplified variant:**

- Added note: "Conceptual simplification - omits actual token transfers"
- Adjusted difficulty: Tier 3 (down from 4)
- Added "conceptual" tag

**Patched variant:**

- `is_vulnerable: false`
- `severity: "none"`
- `vulnerable_function: null`
- Purpose clearly documented

---

## Next Steps

1. ✅ Add `file_content` inline to JSON (in progress)
2. ⚠️ User review and approval
3. ⚠️ If approved, create 9 more exploit originals
4. ⚠️ Create variants for each (18 more variants)
5. ⚠️ Total pre-cutoff dataset: 30-50 samples

---

## Files Created

```
proof_of_concept/
├── euler_original.sol       ✅ (174 lines)
├── euler_renamed.sol        ✅ (155 lines)
├── euler_simplified.sol     ✅ (77 lines)
├── euler_obfuscated.sol     ✅ NEW! (172 lines)
├── euler_patched.sol        ✅ NEW! (161 lines)
├── euler_samples.json       ⚠️  (needs file_content added)
└── README.md                ✅ (documentation)
```

**Status:** All Solidity files complete, JSON metadata needs file_content field
