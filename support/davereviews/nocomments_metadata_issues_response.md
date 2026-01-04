# Nocomments Metadata Issues - Response

## Summary

Reviewed Dave's audit of `dataset/temporal_contamination/nocomments/`. Actions taken below.

---

## Issue 1: README count mismatch

**Dave's Finding:** README claims 50 contracts, actually has 46.

**Status:** ✅ AGREED & FIXED

**Action:** Updated README line 7 from "50 Solidity contracts (nc_tc_001.sol - nc_tc_050.sol)" to "46 Solidity contracts (nc_tc_001.sol - nc_tc_046.sol)"

---

## Issue 2: README claims vulnerable_lines is empty

**Dave's Finding:** README says `vulnerable_lines`: "Empty (requires manual annotation)" but files have populated values.

**Status:** ✅ AGREED & FIXED

**Action:** Updated README line 63 to "Line numbers of vulnerable code"

---

## Issue 3: is_vulnerable missing in 39/46 files

**Dave's Finding:** Only nc_tc_001-007 have `is_vulnerable: true`, rest omit it.

**Status:** ✅ AGREED & FIXED

**Action:** Added `"is_vulnerable": true` to all 39 files (nc_tc_008 - nc_tc_046). All 46 files now have consistent schema.

---

## Issue 4: vulnerable_lines vs vulnerable_function mismatch (21 samples)

**Dave's Finding:** In ~21 samples, `vulnerable_lines` point to different functions than `vulnerable_function`.

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
| is_vulnerable missing | ✅ Fixed (39 files added) |
| vulnerable_lines vs function | ⚠️ By design |

All valid issues have been addressed.
