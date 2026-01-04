## DF code-act annotation issues (temporal_contamination/differential)

### Meta-audit note (how to resolve disagreements)

When metadata, annotations, and code disagree:
- **Contract code (`contracts/df_tc_XXX.sol`)** is treated as the source of truth for *line bounds* and *verbatim code snippets*.
- **Dataset intent** for DF is that `df_tc_XXX` is a *fixed* version (`is_vulnerable: false`). If an annotation still flags a vulnerability in fixed, either the contract must be fixed further or the dataset definition/metadata must change (partial-fix samples).

### Dataset-level

- **DF metadata `transformation.source_*` pointers are renumbering-inconsistent (43/46)**:
  - **Observed**: for `df_tc_004`–`df_tc_046`, the metadata fields:
    - `transformation.source_contract` points to `.../tc_YYY.sol` where **YYY ≠ XXX**
    - `transformation.source_metadata` points to `.../tc_YYY.json` where **YYY ≠ XXX**
  - **Examples**:
    - `df_tc_004` has `variant_parent_id: tc_004`, but `source_contract: .../tc_005.sol` and `source_metadata: .../tc_005.json`
    - `df_tc_046` has `variant_parent_id: tc_046`, but `source_contract: .../tc_050.sol` and `source_metadata: .../tc_050.json`
  - **Impact**: breaks traceability and any tooling that relies on these pointers to load the paired original; it also makes it ambiguous whether `variant_parent_id` or `source_*` is authoritative.
  - **Correctness call**:
    - If DF numbering is authoritative (i.e., `variant_parent_id: tc_XXX` is correct), then **metadata pointers are wrong** and must be renumbered.
    - If `source_*` pointers are authoritative, then **`variant_parent_id` (and likely DF numbering) is wrong** (larger dataset integrity issue).

---

### Systematic issues (critical)

- **DF annotation schema is inconsistent with the differential spec in `support/codeact.md`**:
  - The annotation guide’s differential format is a paired vulnerable/fixed schema with explicit transitions.
  - The dataset currently contains two incompatible schemas:
    - `df_tc_001`–`df_tc_008`: paired `vulnerable:`/`fixed:` sections
    - `df_tc_009`–`df_tc_046`: “fixed-only” schema with top-level `is_fixed` and `CA_FIX*` entries lacking `vulnerable:` sections
  - **Impact**: any validator/scorer built from the guide’s “differential” schema cannot uniformly parse/score the dataset, and transition-based metrics are not computable for 38 samples.
  - **Correctness call**:
    - If the evaluator expects paired transitions, then **fixed-only annotations are wrong/incompatible** as a dataset format.
    - If fixed-only is intended, the schema should be formally versioned/declared and the evaluator updated accordingly (to avoid silent scoring failures).

---

### File-specific issues

### df_tc_001.yaml

- **Fixed-version annotations still mark a real vulnerability**:
  - The fixed-side security function for `CA13` remains `SECONDARY_VULN`.
  - This makes the “fixed” sample still vulnerable per the annotation, contradicting `is_vulnerable: false` and the differential-variant expectation that `df_tc_XXX` should be non-vulnerable.

---

### Audit artifacts (for reproduction)

- Raw machine output: `support/davereviews/_tmp_df_meta_ann_consistency.json`


