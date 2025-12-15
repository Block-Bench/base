# Temporal Contamination Probe Dataset

**Purpose:** Measure AI model memorization vs. genuine reasoning capabilities  
**Status:** 50 pre-cutoff samples complete, 3 proof-of-concept variants complete  
**Last Updated:** December 15, 2024

## Overview

This dataset tests whether AI models truly understand blockchain vulnerabilities or simply memorize known exploits. It uses temporal contamination testing—comparing performance on pre-cutoff exploits (likely in training data) versus post-cutoff exploits (definitely novel) and code variants.

## Dataset Structure

```
temporal_contamination/
├── README.md                    # This file (comprehensive overview)
├── pre_cutoff_originals/        # 50 famous exploits from 2016-2024
│   ├── annotated/               # Full documentation (50 .sol + 50 .json)
│   └── unannotated/             # Clean test samples (50 sample_NNN.sol + mapping.json)
└── proof_of_concept/            # 3 Euler Finance variants (original, renamed, simplified)
```

## Pre-Cutoff Originals (50 samples)

Famous exploits from before September 2025, representing $3.5B in total losses.

### Data Leakage Prevention

**Problem:** Annotated files leak answers through filenames and comments  
**Solution:** Separate annotated (for reference) from unannotated (for evaluation)

**Annotated folder:**
- Descriptive filenames (e.g., `ronin_bridge.sol`)
- Detailed vulnerability comments
- Complete attack documentation
- Comprehensive JSON metadata

**Unannotated folder:**
- Generic names (`sample_001.sol`, `sample_002.sol`, etc.)
- No vulnerability-revealing comments
- Only production-level documentation
- Mapping file links back to annotated versions

### Sample Distribution

**Vulnerability Types:**
- Access Control: 15 samples (30%)
- Price Oracle Manipulation: 10 samples (20%)
- Reentrancy: 6 samples (12%)
- Arithmetic Errors: 5 samples (10%)
- Other: 14 samples (28%)

**Temporal Coverage:**
- 2016-2017: 2 samples
- 2020-2021: 17 samples
- 2022: 11 samples
- 2023: 2 samples
- 2024: 18 samples

**Top 5 Largest Exploits:**
1. Ronin Bridge: $625M
2. Poly Network: $611M
3. PlayDapp: $290M
4. Nomad Bridge: $190M
5. Beanstalk: $182M

### Usage for AI Evaluation

**For Testing:**
- Use only `unannotated/` folder files
- Provide models with `sample_XXX.sol` files
- Do NOT reveal mapping to annotated versions
- Do NOT include JSON metadata during evaluation

**For Reference:**
- Use `annotated/` folder for full documentation
- Consult JSON metadata for exploit details
- Review attack vectors and mitigations

## Proof of Concept (3 samples)

Demonstrates the variant approach using Euler Finance ($197M, March 2023).

**Included:**
- `euler_original.sol` - Complete vulnerable lending contract (151 lines)
- `euler_renamed.sol` - Same logic, all identifiers renamed (127 lines)
- `euler_simplified.sol` - Core vulnerability only (58 lines)

**Testing Hypothesis:**
- If model passes original but fails variants → memorization, not reasoning
- If model passes all → true understanding of vulnerability patterns
- If model needs context → context-dependent reasoning

## Evaluation Protocol

### Task for AI Models

"Review the following smart contract and identify any security vulnerabilities. For each vulnerability found:
1. Describe the vulnerability type
2. Identify the vulnerable function(s)
3. Specify the vulnerable line numbers
4. Explain the potential exploit
5. Suggest a fix"

### Scoring Metrics

**True Positive:** Correctly identifies vulnerability in unannotated code  
**False Negative:** Misses vulnerability (memorization OR reasoning failure)  
**False Positive:** Flags non-vulnerable code as vulnerable

### Temporal Contamination Analysis

**Pre-cutoff samples (2016-2024):**
- Models may have seen these in training data
- High detection rate likely indicates memorization
- Variant detection rates reveal memorization vs. reasoning

**Post-cutoff samples (Sept 2025+):**
- Models should NOT have seen these
- Detection rate reveals true reasoning capability
- Compare against pre-cutoff to measure contamination

## File Formats

### Annotated Solidity Files
- Complete vulnerable contracts with inline vulnerability documentation
- Function-level comments explaining attack vectors
- Root cause analysis
- Suggested fixes and mitigations

### Annotated JSON Metadata
```json
{
  "sample_id": "sample_001",
  "exploit_name": "Nomad Bridge",
  "timestamp": "2022-08",
  "loss_amount_usd": 190000000,
  "blockchain": "ethereum",
  "vulnerability_type": "improper_initialization",
  "severity": "critical",
  "tags": ["bridge", "cross_chain", "validation"],
  "difficulty": "intermediate",
  "temporal_category": "pre_cutoff",
  "description": "...",
  "vulnerability_details": { ... },
  "attack_flow": [ ... ],
  "mitigation": [ ... ],
  "references": [ ... ]
}
```

### Unannotated Files
- Generic `sample_NNN.sol` filenames
- No vulnerability hints in comments or names
- Functional code with standard documentation
- Preserved vulnerability patterns

### Mapping File (unannotated/mapping.json)
```json
{
  "samples": [
    {
      "unannotated_id": "sample_001",
      "unannotated_file": "sample_001.sol",
      "annotated_file": "nomad_bridge.sol",
      "exploit_name": "Nomad Bridge",
      "date": "2022-08",
      "amount_lost_usd": "190000000",
      "vulnerability_type": "improper_initialization"
    }
  ]
}
```

## Next Steps

### Planned Additions

1. **Create variants** for 10 most famous pre-cutoff exploits
   - Renamed versions (identifiers changed)
   - Simplified versions (core vulnerability only)
   - Obfuscated versions (equivalent but harder to recognize)

2. **Post-cutoff exploits** (~20-25 samples from Sept 2025+)
   - Novel exploits definitely not in training data
   - Direct comparison with pre-cutoff for contamination measurement

3. **Processing scripts**
   - Automated validation
   - Metadata consistency checks
   - Dataset statistics generation

4. **Standardization**
   - Ensure all samples follow JSON schema
   - Validate temporal categories
   - Quality assurance checks

## Quality Standards

**All samples must include:**
- ✓ Accurate historical data (dates, amounts, references)
- ✓ Verified vulnerability patterns
- ✓ Complete metadata following schema
- ✓ Clean unannotated versions without hints
- ✓ Proper mapping between annotated/unannotated
- ✓ Difficulty tier classification
- ✓ Tags for filtering and analysis

## Additional Documentation

For detailed information, see support documentation:
- `/support/temporal_contamination/DATASET_SUMMARY.txt` - Complete 50-sample summary
- `/support/temporal_contamination/pre_cutoff_originals_README.md` - Original detailed README
- `/support/temporal_contamination/proof_of_concept_README.md` - POC variant analysis
- `/support/temporal_contamination/*.txt` - Progress reports and batch summaries

## Research Context

This dataset supports research on:
- AI model memorization vs. generalization
- Temporal data contamination in training data
- Transfer learning in security vulnerability detection
- Code understanding vs. pattern matching in LLMs

**Citation:** BlockBench - Temporal Contamination Probe Dataset, 2024

## Contact

For questions or contributions regarding this dataset, refer to project documentation.
