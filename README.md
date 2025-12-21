<p align="center">
  <img src="assets/mascot.svg" alt="BlockBench Logo" width="200"/>
</p>

<h1 align="center">BlockBench</h1>
<p align="center">A Comprehensive Smart Contract Vulnerability Detection Benchmark</p>

<p align="center">
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/></a>
  <a href="https://soliditylang.org/"><img src="https://img.shields.io/badge/Solidity-^0.8.0-blue" alt="Solidity"/></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.8+-green" alt="Python"/></a>
</p>

<p align="center">
  <strong>263 Real-World Vulnerabilities • 13 Vulnerability Types • 1,343+ Transformed Variants</strong>
</p>

<p align="center">
  <a href="https://block-bench.github.io/base/">🌐 View Interactive Dashboard</a>
</p>

---

**BlockBench** is a rigorous benchmark for evaluating AI models' ability to detect vulnerabilities in Solidity smart contracts. The benchmark includes 263 real-world vulnerable contracts with comprehensive ground truth metadata, spanning historical exploits, professional audit findings, and stratified difficulty levels.

> 🚀 **[Explore the interactive dashboard](https://block-bench.github.io/base/)** to browse samples, view statistics, and test adversarial transformation strategies.

## 🎯 Purpose

BlockBench addresses critical gaps in smart contract security evaluation:

1. **Temporal Contamination Testing**: Distinguishes between memorization and genuine understanding using pre-cutoff historical exploits
2. **Zero-Shot Capability**: Tests pure detection ability with post-cutoff audit findings
3. **Robustness Evaluation**: Measures resilience to adversarial transformations (sanitization, obfuscation, thematic renaming)
4. **Graduated Difficulty**: Enables fine-grained capability assessment across vulnerability types and severity levels

## 📊 Dataset Overview

### Dataset Composition

| Subset                          | Samples | Source                               | Purpose                             |
| ------------------------------- | ------- | ------------------------------------ | ----------------------------------- |
| **Temporal Contamination (TC)** | 50      | Historical exploits (pre-March 2025) | Test memorization vs. understanding |
| **Gold Standard (GS)**          | 34      | Professional audits (post-Sept 2025) | Zero-shot vulnerability detection   |
| **Difficulty Stratified (DS)**  | 179     | SmartBugs, Trail of Bits, others     | Graduated difficulty assessment     |
| **Total**                       | **263** | Multiple authoritative sources       | Comprehensive evaluation            |

### Vulnerability Coverage

**13 distinct vulnerability types** across the dataset:

- **Logic Errors** (31 samples, 11.8%): Flawed business logic, incorrect implementations
- **Access Control** (46 samples, 17.5%): Missing or bypassable permission checks
- **Reentrancy** (43 samples, 16.3%): Recursive call vulnerabilities
- **Oracle/Price Manipulation** (13 samples, 4.9%): Manipulable price sources
- **Integer Overflow** (22 samples, 8.4%): Arithmetic boundary issues
- Plus 8 additional types: DoS, Timestamp Dependency, Signature Replay, Front-Running, etc.

See [data.md](data.md) for complete vulnerability taxonomy and distribution.

## 🗂️ Repository Structure

```
blockbench/base/
├── data/                           # All dataset variants
│   ├── base/                       # Original vulnerable contracts (sanitized)
│   │   ├── contracts/              # tc_*, gs_*, ds_* .sol files
│   │   └── metadata/               # Ground truth JSON for each sample
│   ├── originals/                  # Unsanitized original TC samples
│   │   ├── contracts/              # o_tc_*, nc_o_tc_* .sol files
│   │   ├── metadata/               # Original metadata
│   │   └── README.md               # Documentation for originals
│   ├── sanitized/                  # Sanitized variants (sn_*)
│   ├── nocomments/                 # Comment-stripped variants (nc_*)
│   ├── chameleon/                  # Thematically renamed variants (ch_*)
│   ├── shapeshifter/               # Obfuscated variants (ss_l2_*, ss_l3_*)
│   ├── hydra/                      # Multi-transformation variants
│   └── restructure/                # Structurally modified variants
│
├── strategies/                     # Transformation implementations
│   ├── sanitize/                   # Sanitization strategy
│   ├── chameleon/                  # Thematic renaming
│   ├── shapeshifter/              # Multi-level obfuscation
│   ├── hydra/                      # Composite transformations
│   └── restructure/                # Structural modifications
│
├── labelled_data/                  # Annotated versions for evaluation
│   ├── temporal_contamination/     # Fully annotated TC samples
│   └── gold_standard/              # Fully annotated GS samples
│
├── support/                        # Documentation and validation
│   ├── tasks/                      # Strategy documentation
│   └── validation/                 # Metadata validation scripts
│
├── dataset/                        # Raw data and processing scripts
│   ├── raw/                        # Original source materials
│   └── processed/                  # Processed datasets
│
├── data.md                         # Complete dataset documentation
└── README.md                       # This file
```

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Solidity ^0.8.0 (for compilation verification)
- Node.js 16+ (for some validation tools)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd blockbench/base

# Install Python dependencies
pip install -r requirements.txt  # If requirements.txt exists

# Verify dataset integrity
ls data/base/contracts/ | wc -l  # Should show 263
ls data/sanitized/contracts/ | wc -l  # Should show 263
```

### Basic Usage

**1. Load a sample contract:**

```python
import json
from pathlib import Path

# Load a temporal contamination sample
contract_path = Path("data/base/contracts/tc_001.sol")
metadata_path = Path("data/base/metadata/tc_001.json")

contract_code = contract_path.read_text()
metadata = json.loads(metadata_path.read_text())

print(f"Contract: {metadata['ground_truth']['vulnerable_location']['contract_name']}")
print(f"Vulnerability: {metadata['ground_truth']['vulnerability_type']}")
print(f"Severity: {metadata['ground_truth']['severity']}")
```

**2. Access transformed variants:**

```python
# Sanitized version
sanitized_path = Path("data/sanitized/contracts/sn_tc_001.sol")

# No-comments version
nocomments_path = Path("data/nocomments/contracts/nc_tc_001.sol")

# Shapeshifter L2 (identifier obfuscation)
shapeshifter_l2_path = Path("data/shapeshifter/l2/short/contracts/ss_l2_short_nc_tc_001.sol")

# Medical-themed chameleon
chameleon_path = Path("data/chameleon/medical_nc/contracts/ch_medical_nc_tc_001.sol")
```

**3. Validate metadata:**

```python
# Run metadata validation script
!python3 support/validation/validate_metadata.py data/base
```

## 🔄 Transformation Strategies

BlockBench includes six adversarial transformation strategies to test model robustness:

### 1. Sanitization ($\mathcal{T}_{\text{san}}$)

**Purpose**: Remove vulnerability hints from identifiers and comments

**Transformations**:

- 280+ identifier replacement patterns (e.g., `vulnerableTransfer` → `executeTransfer`)
- 100+ comment removal patterns (e.g., "// VULNERABILITY:", "// TODO: add access control")
- Console.log and emit statement cleaning

**Output**: `data/sanitized/` (prefix: `sn_*`)

### 2. No-Comments ($\mathcal{T}_{\text{nc}}$)

**Purpose**: Strip all comments while preserving code

**Transformations**:

- Removes single-line (`//`), multi-line (`/* */`), and doc comments (`/** */`)
- 4,358 comments removed across all files
- Average 15-20 line reduction per file

**Note**: Line numbers in metadata become outdated; use contract + function names for location

**Output**: `data/nocomments/` (prefix: `nc_*`)

### 3. Chameleon ($\mathcal{T}_{\text{cham}}^{\theta}$)

**Purpose**: Thematic renaming using synonym pools

**Themes**: Medical, gaming, resource, abstract, social

**Transformations**:

- Category-specific synonym pools (functions, variables, contracts)
- Layered lookup: direct, compound decomposition, prefix matching
- 60-70% identifier transformation rate
- Deterministic seed for reproducibility

**Example**: `BridgeReplica.process()` → `SystemReplica.treat()`

**Output**: `data/chameleon/medical_nc/` (prefix: `ch_medical_nc_*`)

### 4. Shapeshifter ($\mathcal{T}_{\text{shape}}^{L,v}$)

**Purpose**: Multi-level code obfuscation

**Levels**:

- **L1** (Formatting): compressed, expanded, allman, knr, minified
- **L2** (Identifier): short (single letters), hex (`_0x...`), underscore
- **L3** (Control Flow): L2 + always-true conditionals (`if (1 == 1) { ... }`)
- **L4** (Structural): L3 + dead code injection

**Current Implementations**:

- L2 short: All identifiers → a-z (e.g., `acceptedRoot` → `e`)
- L3 medium: Hex identifiers + medium-intensity control flow obfuscation

**Output**: `data/shapeshifter/l2/short/`, `data/shapeshifter/l3/medium/` (prefix: `ss_l2_*`, `ss_l3_*`)

### 5. Hydra ($\mathcal{T}_{\text{hydra}}^n$)

**Purpose**: Sequential composition of multiple transformations

**Output**: `data/hydra/` (various prefixes)

### 6. Restructure ($\mathcal{T}_{\text{restr}}$)

**Purpose**: Structural modifications via contract splitting/merging

**Output**: `data/restructure/` (various prefixes)

See [data.md](data.md) Appendix for complete mathematical notation and detailed specifications.

## 📈 Dataset Statistics

### Total Variants

| Variant             | Count      | Prefix Pattern         | Source                         |
| ------------------- | ---------- | ---------------------- | ------------------------------ |
| Base                | 263        | `tc_*`, `gs_*`, `ds_*` | Original samples               |
| Sanitized           | 263        | `sn_*`                 | Base → Sanitization            |
| No-Comments         | 263        | `nc_*`                 | Sanitized → Comment removal    |
| Chameleon (Medical) | 50         | `ch_medical_nc_tc_*`   | TC No-Comments → Medical theme |
| Shapeshifter L2     | 252        | `ss_l2_short_nc_*`     | No-Comments → L2 short         |
| Shapeshifter L3     | 252        | `ss_l3_medium_nc_*`    | No-Comments → L3 medium        |
| **Total Variants**  | **1,343+** | -                      | -                              |

### Temporal Contamination Examples

| Sample | Exploit         | Date     | Loss   | Contract         | Vulnerability                   |
| ------ | --------------- | -------- | ------ | ---------------- | ------------------------------- |
| tc_001 | Nomad Bridge    | Aug 2022 | \$190M | BridgeReplica    | Uninitialized storage           |
| tc_002 | Beanstalk       | Apr 2022 | \$182M | GovernanceSystem | Flash loan governance           |
| tc_003 | Parity Wallet   | Nov 2017 | \$150M | WalletLibrary    | Unprotected init + selfdestruct |
| tc_004 | Harvest Finance | Oct 2020 | \$24M  | YieldVault       | Oracle manipulation             |
| tc_005 | Curve Vyper     | Jul 2023 | \$70M  | AMMPool          | Vyper compiler reentrancy       |

### Gold Standard Highlights

- **18 single-file samples** evaluable without context files
- **16 multi-file samples** requiring context
- Sources: Spearbit (11), MixBytes (5), Code4rena (2)
- 53% logic errors (subtle vulnerabilities requiring deep analysis)
- All from audits conducted September 2025 or later

See [support/validation/SINGLE_FILE_GOLD_STANDARD.md](support/validation/SINGLE_FILE_GOLD_STANDARD.md) for the complete list.

## 🔍 Metadata Structure

Each sample includes comprehensive metadata:

```json
{
  "id": "tc_001",
  "contract_file": "contracts/tc_001.sol",
  "subset": "base",
  "ground_truth": {
    "is_vulnerable": true,
    "vulnerability_type": "logic_error",
    "severity": "critical",
    "vulnerable_location": {
      "contract_name": "BridgeReplica",
      "function_name": "process",
      "line_numbers": [21, 51, 71, 72]
    },
    "root_cause": "...",
    "attack_vector": "...",
    "impact": "Funds lost: $190,000,000",
    "correct_fix": "..."
  },
  "provenance": {
    "source": "rekt_news",
    "original_id": "temporal_nomad_001",
    "url": "https://github.com/...",
    "date_discovered": "2022-08-01"
  },
  "code_metadata": {
    "solidity_version": "^0.8.0",
    "num_lines": 84,
    "num_contracts": 1,
    "contract_names": ["BridgeReplica"]
  },
  "tags": ["bridge", "cross-chain", "initialization"],
  "temporal_fields": {
    /* TC-specific fields */
  },
  "gold_standard_fields": {
    /* GS-specific fields */
  }
}
```

## 🛠️ Transformation Scripts

### Generate Sanitized Variants

```bash
python3 -m strategies.sanitize.sanitize
```

### Generate No-Comment Variants

```bash
python3 -m strategies.nocomments.nocomments
```

### Generate Chameleon Variants

```bash
# Medical theme for TC samples
python3 -m strategies.chameleon.chameleon subset tc --theme medical --source nocomments
```

### Generate Shapeshifter Variants

```bash
# L2 short variant
python3 -m strategies.shapeshifter.shapeshifter all --level l2 --variant short --source nocomments

# L3 medium variant
python3 -m strategies.shapeshifter.shapeshifter all --level l3 --variant medium --source nocomments
```

## 📝 Evaluation Guidelines

### For Model Evaluation

1. **Select appropriate dataset variant** based on evaluation goals:

   - Base: Standard evaluation
   - No-comments: Test without natural language hints
   - Chameleon: Test robustness to thematic renaming
   - Shapeshifter L2/L3: Test robustness to obfuscation

2. **Load sample and metadata:**

   ```python
   contract = load_contract(sample_id, variant="base")
   metadata = load_metadata(sample_id, variant="base")
   ```

3. **Present contract to model** without revealing metadata

4. **Collect model predictions:**

   - Vulnerability present? (Yes/No)
   - Vulnerability type
   - Vulnerable location (contract, function, lines)
   - Root cause description
   - Severity assessment

5. **Compare against ground truth:**
   - Exact match on vulnerability type
   - Contract name match
   - Function name match
   - Line number overlap (if applicable for variant)

### Important Notes

- **Do NOT use original versions** (o*tc*_, nc*o_tc*_) for evaluation—these contain leaky contract names
- **Line numbers may be invalid** for:
  - No-comments variants (shifted due to removed lines)
  - Shapeshifter L3+ (restructured control flow)
  - Use contract + function names instead
- **Context files required** for 16/34 GS samples (multi-contract vulnerabilities)

## 📚 Documentation

- **[data.md](data.md)**: Complete dataset documentation with mathematical notation
- **[data/originals/README.md](data/originals/README.md)**: Original TC samples documentation
- **[support/validation/SINGLE_FILE_GOLD_STANDARD.md](support/validation/SINGLE_FILE_GOLD_STANDARD.md)**: Single-file GS samples
- **[support/validation/NOCOMMENTS_README.md](support/validation/NOCOMMENTS_README.md)**: No-comments variant details
- **[support/tasks/](support/tasks/)**: Individual strategy documentation

## 🤝 Contributing

We welcome contributions! Areas for contribution:

- Additional transformation strategies
- New vulnerability samples (with proper validation)
- Evaluation frameworks and metrics
- Bug fixes and documentation improvements

Please ensure:

- All new samples have complete, accurate metadata
- Transformations preserve vulnerability semantics
- Code follows existing patterns and conventions

## 📖 Citation

If you use BlockBench in your research, please cite:

```bibtex
@misc{blockbench2025,
  title={BlockBench: A Comprehensive Smart Contract Vulnerability Detection Benchmark},
  author={[Authors]},
  year={2025},
  note={Available at: [URL]}
}
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

**Educational Purpose Only**: The vulnerable contracts in this benchmark are for research and educational purposes only. They demonstrate real-world vulnerabilities and should **NEVER** be deployed to production environments.

## 🙏 Acknowledgments

This benchmark builds upon vulnerability data from:

- **DeFiHackLabs**: Historical exploit reproductions
- **Rekt News**: DeFi security journalism
- **Spearbit**: Professional security audits
- **MixBytes**: Smart contract audits
- **Code4rena**: Competitive audit platform
- **SmartBugs**: Curated vulnerability dataset
- **Trail of Bits**: Not-So-Smart Contracts repository

We thank these organizations for their contributions to smart contract security research.

## 📧 Contact

For questions, issues, or collaboration inquiries:

- Open an issue on GitHub
- Email: [contact email]

## 🔗 References

[1] SunWeb3Sec. "DeFiHackLabs: Solidity PoC for DeFi exploits." https://github.com/SunWeb3Sec/DeFiHackLabs

[2] Rekt News. "Rekt: Anonymous DeFi Journalism." https://rekt.news

[3] Spearbit. "Security Audits Portfolio." https://github.com/spearbit/portfolio

[4] MixBytes. "Smart Contract Security Audits." https://mixbytes.io

[5] Code4rena. "Competitive Audit Contests." https://code4rena.com

[6] Durieux et al. "SmartBugs: A Framework for Analyzing Solidity Smart Contracts." ASE 2020.

[7] Trail of Bits. "Not So Smart Contracts." https://github.com/crytic/not-so-smart-contracts

---

**Last Updated**: December 18, 2025
**Version**: 1.0.0
**Status**: Active Development
