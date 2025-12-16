# Annotated Dataset

<p align="center">
  <img src="../../assets/mascot.svg" alt="BlockBench" width="64" height="64">
</p>

The annotated dataset contains contracts with comprehensive vulnerability labeling, providing detailed ground truth for model evaluation and training.

## Contents

| Directory | Description |
|-----------|-------------|
| `contracts/` | Source files with optional inline annotations |
| `metadata/` | Extended JSON metadata with detailed vulnerability information |
| `index.json` | Dataset manifest with statistics and sample listing |

## Metadata Schema

Annotated metadata extends the base schema with additional fields:

- `vulnerable_function`: Name of the function containing the vulnerability
- `vulnerable_lines`: Array of line numbers where the vulnerability manifests
- `vulnerability_type`: Detailed classification (e.g., `weak_randomness`, `reentrancy`)
- `description`: Technical explanation of the vulnerability
- `fix_description`: Recommended remediation approach
- `difficulty_tier`: Complexity rating for detection (1-5)
- `context_level`: Required analysis scope (`single_file`, `multi_file`, `cross_contract`)

## Composition

| Prefix | Count | Description |
|--------|-------|-------------|
| `ds_*` | 235 | Difficulty-stratified samples |
| `tc_*` | 50 | Temporal contamination samples |

## Use Cases

- Training supervised vulnerability detection models
- Evaluating model precision on labeled vulnerabilities
- Benchmarking line-level localization accuracy
- Assessing fix generation quality

## Generation

Annotations are manually curated by security researchers from:

- Trail of Bits Not-So-Smart-Contracts
- DeFiHackLabs exploit reproductions
- Audit competition findings (Code4rena, Sherlock)

---

*Part of the BlockBench Smart Contract Security Evaluation Framework*
