# Neodyme CTF & Solana-CTF Repository Assessment

**Date:** December 15, 2024  
**Purpose:** Evaluate neodyme-labs/solana-ctf for dataset integration  
**Repository:** https://github.com/neodyme-labs/solana-ctf

---

## Executive Summary

**Overall Assessment:** ⚠️ **MIXED QUALITY** - Excellent for learning, challenging for structured extraction

**Recommendation:** Extract only **Neodyme Workshop Levels 0-4** (5 samples). Skip other CTF challenges.

### Quick Verdict

| Source                            | Samples | Quality      | Extractable? | Recommend? |
| --------------------------------- | ------- | ------------ | ------------ | ---------- |
| **Neodyme Workshop (levels 0-4)** | 5       | ✅ Excellent | ✅ Yes       | ✅ **YES** |
| Other CTF challenges (10+)        | 10+     | ⚠️ Variable  | ❌ Difficult | ❌ **NO**  |

---

## Neodyme Workshop (Levels 0-4) - RECOMMENDED

### Structure ✅

```
neodyme-breakpoint-workshop/
├── level0/          → CTF intro
├── level1/          → Missing signer check
├── level2/          → Integer overflow/underflow
├── level3/          → Type confusion (Vault vs TipPool)
├── level4/          → Arbitrary CPI
└── docs/
    ├── level1.md              → Challenge description
    ├── level1-bug.md          → Vulnerability description
    ├── level1-hint1.md        → Hint 1
    ├── level1-hint2.md        → Hint 2
    ├── level1-solution.md     → Full solution + PoC
    └── [same pattern for levels 2-4]
```

### Data Quality: 9/10 ✅

#### ✅ Strengths

1. **Excellent Documentation**

   - Each level has clear challenge description
   - Explicit bug descriptions
   - Detailed solutions with mitigation strategies
   - Progressive hints

2. **Clean Code Structure**

   - Single-file or simple multi-file programs
   - Well-commented
   - Focused on one vulnerability per level

3. **Educational Quality**

   - Progressive difficulty (Level 1 → Level 4)
   - Real Solana vulnerability patterns
   - Includes exploit PoCs in solutions

4. **Metadata Available**
   - Vulnerability type clearly stated
   - Mitigation strategies provided
   - Context and usage examples

#### Sample Entry Example (Level 1)

**Challenge:** Personal Vault  
**Vulnerability:** Missing Signer Check  
**Severity:** Critical  
**Code Size:** ~105 lines (processor.rs)

**Bug Location (from docs):**

```rust
// Line 81-90 in withdraw function
fn withdraw(program_id: &Pubkey, accounts: &[AccountInfo], amount: u64) -> ProgramResult {
    let wallet_info = next_account_info(account_info_iter)?;
    let authority_info = next_account_info(account_info_iter)?;
    let wallet = Wallet::deserialize(&mut &(*wallet_info.data).borrow_mut()[..])?;

    assert_eq!(wallet.authority, *authority_info.key);  // ← BUG: checks key match but not signature!
    // Missing: assert!(authority_info.is_signer);
}
```

**Fix (from docs):**

```rust
assert!(authority_info.is_signer);
```

**PoC:** Full exploit code provided in solution docs

### Extractable Metadata ✅

| Field                 | Availability | Source                            | Quality |
| --------------------- | ------------ | --------------------------------- | ------- |
| `id`                  | ✅           | Generate from level name          | High    |
| `vulnerability_type`  | ✅           | bug.md + solution.md              | High    |
| `description`         | ✅           | levelX.md + bug.md                | High    |
| `file_content`        | ✅           | lib.rs + processor.rs             | High    |
| `vulnerable_function` | ✅           | Parse from solution.md            | High    |
| `vulnerable_lines`    | ⚠️           | **Manual inspection needed**      | Medium  |
| `fix_description`     | ✅           | solution.md mitigation section    | High    |
| `severity`            | ⚠️           | **Infer from vulnerability type** | Medium  |
| `difficulty_tier`     | ✅           | Level 1-4 maps to Tier 2-4        | High    |
| `has_poc`             | ✅           | All levels have PoC in solutions  | High    |

**Overall Extractability:** 85% automated, 15% manual curation

### Vulnerability Coverage

| Level   | Vulnerability Type               | Solana-Specific? | Difficulty |
| ------- | -------------------------------- | ---------------- | ---------- |
| Level 0 | Intro/Setup                      | N/A              | N/A        |
| Level 1 | Missing Signer Check             | ✅ Yes           | Tier 2     |
| Level 2 | Integer Overflow/Underflow       | ⚠️ General       | Tier 2     |
| Level 3 | Type Confusion (Account Cosplay) | ✅ Yes           | Tier 3     |
| Level 4 | Arbitrary CPI                    | ✅ Yes           | Tier 3     |

**Assessment:** Good coverage of fundamental Solana vulnerabilities, 3/4 are Solana-specific.

---

## Other CTF Challenges - NOT RECOMMENDED

### Why Skip? ❌

The solana-ctf repo contains 10+ additional challenges from various CTF events:

