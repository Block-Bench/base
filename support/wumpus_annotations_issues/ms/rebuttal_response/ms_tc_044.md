# Rebuttal Response: ms_tc_044 — DeltaPrime Malicious Proxy Upgrade

## 1. Independent Review
- **Contract/Annotation:** Review pinpoints the semantic gap: annotation treats post-compromise impact code as causal, but the true root is off-chain (private key compromise + unsafeguarded proxy governance). The smart contract code lacks the actual upgrade mechanism and malicious logic injection seen in the real event. Code acts are misclassified as on-chain roots and prerequisites when they are only impactful after credential loss.
- **Metadata:** Over-attributes exploit surface to visible contract code, not the operational context.

## 2. Review and Synthesis
- Only one true root cause: off-chain key compromise and governance gap. Function-level contract actions are consequences, not causal bugs.

## 3. Conclusion
- ✅ Reviewer is accurate, and annotation rigor needs improvement: collapse all on-chain consequences after compromise into BENIGN or context/impact, and encode true enabling vulnerability as operational/external.

---
**Summary:**
Correctly identifies the incident model mismatch. Purely on-chain annotation of post-compromise impact is misleading if not clearly tagged as impact, not cause. Only off-chain compromise + missing governance should be causal.
