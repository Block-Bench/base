# Rebuttal for ms_tc_036 (Prisma Finance)

## Summary
**Partially Agree** - PREREQ inflation fixed. Dual ROOT_CAUSE kept (account parameter + token recipient mismatch).

## Changes Made

| Item | Before | After |
|------|--------|-------|
| CA3 (delegate check) | PREREQ | BENIGN |
| CA4 (delegate setter) | PREREQ | BENIGN |
| PREREQ count | 2 | 0 |
| BENIGN count | 4 | 6 |

## Final Classification

- **ROOT_CAUSE (2)**: CA1 (user-controlled account to openTrove), CA2 (mkUSD to msg.sender)
- **PREREQ (0)**: None
- **BENIGN (6)**: All other code acts including delegate logic

## Rationale

The delegate approval system (CA3, CA4) is a standard authorization pattern. Users approving contracts is normal behavior - the vulnerability is specifically how the zap contract misuses this delegation to separate debt assignment from token receipt. The dual ROOT_CAUSE is preserved as both the account parameter and token recipient are required for the exploit.
