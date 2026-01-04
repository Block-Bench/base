# Rebuttal Response: ms_tc_015 — yEarn Virtual Price Inflation (Abstraction Gap)

## 1. Independent Review
- **Contract/Annotation:** earn() fetches virtualPrice but never uses it; annotation and metadata both assume a vulnerability pipeline that doesn’t exist in code. Declared PREREQs are mechanical/accounting (declarations, normal state updates), not exploit preconditions. The only ROOT_CAUSE is in a view function never used by state-changing functions, so no actual vulnerability is exercised.
- **Metadata:** Implies share overvaluation and inflation, but the modeled contract does not propagate the price anywhere.

## 2. Your Review and Paul’s Rebuttal
- **Review:** Rightly flags that annotation assumes value propagation not present in code and that neither share calculation nor inflation logic is actually dangerous in this model. All so-called PREREQs are either inert, mechanical, or unused.
- **Annotation:** Remains misaligned, asserting root causes/PREREQs for semantics inferred but not encoded.

## 3. Key Findings:
- Root cause and precondition labeling must reflect the actual code execution path, not the historical full exploit when the code is abstracted/minimized.
- If a variable or function is never causally connected to share/accounting logic, it cannot be a root cause.
- Benchmark fidelity suffers when semantics are inferred, not observed.

## 4. Conclusion
- ✅ Agree: annotation must tie roots and preconditions to reachable, live logic in the contract. Any causal surface not encoded must be marked as non-exploitable abstraction or an intention-only reference.
- 🔶 Metadata should always annotate whether abstraction was performed.
- ❌ This sample is a semantic outlier, but it clarifies why observation > intent for taxonomy annotation.

---
**Summary:**
True causal annotation must match code, not history. The current yaml remains taxonomically valuable only as a caution of intent-vs-observation error in vulnerability labeling.