1. **allesctf21/** (3 challenges)
2. **cashio-exploit-workshop/**
3. **darksols/**
4. **HalbornCTF_Rust_Solana/**
5. **league-of-lamports/**
6. **moar-horse-5/**
7. **pool/**
8. **solfire/**
9. **solhana-ctf/** (3 challenges)

### Problems ⚠️

#### 1. **CTF Format, Not Educational**

- Designed for competitive hacking, not learning
- Minimal documentation
- No structured vulnerability descriptions
- Often require infrastructure setup (Docker, servers)

#### 2. **Complex Multi-File Structure**

- Not single-vulnerability focused
- Mix of framework code, challenge code, server code
- Difficult to isolate vulnerable code

#### 3. **Lack of Metadata**

- No clear vulnerability type labels
- No fix descriptions
- No severity ratings
- Would require extensive manual curation

#### 4. **Variable Code Quality**

- Some use C (darksols, league-of-lamports)
- Mix of native Solana and Anchor
- Varying documentation quality

### Example: HalbornCTF

```
HalbornCTF_Rust_Solana/
├── README.md       → "You must provide a PoC" (no hints given!)
└── ctf/
    └── src/
        ├── processor.rs (6021 bytes)
        ├── instruction.rs
        ├── state.rs
        └── [4 more files]
```

**Problems:**

- No vulnerability description
- No hints
- No solution provided
- Just a challenge to reverse-engineer
- Would require expert manual analysis

**Extraction Effort:** High (expert review needed per sample)  
**ROI:** Low (would take hours per sample)

---

## Comparison with Current Dataset

### Quality Benchmarks

| Metric                         | Current Solana (sealevel-attacks) | Neodyme Workshop    | Other CTFs       |
| ------------------------------ | --------------------------------- | ------------------- | ---------------- |
| Vulnerability descriptions     | ✅ 100%                           | ✅ 100%             | ❌ ~20%          |
| Fix descriptions               | ✅ 100%                           | ✅ 100%             | ❌ ~10%          |
| Clean code structure           | ✅ Yes                            | ✅ Yes              | ⚠️ Variable      |
| Single vulnerability focus     | ✅ Yes                            | ✅ Yes              | ❌ Often complex |
| Vulnerable line identification | ❌ 0%                             | ⚠️ Need manual work | ❌ 0%            |
| PoC availability               | ❌ 0%                             | ✅ 100%             | ⚠️ Variable      |
| Solana-specific                | ✅ 100%                           | ✅ 75%              | ⚠️ Variable      |

**Neodyme Workshop** matches or exceeds current quality standards! ✅

---

## Data Extraction Plan for Neodyme Workshop

### Phase 1: Manual Assessment (30 minutes)

**For each level (1-4):**

1. Read `levelX.md`, `levelX-bug.md`, `levelX-solution.md`
2. Identify:
   - Vulnerability type
   - Vulnerable function name
   - Approximate vulnerable lines
   - Severity
   - Difficulty tier

### Phase 2: Automated Extraction (Script)

**Process:**

1. Read source files (`lib.rs`, `processor.rs`)
2. Extract code content
3. Parse documentation for descriptions
4. Map level number to difficulty tier:
   - Level 1 → Tier 2 (Medium)
   - Level 2 → Tier 2 (Medium)
   - Level 3 → Tier 3 (Hard)
   - Level 4 → Tier 3/4 (Hard/Expert)

### Phase 3: Manual Refinement (1 hour)

**For each extracted sample:**

1. Manually identify exact vulnerable line numbers
2. Validate vulnerability type classification
3. Extract PoC code from solution docs
4. Verify difficulty tier assignment

### Expected Output

5 high-quality samples with:

- ✅ Complete metadata
- ✅ Vulnerable line identification (manual)
- ✅ PoC code extracted
- ✅ Fix descriptions
- ✅ Proper Solana taxonomy

---

## Impact on Dataset

### Current State

- **Solana samples:** 11 (sealevel-attacks)
- **Quality issues:** 0% vulnerable line identification

### After Neodyme Workshop Integration

- **Solana samples:** 16 (+5)
- **Unique vulnerability types:** +3 new types
  - Integer overflow/underflow
  - Arbitrary CPI
  - Type confusion variants
- **PoC coverage:** 31% (5/16 samples)
- **Still needs:** Vulnerable line fixing for sealevel-attacks samples

### Remaining Gap

- Target: 40-50 Solana samples (20% of Solidity count)
- Still need: 24-34 more samples
- **Cannot be filled from solana-ctf alone**

---

## Integration Recommendations

### ✅ DO THIS (Priority 1)

**Extract Neodyme Workshop Levels 1-4**

- **Why:** High-quality, well-documented, extractable
- **Effort:** Low (1-2 hours for all 5 levels)
- **ROI:** High (5 excellent samples + PoCs)
- **Risk:** Low (structured format, clear documentation)

### ❌ SKIP THIS

**Other CTF Challenges**

- **Why:** High extraction effort, low documentation
- **Effort:** High (3-4 hours per challenge to reverse-engineer)
- **ROI:** Low (uncertain quality, manual curation needed)
- **Risk:** High (may not meet quality standards)

### 🔄 CONSIDER LATER (Phase 3)

**Individual CTF Challenges with Good Docs**

If we still need more samples after:

1. Fixing sealevel-attacks vulnerable_lines
2. Extracting Neodyme Workshop
3. Evaluating other Solana educational resources

Then manually curate 1-2 well-documented CTF challenges:

- Cashio Exploit Workshop (has tutorial format)
- Solhana challenges (if well-documented)

---

## Quality Gates for Extraction

### Minimum Requirements (Neodyme Workshop PASSES ✅)

- [✅] Clear vulnerability type identification
- [✅] Extractable code samples
- [✅] Sufficient context to understand vulnerability
- [✅] License allows redistribution
- [✅] Vulnerability description available
- [✅] Fix/mitigation guidance provided

### Quality Targets (Neodyme Workshop Status)

- [✅] Vulnerable function identification → in docs
- [⚠️] Vulnerable line identification → manual work needed
- [✅] Severity ratings → can infer from vuln type
- [✅] Fix examples → in solution docs
- [✅] Structured format → excellent structure

### Excellence Markers (Neodyme Workshop PASSES ✅)

- [✅] PoC/exploit demonstrations → in solution docs
- [❌] Multiple versions (vulnerable/secure) → only vulnerable version
- [✅] Real-world context → educational scenarios
- [✅] Difficulty indicators → level 1-4 progression

---

## Comparison: Data Quality Matrix

### Source Quality Scores

| Source               | Documentation | Code Quality | Metadata | Extractability | **Total**       |
| -------------------- | ------------- | ------------ | -------- | -------------- | --------------- |
| **sealevel-attacks** | 9/10          | 9/10         | 7/10     | 8/10           | **33/40 (83%)** |
| **Neodyme Workshop** | 10/10         | 9/10         | 8/10     | 7/10           | **34/40 (85%)** |
| **Other CTFs**       | 3/10          | 7/10         | 2/10     | 3/10           | **15/40 (38%)** |

**Winner:** Neodyme Workshop (by small margin) ✅

---

## Proposed Action Items

### Immediate (This Session)

1. ✅ Create extraction script for Neodyme Workshop levels 1-4
2. ✅ Extract 5 samples
3. ✅ Manually identify vulnerable lines
4. ✅ Validate metadata quality
5. ✅ Update master dataset

### Phase 2 (Next Session)

1. ⚠️ Fix vulnerable_lines for existing sealevel-attacks samples (11 samples)
2. ⚠️ Extract secure/recommended versions from sealevel-attacks (22 additional samples)
3. ⚠️ Total Solana samples: 38 (11 + 11 + 11 + 5)

### Phase 3 (Future)

1. ⚠️ Evaluate other Solana educational resources:
   - Solana Cookbook examples
   - Anchor security examples
   - Real audit findings (manual curation)
2. ⚠️ Target: 50 total Solana samples

---

## Conclusion

**Neodyme Workshop: 9/10 - HIGHLY RECOMMENDED** ✅

### Why Extract It?

1. **Matches current quality standards** (85% score)
2. **Adds valuable PoC coverage** (currently 0%)
3. **Low extraction effort** (1-2 hours total)
4. **High confidence in metadata quality**
5. **Adds 3 new vulnerability types**

### Why Skip Other CTFs?

1. **High extraction effort** (3-4 hours each)
2. **Uncertain metadata quality**
3. **Would require expert reverse-engineering**
4. **Poor ROI** (effort vs. quality)

### Next Steps

**If you approve, I will:**

1. Create `process_neodyme_workshop.py` script
2. Extract levels 1-4 (5 samples)
3. Manually identify vulnerable lines
4. Add to master dataset
5. Update dashboard

**Estimated time:** 2-3 hours total

**Expected output:** 5 high-quality Solana samples with PoCs

---

## Appendix: Full Neodyme Workshop Details

### Level 1: Personal Vault

- **Vulnerability:** Missing Signer Check
- **Type:** `missing_signer_check`
- **Severity:** Critical
- **Difficulty:** Tier 2 (Medium)
- **File:** `level1/src/processor.rs` (105 lines)
- **PoC:** Available in `docs/level1-solution.md`

### Level 2: Secure Personal Vault

- **Vulnerability:** Integer Overflow/Underflow
- **Type:** `arithmetic_overflow`
- **Severity:** High
- **Difficulty:** Tier 2 (Medium)
- **File:** `level2/src/processor.rs`
- **PoC:** Available in `docs/level2-solution.md`

### Level 3: Tip Pool

- **Vulnerability:** Type Confusion (Account Cosplay)
- **Type:** `type_cosplay` or `account_type_confusion`
- **Severity:** Critical
- **Difficulty:** Tier 3 (Hard)
- **File:** `level3/src/processor.rs`
- **PoC:** Available in `docs/level3-solution.md`

### Level 4: SPL Token Vault

- **Vulnerability:** Arbitrary CPI
- **Type:** `arbitrary_cpi` or `cpi_injection`
- **Severity:** Critical
- **Difficulty:** Tier 3/4 (Hard/Expert)
- **File:** `level4/src/processor.rs`
- **PoC:** Available in `docs/level4-solution.md`
