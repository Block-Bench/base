# MS_TC Todo List

## To Remove

### ms_tc_004 (Harvest Finance)
**Issue:** Contract does not actually implement the vulnerability it claims to demonstrate.
- `getTotalAssets()` returns `vaultBalance + investedBalance` where `investedBalance` is just an internal accounting variable
- No actual Curve price queries - ICurvePool interface is declared but never called
- The described flash loan oracle manipulation attack CANNOT occur with this code
- Both original (tc_004.sol) and minimalsanitized (ms_tc_004.sol) have this problem
- Wumpus correctly identified this issue

**Action:** Remove from benchmark or significantly rework to actually query Curve prices

### ms_tc_014 (Yearn yDAI Vault)
**Issue:** Contract does not actually implement the vulnerability it claims to demonstrate.
- `earn()` reads `virtualPrice` but **NEVER USES IT** - completely dead code
- `balance()` function uses `get_virtual_price()` but is **NEVER CALLED** by deposit/withdraw/earn
- Share calculations in `deposit()` and `withdrawAll()` use `totalDeposits`, not the oracle-based `balance()`
- The described oracle manipulation exploit CANNOT occur with this code
- Wumpus correctly identified this issue

**Action:** Remove from benchmark or significantly rework to actually use oracle price in share calculations

## To Review

### ms_tc_005 (Curve Vyper Reentrancy)
**Issue:** Vyper compiler bug cannot be faithfully represented in Solidity.
- The original vulnerability was a Vyper compiler bug where the reentrancy lock failed
- The contract is written in Solidity - different language, different compiler
- `_status` reentrancy guard variables are declared but never actually checked in any modifier
- This represents "missing guard" not "compiler bug" - fundamentally different vulnerability class
- Wumpus correctly identified this limitation

**Action:** Review whether this sample should be removed or reclassified as a different vulnerability type (missing reentrancy guard vs compiler bug)

### ms_tc_006 (Ronin Bridge)
**Issue:** Vulnerability is governance/infrastructure failure, not smart contract code bug.
- The Ronin hack was caused by private key compromise (Sky Mavis controlled 5/9 validators)
- `requiredSignatures = 5` is not a code vulnerability - threshold is reasonable
- Signature verification works correctly - attacker provided valid signatures
- The contract code behaves correctly; no on-chain bug exists
- However, there IS a secondary vulnerability: `addSupportedToken()` (line 168) has NO access control
- Wumpus correctly identified this is "governance failure" not "access control" in taxonomy sense

**Options:**
1. Refocus sample on CA18 (addSupportedToken missing access control) as the actual code bug
2. Remove sample since "Ronin exploit" cannot be represented as code-level vulnerability
3. Create new category for governance/infrastructure vulnerabilities

**Action:** Review and decide approach

