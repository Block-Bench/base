<p align="center">
  <img src="../logo.svg" alt="BlockBench Logo" width="150"/>
</p>

# BlockBench Dataset

## Dataset Overview

BlockBench is a comprehensive benchmark for evaluating AI models' ability to detect vulnerabilities in smart contracts. The dataset comprises **263 vulnerable Solidity contracts** organized into three distinct subsets: **Temporal Contamination** (50 samples), **Gold Standard** (34 samples), and **Difficulty Stratified** (179 samples). Each sample contains a real vulnerability with detailed ground truth metadata, including vulnerability type, severity, root cause analysis, attack vectors, and correct fixes.

## Data Collection and Sources

### 1. Temporal Contamination (TC) - 50 Samples

Temporal contamination samples represent historically significant exploits from real-world attacks that resulted in substantial financial losses. These samples test whether models rely on memorized attack patterns from training data versus genuine vulnerability understanding.

**Source**: DeFiHackLabs Repository [1], Rekt News [2]

**Notable Examples**:
- Nomad Bridge (tc_001): $190M, August 2022
- Beanstalk (tc_002): $182M, April 2022
- Parity Wallet (tc_003): $150M, November 2017
- Harvest Finance (tc_004): $24M, October 2020
- Curve Vyper (tc_005): $70M, July 2023

All temporal contamination samples have exploit dates **before March 1, 2025**, ensuring they fall within the training data cutoff dates for current frontier models (Claude Sonnet 4: March 2025, GPT-4 Turbo: December 2024, GPT-4o: October 2024).

### 2. Gold Standard (GS) - 34 Samples

Gold standard samples were extracted from professional security audits conducted **from September 2025 onward**, ensuring they are **post-cutoff** for the latest evaluated models (e.g., GPT-4.5 with August 31, 2025 cutoff). This guarantees zero temporal contamination and tests pure vulnerability detection capability without memorization.

**Sources**:
- **Spearbit**: 11 single-file samples from Aragon, Velodrome, and other audits [3]
- **MixBytes**: 5 single-file samples from various protocol audits [4]
- **Code4rena**: 2 single-file samples from competitive audit contests [5]

We identified **18 single-file samples** that can be evaluated independently without context files, while the remaining **16 samples** require multi-contract context for complete understanding. All gold standard samples underwent rigorous validation to ensure metadata accuracy, including corrections to contract names (gs_001, gs_004), function names (gs_030), and line number ranges (gs_027).

### 3. Difficulty Stratified (DS) - 179 Samples

Difficulty stratified samples provide graduated complexity levels to enable fine-grained capability assessment. Samples were collected from multiple curated vulnerability datasets and stratified by severity.

**Sources**:
- **SmartBugs Curated**: 143 samples from the SmartBugs dataset [6]
- **Not-So-Smart Contracts**: 25 samples from Trail of Bits [7]
- **Other Sources**: 11 samples from various vulnerability databases

**Stratification by Severity**:
- Critical: 4 samples
- High: 79 samples
- Medium: 80 samples
- Low: 16 samples

**Vulnerability Type Distribution**: Reentrancy (36), Access Control (27), Integer Overflow (16), Timestamp Dependency (14), Denial of Service (8), Logic Errors (5), Front-Running (5), and Other (68).

## Vulnerability Type Coverage

BlockBench covers a comprehensive range of vulnerability classes found in real-world smart contracts, spanning 13 distinct vulnerability types across all three subsets. This diversity ensures models are tested on various security weaknesses rather than overfitting to specific vulnerability patterns.

### Vulnerability Taxonomy

**1. Logic Error (31 total: TC=8, GS=18, DS=5)**
- **Description**: Flawed business logic or incorrect implementation of intended functionality
- **Examples**:
  - Incorrect voting power calculation allowing flash loan governance attacks (tc_002)
  - Frozen/blacklisted token balances counted in governance power (gs_017)
  - Emergency withdrawal bypassing reward distribution (gs_003)
- **Impact**: Critical business logic failures, unauthorized state changes, incorrect accounting

**2. Access Control (46 total: TC=16, GS=3, DS=27)**
- **Description**: Missing, incorrect, or bypassable permission checks
- **Examples**:
  - Unprotected library initialization allowing contract destruction (tc_003)
  - Signature replay allowing stale signer reuse (gs_029)
  - Missing owner validation in critical functions (ds samples)
- **Impact**: Unauthorized access, privilege escalation, fund theft

