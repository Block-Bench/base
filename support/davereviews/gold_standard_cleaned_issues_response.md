# Gold Standard Cleaned Issues - Response

## Summary

Reviewed Dave's audit of `dataset/gold_standard/cleaned/`. Actions taken below.

---

## Issue 1: Missing per-sample context bundle

**Dave's Finding:** `cleaned/contracts/context/` contains 0 subdirectories while `original/contracts/context/` has 17 sample-specific context directories.

**Status:** ✅ AGREED & FIXED

**Action Taken:** Copied all 17 context subdirectories from original to cleaned. Also renamed `gs_035` → `gs_034` in both locations to match the renumbering done earlier.

**Files affected:**
- `cleaned/contracts/context/gs_008/`
- `cleaned/contracts/context/gs_011/`
- `cleaned/contracts/context/gs_012/`
- `cleaned/contracts/context/gs_014/`
- `cleaned/contracts/context/gs_015/`
- `cleaned/contracts/context/gs_016/`
- `cleaned/contracts/context/gs_018/`
- `cleaned/contracts/context/gs_019/`
- `cleaned/contracts/context/gs_021/`
- `cleaned/contracts/context/gs_022/`
- `cleaned/contracts/context/gs_027/`
- `cleaned/contracts/context/gs_028/`
- `cleaned/contracts/context/gs_030/`
- `cleaned/contracts/context/gs_031/`
- `cleaned/contracts/context/gs_032/`
- `cleaned/contracts/context/gs_033/`
- `cleaned/contracts/context/gs_034/`

---

## Issue 2: vulnerable_lines is always empty (34/34)

**Dave's Finding:** All cleaned metadata files have `vulnerable_lines: []`.

**Status:** ✅ BY DESIGN - No action needed

**Reason:** This is intentional. The sanitization process removes header blocks and inline markers, which changes line numbers. The `vulnerable_lines` field is cleared to avoid incorrect line references. The transformation metadata documents this.

---

## Issue 3: Metadata identifier mismatches

**Dave's Finding:**
- gs_001, gs_004, gs_008: `vulnerable_contract` is `GovernanceHYBR` but code has `GrowthHYBR`
- gs_029: `vulnerable_function` is `executeSessionCalls` but not found in file

**Status:** ✅ AGREED & FIXED

**Note:** These were pre-existing issues in the **original** metadata, not introduced by sanitization. Fixed in both original and cleaned.

**Changes made:**

| Sample | Field | Before | After |
|--------|-------|--------|-------|
| gs_001 | vulnerable_contract | `GovernanceHYBR` | `GrowthHYBR` |
| gs_004 | vulnerable_contract | `GovernanceHYBR` | `GrowthHYBR` |
| gs_008 | vulnerable_contract | `GovernanceHYBR` | `GrowthHYBR` |
| gs_029 | vulnerable_function | `executeSessionCalls` | `execute` |

---

## Issue 4: Missing relative imports

**Dave's Finding:** All 34 samples have missing relative imports (interfaces, libraries, etc.)

**Status:** ❌ NOT A BUG - No action needed

**Reason:** This is expected behavior for gold standard samples. These are contract extracts from larger codebases (audit findings). The imports reference files from the original project structure that are not included. This does not affect the validity of the vulnerability documentation or the code samples for benchmarking purposes.

---

## Issue 5: Sanitization correctness

**Dave's Finding:** Confirmed that cleaned contracts match original after removing only:
- Vulnerability header block comment
- `// ^^^ VULNERABLE LINE ^^^` markers
- `@audit-issue ...` lines
- Whitespace normalization

**Status:** ✅ CONFIRMED CORRECT

No action needed - sanitization working as intended.

---

## Final Status

| Issue | Status |
|-------|--------|
| Missing context dirs | ✅ Fixed |
| Empty vulnerable_lines | ✅ By design |
| Metadata mismatches | ✅ Fixed (both original & cleaned) |
| Missing imports | ❌ Not a bug |
| Sanitization correctness | ✅ Confirmed |

All valid issues have been addressed.
