# Pre-Cutoff Originals - Dataset Structure

Purpose: Prevent data leakage in AI evaluation by separating annotated documentation from clean test samples.

---

## Directory Structure

```
pre_cutoff_originals/
├── annotated/          # Full documentation (reference only)
│   ├── *.sol          # Contracts with vulnerability comments
│   ├── *.json         # Full metadata with attack details
│   └── ...
├── unannotated/       # Clean test samples (for evaluation)
│   ├── sample_001.sol # Generic names, no vulnerability hints
│   ├── sample_002.sol
│   ├── ...
│   └── mapping.json   # Maps unannotated IDs to annotated files
└── README.md          # This file
```

---

## Purpose of Separation

Problem with annotated files:

1. Filename leakage: `ronin_bridge.sol` tells the model what exploit it is
2. Comment leakage: "VULNERABILITY: This line..." gives away the answer
3. Attack documentation: Detailed explanations in code comments

Solution:

- Annotated folder: Keep for human reference and documentation
- Unannotated folder: Use for AI evaluation with generic names (sample_001.sol, etc.), no vulnerability-revealing comments, only normal production-level documentation, and mapping file to link back to annotated versions

---

## Unannotated Samples

| ID         | File           | Maps To             | Exploit Name    | Date    | Loss   |
| ---------- | -------------- | ------------------- | --------------- | ------- | ------ |
| sample_001 | sample_001.sol | nomad_bridge.sol    | Nomad Bridge    | 2022-08 | \$190M |
| sample_002 | sample_002.sol | beanstalk.sol       | Beanstalk       | 2022-04 | \$182M |
| sample_003 | sample_003.sol | parity_wallet.sol   | Parity Wallet   | 2017-11 | \$150M |
| sample_004 | sample_004.sol | harvest_finance.sol | Harvest Finance | 2020-10 | \$24M  |
| sample_005 | sample_005.sol | curve_vyper.sol     | Curve Finance   | 2023-07 | \$70M  |
| sample_006 | sample_006.sol | ronin_bridge.sol    | Ronin Bridge    | 2022-03 | \$625M |
| sample_007 | sample_007.sol | poly_network.sol    | Poly Network    | 2021-08 | \$611M |
| sample_008 | sample_008.sol | cream_finance.sol   | Cream Finance   | 2021-10 | \$130M |
| sample_009 | sample_009.sol | kyberswap.sol       | KyberSwap       | 2023-11 | \$47M  |

Total: 9 samples, \$2.2B in losses represented

---

## Usage Guidelines

For AI Evaluation:

- Use only unannotated/ folder
- Provide models with sample_XXX.sol files
- Do NOT reveal mapping to annotated versions
- Do NOT include JSON metadata during evaluation

For Reference/Documentation:

- Use annotated/ folder for full vulnerability documentation, attack scenarios, and fix recommendations

---

## What Was Removed from Unannotated Versions

Comments Removed:

- "VULNERABILITY:" markers and explanations
- "ROOT CAUSE:" descriptions
- "ATTACK VECTOR:" documentation
- "VULNERABLE LINES:" indicators
- Post-mortem analysis blocks
- Fix recommendations and lessons learned

Comments Kept:

- Function purpose (what it does)
- Basic structural documentation
- Standard production-level comments

Names Changed:
| Original Contract Name | Unannotated Name |
| ------------------------------ | ------------------------- |
| VulnerableNomadReplica | BridgeReplica |
| VulnerableBeanstalkGovernance | GovernanceSystem |
| VulnerableParityWalletLibrary | WalletLibrary |
| VulnerableHarvestVault | YieldVault |
| VulnerableCurvePool | AMMPool |
| VulnerableRoninBridge | CrossChainBridge |
| VulnerableEthCrossChainManager | CrossChainManager |
| VulnerableCreamLending | LendingProtocol |
| VulnerableKyberSwapPool | ConcentratedLiquidityPool |

---

## Evaluation Protocol

Task for AI Models:
"Review the following smart contract and identify any security vulnerabilities. For each vulnerability found: (1) Describe the vulnerability type, (2) Identify the vulnerable function(s), (3) Specify the vulnerable line numbers, (4) Explain the potential exploit, (5) Suggest a fix"

Scoring:

- True Positive: Correctly identifies vulnerability in unannotated code
- False Negative: Misses vulnerability (memorization failure OR reasoning failure)
- False Positive: Flags non-vulnerable code as vulnerable

Temporal Contamination Testing:

- Pre-cutoff samples (2017-2023): Models may have seen these in training data. High detection rate likely indicates memorization. Variant detection rates reveal memorization vs. reasoning.
- Post-cutoff samples (Sept 2025+): Models should not have seen these. Detection rate reveals true reasoning capability.

---

## Mapping File

The mapping.json file in the unannotated folder contains unannotated ID/filename, corresponding annotated filename, and basic metadata for internal tracking.

Important: This mapping should NOT be provided to models during evaluation.

---

## Quality Verification

All unannotated files have:

- Generic sample_XXX.sol names
- No vulnerability-revealing comments
- Functional but generic contract names
- Correct mapping to annotated versions
- All annotated files preserved with full documentation
- JSON metadata remains in annotated folder only

---

## Future Additions

When adding new pre-cutoff exploits:

1. Create annotated version in annotated/ folder
2. Create unannotated version in unannotated/ folder
3. Use next available sample number (sample_010, sample_011, etc.)
4. Update mapping.json with new entry
5. Remove all vulnerability hints from unannotated version
6. Use generic contract/function names

---

Last Updated: December 15, 2024
Total Samples: 9 pre-cutoff originals
Status: Complete
