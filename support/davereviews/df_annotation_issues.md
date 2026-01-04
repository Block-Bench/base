## DF code-act annotation issues (temporal_contamination/differential)

### Dataset-level

- **README count mismatch**:
  - `dataset/temporal_contamination/differential/index.json` reports `total_files: 46` and there are 46 `df_tc_*.{sol,json,yaml}` triplets.
  - `dataset/temporal_contamination/differential/README.md` still states **“Total files: 50”**.

---

### Systematic issue: `base_sample_id` is wrong for most DF annotations

**Impact:** Many `df_tc_XXX.yaml` files reference the wrong `ms_tc_YYY` base sample. This breaks the “compare to vulnerable base” linkage and makes the `vulnerable:` sections (where present) inconsistent with both DF metadata (`variant_parent_id`) and the actual MS contracts/metadata.

**Observed:** 43/46 DF annotation files have a `base_sample_id` whose MS metadata `variant_parent_id` does **not** match the DF metadata `variant_parent_id`.

**Expected rule:** For each DF sample with metadata `variant_parent_id: tc_XXX`, `base_sample_id` should be the MS sample whose metadata has the same `variant_parent_id: tc_XXX`.

#### Mismatches (DF → current base → expected base)

- `df_tc_004`: `ms_tc_005` → `ms_tc_004`
- `df_tc_005`: `ms_tc_007` → `ms_tc_005`
- `df_tc_006`: `ms_tc_008` → `ms_tc_006`
- `df_tc_007`: `ms_tc_009` → `ms_tc_007`
- `df_tc_008`: `ms_tc_010` → `ms_tc_008`
- `df_tc_009`: `ms_tc_011` → `ms_tc_009`
- `df_tc_010`: `ms_tc_012` → `ms_tc_010`
- `df_tc_011`: `ms_tc_013` → `ms_tc_011`
- `df_tc_012`: `ms_tc_015` → `ms_tc_012`
- `df_tc_013`: `ms_tc_016` → `ms_tc_013`
- `df_tc_014`: `ms_tc_017` → `ms_tc_014`
- `df_tc_015`: `ms_tc_018` → `ms_tc_015`
- `df_tc_016`: `ms_tc_019` → `ms_tc_016`
- `df_tc_017`: `ms_tc_020` → `ms_tc_017`
- `df_tc_018`: `ms_tc_021` → `ms_tc_018`
- `df_tc_019`: `ms_tc_022` → `ms_tc_019`
- `df_tc_020`: `ms_tc_023` → `ms_tc_020`
- `df_tc_021`: `ms_tc_024` → `ms_tc_021`
- `df_tc_022`: `ms_tc_025` → `ms_tc_022`
- `df_tc_023`: `ms_tc_026` → `ms_tc_023`
- `df_tc_024`: `ms_tc_027` → `ms_tc_024`
- `df_tc_025`: `ms_tc_028` → `ms_tc_025`
- `df_tc_026`: `ms_tc_029` → `ms_tc_026`
- `df_tc_027`: `ms_tc_030` → `ms_tc_027`
- `df_tc_028`: `ms_tc_031` → `ms_tc_028`
- `df_tc_029`: `ms_tc_032` → `ms_tc_029`
- `df_tc_030`: `ms_tc_033` → `ms_tc_030`
- `df_tc_031`: `ms_tc_034` → `ms_tc_031`
- `df_tc_032`: `ms_tc_035` → `ms_tc_032`
- `df_tc_033`: `ms_tc_036` → `ms_tc_033`
- `df_tc_034`: `ms_tc_037` → `ms_tc_034`
- `df_tc_035`: `ms_tc_038` → `ms_tc_035`
- `df_tc_036`: `ms_tc_039` → `ms_tc_036`
- `df_tc_037`: `ms_tc_040` → `ms_tc_037`
- `df_tc_038`: `ms_tc_041` → `ms_tc_038`
- `df_tc_039`: `ms_tc_042` → `ms_tc_039`
- `df_tc_040`: `ms_tc_043` → `ms_tc_040`
- `df_tc_041`: `ms_tc_044` → `ms_tc_041`
- `df_tc_042`: `ms_tc_045` → `ms_tc_042`
- `df_tc_043`: `ms_tc_047` → `ms_tc_043`
- `df_tc_044`: `ms_tc_048` → `ms_tc_044`
- `df_tc_045`: `ms_tc_049` → `ms_tc_045`
- `df_tc_046`: `ms_tc_050` → `ms_tc_046`

---

### File-specific issues

### df_tc_001.yaml

- **Fixed-version annotations still mark a real vulnerability**:
  - `code_act_security_functions_fixed` includes `SECONDARY_VULN` (`CA13`).
  - This means the “fixed” contract is still considered vulnerable, contradicting the differential variant expectation that `df_tc_XXX` should be non-vulnerable.

### df_tc_004.yaml / df_tc_005.yaml / df_tc_006.yaml / df_tc_007.yaml / df_tc_008.yaml

- **`fixed.file` references the wrong DF contract filename**:
  - `df_tc_004.yaml` uses `fixed.file: df_tc_005.sol`
  - `df_tc_005.yaml` uses `fixed.file: df_tc_007.sol`
  - `df_tc_006.yaml` uses `fixed.file: df_tc_008.sol`
  - `df_tc_007.yaml` uses `fixed.file: df_tc_009.sol`
  - `df_tc_008.yaml` uses `fixed.file: df_tc_010.sol`
  - Expected: each should reference its own contract file (`fixed.file: df_tc_XXX.sol`).


