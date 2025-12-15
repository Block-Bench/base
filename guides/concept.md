# Evaluating AI Domain Expertise in Blockchain Security

## Research Overview

### Objective

Develop a rigorous benchmark to evaluate whether large language models (LLMs) can genuinely reason about smart contract security vulnerabilities, or if they are merely pattern-matching on memorized examples.

### Target Venue

NeurIPS (Datasets & Benchmarks track recommended)

### Core Research Questions

1. What is the boundary between memorization and generalization in AI vulnerability detection?
2. Can AI models reason about emergent vulnerabilities, or only recognize known patterns?
3. How does explanation quality correlate with detection accuracy?
4. How does performance degrade as reasoning context expands?

---

## Dataset Design

### Target Size

**500 tasks minimum** for statistical validity at NeurIPS level

### Dataset Composition

| Subset                          | Source                         | Purpose                             | Count   |
| ------------------------------- | ------------------------------ | ----------------------------------- | ------- |
| Ground Truth Gold Standard      | Code4rena/Sherlock (Aug 2025+) | Contamination-free evaluation       | 150-200 |
| Adversarial Contrastive Pairs   | Self-generated variants        | Test generalization vs memorization | 150-200 |
| Difficulty Stratified Canonical | SmartBugs, SWC, DeFiVulnLabs   | Baseline + difficulty analysis      | 100-150 |
| Temporal Contamination Probe    | Famous exploits + variants     | Measure memorization empirically    | 50      |

### Vulnerability Categories (Target 10-12)

| Category                   | Target Count | Priority             |
| -------------------------- | ------------ | -------------------- |
| Reentrancy                 | 50-60        | High                 |
| Access Control             | 50-60        | High                 |
| Integer Overflow/Underflow | 40-50        | High                 |
| Oracle Manipulation        | 40-50        | High (DeFi-relevant) |
| Flash Loan Attacks         | 30-40        | Medium               |
| Front-running/MEV          | 30-40        | Medium               |
| Logic Errors               | 40-50        | High                 |
| Denial of Service          | 30-40        | Medium               |
| Signature Issues           | 20-30        | Medium               |
| Upgrade Vulnerabilities    | 20-30        | Medium               |

---

## Model Knowledge Cutoff Dates

Critical for avoiding data contamination.

### Major Models (as of Dec 2025)

| Model                    | Knowledge Cutoff                         | Notes                                               |
| ------------------------ | ---------------------------------------- | --------------------------------------------------- |
| Claude Sonnet 4.5        | Jan 2025 (reliable), Jul 2025 (training) | Anthropic distinguishes reliable vs training cutoff |
| Claude Opus 4.5          | Mar 2025 (reliable), Aug 2025 (training) |                                                     |
| Claude Sonnet 4 / Opus 4 | Mar 2025                                 |                                                     |
| GPT-5                    | Oct 1, 2024                              |                                                     |
| GPT-5.2                  | Aug 31, 2025                             | Released Dec 2025                                   |
| Gemini 2.5 Pro           | Jan 2025                                 |                                                     |
| Gemini 3                 | Jan 2025                                 |                                                     |
| DeepSeek-R1              | Jan 2025                                 |                                                     |
| Llama 4                  | Aug 2024                                 |                                                     |

### Reference Resource

- GitHub: https://github.com/HaoooWang/llm-knowledge-cutoff-dates

### Implication for Dataset

- **Safe for all models**: Audits from Sept 2025 onward
- **Risky**: Audits from early 2024 (likely contaminated)

---

## API Evaluation Setup

### Key Points

- Default API calls have **NO internet access** (use training data only)
- Do not enable web search / browsing / grounding tools
- Document: API version, model snapshot, temperature settings

### Example API Calls

