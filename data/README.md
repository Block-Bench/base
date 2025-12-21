# BlockBench Data Repository

<p align="center">
  <img src="../assets/mascot.svg" alt="BlockBench" width="96" height="96">
</p>

<p align="center">
  <strong>Smart Contract Security Evaluation Datasets</strong>
</p>

---

## Overview

This directory contains the evaluation datasets for the BlockBench smart contract security benchmark. Each subdirectory represents a distinct dataset variant designed to assess different aspects of AI-based vulnerability detection.

## Dataset Structure

```
data/
├── base/           # Original unmodified contracts
├── annotated/      # Contracts with detailed vulnerability labeling
├── sanitized/      # Hint-removed contracts for adversarial evaluation
├── nocomments/     # Comment-stripped contracts for minimal evaluation
└── chameleon/      # Identifier-renamed contracts for semantic testing
```

## Datasets

### Base

The canonical source dataset containing original smart contracts. All derived datasets trace their lineage to this collection.

| Metric | Value |
|--------|-------|
| Total Samples | 285 |
| Solidity Contracts | 275 |
| Rust Contracts | 10 |

**Composition:**
- `ds_*` (235): Difficulty-stratified samples across five complexity tiers
- `tc_*` (50): Temporal contamination samples from pre-cutoff exploits
- `gs_*` (35): Gold standard samples from professional security audits

#### Multi-File Entries (Context Required)

The following gold standard entries require context files for proper vulnerability detection. These are **multi-file vulnerabilities** where the bug cannot be fully understood without examining related contracts. These entries should only be evaluated using the `base` dataset (not sanitized, nocomments, or other transformations).

| Entry ID | Context Files | Vulnerability Type |
|----------|---------------|-------------------|
| `gs_008` | VoterV3.sol | Interface treats mapping as function |
| `gs_011` | LockToVotePlugin.sol, LockManagerBase.sol | Flash loan via balanceOf check |
| `gs_012` | LockManagerBase.sol, MajorityVotingBase.sol | Early execution flash loan |
| `gs_014` | LockManagerBase.sol | Returns allowance not balance |
| `gs_015` | MajorityVotingBase.sol | isProposalOpen semantics |
| `gs_016` | LockManagerBase.sol | Missing action target validation |
| `gs_018` | MajorityVotingBase.sol | Flash-mintable totalSupply |
| `gs_019` | MidasRedemptionVaultPhantomToken.sol | No handling of rejected requests |
| `gs_021` | PancakeSwapInfinityKEMHook.sol | Missing domain separator |
| `gs_022` | UnorderedNonce.sol | Router-level signature (not user-level) |
| `gs_027` | Oracle.sol | Oracle staleness not checked |
| `gs_028` | UnstakeRequestsManager.sol | Rate fixed at request, not claim |
| `gs_030` | SessionSig.sol | Per-call signatures enable partial replay |
| `gs_031` | SessionManager.sol, BaseAuth.sol, Stage2Auth.sol | Missing wallet address in session hash |
| `gs_032` | BaseAuth.sol | Self-call changes msg.sender |
| `gs_033` | ISapient.sol | Returns hardcoded constant |
| `gs_035` | Locker.sol | Fees locked after unlock() |

Context files are located in `base/context/{entry_id}/` and referenced in each entry's metadata via the `context` and `context_files` fields.

**Why base only?** Sanitization renames identifiers which would break cross-file references. Since nocomments and other transformations derive from sanitized, context files would have mismatched references in those datasets.

### Annotated

Extended metadata with comprehensive vulnerability documentation. Includes line-level localization, severity ratings, and remediation guidance.

| Field | Description |
|-------|-------------|
| `vulnerable_function` | Function containing the vulnerability |
| `vulnerable_lines` | Specific line numbers |
| `difficulty_tier` | Detection complexity (1-5) |
| `fix_description` | Recommended remediation |

### Sanitized

Adversarial variants with vulnerability-hinting patterns removed. Designed to evaluate whether models rely on superficial cues rather than semantic understanding.

