# CLAUDE.md - Project Context for AI Assistant

## Project Overview

This is a research project to evaluate AI domain expertise in blockchain/smart contract security. The goal is to create a 500-task benchmark dataset for NeurIPS publication that can distinguish whether LLMs genuinely reason about vulnerabilities or merely pattern-match on memorized examples.

## Key Decisions Made

### Dataset Composition (500 tasks total)

- 150-200: Ground truth from Code4rena/Sherlock (Sept 2025+ for contamination-free)
- 150-200: Adversarial contrastive pairs (patched, cosmetic variants, decoys)
- 100-150: Difficulty-stratified canonical examples (SmartBugs, DeFiVulnLabs)
- 50: Temporal contamination probes

### Model Cutoff Dates (Critical for Contamination)

- Claude Sonnet 4.5: Jan 2025 reliable, Jul 2025 training
- GPT-5: Oct 1, 2024
- GPT-5.2: Aug 31, 2025
- Gemini 2.5/3: Jan 2025
- **Safe threshold: Use audits from Sept 2025 onward**

### Vulnerability Taxonomy (Cross-Language)

**Universal (All Languages)**

- reentrancy, access_control, integer_issues, logic_error, dos, oracle_manipulation

**Solidity-Specific**

- delegatecall_injection, storage_collision, tx_origin_auth, unchecked_return

**Rust/Solana-Specific**

- missing_signer_check, missing_owner_check, account_validation, pda_manipulation
- cpi_injection, state_desync_after_cpi, unclosed_accounts, type_cosplay

**Move-Specific (Sui/Aptos)**

- unrestricted_capability, resource_duplication, resource_leakage
- missing_reinitialization_guard, entry_function_validation

### Inclusion Criteria

- **Multi-language**: Solidity (EVM), Rust (Solana/NEAR), Move (Sui/Aptos), Cairo (Starknet)
- High + Medium severity only
- Confirmed/Acknowledged findings only
- Must have full source code available
- Must have clear bug, clear label, clear fix
- Exclude: gas optimizations, informational, centralization risks, duplicates

## Data Sources

### Multi-Language Audit Platforms

| Platform      | Languages                   | URL                           |
| ------------- | --------------------------- | ----------------------------- |
| **Code4rena** | Solidity, Rust, Move, Cairo | https://code4rena.com/reports |
| **Sherlock**  | Primarily Solidity          | https://audits.sherlock.xyz   |
| **Cantina**   | Solidity, Rust, Move        | https://cantina.xyz           |
| **Solodit**   | Aggregates all languages    | https://solodit.cyfrin.io     |

### Language-Specific Sources

**Solidity (EVM)**

- Code4rena: github.com/code-423n4/{contest}
- Sherlock: github.com/sherlock-audit/{project}-judging
- SmartBugs: github.com/smartbugs/smartbugs-curated
- DeFiVulnLabs: github.com/SunWeb3Sec/DeFiVulnLabs

**Rust (Solana/Anchor/NEAR)**

- Solana Security: github.com/sannykim/solsec
- Neodyme Workshop: github.com/neodyme-labs/solana-security-workshop
- Rust SC Vulns: github.com/elmhamed/smart-contracts-vulns
- Sec3 Blog: sec3.dev/blog (PoCs and tutorials)

**Move (Sui/Aptos)**

- MoveBit Audits: movebit.xyz (Aptos/Sui specialist)
- CertiK Move Reports: certik.com (search Move/Aptos/Sui)
- Sui Incidents: \$226M in exploits documented (Cetus, etc.)

**Cairo (Starknet)**

- Starknet audits on Code4rena
- Cairo-specific security patterns emerging

### Existing Datasets to Clone

```bash
git clone https://github.com/smartbugs/smartbugs-curated
git clone https://github.com/crytic/not-so-smart-contracts
git clone https://github.com/SunWeb3Sec/DeFiVulnLabs
git clone https://github.com/SunWeb3Sec/DeFiHackLabs
```

## Data Schema

### Required Fields

```json
{
  "id": "unique_id",
  "language": "solidity | rust | move | cairo",
  "chain": "evm | solana | sui | aptos | starknet | near",
  "source_platform": "code4rena | sherlock | solodit | cantina",
  "source_url": "link to finding",
  "contest_name": "2025-10-example",
  "contest_date": "2025-10-15",
  "severity": "critical | high | medium",
  "vulnerability_type": "reentrancy | missing_signer_check | ...",
  "context_level": "single_file | intra_contract | cross_contract",
  "primary_file_name": "Vault.sol | vault.rs | vault.move",
  "primary_file_content": "<full source>",
  "vulnerable_function": "withdraw()",
  "finding_description": "<auditor explanation>",
  "fix_description": "<how it was fixed>",
  "is_vulnerable": true
}
```

### For Multi-Contract Vulnerabilities

```json
{
  "context_files": [
    { "name": "Helper.sol", "content": "...", "relevance": "Called by primary" }
  ],
  "context_hint": "Plain English explanation of how contracts interact"
}
```

### For Contrastive Variants

```json
{
  "is_contrastive_variant": true,
  "contrastive_parent_id": "original_id",
  "contrastive_type": "patched | cosmetic | decoy",
  "is_vulnerable": false
}
```

## Directory Structure

```
dataset/
├── raw/                    # Scraped data by source
│   ├── code4rena/
│   ├── sherlock/
│   └── solodit/
├── processed/              # Cleaned and standardized
│   ├── single_file/
│   ├── multi_file/
│   └── contrastive/
├── metadata/
│   └── all_findings.json   # Master index
└── scripts/
    ├── scrape_code4rena.py
    ├── scrape_sherlock.py
    └── generate_variants.py
```

## Current Task

Building the data collection pipeline. Next steps:

1. Manually collect 10 samples to validate schema
2. Build scraper for Code4rena recent audits
3. Build scraper for Solodit aggregated findings
4. Generate adversarial contrastive variants

## Important Context

### Adversarial Contrastive Pairs (Core Novelty)

For each vulnerable contract, create variants:

- **Patched**: Fixed version (tests if model recognizes fix)
- **Cosmetic**: Same bug, different variable names (tests surface-level matching)
- **Decoy**: Looks vulnerable but isn't (tests false positive reasoning)

### Context Levels

- **single_file**: Bug identifiable within one contract
- **intra_contract**: Requires multiple functions in same contract
- **cross_contract**: Requires understanding multiple contracts interacting

### API Evaluation Setup

- Models called via API have NO internet by default
- Don't enable web_search / browsing tools
- Document: model version, temperature, exact prompts

## References

- Full research plan: see RESEARCH_PLAN.md
- LLM cutoffs: https://github.com/HaoooWang/llm-knowledge-cutoff-dates
- SWC Registry: https://swcregistry.io