```python
# Anthropic - no tools = no web search
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    messages=[{"role": "user", "content": prompt}]
)

# OpenAI - standard call without browsing
response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## Data Sources

### Tier 1: Competitive Audit Platforms (Primary Sources)

| Platform         | Reports URL                   | Code Repos                                       | Notes                           |
| ---------------- | ----------------------------- | ------------------------------------------------ | ------------------------------- |
| **Code4rena**    | https://code4rena.com/reports | `github.com/code-423n4/{year}-{month}-{project}` | Public reports + full codebases |
| **Sherlock**     | https://audits.sherlock.xyz   | `github.com/sherlock-audit/{project}-judging`    | High-quality judged findings    |
| **Cantina**      | https://cantina.xyz           | Varies                                           | Growing archive                 |
| **Hats Finance** | https://hats.finance          | Varies                                           | Decentralized bounties          |

### Tier 2: Aggregators (Time-Savers)

| Platform         | URL                                        | Description                                                                                                          |
| ---------------- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| **Solodit**      | https://solodit.cyfrin.io                  | **Best resource** - aggregates Code4rena, Sherlock, Trail of Bits, Consensys, etc. Filter by severity, type, keyword |
| **DeFiHackLabs** | https://github.com/SunWeb3Sec/DeFiHackLabs | Reproducible PoCs of real exploits                                                                                   |
| **Rekt.news**    | https://rekt.news                          | Post-mortems with technical analysis                                                                                 |

### Tier 3: Bug Bounty Writeups

| Platform              | URL                                                           | Notes                   |
| --------------------- | ------------------------------------------------------------- | ----------------------- |
| **Immunefi**          | https://immunefi.com                                          | Largest bounty platform |
| **Immunefi Writeups** | https://github.com/sayan011/Immunefi-bug-bounty-writeups-list | Curated public reports  |

### Tier 4: Professional Audit Firm Reports

| Firm                | Reports Location                              |
| ------------------- | --------------------------------------------- |
| Trail of Bits       | https://github.com/trailofbits/publications   |
| OpenZeppelin        | https://blog.openzeppelin.com/security-audits |
| Consensys Diligence | https://consensys.io/diligence/audits         |

### Tier 5: Curated Vulnerability Datasets

```bash
# Clone these immediately
git clone https://github.com/smartbugs/smartbugs-curated
git clone https://github.com/crytic/not-so-smart-contracts
git clone https://github.com/SunWeb3Sec/DeFiVulnLabs
```

---

## Context Handling Strategy

### The Problem

Some vulnerabilities require multi-contract context to understand. A bug in `StabilityPool.sol` may only make sense when you see how `BorrowerOperations.sol` calls it.

### Context Levels

| Level           | What's Included                          | Example                              |
| --------------- | ---------------------------------------- | ------------------------------------ |
| **Single file** | Just the vulnerable contract             | Simple reentrancy in one function    |
| **Multi-file**  | Primary + dependent contracts            | Cross-contract call exploitation     |
| **System**      | Multiple contracts + interaction summary | Flash loan + oracle + callback chain |

### Recommended Approach

Label each task by context level and provide appropriate context:

```json
{
  "id": "c4_bitvault_001",
  "context_level": "cross_contract",

  "primary_file": {
    "name": "StabilityPool.sol",
    "content": "<full contents>",
    "vulnerable_lines": [245, 267]
  },

  "context_files": [
    {
      "name": "BorrowerOperations.sol",
      "content": "<full contents>",
      "relevance": "Calls StabilityPool.withdraw() during liquidation"
    },
    {
      "name": "PriceFeed.sol",
      "content": "<full contents>",
      "relevance": "Oracle that StabilityPool depends on"
    }
  ],

  "context_hint": "This vulnerability requires understanding how BorrowerOperations.liquidate() triggers StabilityPool.withdraw(), and how PriceFeed values are used in collateral calculations.",

  "vulnerability_type": "oracle_manipulation",
  "severity": "high",
  "ground_truth": "<finding description from report>"
}
```

### Experimental Design

Run experiments with varying context levels:

- Model given only primary file
- Model given all contracts, no hint
- Model given all contracts + hint

The delta between these conditions is scientifically interesting.

---

## Adversarial Contrastive Pairs

### Purpose

Distinguish genuine reasoning from pattern matching.

### For Each Vulnerable Contract, Create:

| Variant                  | Description                        | What It Tests                       |
| ------------------------ | ---------------------------------- | ----------------------------------- |
| A: Original              | Vulnerable code                    | Baseline detection                  |
| B: Minimally Patched     | Fixed version                      | Does model recognize the fix?       |
| C: Cosmetically Modified | Same bug, different variable names | Is model fooled by surface changes? |
| D: Decoy Pattern         | Looks vulnerable but isn't         | False positive reasoning            |

### Example: Reentrancy

```solidity
// A: Vulnerable (ground truth)
function withdraw() external {
    uint bal = balances[msg.sender];
    (bool success,) = msg.sender.call{value: bal}("");
    balances[msg.sender] = 0;
}

