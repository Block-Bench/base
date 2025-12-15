# Multi-Language Smart Contract Vulnerability Collection Guide

## Before You Start Checklist

### 1. Core Criteria (Language-Agnostic)

- [ ] Clear bug with identifiable root cause
- [ ] Clear label (severity + vulnerability type)
- [ ] Clear fix (what changed to resolve it)
- [ ] Full source code available
- [ ] Confirmed/Acknowledged by project (not disputed)

### 2. What to Exclude

- Gas optimizations
- Informational findings
- Centralization risks (subjective)
- Duplicates (keep only primary)
- Findings marked "won't fix" by design

---

## Language-Specific Sources

### Solidity (EVM) — Most Abundant

| Source       | URL                                    | Notes                                  |
| ------------ | -------------------------------------- | -------------------------------------- |
| Code4rena    | code4rena.com/reports                  | Largest source, GitHub repos available |
| Sherlock     | audits.sherlock.xyz                    | High quality, judged findings          |
| Solodit      | solodit.cyfrin.io                      | Aggregates everything, searchable      |
| SmartBugs    | github.com/smartbugs/smartbugs-curated | ~140 curated samples                   |
| DeFiVulnLabs | github.com/SunWeb3Sec/DeFiVulnLabs     | With PoCs                              |
| DeFiHackLabs | github.com/SunWeb3Sec/DeFiHackLabs     | Real exploit reproductions             |

**Common Solidity Vulnerabilities:**

- Reentrancy (classic, read-only, cross-function)
- Access control (missing onlyOwner, tx.origin)
- Integer overflow/underflow
- Delegatecall injection
- Storage collision (proxies)
- Oracle manipulation
- Flash loan attacks
- Front-running / MEV

---

### Rust / Solana / Anchor — Growing Fast

| Source           | URL                                              | Notes                        |
| ---------------- | ------------------------------------------------ | ---------------------------- |
| SolSec           | github.com/sannykim/solsec                       | Comprehensive resource list  |
| Neodyme Workshop | github.com/neodyme-labs/solana-security-workshop | Exercises with solutions     |
| Rust SC Vulns    | github.com/elmhamed/smart-contracts-vulns        | Auditor-focused guide        |
| Sec3 Blog        | sec3.dev/blog                                    | PoCs and penetration testing |
| Code4rena        | Search "Solana" on code4rena.com                 | Growing number of contests   |
| Cantina          | cantina.xyz                                      | Solana audits available      |

**Common Solana/Rust Vulnerabilities:**

- Missing signer check
- Missing owner check
- Account validation failures
- PDA manipulation / seed collision
- CPI (Cross-Program Invocation) injection
- State desync after CPI
- Unclosed accounts (rent leak)
- Type cosplay (account substitution)
- Integer overflow (release mode doesn't check!)

**Solana-Specific Context:**

```rust
// Example: Missing signer check
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    // VULNERABLE: No check that authority is signer
    let authority = &ctx.accounts.authority;
    // Should have: require!(authority.is_signer, ErrorCode::Unauthorized);
    transfer_tokens(amount)?;
    Ok(())
}
```

---

### Move / Sui / Aptos — Emerging

| Source       | URL                       | Notes                      |
| ------------ | ------------------------- | -------------------------- |
| MoveBit      | movebit.xyz               | Sui/Aptos audit specialist |
| CertiK Move  | certik.com/resources/blog | Search "Move" or "Aptos"   |
| Three Sigma  | threesigma.xyz            | Move audit reports         |
| Cantina Blog | cantina.xyz/blog          | Sui security guide         |
| Code4rena    | Search "Sui" or "Aptos"   | Limited but growing        |

**Common Move Vulnerabilities:**

- Unrestricted capability access
- Missing reinitialization guards
- Resource duplication
- Resource leakage (not properly destroyed)
- Entry function validation failures
- Object ownership issues (Sui)
- Parallel execution race conditions

**Move-Specific Context:**
Move is resource-oriented (assets can't be copied/dropped accidentally), but:

- Developers often port Solidity patterns incorrectly
- Capability-based access control can be misconfigured
- Sui's object model introduces unique attack surfaces

**Notable Incidents:**

- Sui ecosystem: \$226M in DeFi exploits (Cetus hack largest)
- Aptos: One major exploit with full recovery

---

### Cairo / Starknet — Early Stage

| Source            | URL                          | Notes               |
| ----------------- | ---------------------------- | ------------------- |
| Code4rena         | Search "Starknet"            | Few contests so far |
| Starknet Security | Community resources emerging |

Cairo is still maturing — fewer public audit reports available.

---

## Data Schema (Updated for Multi-Language)

```json
{
  "id": "unique_id",
  "language": "solidity | rust | move | cairo",
  "chain": "evm | solana | sui | aptos | starknet | near",
  "framework": "hardhat | anchor | sui-move | aptos-move | null",

  "source_platform": "code4rena | sherlock | solodit | cantina | immunefi",
  "source_url": "https://...",
  "contest_name": "2025-10-example",
  "contest_date": "2025-10-15",

  "severity": "critical | high | medium",
  "vulnerability_type": "reentrancy | missing_signer_check | ...",
  "vulnerability_category": "universal | solidity_specific | rust_specific | move_specific",

  "context_level": "single_file | intra_contract | cross_contract",
  "primary_file": {
    "name": "vault.rs",
    "content": "<full source>",
    "vulnerable_lines": [45, 67]
  },
  "context_files": [],

  "finding_title": "Missing signer check allows unauthorized withdrawal",
  "finding_description": "<detailed auditor explanation>",
  "fix_description": "Added require!(authority.is_signer) check",
  "has_poc": true,
  "poc_code": "<if available>",

  "is_vulnerable": true,
  "is_contrastive_variant": false
}
```

---

## Suggested Distribution (500 tasks)

| Language         | Target    | Rationale                                |
| ---------------- | --------- | ---------------------------------------- |
| Solidity         | 300 (60%) | Most abundant data, established patterns |
| Rust/Solana      | 120 (24%) | Growing ecosystem, unique vuln types     |
| Move (Sui/Aptos) | 60 (12%)  | Emerging, novel security model           |
| Cairo            | 20 (4%)   | Limited data, include if available       |

This distribution:

- Reflects actual audit market composition
- Provides enough samples per language for analysis
- Tests cross-language generalization

---

## Research Angle: Language Comparison

**Interesting questions to answer:**

1. Do models trained on Solidity transfer to Rust/Move?
2. Are language-specific vulnerabilities harder to detect?
3. Does Move's safety model reduce vulnerability detection difficulty?
4. How does explanation quality vary by language?

This makes your paper more novel than Solidity-only benchmarks!

---

## Quick Start Commands

```bash
# Clone Solidity resources
git clone https://github.com/smartbugs/smartbugs-curated
git clone https://github.com/SunWeb3Sec/DeFiVulnLabs
git clone https://github.com/SunWeb3Sec/DeFiHackLabs

# Clone Rust/Solana resources
git clone https://github.com/sannykim/solsec
git clone https://github.com/neodyme-labs/solana-security-workshop
git clone https://github.com/elmhamed/smart-contracts-vulns

# Search Solodit for all languages
# https://solodit.cyfrin.io — filter by severity, search keywords
```

---

## Validation Before Finalizing

For each entry, verify:

- [ ] Code compiles (or did at time of audit)
- [ ] Vulnerability is actually present in the code shown
- [ ] Fix makes sense and addresses root cause
- [ ] Severity matches actual impact
- [ ] No duplicate of another entry
