# Rebuttal Response: ms_tc_047 — Unrestricted Mint Authority and Role Persistence

## 1. Independent Review
- **Contract/Annotation:** The exploit (mint inflation via compromised minter) is correctly targeted, but the annotation over-splits and inflates roots, and misuses PREREQ. The only causal locus is the existence of a single, unrestricted minter with no supply cap or governance. setMinter is persistence only, not part of the exploit; implementation details (_mint) do not independently enable the bug; the minter modifier is not a PREREQ, but the actual locus of weakness folded into root.
- **Metadata:** Expands vulnerable functions/capability beyond what is needed for abuse, rather than narrowly targeting mint (core locus).

## 2. Review and Synthesis
- A clean model will have: one ROOT_CAUSE (unrestricted, externally controlled mint privilege), 0 PREREQs. All role rotation, internal implementation, or modifier logic is either BENIGN or context.

## 3. Conclusion
- ✅ Reviewer’s critiques are correct; annotation and metadata should be minimal and strictly reflect only the causal surface.

---
**Summary:**
Taxonomy rigor is best maintained by assigning one root (privilege locus), zero PREREQs, and all other acts to BENIGN/contextual/persistence. No surface or implementation splits.