**3. Reentrancy (43 total: TC=7, DS=36)**
- **Description**: Recursive calls exploiting state inconsistency
- **Examples**:
  - Vyper compiler bug disabling @nonreentrant protection (tc_005)
  - Classic reentrancy in withdrawal functions (ds samples)
- **Impact**: Fund drainage, double-spending, state corruption

**4. Oracle/Price Manipulation (13 total: TC=10, GS=1, DS=2)**
- **Description**: Exploiting manipulable price sources or oracle weaknesses
- **Examples**:
  - Spot price manipulation via flash loans in Curve pools (tc_004)
  - Stale oracle data with no timestamp validation (gs_027)
  - AMM pool price manipulation (tc samples)
- **Impact**: Economic attacks, fund theft via price distortion, liquidation manipulation

**5. Integer Overflow/Underflow (22 total: TC=6, DS=16)**
- **Description**: Arithmetic operations exceeding type boundaries
- **Examples**:
  - Unchecked arithmetic causing wrap-around (tc samples)
  - Token balance overflow/underflow (ds samples)
- **Impact**: Incorrect balances, fund creation, access bypass

**6. Denial of Service (11 total: GS=3, DS=8)**
- **Description**: Contract functionality rendered unusable
- **Examples**:
  - Unbounded loops causing gas exhaustion (gs_005, gs_034)
  - External call failures blocking operations (ds samples)
- **Impact**: Service unavailability, locked funds, protocol halt

**7. Timestamp Dependency (14 total: DS=14)**
- **Description**: Reliance on block.timestamp for critical logic
- **Examples**:
  - Randomness derived from block properties (ds_001)
  - Time-based access control vulnerable to miner manipulation
- **Impact**: Predictable randomness, timing attacks, unfair advantages

**8. Signature Replay (4 total: TC=1, GS=3)**
- **Description**: Reusing valid signatures in unauthorized contexts
- **Examples**:
  - Missing nonce/expiry allowing signature reuse (tc samples)
  - Cross-chain signature replay (gs samples)
- **Impact**: Unauthorized transactions, fund theft, access bypass

**9. Front-Running (7 total: GS=2, DS=5)**
- **Description**: Transaction ordering exploitation
- **Examples**:
  - Unstaking without time lock subject to MEV (gs_025)
  - Race conditions in approval mechanisms (ds samples)
- **Impact**: Value extraction, unfair advantages, sandwich attacks

**10. Flash Loan Attacks (2 total: GS=2)**
- **Description**: Attacks leveraging uncollateralized loans
- **Examples**:
  - Instant voting power acquisition (related to tc_002 pattern)
  - Flash loan-assisted oracle manipulation (related to tc_004 pattern)
- **Impact**: Governance manipulation, protocol exploitation, fund theft

**11. Unchecked Return Values (1 total: GS=1)**
- **Description**: Ignoring return values from critical operations
- **Examples**:
  - Unchecked ERC20 transfer return (gs_013)
  - Low-level call failures not handled (ds samples)
- **Impact**: Silent failures, fund loss, state inconsistency

**12. Input Validation (1 total: GS=1)**
- **Description**: Missing or insufficient input sanitization
- **Examples**:
  - Phantom token withdrawal without proper validation (gs_020)
  - Missing boundary checks on user inputs
- **Impact**: Invalid state, fund loss, contract exploitation

**13. Other (68 total: DS=68)**
- **Description**: Miscellaneous vulnerabilities not fitting primary categories
- **Examples**: Delegate call vulnerabilities, uninitialized storage, bad randomness, tx.origin usage
- **Impact**: Various depending on specific vulnerability

### Cross-Subset Distribution

| Vulnerability Type | TC | GS | DS | Total | Prevalence |
|-------------------|----|----|-----|-------|------------|
| **Logic Error** | 8 | 18 | 5 | 31 | 11.8% |
| **Access Control** | 16 | 3 | 27 | 46 | 17.5% |
| **Reentrancy** | 7 | 0 | 36 | 43 | 16.3% |
| **Oracle/Price Manipulation** | 10 | 1 | 2 | 13 | 4.9% |
| **Integer Overflow** | 6 | 0 | 16 | 22 | 8.4% |
| **Denial of Service** | 0 | 3 | 8 | 11 | 4.2% |
| **Timestamp Dependency** | 0 | 0 | 14 | 14 | 5.3% |
| **Signature Replay** | 1 | 3 | 0 | 4 | 1.5% |
| **Front-Running** | 0 | 2 | 5 | 7 | 2.7% |
| **Flash Loan** | 0 | 2 | 0 | 2 | 0.8% |
| **Unchecked Return** | 0 | 1 | 0 | 1 | 0.4% |
| **Input Validation** | 0 | 1 | 0 | 1 | 0.4% |
| **Other** | 0 | 0 | 68 | 68 | 25.9% |
| **Total** | 50 | 34 | 179 | 263 | 100% |

