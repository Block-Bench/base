## TR (trojan) code-act annotation issues (temporal_contamination/trojan)

### Dataset-level

- **README total files mismatch**:
  - `dataset/temporal_contamination/trojan/index.json` reports `total_files: 46`, and the folder contains `tr_tc_001`–`tr_tc_046` triplets across `contracts/`, `metadata/`, and `code_acts_annotation/`.
  - `dataset/temporal_contamination/trojan/README.md` still states **“Total files: 50”**.

---

### Systematic issue: `base_sample_id` linkage is broken (43/46 files)

**Expected rule:** for each `tr_tc_XXX`, `base_sample_id` should be the MS sample whose metadata has the same `variant_parent_id: tc_XXX` (i.e., typically `ms_tc_XXX`).

**Observed:**
- **39/46** TR YAMLs point to an MS sample with a **different** `variant_parent_id` than the TR metadata (wrong base pairing).
- **4/46** TR YAMLs reference **non-existent** MS samples (`ms_tc_047`–`ms_tc_050`), even though MS is now `ms_tc_001`–`ms_tc_046`.

**Impact:** This breaks the canonical “trojan → base vulnerability” join. Any evaluator that expects `base_sample_id` to identify the underlying vulnerability annotation will compare against the wrong MS sample or fail to load.

#### Missing base samples
- `tr_tc_043`: `base_sample_id: ms_tc_047` (expected `ms_tc_043`)
- `tr_tc_044`: `base_sample_id: ms_tc_048` (expected `ms_tc_044`)
- `tr_tc_045`: `base_sample_id: ms_tc_049` (expected `ms_tc_045`)
- `tr_tc_046`: `base_sample_id: ms_tc_050` (expected `ms_tc_046`)

#### Parent mismatches (TR → current base → expected base)
- `tr_tc_004`: `ms_tc_005` → `ms_tc_004`
- `tr_tc_005`: `ms_tc_007` → `ms_tc_005`
- `tr_tc_006`: `ms_tc_008` → `ms_tc_006`
- `tr_tc_007`: `ms_tc_009` → `ms_tc_007`
- `tr_tc_008`: `ms_tc_010` → `ms_tc_008`
- `tr_tc_009`: `ms_tc_011` → `ms_tc_009`
- `tr_tc_010`: `ms_tc_012` → `ms_tc_010`
- `tr_tc_011`: `ms_tc_013` → `ms_tc_011`
- `tr_tc_012`: `ms_tc_015` → `ms_tc_012`
- `tr_tc_013`: `ms_tc_016` → `ms_tc_013`
- `tr_tc_014`: `ms_tc_017` → `ms_tc_014`
- `tr_tc_015`: `ms_tc_018` → `ms_tc_015`
- `tr_tc_016`: `ms_tc_019` → `ms_tc_016`
- `tr_tc_017`: `ms_tc_020` → `ms_tc_017`
- `tr_tc_018`: `ms_tc_021` → `ms_tc_018`
- `tr_tc_019`: `ms_tc_022` → `ms_tc_019`
- `tr_tc_020`: `ms_tc_023` → `ms_tc_020`
- `tr_tc_021`: `ms_tc_024` → `ms_tc_021`
- `tr_tc_022`: `ms_tc_025` → `ms_tc_022`
- `tr_tc_023`: `ms_tc_026` → `ms_tc_023`
- `tr_tc_024`: `ms_tc_027` → `ms_tc_024`
- `tr_tc_025`: `ms_tc_028` → `ms_tc_025`
- `tr_tc_026`: `ms_tc_029` → `ms_tc_026`
- `tr_tc_027`: `ms_tc_030` → `ms_tc_027`
- `tr_tc_028`: `ms_tc_031` → `ms_tc_028`
- `tr_tc_029`: `ms_tc_032` → `ms_tc_029`
- `tr_tc_030`: `ms_tc_033` → `ms_tc_030`
- `tr_tc_031`: `ms_tc_034` → `ms_tc_031`
- `tr_tc_032`: `ms_tc_035` → `ms_tc_032`
- `tr_tc_033`: `ms_tc_036` → `ms_tc_033`
- `tr_tc_034`: `ms_tc_037` → `ms_tc_034`
- `tr_tc_035`: `ms_tc_038` → `ms_tc_035`
- `tr_tc_036`: `ms_tc_039` → `ms_tc_036`
- `tr_tc_037`: `ms_tc_040` → `ms_tc_037`
- `tr_tc_038`: `ms_tc_041` → `ms_tc_038`
- `tr_tc_039`: `ms_tc_042` → `ms_tc_039`
- `tr_tc_040`: `ms_tc_043` → `ms_tc_040`
- `tr_tc_041`: `ms_tc_044` → `ms_tc_041`
- `tr_tc_042`: `ms_tc_045` → `ms_tc_042`

