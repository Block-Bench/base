# Code Act Review: tr_tc_007 (Poly Network, Trojan/Decoy Variant)

## 1. Metadata ↔ Contract Consistency
- Metadata accurately details one of the largest cross-chain hacks, describing the manager contract's unrestricted ability to route privileged calls to the data contract, matching causal logic (execution via arbitrary contract target).
- Contract and vulnerable lines mapped to the core exploit: `verifyHeaderAndExecuteTx` → external call at line 106.

## 2. Annotation & Decoy Elements
- **DECOYs:**
  - **INJ1:** `setManagerConfigVersion`: Unprotected, admin-style function, but only affects non-critical version variables.
  - **INJ2:** Analytics/metrics state variables (e.g., `crossChainActivityScore`, `headerScore`), tempting for pattern-matchers, but purely contextual.
  - **INJ3:** `_recordHeader` analytics function — state-change after cross-chain exec, but again, analytics only, not causal or impactful.
  - **INJ4:** Helper computation functions — arithmetic/computation, but no state touch, pure analytics.
- All DECOYs have correct annotation and context as non-causal; correct use as pattern-matching traps.

## 3. Root Cause and Exploit Path
- The annotation strictly maps the real exploit as unrestricted delegated call (`toContract.call`) enabled by missing access control, correlating to the true historical exploit.

## 4. Taxonomy & Graph Assessment
- Causal graph is correct: analytic distractors are all non-enabling; only the unrestricted call is root. No PREREQ, context, or inflation present. DECOYs do not cloud or bloat exploit reasoning.

## 5. Summary and Recommendation
- Flawless division of decoy and root. Only unrestricted delegated call should be flagged as root by any reviewer or model; flagging decoy state/config/analytics is a false positive.

---
**Final verdict:**
🍃 Minimal, precise, causally robust with strong decoy discipline. All reviewers should converge to the same root-locus; decoy-resistance is a direct benchmark here.
