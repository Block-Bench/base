## No-comments (nocomments) metadata ↔ code alignment issues (temporal_contamination/nocomments)

### Dataset-level

- **README count mismatch**:
  - `dataset/temporal_contamination/nocomments/README.md` still claims “50 Solidity contracts (nc_tc_001.sol - nc_tc_050.sol)”.
  - Actual dataset contains `nc_tc_001`–`nc_tc_046` (46 contracts + 46 metadata), consistent with `index.json total_files: 46`.

- **README claim about `vulnerable_lines` is false**:
  - README states `vulnerable_lines`: “Empty (requires manual annotation)”.
  - `metadata/nc_tc_*.json` currently contains non-empty `vulnerable_lines` (example: `nc_tc_001` has `[15, 40]`).

---

### Systematic issues (critical)

- **Metadata schema inconsistency: `is_vulnerable` missing in 39/46 files**:
  - `nc_tc_001`–`nc_tc_007` include `is_vulnerable: true`.
  - `nc_tc_008`–`nc_tc_046` omit `is_vulnerable` entirely.
  - **Impact**: any pipeline expecting a consistent `is_vulnerable` boolean across variants will behave inconsistently for nocomments.

- **`vulnerable_lines` do not align with `vulnerable_function` in 21 samples**:
  - In these samples, at least one `vulnerable_lines` entry is inside a **different function** than the one(s) listed in `vulnerable_function`.
  - **Impact**: if `vulnerable_function` is intended to identify where the vulnerable lines live, the metadata is internally inconsistent.

#### Mismatches (sample: line → actual function, but `vulnerable_function` lists ...)

- `nc_tc_002`: LN 48–49 → `deposit`, but `vulnerable_function` is `emergencyCommit`
- `nc_tc_003`: LN 19 → `initWallet`, but `vulnerable_function` is `kill`
- `nc_tc_004`: LN 102 → `_handleETHTransfer`, but `vulnerable_function` is `add_liquidity`
- `nc_tc_010`: LN 71 → `exitMarket`, but `vulnerable_function` is `borrow`
- `nc_tc_013`: LN 55 → `_notifyTransfer`, but `vulnerable_function` is `transfer`
- `nc_tc_015`: LN 53 → `swap`, but `vulnerable_function` is `_updateWeights`
- `nc_tc_017`: LN 68 → `getLPTokenValue`, but `vulnerable_function` is `borrow`
- `nc_tc_021`: LN 33 → `getPrice`, and LN 84 → `getCollateralValue`, but `vulnerable_function` is `borrow`
- `nc_tc_024`: LN 35 → `_getPair`, but `vulnerable_function` is `swapExactTokensForTokens`
- `nc_tc_029`: LN 55 → `deposit`, and LN 136 → `rayDiv`, but `vulnerable_function` is `flashLoan`
- `nc_tc_032`: LN 86 → `withdrawExactShares`, but `vulnerable_function` is `depositExactAmount`
- `nc_tc_034`: LN 92 → `borrow`, and LN 133 → `getAssetPrice`, but `vulnerable_function` is `deposit`
- `nc_tc_035`: LN 65 → `borrow`, but `vulnerable_function` is `mint`
- `nc_tc_037`: LN 76 → `getExchangeRate`, but `vulnerable_function` is `mint`
- `nc_tc_041`: LN 75 → `claimReward`, but `vulnerable_function` is `upgradePool`
- `nc_tc_042`: LN 39 → `claimRewards`, but `vulnerable_function` is `registerMarket`
- `nc_tc_045`: LN 110 → `borrow`, but `vulnerable_function` is `previewDebt`

---

### Notes on correctness

- If `vulnerable_function` is meant to be a **single “main entrypoint”**, then some of these mismatches may be acceptable, but in that case `vulnerable_lines` should avoid listing lines in other functions (or `vulnerable_function` should be renamed to something like `entrypoint_function`).
- If `vulnerable_function` is meant to identify **where the vulnerable lines are located**, then the above samples should be corrected by either:
  - expanding `vulnerable_function` to include the functions that contain the listed lines, or
  - moving/removing `vulnerable_lines` to match the declared function(s).