### Subset Specialization

**Temporal Contamination (TC)**: Focuses on high-impact vulnerabilities from historical exploits, emphasizing complex attack patterns involving oracle manipulation (20%), access control (32%), and logic errors (16%). These represent the most damaging real-world attacks with multi-million dollar impacts.

**Gold Standard (GS)**: Emphasizes subtle logic errors (53%) found in professional audits, representing vulnerabilities that require deep code understanding. Includes newer vulnerability classes like flash loan attacks and signature replay specific to modern DeFi protocols.

**Difficulty Stratified (DS)**: Provides broad coverage of classical vulnerabilities with emphasis on reentrancy (20%) and access control (15%), stratified by severity for graduated difficulty assessment. The "Other" category (38%) includes diverse vulnerability patterns for comprehensive testing.

## Data Processing and Validation

All 263 samples underwent rigorous validation to ensure ground truth accuracy. We systematically verified that contract names, function names, and line numbers in metadata aligned precisely with actual code:

- **TC samples (tc_001-tc_005)**: Corrected contract naming (e.g., VulnerableNomadReplica → BridgeReplica) and updated vulnerable location metadata with accurate line numbers.
- **GS samples**: Fixed metadata misalignments in gs_011, gs_012, gs_027, gs_028, gs_030, including function name corrections (e.g., gs_030: executeSessionCalls → execute, \_execute) and line range updates (e.g., gs_027: lines 230-241 → 251-262).
- **DS samples**: Validated all 179 samples for metadata-code consistency.

This validation process eliminated potential evaluation errors from metadata-code mismatches, ensuring reliable ground truth for model assessment.

## Adversarial Transformations

To systematically test model robustness against surface-level pattern matching, we implemented five adversarial transformation strategies. Each transformation preserves vulnerability semantics while removing specific surface features.

### 1. Sanitization Strategy: $\mathcal{T}_{\text{san}}$

**Formal Definition**:
$$\mathcal{T}_{\text{san}}(C) = \mathcal{R}(\mathcal{C}(C)) \text{ where}$$
$$\mathcal{R}: \text{Identifier} \to \text{Identifier} \text{ (rename function)}$$
$$\mathcal{C}: \text{Code} \to \text{Code} \text{ (comment removal function)}$$

**Implementation**: Sanitization removes vulnerability hints through comprehensive pattern-based cleaning:
- **Identifier Replacement** ($\mathcal{R}$): 280+ patterns mapping leaky identifiers to neutral alternatives (e.g., `vulnerableTransfer` → `executeTransfer`, `unsafeCall` → `invoke`)
- **Comment Removal** ($\mathcal{C}$): 100+ patterns removing vulnerability hints from comments (e.g., "// VULNERABILITY:", "// XXX: unsafe", "// TODO: add access control")
- **Emission Cleaning**: Removes console.log statements and emit events that leak vulnerability information
- **Preserves**: All code logic, control flow, and vulnerability semantics

**Output**: 263 sanitized samples with prefix `sn_*`

### 2. No-Comments Strategy: $\mathcal{T}_{\text{nc}}$

