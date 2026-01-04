# Rebuttal for ms_tc_024 (Curve Price Oracle Manipulation)

## Summary
**Proactive Fix** - Wumpus found no material issues, but PREREQ inflation was present. Applied consistent taxonomy.

## Changes Made

Wumpus approved this annotation but we applied the same consistent taxonomy as other samples:

| Item | Before | After |
|------|--------|-------|
| CA1 (curvePool declaration) | PREREQ | BENIGN |
| CA6 (oracle/token addresses) | PREREQ | BENIGN |
| CA11 (getCollateralValue call) | PREREQ | BENIGN |
| CA12 (maxBorrow calculation) | PREREQ | BENIGN |
| CA13 (borrow limit check) | PREREQ | BENIGN |
| CA18 (collateral value calc) | PREREQ | BENIGN |
| PREREQ count | 6 | 0 |
| BENIGN count | 10 | 16 |

## Rationale

1. **Storage declarations (CA1, CA6)**: Storage variable existence is not a prerequisite to exploitation
2. **Call sites (CA11)**: Calling a function that uses vulnerable data is not the vulnerability
3. **Downstream computations (CA12, CA13, CA18)**: These consume tainted oracle values but are correctly implemented

## Final Classification

- **ROOT_CAUSE (2)**: CA3 (oracle returns manipulable virtual_price), CA17 (lending protocol fetches from manipulable oracle)
- **PREREQ (0)**: None
- **BENIGN (16)**: All other code acts

## Note on Dual ROOT_CAUSE

The dual ROOT_CAUSE is appropriate here because:
- CA3: Oracle definition is flawed (returns virtual_price directly without TWAP)
- CA17: Lending protocol trusts the oracle without manipulation checks

These are two distinct but related vulnerability points in separate contracts.
