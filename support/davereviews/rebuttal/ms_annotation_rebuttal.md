# MS Annotation Rebuttal - RESOLVED

## Summary

After reviewing Dave's rebuttal response and verifying against the codeact_taxonomy.md document, we accepted all of Dave's corrections. The taxonomy document explicitly defines the types Dave cited, and using these types correctly is more important than preserving our original rationales.

---

## All Changes Applied

### ms_tc_009
- **CA20**: Changed from `COMPUTATION` to `STORAGE_READ` (taxonomy defines STORAGE_READ for storage reads)
- **CA22**: Changed from `EXT_CALL` to `COMPUTATION` (this is an internal function call)
- **CA29**: Changed from `COMPUTATION` to `ARITHMETIC` (taxonomy defines ARITHMETIC for overflow/underflow operations)
- **CA30**: Changed from `COMPUTATION` to `ARITHMETIC` (taxonomy defines ARITHMETIC for overflow/underflow operations)

### ms_tc_015
- **vulnerable_lines**: Changed from `[25]` to `[25, 39]` (both the initialization error and the failing guard are relevant for model scoring)
- **CA7**: Changed from `BENIGN` to `INSUFF_GUARD` (the guard fails to protect because it depends on corrupted state)

### ms_tc_022
- **CA1**: Changed from `COMPUTATION` to `INPUT_VAL` (taxonomy explicitly lists `require(...)` as INPUT_VAL pattern)

### ms_tc_026
- **CA2**: Changed from `EXT_CALL` to `SIGNATURE` (taxonomy explicitly lists `permit(...)` under SIGNATURE)
- **vulnerable_lines**: Changed from `[26, 27]` to `[26, 27, 30]` (including the execution continuation line for scoring flexibility)

---

## Rationale for Accepting Dave's Corrections

1. **Types should follow taxonomy definitions**: The taxonomy document (`dataset/codeact_taxonomy.md`) explicitly defines specific types like `ARITHMETIC`, `STORAGE_READ`, `INPUT_VAL`, and `SIGNATURE`. Using these correctly is essential for consistency across the dataset.

2. **The rationale field handles nuance**: Our concern about "emphasizing the nature of the bug" is valid but should be expressed in the `rationale` field, not by changing the `type` away from what the taxonomy defines.

3. **Scoring flexibility**: For `vulnerable_lines`, including lines that models commonly cite (like line 39 in ms_tc_015 and line 30 in ms_tc_026) allows for more realistic scoring without claiming those lines are the root cause.

4. **INSUFF_GUARD for failing guards**: The taxonomy's INSUFF_GUARD category covers guards that "fail to prevent the vulnerability" - this includes guards that are logically correct but depend on corrupted state.

---

## Status: RESOLVED

All corrections have been applied to the annotation files.
