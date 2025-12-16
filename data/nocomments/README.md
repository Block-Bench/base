# No-Comments Dataset

<p align="center">
  <img src="../../assets/mascot.svg" alt="BlockBench" width="64" height="64">
</p>

The no-comments dataset contains contracts with all comments removed, providing a minimal evaluation surface focused purely on code structure and logic.

## Contents

| Directory | Description |
|-----------|-------------|
| `contracts/` | Comment-stripped source files (nc_* naming) |
| `metadata/` | JSON metadata with transformation references |
| `index.json` | Dataset manifest with statistics and sample listing |

## Naming Convention

- `nc_ds_001.sol` - No-comments version derived from `sn_ds_001`
- `nc_tc_042.sol` - No-comments version derived from `sn_tc_042`

## Transformations Applied

All comment patterns are removed:

- Single-line comments (`//`)
- Multi-line comments (`/* */`)
- NatSpec documentation (`/** */`, `///`)
- Rust documentation comments (`//!`, `///`)

## Metadata Schema

Each metadata file includes:

- `id`: No-comments identifier (e.g., `nc_ds_001`)
- `contract_file`: Path to comment-stripped source
- `original_contract_file`: Reference to base dataset source
- `derived_from`: Sanitized contract identifier (sn_*)
- `original_id`: Base contract identifier

## Transformation Chain

```
base (ds_001) -> sanitized (sn_ds_001) -> nocomments (nc_ds_001)
```

## Generation

Run the no-comments transformation:

```bash
python -m strategies.nocomments.nocomment all
```

Configuration is defined in `strategies/nocomments/nocomment.py`.

---

*Part of the BlockBench Smart Contract Security Evaluation Framework*
