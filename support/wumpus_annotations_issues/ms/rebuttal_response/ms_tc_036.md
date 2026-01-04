# Rebuttal Response: ms_tc_036 — Prisma Finance Delegate Approval (Zap Exploit)

## 1. Independent Review
- **Contract/Annotation:** Detects authority-value decoupling enabled by cross-contract delegation, but duplicates root cause (user-controlled destination and transfer) and marks delegate controls as PREREQ. The correct model is a unified root cause—permissive delegation enables decoupling of debt and value, across both contracts. This is not generic access control but an authority mismatch.
- **Metadata:** Vulnerable lines, contracts, and types do not accurately represent cross-contract surface. Needs to include both zap and delegation logic.

## 2. Review and Synthesis
- All enabling logic (including delegation system) belongs in ROOT_CAUSE. Transfer to attacker's address is an effect, not a cause. PREREQ should not be used for either contract in authority-bound flaws. Enrich future taxonomy with `delegated_authority_misuse` or more specific authority/value separation categories.

## 3. Conclusion
- ✅ Bug and scenario clarity are high, but root cause should be unified and explicitly cover cross-contract enabling logic; PREREQ must be pruned. Taxonomy must distinguish cross-contract and value/binding flaws from generic access-control mistakes.

---
**Summary:**
Cleanest annotation for authority misbinding exploits must unify the cause and treat all precondition/control logic among all involved contracts as part of the single bug.
