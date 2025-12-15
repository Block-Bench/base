# Task Two: Temporal Contamination Probe - Assessment & Plan

**Date:** December 15, 2024  
**Branch:** feat/task-two-ground-truth-gold-standard  
**Objective:** Create ~50 samples to measure AI memorization vs. reasoning

---

## Executive Summary

DeFiHackLabs repository provides **excellent** infrastructure for this task:

- ✅ 674 incidents documented with PoC code
- ✅ Organized by date (easy to filter pre/post-cutoff)
- ✅ Post-Sept 2025 incidents available (2025-09, 10, 11, 12)
- ✅ Famous pre-cutoff exploits present (Euler, Curve, Nomad, etc.)

**Recommendation:** Proceed with extraction

---

## Repository Structure

```
DeFiHackLabs/
├── src/test/
│   ├── 2025-12/    → Most recent (POST-CUTOFF)
│   ├── 2025-11/    → POST-CUTOFF
│   ├── 2025-10/    → POST-CUTOFF
│   ├── 2025-09/    → POST-CUTOFF (start here)
│   ├── 2024-XX/    → Too recent but PRE-CUTOFF
│   ├── 2023-XX/    → Euler, Curve, etc.
│   ├── 2022-XX/    → Nomad, Wormhole, Beanstalk
│   └── ...
└── README.md       → Full list of incidents
```

---

## Post-Cutoff Samples Identified (Sept 2025+)

### From 2025-09:

- Kame

### From 2025-10:

- MIMSpell3
- SharwaFinance
- TokenHolder

### From 2025-11:

- BalancerV2
- DRLVaultV3
- Moonwell

### From 2025-12:

- (Need to check)

**Estimated:** 10-15 post-Sept 2025 exploits available  
**Target:** 20-25 samples  
**Gap:** Need to supplement with Code4rena/Sherlock findings

---

## Pre-Cutoff Famous Exploits Located

### High Priority (Well-Known, Likely Memorized)

| Exploit             | Date     | Found in DeFiHackLabs           | Priority       |
| ------------------- | -------- | ------------------------------- | -------------- |
| **Euler Finance**   | Mar 2023 | ✅ /2023-03/Euler_exp.sol       | 🔴 High        |
| **Curve Finance**   | Jul 2023 | ✅ /2023-07/Curve_exp01.sol     | 🔴 High        |
| **Nomad Bridge**    | Aug 2022 | ✅ /2022-08/NomadBridge_exp.sol | 🔴 High        |
| **Wormhole**        | Feb 2022 | ⚠️ Need to check                | 🔴 High        |
| **Mango Markets**   | Oct 2022 | ⚠️ Need to check                | 🔴 High        |
| **Cashio**          | Mar 2022 | ⚠️ Need to check                | 🔴 High        |
| **Beanstalk**       | Apr 2022 | ⚠️ Need to check                | 🔴 High        |
| **Badger DAO**      | Dec 2021 | ⚠️ Need to check                | 🟡 Medium      |
| **Cream Finance**   | Oct 2021 | ⚠️ Need to check                | 🟡 Medium      |
| **Poly Network**    | Aug 2021 | ⚠️ Need to check                | 🟡 Medium      |
| **Yearn yDAI**      | Feb 2021 | ⚠️ Need to check                | 🟡 Medium      |
| **Harvest Finance** | Oct 2020 | ⚠️ Need to check                | 🟡 Medium      |
| **bZx**             | Feb 2020 | ⚠️ Need to check                | 🟡 Medium      |
| **Parity Wallet**   | Nov 2017 | ⚠️ Need to check                | 🟢 Low (older) |
| **The DAO**         | Jun 2016 | ⚠️ Need to check                | 🟢 Low (older) |

**Next Steps:** Search DeFiHackLabs for remaining exploits

---

## Variant Strategy

### Top 10 Candidates for Variants

Based on fame and documentation quality:

1. **Euler Finance** (2023) - Donation attack
2. **Curve Finance** (2023) - Vyper reentrancy
3. **Nomad Bridge** (2022) - Message validation
4. **Wormhole** (2022) - Signature verification
5. **Beanstalk** (2022) - Governance flash loan
6. **Mango Markets** (2022) - Oracle manipulation
7. **Cashio** (2022) - Account validation
8. **Cream Finance** (2021) - Flash loan + oracle
9. **Harvest Finance** (2020) - Price manipulation
10. **The DAO** (2016) - Reentrancy (classic)

### Variant Types for Each:

- **renamed**: Change function/variable names
- **simplified**: Strip to core vulnerability
- **obfuscated**: Restructure code (optional, most labor-intensive)

**Estimated:** 10 originals × 2-3 variants = **20-30 variant samples**

---

## Dataset Composition (Final)

| Category                 | Target | Status                       |
| ------------------------ | ------ | ---------------------------- |
| **Pre-cutoff originals** | 25-30  | 🟡 15 found, need 10-15 more |
| **Pre-cutoff variants**  | 20-30  | 🔴 Not started               |
| **Post-cutoff**          | 20-25  | 🟡 10 found, need 10-15 more |
| **TOTAL**                | 65-85  | In progress                  |

**Adjusted Target:** 70 samples (more than initial 50, better for analysis)

---

## Data Schema Compliance

### Required Fields (Per Task Doc)

```json
{
  "id": "temporal_<name>_<num>",
  "subset": "temporal_contamination_probe",

  "exploit_name": "...",
  "exploit_date": "YYYY-MM-DD",
  "amount_lost_usd": 0,

  "temporal_category": "pre_cutoff | post_cutoff",
  "likely_in_training": true / false,

  "language": "solidity | rust",
  "chain": "ethereum | solana | ...",

  "file_content": "...",
  "vulnerable_function": "...",
  "vulnerable_lines": [],

  "vulnerability_type": "...",
  "severity": "...",

  "is_variant": false,
  "variant_type": null,
  "source_url": "..."
}
```

---

## Processing Plan

### Phase 1: Pre-Cutoff Collection (3-4 hours)

1. ✅ Clone DeFiHackLabs
2. ⚠️ Search for all 15 famous exploits
3. ⚠️ Extract vulnerable code from each PoC
4. ⚠️ Create JSON entries with metadata
5. ⚠️ Validate dates and amounts

### Phase 2: Variant Generation (4-5 hours)

1. Select 10 best-documented exploits
2. For each exploit:
   - Create renamed version (change identifiers)
   - Create simplified version (core vuln only)
   - Optionally create obfuscated version
3. Validate variants maintain same vulnerability
4. Link variants to parent via `variant_parent_id`

### Phase 3: Post-Cutoff Collection (3-4 hours)

1. ✅ Identify DeFiHackLabs post-Sept 2025 samples (10 found)
2. ⚠️ Search Code4rena reports (Sept-Dec 2025)
3. ⚠️ Search Sherlock reports (Sept-Dec 2025)
4. ⚠️ Check Rekt.news for recent incidents
5. ⚠️ Extract vulnerable code from findings/repos
6. ⚠️ Create JSON entries

### Phase 4: Standardization & Validation (2-3 hours)

1. Consolidate all JSONs
2. Validate schema compliance
3. Check temporal categories
4. Generate summary statistics
5. Create master index

---

## Challenges & Mitigation

### Challenge 1: Finding The DAO / Parity Code

**Issue:** Very old exploits (2016-2017) may not have standardized PoCs in DeFiHackLabs

**Solution:**

- Check DeFiHackLabs archives
- Reconstruct from historical writeups if needed
- Worst case: Skip if can't find reliable code

### Challenge 2: Post-Cutoff Sample Scarcity

**Issue:** May not find 20-25 high-quality post-Sept 2025 exploits

**Solution:**

- Lower threshold to 15-20 if needed
- Include high-severity Code4rena findings (not just exploits)
- Focus on quality over quantity

### Challenge 3: Variant Creation Labor

**Issue:** Creating 20-30 variants manually is time-intensive