// B: Patched (safe) - CEI pattern
function withdraw() external {
    uint bal = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool success,) = msg.sender.call{value: bal}("");
}

// C: Cosmetic change (still vulnerable)
function withdrawFunds() external {
    uint amount = userBalances[msg.sender];
    (bool sent,) = msg.sender.call{value: amount}("");
    userBalances[msg.sender] = 0;
}

// D: Decoy (looks suspicious but safe)
function withdraw() external nonReentrant {
    uint bal = balances[msg.sender];
    (bool success,) = msg.sender.call{value: bal}("");
    balances[msg.sender] = 0;
}
```

A model that truly understands should get all four right.

---

## Data Schema

### Single-Contract Vulnerability

```json
{
  "id": "string (unique identifier)",
  "source": "code4rena | sherlock | immunefi | synthetic | ...",
  "contest": "string (e.g., 2025-04-bitvault)",
  "date_discovered": "ISO date",
  "post_cutoff_for": ["gpt-5", "claude-sonnet-4", "..."],

  "context_level": "single_file | intra_contract | cross_contract | system",

  "file": "string (filename)",
  "full_contract": "string (entire file contents)",
  "vulnerable_function": "string (function name)",
  "vulnerable_lines": [int, int],

  "vulnerability_type": "reentrancy | access_control | oracle_manipulation | ...",
  "severity": "critical | high | medium | low",
  "difficulty_tier": 1 | 2 | 3 | 4,

  "finding_description": "string (ground truth explanation)",
  "is_contrastive_variant": false,
  "contrastive_parent_id": null,
  "contrastive_type": null
}
```

### Multi-Contract Vulnerability

```json
{
  "id": "string",
  "source": "string",
  "contest": "string",
  "context_level": "cross_contract",

  "primary_file": {
    "name": "string",
    "content": "string",
    "vulnerable_lines": [int, int]
  },

  "context_files": [
    {
      "name": "string",
      "content": "string",
      "relevance": "string (why this file matters)"
    }
  ],

  "context_hint": "string (high-level description of interactions)",
  "call_flow": ["Step 1", "Step 2", "..."],

  "vulnerability_type": "string",
  "severity": "string",
  "ground_truth": "string"
}
```

### Contrastive Variant

```json
{
  "id": "c4_bitvault_001_patched",
  "is_contrastive_variant": true,
  "contrastive_parent_id": "c4_bitvault_001",
  "contrastive_type": "patched | cosmetic | decoy",

  "file": "StabilityPool_patched.sol",
  "full_contract": "<modified contents>",

  "is_vulnerable": false,
  "expected_model_response": "No vulnerability - the CEI pattern prevents reentrancy"
}
```

---

## One-Week Sprint Plan

### Day 1-2: Existing Datasets + Solodit

**Morning Day 1:**

```bash
git clone https://github.com/smartbugs/smartbugs-curated
git clone https://github.com/crytic/not-so-smart-contracts
git clone https://github.com/SunWeb3Sec/DeFiVulnLabs
```

**Afternoon Day 1 - Day 2:**

- Use Solodit (https://solodit.cyfrin.io)
- Filter: High/Critical severity, 2025, Solidity
- Export 150-200 findings with code links
- Standardize into JSON schema

**Output:** ~200 labeled samples

### Day 2-3: Code4rena Recent Audits

```bash
# Clone recent contests (post-cutoff)
for repo in 2025-10-covenant 2025-11-megapot 2025-11-sukukfi 2025-11-garden; do
  git clone https://github.com/code-423n4/$repo
