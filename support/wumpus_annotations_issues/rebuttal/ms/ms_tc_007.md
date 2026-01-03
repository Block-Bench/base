# Rebuttal for ms_tc_007 (Poly Network)

## Summary
**Agree** - We accept the PREREQ inflation concerns and have updated the annotations.

## Issue-by-Issue Response

### Issue 2.1 - CA3 (onlyOwner) mislabeled as PREREQ
**Agree - UPDATED**
The onlyOwner modifier is correctly implemented access control. It's architectural context, not an attacker-controlled prerequisite. Changed to BENIGN.

### Issue 2.2 - CA4 (putCurEpochConPubKeyBytes) mislabeled as PREREQ
**Agree - UPDATED**
This function is the attack target, not a prerequisite. The function itself is correctly implemented. Changed to BENIGN.

### Issue 2.3 - CA11 and CA17 double-count
**Agree - UPDATED**
CA11 (call site) and CA17 (function implementation) represented the same conceptual issue. Changed CA11 to BENIGN since the call itself is correct - the issue is in the function returning an unvalidated target.

### Issue 2.4 - ROOT_CAUSE scope
**Noted**
The ROOT_CAUSE rationale already mentions "No validation that toContract is not a privileged system contract" but point taken that it could emphasize the missing allowlist more.

## Changes Made

| Code Act | Before | After |
|----------|--------|-------|
| CA3 (onlyOwner) | PREREQ | BENIGN |
| CA4 (putCurEpochConPubKeyBytes) | PREREQ | BENIGN |
| CA11 (decode call) | PREREQ | BENIGN |

## Final Classification

- **ROOT_CAUSE (1)**: CA12 - unrestricted external call (line 91)
- **PREREQ (2)**: CA7 (dataContract storage), CA17 (_decodeTx returns unvalidated target)
- **BENIGN (14)**: All other code acts
