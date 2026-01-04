# Shapeshifter L3 Metadata Issues - Response

## Summary

Reviewed Dave's audit of `dataset/temporal_contamination/shapeshifter_l3/`. Actions taken below.

---

## Issue 1: README count mismatch

**Dave's Finding:** README claims 50 contracts, actually has 46.

**Status:** ✅ AGREED & FIXED

**Action:** Updated README:
- Line 7: "50 Solidity contracts" → "46 Solidity contracts"
- Line 78: "Total Samples: 50" → "Total Samples: 46"

---

## Issue 2: README claims vulnerable_lines is empty

**Dave's Finding:** README says `vulnerable_lines`: "Empty (line numbers invalid after transformation)" but files have populated values with fresh LN markers.

**Status:** ✅ AGREED & FIXED

**Action:** Updated README line 98 to "Line numbers of vulnerable code"

---

## Issue 3: index.json claims 50 samples but only 46 exist

**Dave's Finding:** `statistics.total_samples` is 50, `samples[]` lists ss_tc_047-050 which don't exist.

**Status:** ✅ AGREED & FIXED

**Action:** Updated index.json:
- `statistics.total_samples`: 50 → 46
- `statistics.vulnerable_count`: 50 → 46
- Removed non-existent samples (ss_tc_047-050) from samples array

---

## Issue 4: is_vulnerable missing in 39/46 files

**Dave's Finding:** Only ss_tc_001-007 have `is_vulnerable: true`, rest omit it.

**Status:** ✅ AGREED & FIXED

**Action:** Added `"is_vulnerable": true` to all 39 files (ss_tc_008 - ss_tc_046). All 46 files now have consistent schema.

---

## Issue 5: vulnerable_lines vs vulnerable_function mismatch (19 samples)

**Dave's Finding:** In ~19 samples, `vulnerable_lines` point to different functions than `vulnerable_function`.

**Status:** ⚠️ BY DESIGN - No action needed

**Explanation:** The `vulnerable_function` field represents the **entry point** function that an attacker would call to exploit the vulnerability. The `vulnerable_lines` field points to the actual location of the vulnerable code, which may be in a different (internal/helper) function called by the entry point.

This is intentional design:
- `vulnerable_function` = attack entry point (what attacker calls)
- `vulnerable_lines` = location of flawed code (may be in called function)

Note: In shapeshifter, both function names are obfuscated to hex style (e.g., `_0x7d6277`), but the semantic relationship is preserved from the source.

---

## Final Status

| Issue | Status |
|-------|--------|
| README count (50→46) | ✅ Fixed |
| README vulnerable_lines claim | ✅ Fixed |
| index.json total_samples | ✅ Fixed |
| index.json samples array | ✅ Fixed |
| is_vulnerable missing | ✅ Fixed (39 files added) |
| vulnerable_lines vs function | ⚠️ By design |

All valid issues have been addressed.
