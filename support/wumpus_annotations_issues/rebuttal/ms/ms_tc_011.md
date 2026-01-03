# Rebuttal for ms_tc_011 (Lendf.Me ERC-777)

## Summary
**Agree** - We accept the ROOT_CAUSE duplication and PREREQ misuse concerns. Same pattern as ms_tc_010.

## Issue-by-Issue Response

### Issue 2.1 - CA1 (supplied mapping) mislabeled as PREREQ
**Agree - UPDATED**
Balance storage is architectural, not an exploit prerequisite. The vulnerability is ordering, not existence of storage. Changed to BENIGN.

### Issue 2.2 - CA5, CA6, CA8 misclassified as PREREQ
**Agree - UPDATED**
These are consequences of missing state update, not exploit prerequisites. The reentrancy would succeed even without local caching. Changed all to BENIGN.

### Issue 2.3 - ROOT_CAUSE duplication (CA9 and CA10)
**Agree - UPDATED**
CA9 (external call) and CA10 (state update) represent one CEI violation. The external call before state update (CA9) is the root cause. CA10 is correct code in wrong position. Changed CA10 to BENIGN.

### Issue 3.3 - ERC-777 specificity
**Noted**
The taxonomy does not currently distinguish ETH call vs ERC-777 hook-triggering transfer. This is a future enhancement consideration.

## Changes Made

| Code Act | Before | After |
|----------|--------|-------|
| CA1 (supplied mapping) | PREREQ | BENIGN |
| CA5 (balance cache) | PREREQ | BENIGN |
| CA6 (balance check) | PREREQ | BENIGN |
| CA8 (insufficient check) | PREREQ | BENIGN |
| CA10 (state update) | ROOT_CAUSE | BENIGN |
| vulnerable_lines | [68, 71] | [68] |

## Final Classification

- **ROOT_CAUSE (1)**: CA9 - ERC-777 transfer before state update (line 68)
- **PREREQ (0)**: None
- **BENIGN (11)**: All other code acts
