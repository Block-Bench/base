# Rebuttal for ms_tc_050 (Munchables)

## Summary
**Agree** - ROOT_CAUSE and PREREQ inflation fixed. Single ROOT_CAUSE for rogue admin fund redirection.

## Changes Made

| Item | Before | After |
|------|--------|-------|
| CA2 (emergencyUnlock) | ROOT_CAUSE | BENIGN |
| CA3 (setConfigStorage) | ROOT_CAUSE | BENIGN |
| CA4 (transferAdmin) | ROOT_CAUSE | BENIGN |
| CA5 (onlyAdmin) | PREREQ | BENIGN |
| ROOT_CAUSE count | 4 | 1 |
| PREREQ count | 1 | 0 |
| BENIGN count | 3 | 7 |

## Final Classification

- **ROOT_CAUSE (1)**: CA1 - setLockRecipient allows admin to redirect user funds without consent
- **PREREQ (0)**: None
- **BENIGN (7)**: All other code acts

## Rationale

The core invariant violated: single admin can redirect user funds without consent. CA2 (emergencyUnlock) is the impact execution path. CA3 and CA4 are latent admin capabilities not exercised in the actual attack. CA5 (onlyAdmin) is correctly implemented - the weakness is the governance design giving a single admin unilateral control over user funds.

Note: This is an insider threat/rogue developer incident. The on-chain code pattern documents centralized control risks valuable for benchmarking.
