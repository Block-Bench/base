# Base Dataset

<p align="center">
  <img src="../../assets/mascot.svg" alt="BlockBench" width="64" height="64">
</p>

The base dataset contains the original, unmodified smart contracts used as source material for all derived datasets in the BlockBench evaluation suite.

## Contents

| Directory | Description |
|-----------|-------------|
| `contracts/` | Original Solidity (.sol) and Rust (.rs) source files |
| `metadata/` | JSON metadata files with ground truth labels |
| `index.json` | Dataset manifest with statistics and sample listing |

## Composition

The base dataset consolidates contracts from two evaluation categories:

- **ds_*** (235 samples): Difficulty-stratified contracts organized by detection complexity
- **tc_*** (50 samples): Temporal contamination set featuring pre-cutoff DeFi exploits

## Schema

Each metadata file contains:

- `id`: Unique identifier (e.g., `ds_001`, `tc_042`)
- `contract_file`: Relative path to source file
- `ground_truth`: Vulnerability classification and location details
- `provenance`: Source attribution and discovery information
- `code_metadata`: Static analysis of contract structure

## Usage

This dataset serves as the canonical source for:

1. Generating sanitized variants (removal of vulnerability hints)
2. Creating comment-stripped versions for evaluation
3. Producing annotated copies with detailed labeling

## Generation

Base contracts are curated from established vulnerability databases and audit reports. No automated transformations are applied to this dataset.

---

*Part of the BlockBench Smart Contract Security Evaluation Framework*