done
```

- Match published findings to code files
- Extract vulnerable functions + full contracts
- Record severity, type, context level

**Output:** ~150 labeled samples

### Day 4-5: Adversarial Variant Generation

- Select 40 clearest vulnerabilities
- For each, create:
  - 1 patched version (safe)
  - 1 cosmetic variant (still vulnerable)
  - 0.5-1 decoy patterns (looks bad, actually safe)

**Output:** ~120 contrastive samples

### Day 6: Balance and Stratify

- Ensure ~50% vulnerable, ~50% safe
- Tag difficulty levels (Tier 1-4)
- Fill category gaps
- Add contamination probe set (famous exploits)

**Output:** Balanced dataset of ~500 tasks

### Day 7: Format and Validate

- Finalize JSON schema
- Sanity check 10% random sample
- Write datasheet documentation
- Prepare evaluation scripts

---

## Evaluation Methodology

### Metrics to Report

| Metric                   | Description                         |
| ------------------------ | ----------------------------------- |
| Detection Accuracy       | Overall correct identification      |
| Precision                | TP / (TP + FP)                      |
| Recall                   | TP / (TP + FN)                      |
| F1 Score                 | Harmonic mean of precision/recall   |
| Per-category breakdown   | Performance by vulnerability type   |
| Per-difficulty breakdown | Performance by tier                 |
| Contrastive accuracy     | Performance on adversarial variants |
| Explanation quality      | Human-rated reasoning soundness     |

### Experimental Conditions

1. **Context ablation**: Single file vs multi-file vs full context
2. **Prompt variations**: Zero-shot vs few-shot vs chain-of-thought
3. **Temporal analysis**: Pre-cutoff vs post-cutoff performance
4. **Model comparison**: 6-10 models across providers

### Statistical Rigor

- Report confidence intervals
- Use appropriate significance tests (McNemar's for paired comparisons)
- Multiple comparisons correction if needed
- Effect size reporting

---

## Novelty Angle for Publication

### Primary Contribution

A methodology for distinguishing **memorization vs. generalization** in LLM security reasoning, using adversarial contrastive evaluation.

### Key Findings to Aim For

1. "Models perform at X level on known patterns but degrade to Y on post-cutoff vulnerabilities"
2. "Contrastive accuracy reveals models are pattern-matching, not reasoning"
3. "Performance degrades sharply when cross-contract context is required"
4. "Explanation quality correlates weakly with detection accuracy"

### What Reviewers Will Care About

- Reproducible benchmark others can build on
- Clear taxonomy of expertise levels
- Human baseline comparison (if possible)
- Actionable insights for practitioners

---

## Appendix: Useful Commands

### Clone Multiple Code4rena Repos

```bash
#!/bin/bash
repos=(
  "2025-01-next-generation"
  "2025-02-thorwallet"
  "2025-04-bitvault"
  "2025-04-virtuals-protocol"
  "2025-10-covenant"
  "2025-11-megapot"
)

for repo in "${repos[@]}"; do
  git clone "https://github.com/code-423n4/$repo"
done
```

### Extract Solidity Imports

```python
import re

def extract_imports(solidity_code):
    pattern = r'import\s+["\'](.+?)["\']|import\s+\{.+?\}\s+from\s+["\'](.+?)["\']'
    matches = re.findall(pattern, solidity_code)
    return [m[0] or m[1] for m in matches]
```

### Find External Calls

```python
def extract_external_calls(solidity_code):
    pattern = r'(\w+)\([^)]*\)\.\w+\('
    return list(set(re.findall(pattern, solidity_code)))
```

---

## References

- Code4rena Reports: https://code4rena.com/reports
- Sherlock Reports: https://github.com/sherlock-protocol/sherlock-reports
- Solodit: https://solodit.cyfrin.io
- LLM Cutoff Dates: https://github.com/HaoooWang/llm-knowledge-cutoff-dates
- SmartBugs: https://github.com/smartbugs/smartbugs-curated
- DeFiVulnLabs: https://github.com/SunWeb3Sec/DeFiVulnLabs
- DeFiHackLabs: https://github.com/SunWeb3Sec/DeFiHackLabs
- SWC Registry: https://swcregistry.io
- Immunefi Top 10: https://immunefi.com/immunefi-top-10/
- Rekt News: https://rekt.news

---

_Document generated: December 2025_
_Project: AI Domain Expertise Evaluation in Blockchain Security_
