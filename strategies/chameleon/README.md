# Chameleon Transformation Strategy

Chameleon systematically renames all user-defined identifiers in smart contracts using randomized synonym pools to test whether AI models rely on keyword patterns rather than understanding code semantics.

## Overview

The Chameleon strategy addresses a critical evaluation gap: when models appear to detect vulnerabilities, are they actually understanding the code semantics, or are they pattern-matching on identifier names like "withdraw", "balance", "vulnerable"?

By renaming identifiers to thematically different but semantically neutral alternatives, we can test if model accuracy drops significantly - indicating reliance on surface-level keyword patterns.

## Usage

```bash
# Transform a single file
python -m strategies.chameleon.chameleon one sn_ds_001 --theme gaming --source sanitized

# Transform all files from a source dataset
python -m strategies.chameleon.chameleon all --theme gaming --source sanitized

# Transform a subset (ds = difficulty_stratified, tc = temporal_contamination)
python -m strategies.chameleon.chameleon subset ds --theme gaming --source sanitized

# Transform code from stdin
echo "contract Vault { ... }" | python -m strategies.chameleon.chameleon code --theme gaming
```

## Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `--theme, -t` | gaming, resource, abstract, medical, social | gaming | Terminology theme |
| `--source, -s` | sanitized, nocomments | sanitized | Source dataset |
| `--variation, -v` | low, medium, high, extreme | medium | Randomization level |

## Themes

- **gaming**: Video game, RPG, loot, rewards terminology
- **resource**: Generic business, allocation, resource management
- **abstract**: Domain-neutral technical/procedural terminology
- **medical**: Healthcare and medical terminology
- **social**: Social media and community platform terminology

## Output Naming

Output files follow the pattern: `ch_{theme}_{source_prefix}_{original_id}`

Examples:
- `ch_gaming_sn_ds_001.sol` - Gaming theme applied to sanitized ds_001
- `ch_resource_nc_tc_042.sol` - Resource theme applied to nocomments tc_042

## Variation Levels

| Level | Pool Usage | Description |
|-------|------------|-------------|
| low | Top 3 synonyms | Consistent, natural-looking |
| medium | Top 50% of pool | Balanced variation |
| high | Full pool | Maximum variety |
| extreme | Full pool + random suffixes | Stress testing |

## Key Features

1. **Seeded Randomization**: Same input + theme always produces same output (reproducible)
2. **Contract-specific Seeds**: Different contracts get different random selections
3. **Reserved Word Protection**: Solidity keywords and standard interface functions never renamed
4. **Compound Decomposition**: Handles camelCase and snake_case identifiers
5. **Coverage Tracking**: Reports percentage of identifiers transformed

## File Structure

```
strategies/chameleon/
├── __init__.py          # Public API exports
├── chameleon.py         # Main transformer implementation
├── README.md            # This file
└── themes/              # Synonym pools (JSON)
    ├── gaming.json
    ├── resource.json
    ├── abstract.json
    ├── medical.json
    └── social.json
```

## Transformation Pipeline

1. **Parse**: Extract all identifiers from source code
2. **Map**: Build rename map using synonym pools + randomization
3. **Transform**: Apply renames back-to-front (for position validity)
4. **Validate**: Check syntax, verify no reserved words renamed

## Coverage

Target coverage is ≥75% of user-defined identifiers. Coverage reports include:
- Total identifiers found
- Number transformed
- Number untransformed (with reasons)
- Skipped reserved words

---

*Part of the BlockBench Smart Contract Security Evaluation Framework*
