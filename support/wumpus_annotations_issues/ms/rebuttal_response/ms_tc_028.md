# Rebuttal Response: ms_tc_028 — Fee-on-Transfer Vault Accounting Flaw

## 1. Independent Review
- **Contract/Annotation:** True enabling flaw is correctly captured at the moment of accounting failure (CA10), but the annotation spreads PREREQ across numerous declarations and internal variables (CA1, CA7, CA2, CA3, CA5, CA6), most of which are structural/context, not prerequisites.
- Declarations should be UNRELATED/BENIGN; only variables directly and causally involved in the bug should rank as PREREQ.

## 2. Review and Synthesis
- This is a clear example where context inflation dilutes causal clarity. The central flaw is singular—accounting error at the vault level, not individual token logic.
- There are no downstream propagation mistakes.

## 3. Conclusion
- ✅ Agree with the review: annotation should cut PREREQ to the minimum, place declarations/context as UNRELATED, and consolidate causal path to only what is required for exploit onset.

---
**Summary:**
Annotation should always seek to minimize PREREQ quantity and only elevate storage/context when they directly enable, not merely coincide with, exploitation.