**Solution:**

- Start with 2 variants per exploit (renamed + simplified)
- Skip obfuscated unless exploit is super-famous
- Use semi-automated renaming where possible

### Challenge 4: Vulnerable Line Identification

**Issue:** DeFiHackLabs PoCs are test files, not extracted vulnerable contracts

**Solution:**

- Extract vulnerable contract code from PoC imports
- Use comments/docs to identify vulnerable lines
- Manual inspection when needed

---

## Quality Gates

### For All Samples

- [ ] Has exploit name and accurate date
- [ ] Has vulnerability type classification
- [ ] Has severity rating
- [ ] Temporal category is correct (pre/post Sept 2025)
- [ ] Code is actual vulnerable contract (not test harness)

### For Pre-Cutoff

- [ ] Exploit is well-documented (multiple sources)
- [ ] Amount lost is documented
- [ ] Exploit definitely occurred before Jan 2024
- [ ] Code is accurate representation

### For Variants

- [ ] Maintains same vulnerability as original
- [ ] Changes match variant type (renamed/simplified/obfuscated)
- [ ] Linked to parent via `variant_parent_id`

### For Post-Cutoff

- [ ] Definitely occurred after Sept 1, 2025
- [ ] Not covered in earlier training data
- [ ] Code is from actual incident or audit finding

---

## Expected Outputs

```
dataset/
├── processed/
│   └── temporal_contamination/
│       ├── pre_cutoff_originals.json      (25-30 samples)
│       ├── pre_cutoff_variants.json       (20-30 samples)
│       └── post_cutoff.json               (15-25 samples)
├── metadata/
│   ├── temporal_contamination_master.json  (all combined)
│   └── temporal_analysis_readme.md
└── scripts/
    ├── process_defihacklabs.py
    ├── create_variants.py
    └── consolidate_temporal.py
```

---

## Timeline

| Phase     | Task                        | Time            | Status         |
| --------- | --------------------------- | --------------- | -------------- |
| 1         | Clone DeFiHackLabs          | 5 min           | ✅ Done        |
| 1         | Identify pre-cutoff samples | 1-2 hours       | 🟡 In progress |
| 1         | Extract code & metadata     | 2-3 hours       | ⚠️ Pending     |
| 2         | Create variants             | 4-5 hours       | ⚠️ Pending     |
| 3         | Find post-cutoff samples    | 2-3 hours       | 🟡 Started     |
| 3         | Extract post-cutoff code    | 2-3 hours       | ⚠️ Pending     |
| 4         | Standardize & validate      | 2-3 hours       | ⚠️ Pending     |
| **TOTAL** |                             | **~1-1.5 days** |                |

---

## Next Immediate Steps

1. ✅ Search DeFiHackLabs for all 15 famous exploits
2. ✅ Create extraction script for DeFiHackLabs PoCs
3. ✅ Extract first 10 pre-cutoff samples
4. ✅ Extract first 10 post-cutoff samples
5. ✅ Create 5 variants as proof-of-concept
6. ⚠️ Validate quality and iterate

---

## Success Criteria

**Minimum Viable Dataset:**

- 20 pre-cutoff originals
- 15 pre-cutoff variants
- 15 post-cutoff samples
- **Total: 50 samples** (original target)

**Ideal Dataset:**

- 25-30 pre-cutoff originals
- 20-30 pre-cutoff variants
- 20-25 post-cutoff samples
- **Total: 65-85 samples**

**Quality Threshold:**

- 100% have accurate dates
- 100% have correct temporal category
- 100% have vulnerability type
- 90%+ have vulnerable line identification
- Variants verified to maintain original vulnerability

---

## Conclusion

**Task Two is FEASIBLE and well-scoped.**

DeFiHackLabs provides excellent infrastructure. The main work is:

1. Systematic extraction (can be partially automated)
2. Variant creation (manual but straightforward)
3. Post-cutoff supplementation (requires some research)

**Estimated time:** 1-1.5 days of focused work

**Recommendation:** Proceed with phased extraction approach.
