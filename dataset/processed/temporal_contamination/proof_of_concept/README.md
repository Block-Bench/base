# Temporal Contamination Probe - Proof of Concept

**Created:** December 15, 2024  
**Exploit:** Euler Finance Hack (March 2023)  
**Samples:** 1 original + 2 variants = 3 total

---

## Overview

This is a **proof-of-concept** for Task Two's temporal contamination dataset. It demonstrates the approach using the Euler Finance exploit as an example.

### What's Included

| File                   | Type                   | Description                                           | Lines | Difficulty |
| ---------------------- | ---------------------- | ----------------------------------------------------- | ----- | ---------- |
| `euler_original.sol`   | **Original**           | Full vulnerable lending contract with donation attack | 151   | Tier 4     |
| `euler_renamed.sol`    | **Renamed variant**    | Same vulnerability, all identifiers renamed           | 127   | Tier 4     |
| `euler_simplified.sol` | **Simplified variant** | Core vulnerability only, minimal code                 | 58    | Tier 3     |
| `euler_samples.json`   | **Metadata**           | Complete JSON entries for all 3 samples               | -     | -          |

---

## Euler Finance Hack Context

**Date:** March 13, 2023  
**Loss:** \$197M  
**Vulnerability:** Donation inflation attack

### The Vulnerability

The `donateToReserves()` function allowed users to:

1. Burn their eTokens (collateral tokens)
2. Inflate protocol reserves **without transferring underlying assets**
3. Improve health scores artificially via inflated reserves
4. Self-liquidate for profit with liquidation bonus

### Why This Is Perfect for Temporal Testing

✅ **Pre-cutoff** - Occurred March 2023, definitely in training data  
✅ **Well-documented** - Extensive coverage on security Twitter, blogs  
✅ **Clear vulnerability** - Single function causes the issue  
✅ **High-profile** - \$197M loss, widely memorized  
✅ **Good for variants** - Clean code structure for renaming/simplifying

---

## Sample Analysis

### 1. Original Version (`euler_original.sol`)

**What It Is:**

- Simplified but complete vulnerable lending protocol
- Shows donation attack in context of full lending system
- Includes deposit, borrow, repay, liquidate, donate functions
- Demonstrates how reserves affect health calculations

**Key Vulnerable Code:**

```solidity
function donateToReserves(uint256 amount) external {
    require(deposits[msg.sender] >= amount, "Insufficient balance");

    deposits[msg.sender] -= amount;
    totalDeposits -= amount;
    totalReserves += amount;  // <-- VULNERABILITY: Reserve inflation

    // No transfer of underlying tokens!
}
```

**Learning Goal:** Can AI identify the donation attack in full context?

---

### 2. Renamed Variant (`euler_renamed.sol`)

**What Changed:**

- `VulnerableLendingPool` → `DefiLiquidityVault`
- `deposits` → `collateralShares`
- `borrowed` → `debtShares`
- `totalReserves` → `protocolTreasury`
- `donateToReserves()` → `contributeToTreasury()`
- `isHealthy()` → `checkSolvency()`
- All variables and functions renamed

**What Stayed the Same:**

- Exact same logic and vulnerability
- Same attack vector
- Same root cause (reserve inflation without token transfer)

**Learning Goal:** Does AI recognize the pattern when names change?

**Test:** If model correctly identifies original but fails on renamed, it's pattern matching not reasoning.

---

### 3. Simplified Variant (`euler_simplified.sol`)

**What's Removed:**

- Repay functionality
- Withdraw functionality
- Liquidation logic
- Complex health calculations
- Token transfers
- All non-essential code

**What's Kept:**

- `deposit()` - adds balance
- `borrow()` - creates debt
- `donate()` - **THE VULNERABILITY** (inflates reserves)
- `isHealthy()` - uses inflated reserves in calculation

**Core Pattern (58 lines):**

```solidity
function donate(uint256 amount) external {
    balance[msg.sender] -= amount;
    reserves += amount;  // Inflation without transfer
}

function isHealthy(address user, uint256 newDebt) public view returns (bool) {
    uint256 effectiveCollateral = balance[user] + (reserves / 100);  // Uses inflated reserves!
    return effectiveCollateral >= (totalDebt * 3) / 2;
}
```

**Learning Goal:** Can AI identify the essence of the vulnerability without context?

**Test:** If model fails on simplified but passes on original, it needs context to identify issues.

---

## Metadata Quality Check

### ✅ All Required Fields Present

