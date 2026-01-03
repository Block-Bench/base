# Rebuttal for ms_tc_015 (Compound TUSD Sweep)

## Summary
**Agree** - We accept the PREREQ overuse and ROOT_CAUSE duplication concerns.

## Issue-by-Issue Response

### Issue 2.1 - CA1 (underlying declaration) mislabeled as PREREQ
**Agree - UPDATED**
Variable declarations are not prerequisites. The bug is in initialization, not existence. Changed to BENIGN.

### Issue 2.2 - CA2, CA3 (constants) misclassified as PREREQ
**Agree - UPDATED**
Constants are contextual data, not exploit prerequisites. Changed to BENIGN.

### Issue 2.3 - CA5 (mint transfer) incorrectly marked PREREQ
**Agree - UPDATED**
This line does not enable or gate the exploit. Changed to BENIGN.

### Issue 2.4 - CA8 (sweep transfer) incorrectly marked PREREQ
**Agree - UPDATED**
This is the exploit payoff action, not a prerequisite. Prerequisites must exist before exploitation; this is the effect. Changed to BENIGN.

### Issue 2.5 - CA11 (redeem transfer) incorrectly marked PREREQ
**Agree - UPDATED**
Redemption logic is orthogonal to the sweep exploit. Changed to BENIGN.

### Issue 3.2 - Dual ROOT_CAUSE is logically redundant
**Agree - UPDATED**
CA4 (initialization) and CA7 (check) were both marked ROOT_CAUSE. The vulnerability is a single logical failure: `underlying` is initialized to the wrong token address. CA7's check logic is correct - it's just checking against a wrong value. Changed CA7 to BENIGN, kept CA4 as sole ROOT_CAUSE.

### Issue 1.1 - mint() uses transfer instead of transferFrom
**Noted**
This is a realism issue but does not affect the exploit demonstration.

### Issue 1.2 - sweepToken has no admin restriction
**Noted**
This inflates severity but the core exploit (wrong underlying address) is correctly demonstrated.

## Changes Made

| Code Act | Before | After |
|----------|--------|-------|
| CA1 (underlying) | PREREQ | BENIGN |
| CA2 (OLD_TUSD) | PREREQ | BENIGN |
| CA3 (NEW_TUSD) | PREREQ | BENIGN |
| CA5 (mint transfer) | PREREQ | BENIGN |
| CA7 (sweep check) | ROOT_CAUSE | BENIGN |
| CA8 (sweep transfer) | PREREQ | BENIGN |
| CA11 (redeem transfer) | PREREQ | BENIGN |
| vulnerable_lines | [39] | [25] |

## Final Classification

- **ROOT_CAUSE (1)**: CA4 - constructor initializes underlying to OLD_TUSD instead of NEW_TUSD (line 25)
- **PREREQ (0)**: None
- **BENIGN (10)**: All other code acts
