# Rebuttal for ms_tc_012 (Rari Fuse Cross-Function Reentrancy)

## Summary
**Agree** - We accept the ROOT_CAUSE duplication and PREREQ misuse concerns. Same pattern as ms_tc_010/011.

## Issue-by-Issue Response

### Issue 2.1 - CA1, CA2, CA3 (storage mappings) mislabeled as PREREQ
**Agree - UPDATED**
These are baseline accounting state, not exploit prerequisites. The exploit depends on ordering + cross-function access. Changed all to BENIGN.

### Issue 2.2 - CA6 PREREQ rationale inconsistent
**Agree - UPDATED**
This is validation logic whose ordering is violated, not a prerequisite. Changed to BENIGN.

### Issue 2.3 - CA10 mislabeled as PREREQ
**Agree - UPDATED**
This state update BEFORE the external call is actually protective - it limits same-function reentrancy. The exploit relies on cross-function manipulation (exitMarket). Changed to BENIGN.

### Issue 2.4 - ROOT_CAUSE duplication (CA11 and CA12)
**Agree - UPDATED**
CA11 (external call) and CA12 (post-call check) are one causal chain. CA12 is an effect, not an independent root cause. Changed CA12 to BENIGN.

### Issue 2.5 - CA13, CA14 misclassified as PREREQ
**Agree - UPDATED**
These are attacker actions executed during reentrancy, not prerequisites. Changed to BENIGN.

### Issue 3.2 - Cross-function nature not encoded
**Noted**
The taxonomy does not currently have explicit cross-function reentrancy markers. This is a future enhancement consideration.

## Changes Made

| Code Act | Before | After |
|----------|--------|-------|
| CA1, CA2, CA3 (mappings) | PREREQ | BENIGN |
| CA6 (market check) | PREREQ | BENIGN |
| CA9 (initial health check) | PREREQ | BENIGN |
| CA10 (borrowed update) | PREREQ | BENIGN |
| CA12 (post-call check) | ROOT_CAUSE | BENIGN |
| CA13 (debt check) | PREREQ | BENIGN |
| CA14 (inMarket=false) | PREREQ | BENIGN |
| vulnerable_lines | [68, 71] | [68] |

## Final Classification

- **ROOT_CAUSE (1)**: CA11 - external ETH call enables cross-function reentrancy (line 68)
- **PREREQ (0)**: None
- **BENIGN (15)**: All other code acts
