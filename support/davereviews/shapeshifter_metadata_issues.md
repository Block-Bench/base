## Shapeshifter L3 metadata ↔ code alignment issues (temporal_contamination/shapeshifter_l3)

### Dataset-level

- **README count mismatch**:
  - `dataset/temporal_contamination/shapeshifter_l3/README.md` claims “50 Solidity contracts (ss_tc_001.sol - ss_tc_050.sol)”.
  - Actual folder contains `ss_tc_001`–`ss_tc_046` (46 contracts + 46 metadata).

- **README claim about `vulnerable_lines` is false**:
  - README states `vulnerable_lines`: “Empty (line numbers invalid after transformation)”.
  - `metadata/ss_tc_*.json` currently contains non-empty `vulnerable_lines` (example: `ss_tc_001` has `[9, 23]`) and the contracts embed fresh sequential `/*LN-###*/` markers.

- **`index.json` internally inconsistent with the directory contents**:
  - `statistics.total_samples` is **50**, but only **46** metadata/contract pairs exist.
  - `samples[]` lists **50** sample entries and includes `ss_tc_047`–`ss_tc_050`, but those files do not exist under `contracts/` or `metadata/`.

---

### Systematic issues (critical)

- **Metadata schema inconsistency: `is_vulnerable` missing in 39/46 files**:
  - `ss_tc_001`–`ss_tc_007` include `is_vulnerable: true`.
  - `ss_tc_008`–`ss_tc_046` omit `is_vulnerable` entirely.
  - **Impact**: pipelines expecting a consistent `is_vulnerable` boolean across variants will behave inconsistently.

- **`vulnerable_lines` do not align with `vulnerable_function` in 19 samples**:
  - In these samples, at least one `vulnerable_lines` entry is inside a **different function** than the one(s) listed in `vulnerable_function` (post-obfuscation).
  - **Impact**: if scoring or evaluation assumes `vulnerable_function` localizes the vulnerable line(s), the metadata is internally inconsistent.

#### Mismatches (sample: vulnerable_lines → actual function, but `vulnerable_function` lists ...)

- `ss_tc_002`: LN 34–35 → `_0xd6cb4d`, but `vulnerable_function` is `_0x7d6277`
- `ss_tc_003`: LN 13 → `_0x7d6277`, but `vulnerable_function` is `_0x70dd97`
- `ss_tc_004`: LN 67 → `_0x390062`, but `vulnerable_function` is `_0x7d6277`
- `ss_tc_010`: LN 49 → `_0x1045d1`, but `vulnerable_function` is `_0x0353ce`
- `ss_tc_013`: LN 36 → `_0x8cd0a4`, but `vulnerable_function` is `transfer`
- `ss_tc_015`: LN 38 → `_0x4f9b02`, but `vulnerable_function` is `_0x0cce35`
- `ss_tc_017`: LN 50 → `_0x8cd0a4`, but `vulnerable_function` is `_0xac561e`
- `ss_tc_021`: LN 24 → `_0x390062` and LN 62 → `_0x70dd97`, but `vulnerable_function` is `_0x8e4527`
- `ss_tc_023`: LN 18–20 → `_0x390062`, but `vulnerable_function` is `_0x347a3f`
- `ss_tc_024`: LN 25 → `_0x2ff8d2`, but `vulnerable_function` is `_0x390062`
- `ss_tc_029`: LN 41 → `_0xac561e` and LN 103 → `_0xae3550`, but `vulnerable_function` is `_0xd6cb4d`
- `ss_tc_030`: LN 43 → `_0x7d6277`, but `vulnerable_function` is `_0x7248ad`
- `ss_tc_032`: LN 62 → `_0x0cce35`, but `vulnerable_function` is `_0x7248ad`
- `ss_tc_034`: LN 75 → `_0x3454e7` and LN 104 → `_0x7248ad`, but `vulnerable_function` is `_0xd860ea`
- `ss_tc_035`: LN 47 → `_0xac561e`, but `vulnerable_function` is `_0xb7cc25`
- `ss_tc_037`: LN 54 → `_0x477183`, but `vulnerable_function` is `_0xac561e`
- `ss_tc_041`: LN 55 → `_0x347a3f`, but `vulnerable_function` is `_0x2c833f`
- `ss_tc_042`: LN 26 → `_0x7248ad`, but `vulnerable_function` is `_0x7d6277`
- `ss_tc_045`: LN 85 → `_0x8e4527`, but `vulnerable_function` is `_0xd80623`



