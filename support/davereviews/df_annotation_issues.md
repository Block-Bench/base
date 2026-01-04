## DF code-act annotation issues (temporal_contamination/differential)

### Dataset-level

- **README references non-existent samples**:
  - `dataset/temporal_contamination/differential/README.md` mentions `df_tc_048` and `df_tc_050` under “Key Fixes Applied”, but the dataset only contains `df_tc_001`–`df_tc_046` (46 triplets across `contracts/`, `metadata/`, and `code_acts_annotation/`).

---

### Systematic issues (critical)

- **Annotation YAML internal `sample_id` mismatches filename (39/46)**:
  - **Impact**: any join/validation/scoring logic that trusts `sample_id` (instead of filename) will associate annotations to the wrong contract/metadata.
  - **Mismatches (filename → YAML `sample_id`)**:
    - `df_tc_005` → `df_tc_004`
    - `df_tc_007` → `df_tc_005`
    - `df_tc_008` → `df_tc_006`
    - `df_tc_009` → `df_tc_007`
    - `df_tc_010` → `df_tc_008`
    - `df_tc_011` → `df_tc_009`
    - `df_tc_012` → `df_tc_010`
    - `df_tc_013` → `df_tc_011`
    - `df_tc_015` → `df_tc_012`
    - `df_tc_016` → `df_tc_013`
    - `df_tc_017` → `df_tc_014`
    - `df_tc_018` → `df_tc_015`
    - `df_tc_019` → `df_tc_016`
    - `df_tc_020` → `df_tc_017`
    - `df_tc_021` → `df_tc_018`
    - `df_tc_022` → `df_tc_019`
    - `df_tc_023` → `df_tc_020`
    - `df_tc_024` → `df_tc_021`
    - `df_tc_025` → `df_tc_022`
    - `df_tc_026` → `df_tc_023`
    - `df_tc_027` → `df_tc_024`
    - `df_tc_028` → `df_tc_025`
    - `df_tc_029` → `df_tc_026`
    - `df_tc_030` → `df_tc_027`
    - `df_tc_031` → `df_tc_028`
    - `df_tc_032` → `df_tc_029`
    - `df_tc_033` → `df_tc_030`
    - `df_tc_034` → `df_tc_031`
    - `df_tc_035` → `df_tc_032`
    - `df_tc_036` → `df_tc_033`
    - `df_tc_037` → `df_tc_034`
    - `df_tc_038` → `df_tc_035`
    - `df_tc_039` → `df_tc_036`
    - `df_tc_040` → `df_tc_037`
    - `df_tc_041` → `df_tc_038`
    - `df_tc_042` → `df_tc_039`
    - `df_tc_043` → `df_tc_040`
    - `df_tc_044` → `df_tc_041`
    - `df_tc_045` → `df_tc_042`

- **DF annotation schema is inconsistent with the “transition” format (44/46)**:
  - **Expected** (as used in `df_tc_001.yaml`): each `code_acts[]` entry contains both `vulnerable:{...}` and `fixed:{...}` sections, supporting explicit security-function transitions.
  - **Observed**: 44 files include one-version “fixed-only” code acts (e.g., `CA_FIX*`) that do not have `vulnerable:` sections, so transitions cannot be validated/scored consistently.
  - **Also observed**: 38 files use top-level `is_fixed` instead of `is_vulnerable`, despite `schema_version: "1.0"`.

- **Non-taxonomy Security Function value `FIX` used (38/46)**:
  - **Impact**: breaks any scorer/validator expecting taxonomy Security Functions only (`ROOT_CAUSE`, `PREREQ`, `INSUFF_GUARD`, `DECOY`, `BENIGN`, `SECONDARY_VULN`, `UNRELATED`).
  - **Where**: `df_tc_009.yaml`–`df_tc_046.yaml` (121 occurrences).

---

### File-specific issues

### df_tc_001.yaml

- **Fixed-version annotations still mark a real vulnerability**:
  - `code_act_security_functions_fixed` includes `SECONDARY_VULN` (`CA13`).
  - This makes the “fixed” sample still vulnerable per the annotation, contradicting `is_vulnerable: false` and the differential-variant expectation that `df_tc_XXX` is non-vulnerable.


