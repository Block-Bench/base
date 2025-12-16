# Chameleon Dataset

<p align="center">
  <img src="../../assets/mascot.svg" alt="BlockBench" width="64" height="64">
</p>

The chameleon dataset contains contracts with all user-defined identifiers renamed using randomized synonym pools, designed to test whether AI models rely on keyword patterns rather than understanding code semantics.

## Contents

| Directory | Contracts | Description |
|-----------|-----------|-------------|
| `gaming_sn/` | 285 | Gaming theme applied to sanitized contracts |
| `gaming_nc/` | 285 | Gaming theme applied to nocomments contracts |
| `medical_sn/` | 285 | Medical theme applied to sanitized contracts |
| `medical_nc/` | 285 | Medical theme applied to nocomments contracts |

**Total: 1,140 transformed contracts**

## Naming Convention

- `ch_gaming_sn_ds_001.sol` - Gaming theme, from sanitized ds_001
- `ch_medical_nc_tc_042.sol` - Medical theme, from nocomments tc_042

## Active Themes

### Gaming Theme
Comprehensive video game, RPG, MMO, and rewards terminology:
- `withdraw` → `claimLoot`, `collectBounty`, `gatherTreasure`
- `balance` → `goldHolding`, `treasureAmount`, `coinPurse`
- `owner` → `guildMaster`, `gameAdmin`, `dungeonMaster`
- `Vault` → `TreasureHold`, `LootVault`, `RewardCache`

### Medical Theme
Comprehensive healthcare, hospital, clinical, and patient care terminology:
- `withdraw` → `discharge`, `dispenseMedication`, `releaseFunds`
- `balance` → `coverage`, `benefits`, `credits`
- `owner` → `administrator`, `director`, `chiefMedical`
- `Vault` → `PatientRecords`, `MedicalVault`, `CareRepository`

## Transformations Applied

The Chameleon strategy renames identifiers using thematically consistent synonym pools:

1. **Contract Names**: 40+ pattern categories
2. **Function Names**: 90+ pattern categories
3. **Variable Names**: 170+ pattern categories
4. **Event Names**: 25+ pattern categories
5. **Error Names**: 20+ pattern categories
6. **Modifier Names**: 11+ pattern categories
7. **Struct Names**: 8+ pattern categories

## Coverage Statistics

| Source | Gaming | Medical |
|--------|--------|---------|
| Sanitized | ~40% | ~40% |
| No-Comments | ~55% | ~55% |

*Coverage = percentage of user-defined identifiers successfully transformed*

## Metadata Schema

Each metadata file includes:

- `id`: Chameleon identifier (e.g., `ch_gaming_sn_ds_001`)
- `contract_file`: Path to transformed source
- `transformation`: Details including theme, seed, coverage, rename_map

## Transformation Chain

```
base (ds_001) -> sanitized (sn_ds_001) -> chameleon (ch_gaming_sn_ds_001)
                                       -> chameleon (ch_medical_sn_ds_001)

base (ds_001) -> sanitized (sn_ds_001) -> nocomments (nc_ds_001) -> chameleon (ch_gaming_nc_ds_001)
                                                                  -> chameleon (ch_medical_nc_ds_001)
```

## Generation

Run the chameleon transformation:

```bash
# Transform all sanitized contracts with gaming theme
python -m strategies.chameleon.chameleon all --theme gaming --source sanitized

# Transform all nocomments contracts with medical theme
python -m strategies.chameleon.chameleon all --theme medical --source nocomments
```

---

*Part of the BlockBench Smart Contract Security Evaluation Framework*