---

### Systematic issue: injected DECOY `location.file` points to the wrong contract (34/46 files)

**Expected:** each injection should point to `location.file: tr_tc_XXX.sol` for that same sample.

**Observed:** many TR YAMLs point their injections at a different contract file (suggesting the annotation content is mis-associated with the wrong sample number).

**Examples (filename → injected `location.file`)**:
- `tr_tc_004.yaml` → `tr_tc_005.sol`
- `tr_tc_005.yaml` → `tr_tc_007.sol`
- `tr_tc_006.yaml` → `tr_tc_008.sol`
- `tr_tc_007.yaml` → `tr_tc_009.sol`
- `tr_tc_008.yaml` → `tr_tc_010.sol`
- `tr_tc_018.yaml` → `tr_tc_021.sol`
- `tr_tc_019.yaml` → `tr_tc_022.sol`
- `tr_tc_020.yaml` → `tr_tc_023.sol`
- `tr_tc_021.yaml` → `tr_tc_024.sol`
- `tr_tc_022.yaml` → `tr_tc_025.sol`
- `tr_tc_023.yaml` → `tr_tc_026.sol`
- `tr_tc_024.yaml` → `tr_tc_027.sol`
- `tr_tc_025.yaml` → `tr_tc_028.sol`
- `tr_tc_026.yaml` → `tr_tc_029.sol`
- `tr_tc_027.yaml` → `tr_tc_030.sol`
- `tr_tc_028.yaml` → `tr_tc_031.sol`
- `tr_tc_029.yaml` → `tr_tc_032.sol`
- `tr_tc_030.yaml` → `tr_tc_033.sol`
- `tr_tc_031.yaml` → `tr_tc_034.sol`
- `tr_tc_032.yaml` → `tr_tc_035.sol`
- `tr_tc_033.yaml` → `tr_tc_036.sol`
- `tr_tc_034.yaml` → `tr_tc_037.sol`
- `tr_tc_035.yaml` → `tr_tc_038.sol`
- `tr_tc_036.yaml` → `tr_tc_039.sol`
- `tr_tc_037.yaml` → `tr_tc_040.sol`
- `tr_tc_038.yaml` → `tr_tc_041.sol`
- `tr_tc_039.yaml` → `tr_tc_042.sol`
- `tr_tc_040.yaml` → `tr_tc_043.sol`
- `tr_tc_041.yaml` → `tr_tc_044.sol`
- `tr_tc_042.yaml` → `tr_tc_045.sol`

**Impact:** tooling cannot reliably locate DECOY code acts, and models cannot be scored accurately against the intended sample.

---

### Systematic issue: TR files violate the Trojan scope by annotating non-injected code (38/46 files)

The trojan protocol specifies “annotate ONLY injected DECOYs” (base vulnerability is referenced via `base_sample_id`).

**Observed:** `tr_tc_009.yaml`–`tr_tc_046.yaml` include a `code_acts:` section that assigns `ROOT_CAUSE`/`PREREQ`/`BENIGN` etc for non-injected code acts (i.e., re-annotating the base vulnerability and other acts).

**Impact:** inconsistent dataset format and ambiguous scorer behavior (should the scorer use MS for base, or trust TR’s embedded base annotations?).

---

### Systematic issue: non-verbatim “code” snippets / placeholders (many files)

The annotation guide expects code snippets to be **verbatim excerpts** (exact code). Multiple TR annotations use placeholders and ellipses instead of exact code, e.g.:
- `tr_tc_004.yaml` `INJ3` includes `... poolActivityScore += increment; ...`
- `tr_tc_029.yaml` contains entries like:
  - `code: "flashLoan function"`
  - `code: "rayDiv function with rounding"`
  - `INJ4` `code: "Analytics tracking variables"`

**Impact:** reviewers and automated validators cannot confirm that an annotation actually matches the contract code; this also risks line/code drift going unnoticed.

---

### Additional note (spec consistency)

- `tr_tc_002.sol` includes a DECOY `staticcall` helper (`simulateExecution`), which is correctly annotated as `EXT_CALL` + `DECOY` in `tr_tc_002.yaml`.
- However, the trojan README claims “No external calls in distractor code”. `staticcall` is still an external call (even if read-only), so the README guarantee is not strictly true.

