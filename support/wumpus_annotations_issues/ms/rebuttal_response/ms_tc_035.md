# Rebuttal Response: ms_tc_035 — Wise Lending Rounding Error

## 1. Independent Review
- **Contract/Annotation:** Correctly identifies rounding bug in pool accounting, but ROOT_CAUSE is duplicated for each function and PREREQ is used for a third related path. These represent a systemic invariant failure—arithmetic edge cases propagate through all deposit/withdrawal permutations. Metadata and function scoping only partially represent the exploit; all three withdrawal/mint APIs (depositExactAmount, withdrawExactShares, withdrawExactAmount) express the same issue.

## 2. Review and Synthesis
- Single root cause (unbounded share–pool ratio integer division) spans all three code locations. PREREQ is inappropriate for any expression of the same flaw. Annotation should tie all affected paths to the single invariant, and enrich taxonomy with state precondition information (pool ratios).

## 3. Conclusion
- ✅ Critical details and exploit scenario are sound, but fragmenting root causes obscures the true systemic risk. LABEL: unify causal set, demote other paths to BENIGN, expand metadata to all three code loci.

---
**Summary:**
Correctable taxonomy bug: only invariant failure should be causal. PREREQ and ROOT_CAUSE inflation weakens compositional signal for model learning.