**Formal Definition**:
$$\mathcal{T}_{\text{nc}}(C) = C \setminus \mathcal{S}_{\text{comments}}$$
where $\mathcal{S}_{\text{comments}} = \{//\cdot, /\*\cdot\*/, ///\cdot\}$

**Implementation**: Strips all comments while preserving code structure:
- Single-line comments (`//`)
- Multi-line comments (`/* */`)
- Documentation comments (`///`, `/** */`)
- **Total Removed**: 4,358 comments across all files
- **Line Impact**: Average 15-20 lines removed per file

**Note**: Line numbers in metadata become outdated after comment removal due to line shifts. Evaluation should rely on contract + function names rather than exact line positions.

**Output**: 263 no-comments samples with prefix `nc_*`

### 3. Chameleon Strategy: $\mathcal{T}_{\text{cham}}$

**Formal Definition**:
$$\mathcal{T}_{\text{cham}}^{\theta}(C) = \bigcup_{i \in \mathcal{I}(C)} \rho_\theta(i)$$
where $\mathcal{I}(C)$ extracts all identifiers from $C$, and $\rho_\theta: \text{Identifier} \to \text{Identifier}$ applies thematic renaming with theme $\theta$

**Implementation**: Applies thematic renaming using randomized synonym pools while preserving code semantics:
- **Theme**: Medical ($\theta = \text{medical}$)
- **Synonym Pools**: Category-specific mappings (function names, variable names, contract names)
- **Layered Lookup**: (1) Direct lookup, (2) Compound word decomposition, (3) Prefix matching
- **Collision Resolution**: Deterministic suffix assignment for naming conflicts
- **Coverage**: 60-70% identifier transformation rate

**Example**: `BridgeReplica.process()` → `SystemReplica.treat()`

**Output**: 50 medical-themed TC samples with prefix `ch_medical_nc_tc_*`

### 4. Shapeshifter Strategy: $\mathcal{T}_{\text{shape}}$

**Formal Definition**:
$$\mathcal{T}_{\text{shape}}^{L,v}(C) = \mathcal{O}^v \circ \mathcal{F}(C)$$
where:
- $L \in \{L1, L2, L3, L4\}$ denotes transformation level
- $v$ denotes variant within level
- $\mathcal{F}$: formatting transformation (L1)
- $\mathcal{O}^v$: obfuscation at level/variant

**Levels**:
- **L1** (Formatting): $\mathcal{T}_{\text{shape}}^{L1,v}(C) = \mathcal{F}^v(C)$ where $v \in \{\text{compressed, expanded, allman, knr, minified}\}$
- **L2** (Identifier): $\mathcal{T}_{\text{shape}}^{L2,v}(C) = \mathcal{O}_{\text{id}}^v(C)$ where $v \in \{\text{short, hex, underscore}\}$
- **L3** (Control Flow): $\mathcal{T}_{\text{shape}}^{L3,v}(C) = \mathcal{O}_{\text{cf}}^v \circ \mathcal{O}_{\text{id}}(C)$ where $v \in \{\text{low, medium, high}\}$
- **L4** (Structural): $\mathcal{T}_{\text{shape}}^{L4,v}(C) = \mathcal{O}_{\text{struct}}^v \circ \mathcal{O}_{\text{cf}} \circ \mathcal{O}_{\text{id}}(C)$

**Implementation**:
- **L2 Short**: All identifiers → single letters (a-z): `acceptedRoot` → `e`, `process` → `m`
- **L3 Medium**: Hex-style identifiers + control flow obfuscation: `process` → `_0x1ff166`, adds always-true conditionals `if (1 == 1) { ... }`
- **Line Numbers**: Empty for L3+ due to control flow restructuring

**Output**:
- L2 short: 252 samples with prefix `ss_l2_short_nc_*`
- L3 medium: 252 samples with prefix `ss_l3_medium_nc_*`

### 5. Hydra Strategy: $\mathcal{T}_{\text{hydra}}$

**Formal Definition**:
$$\mathcal{T}_{\text{hydra}}^n(C) = \mathcal{T}_n \circ \cdots \circ \mathcal{T}_2 \circ \mathcal{T}_1(C)$$
where $\mathcal{T}_i$ represents composable transformations

**Implementation**: Combines multiple transformation strategies in sequence to create maximally obfuscated variants while preserving vulnerability semantics.

### 6. Restructure Strategy: $\mathcal{T}_{\text{restr}}$

**Formal Definition**:
$$\mathcal{T}_{\text{restr}}(C) = \begin{cases}
\mathcal{M}(\mathcal{S}(C)) & \text{merge mode} \\
\mathcal{S}(\mathcal{M}(C)) & \text{split mode}
\end{cases}$$
where:
- $\mathcal{S}$: contract splitting transformation
- $\mathcal{M}$: contract merging transformation

**Implementation**: Applies structural modifications through contract splitting (distributing functionality across multiple contracts) and merging operations (consolidating related functionality) to test model robustness to architectural changes.

## Dataset Statistics

| Variant | Count | Prefix Pattern | Source |
|---------|-------|----------------|--------|
| **Base** | 263 | `tc_*`, `gs_*`, `ds_*` | Original samples |
| **Sanitized** | 263 | `sn_*` | Base → Sanitization |
| **No-Comments** | 263 | `nc_*` | Sanitized → Comment removal |
| **Chameleon (Medical)** | 50 | `ch_medical_nc_tc_*` | TC No-Comments → Medical theme |
| **Shapeshifter L2** | 252 | `ss_l2_short_nc_*` | No-Comments → L2 short |
| **Shapeshifter L3** | 252 | `ss_l3_medium_nc_*` | No-Comments → L3 medium |
| **Total Variants** | 1,343 | - | - |

All transformations preserve vulnerability semantics while systematically removing surface-level patterns, enabling rigorous evaluation of model understanding versus memorization.

---

## Appendix: Detailed Transformation Notation

### A.1 Sanitization Transformation

**Full Notation**:
$$\mathcal{T}_{\text{san}}: \mathcal{C}_{\text{Solidity}} \to \mathcal{C}_{\text{Solidity}}$$

$$\mathcal{T}_{\text{san}}(C) = \mathcal{R}_{\text{ids}} \circ \mathcal{C}_{\text{comments}} \circ \mathcal{E}_{\text{emissions}}(C)$$

Where:
- $\mathcal{C}_{\text{Solidity}}$: Set of all valid Solidity contracts
- $\mathcal{R}_{\text{ids}}$: Identifier renaming with pattern database $\mathcal{P}_{\text{ids}} = \{p_1, \ldots, p_{280}\}$
- $\mathcal{C}_{\text{comments}}$: Comment removal with pattern database $\mathcal{P}_{\text{comm}} = \{p_1, \ldots, p_{100}\}$
- $\mathcal{E}_{\text{emissions}}$: Emission statement cleaning

**Pattern Matching**: For each pattern $p_i = (\text{regex}_i, \text{replacement}_i)$:
$$\mathcal{R}_{\text{ids}}^{p_i}(s) = \text{regex}_i.\text{replace}(s, \text{replacement}_i)$$

**Composition**:
$$\mathcal{T}_{\text{san}}(C) = \left(\bigcirc_{i=1}^{280} \mathcal{R}_{\text{ids}}^{p_i}\right) \circ \left(\bigcirc_{j=1}^{100} \mathcal{C}_{\text{comments}}^{p_j}\right) \circ \mathcal{E}_{\text{emissions}}(C)$$

### A.2 Chameleon Thematic Renaming

**Full Notation**:
$$\mathcal{T}_{\text{cham}}^{\theta}: \mathcal{C}_{\text{Solidity}} \to \mathcal{C}_{\text{Solidity}}$$

$$\mathcal{T}_{\text{cham}}^{\theta}(C) = \text{apply\_renames}(C, \mathcal{M}_{\theta})$$

Where:
- $\theta \in \Theta = \{\text{gaming, resource, abstract, medical, social}\}$: Theme
- $\mathcal{M}_{\theta} = \{(i_1, r_1), \ldots, (i_n, r_n)\}$: Rename map from identifier extraction
- $\mathcal{I}(C) = \{i_1, \ldots, i_n\}$: All user-defined identifiers in $C$

**Synonym Lookup**: For each identifier $i \in \mathcal{I}(C)$:
$$\rho_\theta(i) = \begin{cases}
\text{sample}(\mathcal{P}_{\theta,\text{cat}}[i]) & \text{if } i \in \mathcal{P}_{\theta,\text{cat}} \\
\text{decompose\_rename}(i, \theta) & \text{if compound word} \\
\text{prefix\_match}(i, \theta) & \text{if prefix matches} \\
i & \text{otherwise}
\end{cases}$$

Where $\mathcal{P}_{\theta,\text{cat}}$ is the synonym pool for theme $\theta$ and category $\text{cat} \in \{\text{function, variable, contract, event, error, modifier, struct}\}$

**Deterministic Seed**: $\text{seed} = \text{hash}(\theta \| \text{SHA256}(C)) \mod 2^{32}$

### A.3 Shapeshifter Multi-Level Obfuscation

**Full Notation**:
$$\mathcal{T}_{\text{shape}}^{L,v}: \mathcal{C}_{\text{Solidity}} \to \mathcal{C}_{\text{Solidity}}$$

**Level Definitions**:

**L2 (Identifier Obfuscation)**:
$$\mathcal{T}_{\text{shape}}^{L2,\text{short}}(C) = \text{apply\_renames}(C, \mathcal{M}_{\text{short}})$$

Where $\mathcal{M}_{\text{short}} = \{(i_k, \alpha_k) : i_k \in \mathcal{I}(C), \alpha_k \in \{a, b, \ldots, z\}\}$ with deterministic assignment

**L3 (Control Flow + Identifier Obfuscation)**:
$$\mathcal{T}_{\text{shape}}^{L3,\text{medium}}(C) = \mathcal{O}_{\text{cf}}^{\text{medium}} \circ \mathcal{T}_{\text{shape}}^{L2,\text{hex}}(C)$$

Where:
- $\mathcal{T}_{\text{shape}}^{L2,\text{hex}}$: Hex identifier obfuscation ($i_k \to \text{\_0x}[0-9a-f]\{6\}$)
- $\mathcal{O}_{\text{cf}}^{\text{medium}}$: Control flow obfuscation with medium intensity

**Control Flow Injection**: For statement $s$:
$$\mathcal{O}_{\text{cf}}(s) = \text{if } (\text{always\_true}()) \{ s \}$$

Where $\text{always\_true}() \in \{1 == 1, \text{block.timestamp} > 0, \text{true}\}$

**Intensity Levels**:
- Low: 10-30% statements wrapped
- Medium: 30-60% statements wrapped
- High: 60-90% statements wrapped

### A.4 No-Comments Line Mapping

**Full Notation**:
$$\mathcal{T}_{\text{nc}}: \mathcal{C}_{\text{Solidity}} \to \mathcal{C}_{\text{Solidity}}$$

$$\mathcal{T}_{\text{nc}}(C) = \bigcup_{l \in \mathcal{L}(C)} \begin{cases}
\emptyset & \text{if } l \in \mathcal{S}_{\text{comments}} \\
l & \text{otherwise}
\end{cases}$$

Where:
- $\mathcal{L}(C) = \{l_1, \ldots, l_m\}$: All lines in contract $C$
- $\mathcal{S}_{\text{comments}} = \{l : l \text{ matches } //\cdot \lor /\*\cdot\*/ \lor ///\cdot\}$

**Line Number Mapping**: For line $n$ in original code:
$$\phi_{\text{nc}}(n) = n - |\{l \in \mathcal{S}_{\text{comments}} : \text{line}(l) < n\}|$$

Note: Current implementation does not update line numbers in metadata, hence $\phi_{\text{nc}}$ is not applied. Evaluators should use contract + function names instead of line numbers.

### A.5 Vulnerability Semantic Preservation

**Invariant**: For all transformations $\mathcal{T} \in \{\mathcal{T}_{\text{san}}, \mathcal{T}_{\text{nc}}, \mathcal{T}_{\text{cham}}, \mathcal{T}_{\text{shape}}\}$:

$$\mathcal{V}(\mathcal{T}(C)) = \mathcal{V}(C)$$

Where $\mathcal{V}: \mathcal{C}_{\text{Solidity}} \to \{\text{vuln\_type}, \text{root\_cause}, \text{attack\_vector}\}$ extracts vulnerability semantics.

**Preservation Guarantee**: Transformations satisfy:
1. **Control Flow Preservation**: $\mathcal{F}_{\text{cfg}}(\mathcal{T}(C)) \equiv \mathcal{F}_{\text{cfg}}(C)$
2. **Data Flow Preservation**: $\mathcal{F}_{\text{dfa}}(\mathcal{T}(C)) \equiv \mathcal{F}_{\text{dfa}}(C)$
3. **State Transition Preservation**: $\forall \sigma, \sigma': (\sigma, C) \to \sigma' \iff (\sigma, \mathcal{T}(C)) \to \sigma'$

---

## References

[1] SunWeb3Sec. "DeFiHackLabs: Solidity PoC for DeFi exploits." GitHub repository. https://github.com/SunWeb3Sec/DeFiHackLabs

[2] Rekt News. "Rekt: Anonymous DeFi Journalism." https://rekt.news

[3] Spearbit. "Security Audits: Aragon Lock-to-Vote, Velodrome V2." 2025. https://github.com/spearbit/portfolio

[4] MixBytes. "Smart Contract Security Audits." 2025. https://mixbytes.io

[5] Code4rena. "Competitive Audit Contests." 2025. https://code4rena.com

[6] Durieux, T., Ferreira, J. F., Abreu, R., & Cruz, P. "SmartBugs: A Framework for Analyzing Solidity Smart Contracts." ASE 2020. https://github.com/smartbugs/smartbugs

[7] Trail of Bits. "Not So Smart Contracts: Examples of common Ethereum smart contract vulnerabilities." GitHub repository. https://github.com/crytic/not-so-smart-contracts