- [x] `id` (unique identifier)
- [x] `exploit_name`, `exploit_date`, `amount_lost_usd`
- [x] `temporal_category` (pre_cutoff)
- [x] `likely_in_training` (true + explanation)
- [x] `language`, `chain`, `protocol_type`
- [x] `file_name`, `vulnerable_function`, `vulnerable_lines`
- [x] `vulnerability_type`, `severity`
- [x] `description`, `fix_description`, `attack_vector`
- [x] `is_variant`, `variant_type`, `variant_parent_id`
- [x] `source_url`, `code_source`, `poc_url`
- [x] `difficulty_tier`, `context_level`, `tags`

### Variant Linking

```
temporal_euler_001 (original)
    ↓
    ├─→ temporal_euler_001_renamed
    └─→ temporal_euler_001_simplified
```

All variants properly link back to parent via `variant_parent_id`.

---

## Expected AI Model Performance

### Scenario 1: Strong Memorization

```
✓ Original:    Correctly identifies donation attack
✓ Renamed:     Correctly identifies (recognizes pattern)
✓ Simplified:  Correctly identifies (understands essence)
→ Model generalizes well
```

### Scenario 2: Surface Pattern Matching

```
✓ Original:    Correctly identifies (memorized "donateToReserves")
✗ Renamed:     Fails (doesn't recognize "contributeToTreasury")
✗ Simplified:  Fails (needs full context)
→ Model relies on memorization
```

### Scenario 3: Context-Dependent

```
✓ Original:    Correctly identifies (has full context)
✓ Renamed:     Correctly identifies (logic preserved)
✗ Simplified:  Fails (too abstract without context)
→ Model needs context but understands logic
```

### Scenario 4: Weak Understanding

```
✓ Original:    Correctly identifies (memorized)
✗ Renamed:     Fails (names changed)
✗ Simplified:  Fails (no context)
→ Pure memorization, no reasoning
```

---

## Quality Assessment

### Strengths ✅

1. **Accurate representation** - Captures real Euler vulnerability
2. **Clean variants** - Changes are systematic and verifiable
3. **Complete metadata** - All required fields present
4. **Good documentation** - Clear explanations and attack vectors
5. **Testable hypothesis** - Clear expected behaviors for different models

### Areas for Improvement ⚠️

1. **Vulnerable lines** - Could be more precise (currently approximate)
2. **Code compilation** - Not tested for actual compilation
3. **Import statements** - Uses OpenZeppelin imports that may not resolve

### Recommended Improvements

1. Test compilation with Foundry
2. Verify vulnerable line numbers are exact
3. Add more inline comments explaining each step
4. Create a fourth variant (obfuscated) if user approves

---

## Next Steps

### If Approved ✅

1. Create 9 more exploits (10 total originals)

   - Curve Finance (reentrancy)
   - Nomad Bridge (validation)
   - Wormhole (signature)
   - Beanstalk (governance)
   - Mango Markets (oracle)
   - etc.

2. Create 2 variants each (20 total variants)

   - Renamed version for each
   - Simplified version for each

3. **Total pre-cutoff dataset:** 30 samples (10 originals + 20 variants)

### If Changes Needed ⚠️

Please specify:

- Vulnerable line precision
- Code structure preferences
- Metadata format changes
- Additional variant types
- Any other improvements

---

## Files Summary

```
proof_of_concept/
├── euler_original.sol           (151 lines)
├── euler_renamed.sol            (127 lines)
├── euler_simplified.sol         (58 lines)
├── euler_samples.json           (metadata for all 3)
└── README.md                    (this file)
```

**Total:** 3 Solidity files + 1 JSON + 1 README

---

## Validation Checklist

- [x] Exploit is famous and well-documented
- [x] Date is accurate (March 13, 2023)
- [x] Amount lost is correct (\$197M)
- [x] Temporal category correct (pre_cutoff)
- [x] Vulnerability type accurate (donation_attack)
- [x] Original code captures the vulnerability
- [x] Renamed variant maintains same logic
- [x] Simplified variant preserves core issue
- [x] All variants properly linked to parent
- [x] Metadata schema compliant
- [x] Clear expected AI behaviors documented

---

## Review Questions for User

1. **Code quality:** Is the vulnerable contract code representative enough?
2. **Variant approach:** Are renamed + simplified sufficient, or add obfuscated?
3. **Metadata completeness:** Any additional fields needed?
4. **Vulnerable lines:** Should they be more precise (requires testing)?
5. **Scale approval:** Ready to proceed with 9 more exploits?

**Please review and provide feedback before I continue with the full dataset!**
