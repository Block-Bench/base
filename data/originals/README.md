# Original Temporal Contamination Samples

## Overview

This directory contains the **original, unsanitized versions** of the temporal contamination samples (tc_001 to tc_005). These are the raw annotated contracts before any sanitization or transformation was applied.

## What Makes These "Original"

These files contain:
- ✅ **Full vulnerability annotations** in comments (VULNERABILITY:, ROOT CAUSE:, ATTACK VECTOR:)
- ✅ **Verbose contract names** (VulnerableNomadReplica, VulnerableBeanstalkGovernance, etc.)
- ✅ **Detailed documentation comments** explaining the exploit
- ✅ **Leaky identifiers** that hint at the vulnerability

In contrast, the **base** versions (tc_001 to tc_005) have been sanitized to remove these hints, making them suitable for benchmark evaluation.

## Sample Mapping

| Original (Annotated) | No-Comment | Base | Exploit | Amount Lost | Contract Name |
|---------------------|-----------|------|---------|-------------|---------------|
| o_tc_001 | nc_o_tc_001 | tc_001 | Nomad Bridge | $190M | VulnerableNomadReplica |
| o_tc_002 | nc_o_tc_002 | tc_002 | Beanstalk | $182M | VulnerableBeanstalkGovernance |
| o_tc_003 | nc_o_tc_003 | tc_003 | Parity Wallet | $150M | VulnerableParityWalletLibrary |
| o_tc_004 | nc_o_tc_004 | tc_004 | Harvest Finance | $24M | VulnerableHarvestVault |
| o_tc_005 | nc_o_tc_005 | tc_005 | Curve Vyper | $70M | VulnerableCurvePool |

## Source Provenance

These files were sourced from `dataset/processed/temporal_contamination/pre_cutoff_originals/annotated/` which contains the raw annotated versions collected from:
- **DeFiHackLabs Repository**: https://github.com/SunWeb3Sec/DeFiHackLabs
- **Rekt News**: https://rekt.news
- Various blockchain security research sources

## Key Differences from Base Versions

### o_tc_001.sol vs tc_001.sol (Nomad Bridge)

**Original (o_tc_001.sol)**:
```solidity
/**
 * @title Nomad Bridge Replica Contract (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $190M Nomad Bridge hack
 *
 * VULNERABILITY: Improper message validation in cross-chain bridge
 *
 * ROOT CAUSE:
 * The Replica contract's process() function relies on messages() mapping...
 */
contract VulnerableNomadReplica {
    // VULNERABILITY: After contract upgrade, this was not properly initialized
    mapping(bytes32 => MessageStatus) public messages;

    // VULNERABILITY: This was set to 0x00...00 after upgrade
    bytes32 public acceptedRoot;
```

**Base (tc_001.sol)**:
```solidity
/**
 * @title Bridge Replica Contract
 * @notice Processes cross-chain messages from source chain to destination chain
 */
contract BridgeReplica {
    // Mapping of message hash to status
    mapping(bytes32 => MessageStatus) public messages;

    // The confirmed root for messages
    bytes32 public acceptedRoot;
```

### o_tc_002.sol vs tc_002.sol (Beanstalk)

**Original (o_tc_002.sol)**:
```solidity
/**
 * VULNERABILITY: Flash loan governance attack
 *
 * ROOT CAUSE:
 * The Beanstalk protocol used a governance system where voting power was based on
 * deposited assets... allowed proposals to be executed immediately via emergencyCommit()
 */
contract VulnerableBeanstalkGovernance {
    // VULNERABILITY: Instant voting power from deposits
    function deposit(uint256 amount) external { ... }

    // VULNERABILITY: No timelock on execution
    function emergencyCommit(uint256 proposalId) external { ... }
```

**Base (tc_002.sol)**:
```solidity
contract GovernanceSystem {
    function deposit(uint256 amount) external { ... }

    function emergencyCommit(uint256 proposalId) external { ... }
```

## No-Comment Originals

In addition to the fully annotated originals, we provide **no-comment versions** (nc_o_tc_*) that preserve the vulnerable contract names while removing all comments. These files:

- ✅ Keep "Vulnerable*" contract names (VulnerableNomadReplica, etc.)
- ✅ Remove all single-line comments (`//`)
- ✅ Remove all multi-line comments (`/* */`)
- ✅ Remove all doc comments (`/** */`)
- ✅ Preserve all code logic and structure
- ⚠️ Still unsuitable for benchmark evaluation due to leaky contract names

**Purpose**: Test whether models can detect vulnerabilities in code with leaky contract names but no comment hints.

**Comparison**:
- **o_tc_001.sol**: Full annotations + VulnerableNomadReplica name
- **nc_o_tc_001.sol**: No comments + VulnerableNomadReplica name (still leaky!)
- **tc_001.sol**: No comments + BridgeReplica name (sanitized, suitable for evaluation)

## Usage Guidelines

### For Research & Analysis
✅ Use original versions (o_tc_*) to understand the full context of historical exploits
✅ Use no-comment originals (nc_o_tc_*) to study code without natural language hints
✅ Compare all three versions to see sanitization effectiveness
✅ Study vulnerability documentation for educational purposes

### For Benchmark Evaluation
❌ DO NOT use original versions (o_tc_* or nc_o_tc_*) for model evaluation
✅ Use base versions (tc_001 to tc_005) which are properly sanitized
✅ Use transformed variants (sanitized, no-comments, chameleon, shapeshifter)

## Transformation Pipeline

```
Original (o_tc_*)
    ↓
    ↓ [Sanitization: Remove hints]
    ↓
Base (tc_*)
    ↓
    ↓ [Sanitization Strategy]
    ↓
Sanitized (sn_tc_*)
    ↓
    ↓ [Comment Removal]
    ↓
No-Comments (nc_tc_*)
    ↓
    ↓ [Thematic Renaming / Obfuscation]
    ↓
Chameleon (ch_*_tc_*) / Shapeshifter (ss_*_tc_*)
```

## File Statistics

### Original (Annotated) Versions

| File | Lines | Size | Comments | Vulnerability Annotations |
|------|-------|------|----------|---------------------------|
| o_tc_001.sol | 148 | 5.5 KB | 90 lines | 8 blocks |
| o_tc_002.sol | 195 | 6.9 KB | 117 lines | 12 blocks |
| o_tc_003.sol | 208 | 7.5 KB | 138 lines | 15 blocks |
| o_tc_004.sol | 229 | 8.3 KB | 152 lines | 18 blocks |
| o_tc_005.sol | 269 | 9.4 KB | 178 lines | 22 blocks |

### No-Comment Versions

| File | Lines | Size | Reduction |
|------|-------|------|-----------|
| nc_o_tc_001.sol | 58 | 1.4 KB | 60.8% fewer lines |
| nc_o_tc_002.sol | 95 | 2.6 KB | 51.3% fewer lines |
| nc_o_tc_003.sol | 91 | 2.1 KB | 56.3% fewer lines |
| nc_o_tc_004.sol | 98 | 2.4 KB | 57.2% fewer lines |
| nc_o_tc_005.sol | 125 | 3.1 KB | 53.5% fewer lines |

**Average Reduction**: 55.8% fewer lines when comments removed

## Metadata

Each original file has corresponding metadata in `data/originals/metadata/` with:
- Complete vulnerability details
- Exploit information (date, protocol name, funds lost)
- Provenance information
- Original source URLs

## Important Notes

1. **These files contain educational vulnerability examples**: They are intentionally vulnerable and should never be deployed
2. **Annotation density**: Original files have 30-35% comment lines explaining vulnerabilities
3. **Contract naming**: All use "Vulnerable*" prefix to clearly indicate vulnerable code
4. **Preservation**: These originals are preserved for research and comparison purposes
5. **Not for evaluation**: The base versions (tc_*) are the canonical benchmark samples

## References

- DeFiHackLabs: https://github.com/SunWeb3Sec/DeFiHackLabs
- Rekt News: https://rekt.news
- BlockBench Paper: [Citation pending]

---

**Created**: December 18, 2025
**Purpose**: Preserve original annotated temporal contamination samples for research and comparison
