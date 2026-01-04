# Code Act Review: tr_tc_009 (KyberSwap Elastic, Trojan/Decoy Variant)

## 1. Metadata ↔ Contract Consistency
- Metadata fully covers a multi-chain precision-loss attack. Contract lines and annotation correctly trace the exploit through `swap` and `_addLiquidity`, with bug and exploit mechanics well aligned.

## 2. Annotation & Decoy Elements
- **DECOYs:**
  - **INJ1:** `setPoolConfigVersion` — Pattern-matching admin/config, but only changes version for analytics.
  - **INJ2:** Analytics state variables — contextually complex but non-causal, have no bearing on precision, tick calculation, or pool mechanics.
  - **INJ3:** `_recordPoolActivity`: Internal, state-modifying, called in function context, but updates only analytics/score; not implicated in core arithmetic bug.
  - **INJ4:** Tick/score computation helpers — designed to confuse those seeking tick math surface; pure computation, non-causal for bug.
- All DECOYs are safe, properly described, and would be flagged incorrectly by pattern-matching reviewers or models.

## 3. Root Cause and Exploit Path
- True exploit traces only through unchecked arithmetic during tick crossings and liquidity operations. No PREREQ/context inflation. Any DECOY flagged is a review/model error.

## 4. Taxonomy & Graph Assessment
- The annotation preserves the exploit’s arithmetic root and never mixes analytics/decoy/context as causal. Rating is high for model/annotator decoy resistance and minimalism.

## 5. Summary and Recommendation
- Flawless causal minimalism: analytics/config distractors should not be labeled as risk—serves as a rigorous test for precision in arithmetic/AMM exploit recognition.

---
**Final verdict:**
🍃 No causal drift or decoy pollution. Only arithmetic logic is root; decoy rigor is high and intentional. Recommended for robust benchmarking.
