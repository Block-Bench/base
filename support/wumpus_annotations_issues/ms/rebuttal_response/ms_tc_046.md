# Rebuttal Response: ms_tc_046 — FixedFloat Hot Wallet Key Compromise

## 1. Independent Review
- **Contract/Annotation:** Identifies fund loss pathways, but wrongly assigns root cause to all owner-only functions and their modifier. The true causal flaw is the single-key (centralized) operational design; safe-by-design withdrawal/ownership logic is only abused after off-chain key compromise. The onlyOwner modifier is not a vulnerability.
- **Metadata:** Full alignment between code, function, and loss narrative—no metadata issues.

## 2. Review and Synthesis
- Minimal and correct annotation must reflect a single operational root: compromised hot-wallet key due to centralization. All downstream contract logic is effect/impact.

## 3. Conclusion
- ✅ Reviewer is correct: annotation must not inflate causal set. Demote all code acts after key loss to BENIGN/context; encode one contextual root cause: single-key trust failure.

---
**Summary:**
Dataset must distinguish operational/organizational risks (hot wallet key, admin compromise) from smart contract root causes. All contract logic here is effect—root is operational.
