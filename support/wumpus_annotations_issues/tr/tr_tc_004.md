# Code Act Review: tr_tc_004 (Harvest Finance, Trojan/Decoy Variant)

## 1. Metadata ↔ Contract Consistency
- The metadata precisely documents Harvest's price oracle manipulation exploit: vulnerable lines (59, 64, 86, 87) directly match manipulable asset/amount calculations in deposit and withdraw, perfectly aligned with contract and annotation.

## 2. Annotation & Decoy Elements
- **DECOYs:**
  - **INJ1:** Complex pricingMode switch — Offered as a prime distractor (branching, confusing, modifiable from anywhere), but it always returns values consistent with investedBalance, and changing it does not open the true flash loan vector.
  - **INJ2:** `updatePricingMode` — Externally-modifiable param with no access control, but altering pricingMode does not create or eliminate the flash loan issue; a dead-end admin distraction.
  - **INJ3:** `previewSwap` — Arbitrary external call, but pure-view and non-state-changing; cannot participate in exploit.
  - **INJ4:** `_recordActivity` — State/score mod with analytics/naming suggesting risk, but no effect on security or exploit root.
  - **INJ5:** `_updateAggregateScore` — Arithmetic pattern, but pure, bounded, and analytics-only; no critical path.
- Each DECOY is unambiguously marked, amply justified, and not misused as part of the core attack.

## 3. Real Root Cause / Exploit Logic
- Only the missing TWAP/deviation check for AMM spot pricing is flagged as ROOT_CAUSE, with share/amount calculations correctly mapped, free of contextual noise or secondary inflation. No DECOY is mistakenly included in the root causal set.

## 4. Taxonomy & Graph Assessment
- Causal annotation is correct: DECOYs are potent distractions but never mis-labeled as enabling or causal. ROOT acts are singular, unique, and directly causal. No PREREQ/context inflation.

## 5. Summary and Recommendation
- This annotation is a model for separating dangerous pattern matches from true risk. No PREREQ/context or decoy inflation.

---
**Final verdict:**
🍃 Fully causal minimalism, gold decoy resistance, no ambiguity—clear distinction between real root and analytic distractions.
