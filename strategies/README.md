# Adversarial Transformation Strategies

This directory contains strategies for transforming smart contracts to test AI vulnerability detection robustness. Each strategy applies different transformations while preserving the underlying vulnerabilities.

## Pipeline Architecture

```
base → sanitize → nocomments ─┬─→ chameleon    (thematic renaming)
                              └─→ shapeshifter (surface transformation)
```

All strategies:
- Preserve vulnerability semantics (bugs remain exploitable)
- Transform metadata alongside contracts (ground truth stays synchronized)
- Are fully rule-based (no LLM required)

---

## Active Strategies

### 1. Sanitize (`sanitize/`)

**Purpose:** Remove obvious identifier hints that leak vulnerability information.

**What it does:**
- Renames identifiers that directly hint at vulnerabilities (e.g., `Reentrance` → `TokenVault`)
- Applies consistent renaming across contracts and metadata
- Preserves code structure and functionality

**Output:** `data/sanitized/`

**Usage:**
```bash
python -m strategies.sanitize.sanitize all
python -m strategies.sanitize.sanitize one ds_001
```

---

### 2. NoComments (`nocomments/`)

**Purpose:** Remove all comments from contracts.

**What it does:**
- Strips single-line comments (`//`)
- Strips multi-line comments (`/* */`)
- Strips NatSpec documentation (`///`, `/** */`)
- Preserves SPDX license identifiers

**Input:** Sanitized contracts
**Output:** `data/nocomments/`

**Usage:**
```bash
python -m strategies.nocomments.nocomments all
python -m strategies.nocomments.nocomments one sn_ds_001
```

---

### 3. Chameleon (`chameleon/`)

**Purpose:** Transform identifiers using thematic synonym mappings to test if models rely on keyword patterns.

**What it does:**
- Renames functions, variables, contracts using themed dictionaries
- Supports multiple themes (medical, gaming, etc.)
- Preserves Solidity reserved keywords and built-in properties
- Transforms metadata identifiers to match

**Themes available:**
- `medical` - Healthcare/clinical terminology

**Input:** NoComments contracts
**Output:** `data/chameleon/{theme}_{source}/`

**Usage:**
```bash
python -m strategies.chameleon.chameleon all --theme medical --source nocomments
python -m strategies.chameleon.chameleon one nc_ds_001 --theme medical
```

**Example transformation:**
| Original | Medical Theme |
|----------|---------------|
| `withdraw` | `dischargeFunds` |
| `balance` | `accountCredits` |
| `TokenVault` | `PatientRecordsVault` |

---

### 4. Shapeshifter (`shapeshifter/`)

**Purpose:** Transform code surface/visual presentation to test if models rely on formatting or naming conventions.

**What it does:**
- **L2 (short):** Renames identifiers to minimal names (a, b, c, ...)
- **L3 (medium):** L2 + hex-style names (_0x1f2345) + control flow wrapping

**Levels:**
| Level | Variant | Description |
|-------|---------|-------------|
| L2 | short | Identifier shortening (balances → b) |
| L3 | medium | Hex names + always-true conditionals |

**Input:** Sanitized or NoComments contracts
**Output:** `data/shapeshifter/{level}/{variant}/`

**Usage:**
```bash
python -m strategies.shapeshifter.shapeshifter all --level l2 --variant short --source sanitized
python -m strategies.shapeshifter.shapeshifter all --level l3 --variant medium --source nocomments
python -m strategies.shapeshifter.shapeshifter one sn_ds_001 --level l2 --variant short
```

**Example transformation (L2):**
| Original | L2 Short |
|----------|----------|
| `withdrawBalance` | `c` |
| `userBalance` | `e` |
| `getBalance` | `f` |

**Example transformation (L3):**
| Original | L3 Hex |
|----------|--------|
| `withdrawBalance` | `_0x1f2345` |
| `userBalance` | `_0x0d5643` |

**Note:** L3 clears `line_numbers` in metadata since control flow restructuring invalidates them.

---

## Planned Strategies

### 5. Restructure (`restructure/`)

**Purpose:** Transform code structure to test cross-function analysis capability.

**Modes:**
- **Split:** Break one function into multiple helpers (Hydra pattern)
- **Merge:** Combine multiple functions with conditional branching (Chimera pattern)

**Status:** Implementation exists, not yet integrated into pipeline.

---

### 6. Guardian (`guardian_v2/`)

**Purpose:** Inject protection mechanisms to test if models recognize when vulnerabilities are neutralized.

**Variants:**
- **Explicit:** Obvious protections (ReentrancyGuard, CEI pattern)
- **Implicit:** Subtle protections (hidden mutex, block number checks)

**Note:** This strategy changes vulnerability status from vulnerable → safe.

**Status:** Implementation exists, not yet integrated into pipeline.

---

## Common Utilities (`common/`)

Shared utilities used by all strategies:

- `reserved.py` - Solidity reserved keywords and built-in properties
- `parser.py` - Tree-sitter based Solidity parsing
- `syntax.py` - Syntax validation utilities

---

## Metadata Transformation

All strategies that rename identifiers also transform metadata to keep ground truth synchronized:

**Fields transformed:**
- `ground_truth.vulnerable_location.function_name`
- `ground_truth.vulnerable_location.contract_name`
- `code_metadata.contract_names`

**Traceability:**
- `identifier_mappings` - Maps original → transformed names
- `derived_from` - Links to source contract ID
- `transformation` - Records strategy parameters and changes

---

## Output Structure

```
data/
├── base/                    # Original contracts
├── sanitized/               # After sanitize strategy
├── nocomments/              # After nocomments strategy
├── chameleon/
│   └── medical_nc/          # Medical theme from nocomments
└── shapeshifter/
    ├── l2/
    │   └── short/           # L2 short variant
    └── l3/
        └── medium/          # L3 medium variant
```

Each output directory contains:
- `contracts/` - Transformed Solidity files
- `metadata/` - Transformed JSON metadata
- `index.json` - Dataset index with statistics
