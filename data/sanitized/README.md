# Sanitized Dataset

<p align="center">
  <img src="../../assets/mascot.svg" alt="BlockBench" width="64" height="64">
</p>

The sanitized dataset contains contracts with vulnerability-hinting patterns removed, designed to evaluate model reasoning capabilities independent of superficial cues.

## Contents

| Directory | Description |
|-----------|-------------|
| `contracts/` | Sanitized source files (sn_* naming) |
| `metadata/` | JSON metadata with transformation references |
| `index.json` | Dataset manifest with statistics and sample listing |

## Naming Convention

- `sn_ds_001.sol` - Sanitized version of `ds_001`
- `sn_tc_042.sol` - Sanitized version of `tc_042`

## Transformations Applied

The sanitization process removes patterns that could enable shortcut learning:

1. **Identifier Renaming**: Contract, function, and variable names that reveal vulnerability types (e.g., `ReentrancyVault` becomes `TokenVault`)
2. **Comment Removal**: Hint comments describing vulnerabilities or attack vectors
3. **Console Log Sanitization**: Debug statements referencing exploits
4. **Raw Text Replacement**: File headers and documentation mentioning vulnerability types

## Metadata Schema

Each metadata file includes:

- `id`: Sanitized identifier (e.g., `sn_ds_001`)
- `contract_file`: Path to sanitized source
- `original_contract_file`: Reference to base dataset source
- `sanitized_from`: Original contract identifier

## Generation

Run the sanitization strategy:

```bash
python -m strategies.base.sanitize all
```

Configuration and replacement patterns are defined in `strategies/base/sanitize.py`.

---

*Part of the BlockBench Smart Contract Security Evaluation Framework*
