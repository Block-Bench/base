# Rebuttal Response: ms_tc_040 — Bedrock DeFi Exchange Rate Exploit

## 1. Independent Review
- **Contract/Annotation:** The exploit (ETH mapped 1:1 to BTC at mint, without market-based conversion) is correctly targeted, but the annotation splits root cause across both active and dead code and treats transfer and redeem logic as additional PREREQ. Only the mint path with the wrong rate is causal; all else is realization or non-participatory. Metadata also over-scopes vulnerable functions, confusing auxiliary/explanatory logic for true exploit path.

## 2. Review and Synthesis
- Only one root cause: ETH↔BTC exchange invariant break in mint. All other acts—token transfer, redeem, getExchangeRate—should be classed as BENIGN/UNRELATED. Metadata should scope function to mint only, and note others as unused or reflection-only.

## 3. Conclusion
- ✅ Exploit is soundly identified, but single-root-cause rigor is required. All realization paths and dead code must be clearly demoted.

---
**Summary:**
Economic invariant breakages (wrong exchange, price, rate, or units) must always be captured as singular roots. All downstream accounting or mirrored logic is only effect or realization, not PREREQ or additional roots.
