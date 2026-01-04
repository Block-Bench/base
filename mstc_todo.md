# MS_TC Todo List

## Completed

### ms_tc_004 (Harvest Finance) - REMOVED
**Date:** 2026-01-04
**Issue:** Contract does not actually implement the vulnerability it claims to demonstrate.
- `getTotalAssets()` returns `vaultBalance + investedBalance` where `investedBalance` is just an internal accounting variable
- No actual Curve price queries - ICurvePool interface is declared but never called
- Moved to `removed/` folder

### ms_tc_014 (Yearn yDAI Vault) - REMOVED
**Date:** 2026-01-04
**Issue:** Contract does not actually implement the vulnerability it claims to demonstrate.
- `earn()` reads `virtualPrice` but **NEVER USES IT** - completely dead code
- `balance()` function uses `get_virtual_price()` but is **NEVER CALLED** by deposit/withdraw/earn
- Moved to `removed/` folder

### ms_tc_005 (Curve Vyper Reentrancy) - RECLASSIFIED
**Date:** 2026-01-04
**Changes:**
- Changed vulnerability_subtype from "compiler_bug_vyper" to "cei_violation"
- Reduced ROOT_CAUSE from 2 to 1 (CA1 only)
- Changed CA2, CA4, CA5, CA9 from ROOT_CAUSE/PREREQ to BENIGN
- Updated metadata description, root_cause, attack_scenario, fix_description
- This Solidity sample now correctly represents a CEI violation, not a compiler bug

### ms_tc_006 (Ronin Bridge) - RECLASSIFIED
**Date:** 2026-01-04
**Changes:**
- Refocused from off-chain governance failure to actual code vulnerability
- Changed ROOT_CAUSE from CA1 (threshold constant) to CA18 (addSupportedToken missing access control)
- Changed vulnerable_lines from [9] to [168, 169, 170]
- Changed vulnerable_function from "withdrawERC20For" to "addSupportedToken"
- Changed CA1, CA9, CA12, CA14 from ROOT_CAUSE/PREREQ to BENIGN
- Updated metadata to describe the access control vulnerability

### ms_tc_007 (Poly Network) - PREREQ FIXED
**Date:** 2026-01-04
**Changes:**
- Changed CA7 (dataContract declaration) from PREREQ to BENIGN
- Changed CA17 (_decodeTx function) from PREREQ to BENIGN
- These were architectural facts, not prerequisites
- ROOT_CAUSE remains CA12 (unrestricted external call)

## Reviewed - No Changes Needed

After careful review, most samples mentioned by wumpus already have PREREQ: 0:
- ms_tc_011, ms_tc_012, ms_tc_013, ms_tc_016, ms_tc_017, ms_tc_018, ms_tc_019, ms_tc_020

Samples with valid PREREQs (wumpus agreed they're correct):
- ms_tc_002 (6 PREREQs)
- ms_tc_003 (3 PREREQs)
- ms_tc_008 (4 PREREQs)
- ms_tc_009 (3 PREREQs)

## Notes

- ms_tc_015 (Compound cTUSD) - Wumpus reviewed wrong file (described yEarn not Compound). Annotation is CORRECT.
- ms_tc_001 - Already fixed per wumpus rebuttal (CA1, CA2 → BENIGN, CA6 sole ROOT_CAUSE)