**Transformations:**
- Identifier renaming (280+ patterns)
- Comment removal (100+ patterns)
- Console log sanitization
- Raw text replacement

**Naming:** `sn_{original_id}` (e.g., `sn_ds_001`)

### No-Comments

Minimal evaluation surface with all comments stripped. Derived from sanitized contracts to provide the cleanest possible code for analysis.

**Transformations:**
- Single-line comment removal (`//`)
- Multi-line comment removal (`/* */`)
- Documentation comment removal (`/** */`, `///`)

**Naming:** `nc_{original_id}` (e.g., `nc_ds_001`)

### Chameleon

Adversarial variants with all user-defined identifiers renamed using randomized synonym pools. Tests whether models rely on keyword patterns rather than semantic understanding.

**Themes:**
- `gaming`: Video game, RPG, loot, rewards terminology
- `resource`: Business, allocation, resource management
- `abstract`: Domain-neutral technical terminology
- `medical`: Healthcare and medical terminology
- `social`: Social media and community terminology

**Transformations:**
- Function names: `withdraw` → `claimLoot`, `collectBounty`, etc.
- Variable names: `balance` → `goldHolding`, `treasureAmount`, etc.
- Contract names: `Vault` → `TreasureHold`, `LootVault`, etc.
- Compound decomposition: `getUserBalance` → `fetchPlayerGold`

**Naming:** `ch_{theme}_{source}_{original_id}` (e.g., `ch_gaming_sn_ds_001`)

## Transformation Pipeline

```
base/
  └── ds_001.sol (original)
        │
        ├── annotated/ds_001.sol (with detailed labeling)
        │
        └── sanitized/sn_ds_001.sol (hints removed)
                │
                ├── nocomments/nc_ds_001.sol (comments stripped)
                │       │
                │       └── chameleon/ch_{theme}_nc_ds_001.sol (identifiers renamed)
                │
                └── chameleon/ch_{theme}_sn_ds_001.sol (identifiers renamed)
```

## File Organization

Each dataset follows a consistent structure:

```
{dataset}/
├── contracts/      # Source code files (.sol, .rs)
├── metadata/       # JSON metadata files
├── context/        # Context files for multi-file entries (base only)
│   └── {entry_id}/ # e.g., gs_008/
│       └── *.sol   # Supporting contract files
├── index.json      # Dataset manifest
└── README.md       # Dataset documentation
```

Note: The `context/` folder only exists in the `base` dataset for multi-file vulnerability entries.

## Metadata Schema

All datasets share a common metadata schema:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier |
| `contract_file` | string | Relative path to source |
| `subset` | string | Dataset name |
| `ground_truth` | object | Vulnerability classification |
| `provenance` | object | Source attribution |
| `code_metadata` | object | Static code analysis |

## Usage

### Loading a Dataset

```python
import json
from pathlib import Path

def load_dataset(name: str):
    data_dir = Path(f"data/{name}")
    index = json.loads((data_dir / "index.json").read_text())

    for sample in index["samples"]:
        contract = (data_dir / sample["contract_file"]).read_text()
        metadata = json.loads((data_dir / sample["metadata_file"]).read_text())
        yield contract, metadata
```

### Generating Derived Datasets

```bash
# Generate sanitized contracts from base
python -m strategies.sanitize.sanitize all

# Generate no-comments contracts from sanitized
python -m strategies.nocomments.nocomment all

# Generate chameleon contracts (gaming theme from sanitized)
python -m strategies.chameleon.chameleon all --theme gaming --source sanitized

# Generate chameleon contracts (gaming theme from nocomments)
python -m strategies.chameleon.chameleon all --theme gaming --source nocomments
```

## Quality Assurance

All contracts in the base dataset are:

- Syntactically valid (verified with solc/rustc)
- Manually reviewed for ground truth accuracy
- Traceable to original source material

---

<p align="center">
  <em>BlockBench Smart Contract Security Evaluation Framework</em>
</p>
