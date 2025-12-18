# Single-File Gold Standard Samples

## Overview

**Total single-file samples**: 18 out of 34 gold standard samples (53%)

These samples can be evaluated from the main contract alone without requiring context files. The vulnerabilities are contained within a single contract and do not depend on understanding external dependencies or multi-contract interactions.

---

## Sample List

| ID | Contract | Function | Vuln Type | Severity | Lines | Source |
|----|----------|----------|-----------|----------|-------|--------|
| gs_001 | GrowthHYBR | deposit | logic_error | high | 8 lines | spearbit |
| gs_002 | CLFactory | getSwapFee | logic_error | medium | 14 lines | spearbit |
| gs_003 | GaugeV2 | emergencyWithdraw | logic_error | medium | 12 lines | spearbit |
| gs_004 | GrowthHYBR | deposit | logic_error | medium | 20 lines | spearbit |
| gs_005 | VoterV3 | poke | dos | medium | 4 lines | spearbit |
| gs_006 | GaugeCL | notifyRewardAmount | logic_error | medium | 1 line | spearbit |
| gs_007 | GaugeCL | _claimFees | logic_error | medium | 32 lines | spearbit |
| gs_009 | VotingEscrow | _checkpoint | logic_error | medium | 1 line | spearbit |
| gs_013 | LockManagerERC20 | _doLockTransfer | unchecked_return | medium | 6 lines | spearbit |
| gs_014 | LockManagerERC20 | _incomingTokenBalance | logic_error | medium | 3 lines | spearbit |
| gs_017 | MinVotingPowerCondition | isGranted | logic_error | medium | 13 lines | spearbit |
| gs_020 | MidasRedemptionVaultAdapter | withdrawPhantomToken | input_validation | medium | 5 lines | mixbytes |
| gs_023 | LiquidityBuffer | updatePositionManager | logic_error | medium | 48 lines | mixbytes |
| gs_024 | LiquidityBuffer | getControlledBalance | logic_error | medium | 42 lines | mixbytes |
| gs_025 | Staking | unstakeRequestWithPermit | front_running | medium | 11 lines | mixbytes |
| gs_026 | PositionManager | emergencyTokenTransfer | access_control | medium | 10 lines | mixbytes |
| gs_029 | BaseSig | recover | access_control | high | 37 lines | code4rena |
| gs_034 | Factory | deploy | dos | medium | 9 lines | code4rena |

---

## Vulnerability Type Distribution

| Type | Count | Samples |
|------|-------|---------|
| **logic_error** | 10 | gs_001, gs_002, gs_003, gs_004, gs_006, gs_007, gs_009, gs_014, gs_017, gs_023, gs_024 |
| **dos** | 2 | gs_005, gs_034 |
| **access_control** | 2 | gs_026, gs_029 |
| **unchecked_return** | 1 | gs_013 |
| **input_validation** | 1 | gs_020 |
| **front_running** | 1 | gs_025 |

---

## Source Distribution

| Source | Count | Samples |
|--------|-------|---------|
| **spearbit** | 11 | gs_001, gs_002, gs_003, gs_004, gs_005, gs_006, gs_007, gs_009, gs_013, gs_014, gs_017 |
| **mixbytes** | 5 | gs_020, gs_023, gs_024, gs_025, gs_026 |
| **code4rena** | 2 | gs_029, gs_034 |

---

## Severity Distribution

| Severity | Count | Samples |
|----------|-------|---------|
| **high** | 2 | gs_001, gs_029 |
| **medium** | 16 | All others |

---

## Verification Status

✅ **All 18 BASE samples verified:**
- Contract files exist and are valid Solidity
- Contract names match actual code
- Function names exist in contracts
- Line numbers are within bounds
- No leaky vulnerability hints found
- Ground truth metadata is accurate

✅ **All 18 SANITIZED samples verified:**
- All sanitized contracts exist
- All contract names match base metadata
- All function names preserved correctly
- All line numbers match exactly (no offset)
- All vulnerabilities still present in code
- All ground truth preserved from base

### Metadata Fixes Applied

Fixed contract name mismatches:
- **gs_001**: Changed "GovernanceHYBR" → "GrowthHYBR" ✅
- **gs_004**: Changed "GovernanceHYBR" → "GrowthHYBR" ✅
- Both base and sanitized updated

### Sanitization Changes

**6 samples unchanged** (no leaky hints): gs_013, gs_014, gs_017, gs_020, gs_029, gs_034

**12 samples sanitized**: gs_001, gs_002, gs_003, gs_004, gs_005, gs_006, gs_007, gs_009, gs_023, gs_024, gs_025, gs_026
- Removed extra whitespace
- Removed 1 comment hint (gs_002)
- All changes non-functional (vulnerabilities preserved)

---

## Key Characteristics

### Contract Sizes
- **Smallest vulnerable range**: gs_006, gs_009 (1 line each)
- **Largest vulnerable range**: gs_023 (48 lines)
- **Average vulnerable range**: ~15 lines

### Complexity
- All bugs are self-contained within single files
- No external contract dependencies needed for understanding
- Suitable for evaluating models on isolated vulnerability patterns

### Vulnerability Patterns
1. **Calculation errors** (gs_001, gs_002, gs_004, gs_024)
2. **Missing validations** (gs_006, gs_020)
3. **State management issues** (gs_003, gs_009)
4. **DoS vulnerabilities** (gs_005, gs_034)
5. **Access control flaws** (gs_026, gs_029)

---

## Evaluation Guidelines

### For Model Evaluation:
1. Provide only the main contract file (no context needed)
2. Ask model to identify vulnerabilities
3. Compare findings against ground truth metadata
4. These samples test ability to spot bugs without multi-contract context

### Expected Difficulty:
- **Easier**: Single-line bugs (gs_006, gs_009)
- **Medium**: Standard logic errors (most samples)
- **Harder**: Complex state management (gs_023, gs_024)

---

## Files Location

- **Contracts**: `data/base/contracts/gs_XXX.sol`
- **Metadata**: `data/base/metadata/gs_XXX.json`
- **Sanitized**: `data/sanitized/contracts/sn_gs_XXX.sol`

---

## Notes

- These 18 samples complement the 16 multi-file samples that require context
- All samples are from professional security audits (Spearbit, Mixbytes, Code4rena)
- Represent real vulnerabilities found in production code
- No artificial or synthetic vulnerabilities

---

**Last Updated**: 2025-12-18
**Verification Status**: ✅ All samples validated
