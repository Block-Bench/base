# Rebuttal for ms_tc_009 (Kyber Swap)

## Summary
**Agree** - We accept the ROOT_CAUSE duplication and PREREQ inflation concerns.

## Issue-by-Issue Response

### Issue 2.1 - CA2 (state declarations) mislabeled as PREREQ
**Agree - UPDATED**
State variable declarations are neutral storage, not exploit-enabling prerequisites. Changed to BENIGN.

### Issue 2.2 - CA3 (liquidityNet declaration) mislabeled as PREREQ
**Agree - UPDATED**
The mapping declaration is not the vulnerability - the issue is the unchecked arithmetic. Changed to BENIGN.

### Issue 2.3 - PREREQ inflation in swap control flow
**Agree - UPDATED**
CA15, CA18, CA19, CA21, CA28 are execution mechanics, not true prerequisites. Changed to BENIGN.

### Issue 2.4 - ROOT_CAUSE duplication (CA22 call site)
**Agree - UPDATED**
CA22 is a call site to _addLiquidity - the vulnerability is inside the function (CA29, CA30), not at the call site. Changed CA22 to BENIGN.

### Issue 1.1 - Precision loss narrative
**Noted**
The contract models unchecked arithmetic rather than precision loss. This is an acceptable abstraction for minimal sanitization but should be acknowledged.

## Changes Made

| Code Act | Before | After |
|----------|--------|-------|
| CA2 (state declarations) | PREREQ | BENIGN |
| CA3 (liquidityNet declaration) | PREREQ | BENIGN |
| CA15 (while loop) | PREREQ | BENIGN |
| CA18 (tick calculation) | PREREQ | BENIGN |
| CA19 (tick condition) | PREREQ | BENIGN |
| CA21 (negation) | PREREQ | BENIGN |
| CA22 (call site) | ROOT_CAUSE | BENIGN |
| CA28 (branch selection) | PREREQ | BENIGN |
| vulnerable_lines | [128, 157, 159] | [157, 159] |

## Final Classification

- **ROOT_CAUSE (2)**: CA29 (unchecked subtraction), CA30 (unchecked addition)
- **PREREQ (3)**: CA9, CA20, CA25
- **BENIGN (28)**: All other code acts
