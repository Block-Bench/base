# Rebuttal for ms_tc_047 (PlayDapp)

## Summary
**Agree** - ROOT_CAUSE and PREREQ inflation fixed. Single ROOT_CAUSE for mint() vulnerability.

## Changes Made

| Item | Before | After |
|------|--------|-------|
| CA2 (_mint internal) | ROOT_CAUSE | BENIGN |
| CA3 (setMinter) | ROOT_CAUSE | BENIGN |
| CA4 (onlyMinter) | PREREQ | BENIGN |
| ROOT_CAUSE count | 3 | 1 |
| PREREQ count | 1 | 0 |
| BENIGN count | 4 | 7 |

## Final Classification

- **ROOT_CAUSE (1)**: CA1 - mint() with single-key protection, no supply cap
- **PREREQ (0)**: None
- **BENIGN (7)**: All other code acts

## Rationale

The vulnerability is a single invariant violation: unrestricted mint authority. CA2 (_mint) is internal implementation not externally reachable. CA3 (setMinter) is post-compromise persistence - compromised key already satisfies onlyMinter. CA4 (onlyMinter modifier) is correctly implemented; the weakness is the architectural choice to use single-key authority, captured in CA1.
