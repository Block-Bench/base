## DF code-act annotation issues (temporal_contamination/differential)

### Meta-audit note (how to resolve disagreements)

When metadata, annotations, and code disagree:
- **Contract code (`contracts/df_tc_XXX.sol`)** is treated as the source of truth for *verbatim code snippets*.
- **Line numbers**: DF contracts embed `/*LN-###*/` markers; these are the only line numbers that can be relied on for scoring/validation. If LN markers are duplicated or missing, line-based mappings become ambiguous.
- **Dataset intent** for DF is that `df_tc_XXX` is a *fixed* version (`is_vulnerable: false`). If an annotation still flags a vulnerability in fixed, either the contract must be fixed further or the dataset definition/metadata must change (partial-fix samples).

### Dataset-level

- **Two-schema approach is approved**:
  - `df_tc_001`–`df_tc_008`: paired vulnerable/fixed transitions
  - `df_tc_009`–`df_tc_046`: fixed-only with `is_fixed` + `CA_FIX*`
  - This section is not considered an “issue” going forward.

---

### Systematic issues (critical)

- **Metadata `vulnerable_function` list is semantically misleading in some samples**:
  - **Context**: several DF metadata files use comma-separated function lists to mean “multiple functions involved in the exploit flow”. This can be acceptable, but a few cases are misleading/incomplete when checked against the vulnerable (MS) code + MS code acts.
  - **Issues**:
    - `df_tc_037`: metadata lists `mint, getExchangeRate`, but in the vulnerable MS annotation `getExchangeRate` is **not used by `mint()`** (it’s effectively dead/unused). Including it as “vulnerable” is misleading.
    - `df_tc_042`: metadata lists `claimRewards, deposit, withdraw`, but the vulnerable MS annotation treats `registerMarket()` as a **PREREQ** enabling condition. If the list is meant to capture all exploit-enabling functions, it is incomplete without `registerMarket`.

---

### File-specific issues

### Audit artifacts (for reproduction)

- Raw machine output: `support/davereviews/_tmp_df_meta_ann_consistency.json`


