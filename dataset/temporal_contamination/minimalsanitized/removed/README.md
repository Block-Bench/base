# Removed Samples

These samples were removed from the minimalsanitized benchmark due to fundamental issues with their implementation.

## ms_tc_004 (Harvest Finance)
**Removal Date:** 2026-01-04
**Issue:** Contract does not implement the vulnerability it claims to demonstrate.
- `getTotalAssets()` returns `vaultBalance + investedBalance` where `investedBalance` is just an internal accounting variable
- No actual Curve price queries - ICurvePool interface is declared but never called
- The described flash loan oracle manipulation attack CANNOT occur with this code
- Confirmed by both internal review and external reviewer (wumpus)

## ms_tc_014 (Yearn yDAI Vault)
**Removal Date:** 2026-01-04
**Issue:** Contract does not implement the vulnerability it claims to demonstrate.
- `earn()` reads `virtualPrice` but NEVER USES IT - completely dead code
- `balance()` function uses `get_virtual_price()` but is NEVER CALLED by deposit/withdraw/earn
- Share calculations in `deposit()` and `withdrawAll()` use `totalDeposits`, not the oracle-based `balance()`
- The described oracle manipulation exploit CANNOT occur with this code
- Confirmed by both internal review and external reviewer (wumpus)
