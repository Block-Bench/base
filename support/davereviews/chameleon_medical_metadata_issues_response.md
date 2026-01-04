# Chameleon Medical Metadata Issues - Response

## Summary

Reviewed Dave's audit of `dataset/temporal_contamination/chameleon_medical/`. Actions taken below.

---

## Issue 1: README count mismatch

**Dave's Finding:** README claims 50 contracts, actually has 46.

**Status:** ✅ AGREED & FIXED

**Action:** Updated README line 7 from "50 Solidity contracts (ch_medical_tc_001.sol - ch_medical_tc_050.sol)" to "46 Solidity contracts (ch_medical_tc_001.sol - ch_medical_tc_046.sol)"

---

## Issue 2: README claims vulnerable_lines is empty

**Dave's Finding:** README says `vulnerable_lines`: "Empty (requires manual annotation)" but files have populated values.

**Status:** ✅ AGREED & FIXED

**Action:** Updated README line 62 to "Line numbers of vulnerable code"

---

## Issue 3: is_vulnerable missing in 39/46 files

**Dave's Finding:** Only ch_medical_tc_001-007 have `is_vulnerable: true`, rest omit it.

**Status:** ✅ AGREED & FIXED

**Action:** Added `"is_vulnerable": true` to all 39 files (ch_medical_tc_008 - ch_medical_tc_046). All 46 files now have consistent schema.

---

## Issue 4: .length renamed to .duration (CRITICAL)

**Dave's Finding:** Solidity built-in `.length` was incorrectly renamed to `.duration`, breaking compilation.

**Status:** ✅ AGREED & FIXED (CRITICAL)

**Affected files (8):**
- ch_medical_tc_001.sol
- ch_medical_tc_003.sol
- ch_medical_tc_006.sol
- ch_medical_tc_014.sol
- ch_medical_tc_015.sol
- ch_medical_tc_024.sol
- ch_medical_tc_035.sol
- ch_medical_tc_042.sol

**Action:** Replaced all `.duration` with `.length` in these 8 files. Verified 0 occurrences remain.

**Root cause:** The chameleon transformation incorrectly treated `.length` as a user-defined identifier instead of a Solidity built-in.

---

## Issue 5: vulnerable_lines vs vulnerable_function mismatch (20 samples)

**Dave's Finding:** In ~20 samples, `vulnerable_lines` point to different functions than `vulnerable_function`.

**Status:** ⚠️ BY DESIGN - No action needed

**Explanation:** The `vulnerable_function` field represents the **entry point** function that an attacker would call to exploit the vulnerability. The `vulnerable_lines` field points to the actual location of the vulnerable code, which may be in a different (internal/helper) function called by the entry point.

This is intentional design:
- `vulnerable_function` = attack entry point (what attacker calls)
- `vulnerable_lines` = location of flawed code (may be in called function)

Example: `nc_tc_002` - entry point is `emergencyCommit` but the vulnerable code is in `deposit` which is called internally.

---

## Final Status

| Issue | Status |
|-------|--------|
| README count (50→46) | ✅ Fixed |
| README vulnerable_lines claim | ✅ Fixed |
| is_vulnerable missing | ✅ Fixed (all 46 files) |
| .duration bug (critical) | ✅ Fixed (8 files) |
| vulnerable_lines vs function | ⚠️ By design |

All valid issues have been addressed.
