## DF metadata ↔ code-acts ↔ code consistency audit (temporal_contamination/differential)

This audit checks whether each DF sample’s:
- `metadata/df_tc_XXX.json`
- `code_acts_annotation/df_tc_XXX.yaml`
- `contracts/df_tc_XXX.sol`

…are mutually consistent. When there is disagreement, **contract code is treated as the source of truth** for line bounds and code snippets.

### Summary (46 samples)

- **Metadata → original pointers are inconsistent (43/46)**:
  - `transformation.source_contract` and `transformation.source_metadata` point to `tc_YYY.*` where `YYY != XXX` for `df_tc_004`–`df_tc_046`.
  - This contradicts `variant_parent_id: tc_XXX` and breaks traceability for pairwise comparisons driven by metadata pointers.

- **Annotations use two incompatible schemas (596 code_acts entries missing vulnerable/fixed pairing)**:
  - `df_tc_009`–`df_tc_046` contain “fixed-only” `CA_FIX*` entries (no `vulnerable:` section), which prevents uniform differential transition validation/scoring using the paired schema.

- **Fixed annotation still claims a vulnerability (1 file)**:
  - `df_tc_001.yaml` marks `CA13` as `SECONDARY_VULN` on the fixed side, contradicting DF’s fixed expectation and `is_vulnerable: false`.

### Details (issues only)

#### 1) Metadata `transformation.source_*` pointer mismatches (43/46)

- **Rule**: for `df_tc_XXX` with `variant_parent_id: tc_XXX`, metadata pointers should refer to `.../tc_XXX.sol` and `.../tc_XXX.json`.
- **Observed**: `df_tc_004`–`df_tc_046` point to a different `tc_YYY`.
- **Examples**:
  - `df_tc_004`: points to `tc_005.sol` / `tc_005.json`
  - `df_tc_046`: points to `tc_050.sol` / `tc_050.json`

**Correctness call**:
- If DF numbering is authoritative (i.e., `variant_parent_id` is correct), then **metadata pointers are wrong** and must be renumbered.
- If the pointers are authoritative, then **`variant_parent_id` (and likely sample numbering) is wrong**. This would be a much larger dataset integrity issue.

#### 2) DF annotation schema mismatch (596 entries)

- **Rule** (per differential protocol): code acts should be described as paired vulnerable/fixed elements with explicit transitions.
- **Observed**: 596 `code_acts[]` entries (across `df_tc_002`–`df_tc_046`) do not have both `vulnerable:` and `fixed:` sections (primarily `CA_FIX*` entries).

**Correctness call**:
- If the scorer/validator expects the paired schema, then **annotations are wrong/incompatible** as a dataset format.
- If “fixed-only” is accepted, the schema should be formally versioned/declared and the evaluator updated accordingly (otherwise silent scoring failures are likely).

#### 3) `df_tc_001.yaml` fixed-side `SECONDARY_VULN`

- **Observed**: `df_tc_001.yaml` keeps `CA13` as `SECONDARY_VULN` on the fixed side.

**Correctness call**:
- If differential samples must be non-vulnerable, then **the annotation is wrong** (or the fixed contract must actually be fixed further).
- If partial-fix samples are allowed, then **the metadata should not claim `is_vulnerable: false`**, and the dataset definition for differential must be updated (since “fixed version” would no longer mean “non-vulnerable”).

---

### Artifact

Raw machine output was written to:
- `support/davereviews/_tmp_df_meta_ann_consistency.json`

