# BlockBench Code Act Annotation Guide

## Manual Annotation Protocol for Causal Understanding Evaluation

**Version:** 1.0  
**Last Updated:** January 2026  
**Purpose:** Standardized annotation of Code Acts and Security Functions for BlockBench Differential and Trojan samples

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Goals and Research Questions](#2-goals-and-research-questions)
3. [Code Act Taxonomy](#3-code-act-taxonomy)
4. [Security Function Taxonomy](#4-security-function-taxonomy)
5. [Annotation Scope](#5-annotation-scope)
6. [Differential Sample Annotation](#6-differential-sample-annotation)
7. [Trojan Sample Annotation](#7-trojan-sample-annotation)
8. [Annotation Procedure](#8-annotation-procedure)
9. [Quality Control](#9-quality-control)
10. [Dataset Release Format](#10-dataset-release-format)
11. [Examples](#11-examples)

---

## 1. Introduction

### 1.1 What Are Code Acts?

Code Acts are discrete, security-relevant code operations within a smart contract. Each Code Act represents an atomic unit of code that could plausibly be involved in a security vulnerability.

The term draws inspiration from Speech Act Theory in linguistics, where utterances are classified by their function (assertion, request, promise, etc.). Similarly, Code Acts classify code segments by their security-relevant function.

### 1.2 Why Code Act Annotation?

Standard vulnerability detection metrics (accuracy, precision, recall) measure **what** models detect but not **why** they detect it. Two models might both correctly identify a reentrancy vulnerability:

- **Model A:** "The external call at line 45 occurs before the state update at line 48, allowing recursive calls to drain funds."

- **Model B:** "This contract has a reentrancy vulnerability because it uses an external call."

Both achieve TARGET_MATCH. But Model A demonstrates causal understanding while Model B shows pattern recognition.

Code Act annotation enables us to measure:

- Does the model identify the correct code elements as the vulnerability root cause?
- Does the model get distracted by suspicious-looking but safe code?
- Does the model understand what a fix changes and why it works?

### 1.3 Scope of This Guide

This guide covers annotation for two BlockBench transformation types:

| Transformation   | Description                                            | Code Act Purpose                                   |
| ---------------- | ------------------------------------------------------ | -------------------------------------------------- |
| **Differential** | Vulnerable (MinimalSanitized) vs. Fixed version pairs  | Track ROOT_CAUSE → BENIGN transitions              |
| **Trojan**       | Vulnerable code with injected suspicious-but-safe code | Identify DECOY elements that test pattern matching |

Other transformations (Sanitization, Chameleon, Shapeshifter, FalseProject) do not require Code Act annotation — existing metrics suffice.

---

## 2. Goals and Research Questions

### 2.1 Primary Goal

Provide ground-truth annotations that enable measurement of **causal understanding** versus **pattern matching** in LLM vulnerability detection.

### 2.2 Research Questions Addressed

| Question                                              | How Code Acts Help                                      |
| ----------------------------------------------------- | ------------------------------------------------------- |
| Do models understand WHY code is vulnerable?          | Check if model identifies ROOT_CAUSE elements           |
| Do models recognize when vulnerabilities are fixed?   | Compare model verdicts on vulnerable vs. fixed versions |
| Do models get fooled by suspicious-looking safe code? | Check if model flags DECOY elements                     |
| Is model reasoning causal or superficial?             | Analyze which Code Acts model emphasizes in explanation |

### 2.3 Metrics Enabled

| Metric                            | Definition                                         | Requires                 |
| --------------------------------- | -------------------------------------------------- | ------------------------ |
| **Differential Consistency (DC)** | Correct on both vulnerable AND fixed versions      | Differential annotations |
| **Fix Recognition Rate (FRR)**    | Recognizes fixed version is secure                 | Differential annotations |
| **Root Cause Precision (RCP)**    | Proportion of flagged elements that are ROOT_CAUSE | Both                     |
| **Decoy Resistance (DR)**         | Avoids flagging DECOY elements                     | Trojan annotations       |
| **Distraction Rate**              | Real vulnerability missed due to DECOY focus       | Trojan annotations       |

---

## 3. Code Act Taxonomy

### 3.1 Definition

A **Code Act** is an atomic code operation that:

1. Could plausibly be identified as security-relevant by a model or auditor
2. Has a defined location (file, function, line number)
3. Falls into one of the defined categories below

### 3.2 Code Act Types

#### 3.2.1 EXT_CALL — External Call

**Definition:** Any call to an external contract or address.

**Security Relevance:** Classic trigger for reentrancy, can transfer control flow to untrusted code.

**Solidity Patterns:**

```solidity
// Low-level calls
address.call{value: x}("");
address.call(data);
address.delegatecall(data);
address.staticcall(data);

// High-level calls
IERC20(token).transfer(to, amount);
externalContract.someFunction();

// Transfer/send
payable(addr).transfer(amount);
payable(addr).send(amount);
```

**Annotation Notes:**

- Each distinct external call is a separate Code Act
- Internal function calls within the same contract are NOT Code Acts
- Calls to well-known safe contracts (e.g., OpenZeppelin) are still Code Acts but may be BENIGN

---

#### 3.2.2 STATE_MOD — State Modification

**Definition:** Any write to a storage variable.

**Security Relevance:** Order of state modifications relative to external calls determines reentrancy exploitability. Missing state updates cause logic errors.

**Solidity Patterns:**

```solidity
balances[user] = 0;
totalSupply += amount;
owner = newOwner;
isActive = false;
mapping[key] = value;
array.push(item);
delete mapping[key];
```

**Annotation Notes:**

- Each distinct state modification is a separate Code Act
- Memory/stack variables are NOT Code Acts (only storage)
- The order relative to EXT_CALL is often critical

---

#### 3.2.3 ACCESS_CTRL — Access Control Check

**Definition:** Permission or authorization check that restricts function access.

**Security Relevance:** Missing or incorrect access control is a top vulnerability class.

**Solidity Patterns:**

```solidity
require(msg.sender == owner, "Not owner");
require(hasRole(ADMIN_ROLE, msg.sender));
onlyOwner modifier
onlyRole(MINTER_ROLE) modifier
if (msg.sender != admin) revert();
```

**Annotation Notes:**

- Annotate both the check AND its location
- Note if the check is present but insufficient (INSUFF_GUARD)
- Missing access control is annotated as absence of expected ACCESS_CTRL

---

#### 3.2.4 ARITHMETIC — Arithmetic Operation

**Definition:** Mathematical computation that could overflow, underflow, or produce unexpected results.

**Security Relevance:** Overflow/underflow (pre-0.8.0), precision loss, division by zero, rounding errors.

**Solidity Patterns:**

```solidity
amount * price / PRECISION
balance + deposit
unchecked { counter++; }
a / b  // potential division by zero
(a * b) / c  // potential overflow before division
```

**Annotation Notes:**

- Focus on operations involving user input or external data
- Note Solidity version (0.8.0+ has built-in overflow checks)
- unchecked blocks are particularly relevant

---

#### 3.2.5 INPUT_VAL — Input Validation

**Definition:** Validation or sanitization of input parameters.

**Security Relevance:** Missing validation enables various attacks; incorrect validation gives false security.

**Solidity Patterns:**

```solidity
require(amount > 0, "Zero amount");
require(to != address(0), "Invalid address");
require(deadline >= block.timestamp, "Expired");
if (amount > maxAllowed) revert();
```

**Annotation Notes:**

- Note what is being validated and what is NOT
- Missing expected validation is noted as absence
- Validate whether the check is sufficient for its purpose

---

#### 3.2.6 CTRL_FLOW — Control Flow Logic

**Definition:** Conditional logic or loops that affect execution path.

**Security Relevance:** Logic errors, incorrect conditions, loop manipulation.

**Solidity Patterns:**

```solidity
if (balance > threshold) { ... }
for (uint i = 0; i < users.length; i++) { ... }
while (remaining > 0) { ... }
condition ? valueA : valueB
```

**Annotation Notes:**

- Focus on conditions with security implications
- Note if condition can be manipulated by attacker
- Unbounded loops are particularly relevant (DoS)

---

#### 3.2.7 FUND_XFER — Fund Transfer

**Definition:** Movement of ETH or tokens.

**Security Relevance:** Direct financial impact, often the target of exploits.

**Solidity Patterns:**

```solidity
payable(recipient).transfer(amount);
IERC20(token).transfer(to, amount);
IERC20(token).transferFrom(from, to, amount);
(bool success,) = to.call{value: amount}("");
```

**Annotation Notes:**

- FUND_XFER often overlaps with EXT_CALL — annotate as FUND_XFER when funds move
- Note source and destination of funds
- Check for return value handling

---

#### 3.2.8 DELEGATE — Delegate Call

**Definition:** delegatecall that executes external code in current context.

**Security Relevance:** Extremely dangerous — external code can modify all storage.

**Solidity Patterns:**

```solidity
implementation.delegatecall(data);
proxy.delegatecall(abi.encodeWithSignature(...));
```

**Annotation Notes:**

- Almost always high-risk unless in controlled proxy patterns
- Note if destination address is user-controllable
- Check for proper access control on functions using delegatecall

---

#### 3.2.9 TIMESTAMP — Timestamp Dependency

**Definition:** Use of block.timestamp or time-based logic.

**Security Relevance:** Miner manipulation (within ~15 second window), deadline bypasses.

**Solidity Patterns:**

```solidity
require(block.timestamp >= startTime);
if (block.timestamp > deadline) revert();
lockTime = block.timestamp + duration;
```

**Annotation Notes:**

- Critical for time-locked functions
- Note the tolerance/window for manipulation
- Less critical in PoS (post-merge)

---

#### 3.2.10 RANDOM — Randomness Source

**Definition:** Attempt to generate random values on-chain.

**Security Relevance:** On-chain randomness is predictable/manipulable.

**Solidity Patterns:**

```solidity
uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
block.prevrandao  // post-merge)
blockhash(block.number - 1)
```

**Annotation Notes:**

- On-chain randomness is almost never secure
- Note if used for high-value decisions
- Check for commit-reveal or oracle-based alternatives

---

#### 3.2.11 ORACLE — Oracle Interaction

**Definition:** Query to external price feed or data oracle.

**Security Relevance:** Price manipulation, stale data, oracle failure.

**Solidity Patterns:**

```solidity
oracle.latestAnswer();
priceFeed.getLatestPrice();
pool.observe(...);  // Uniswap TWAP
```

**Annotation Notes:**

- Check for staleness validation
- Note if single oracle or multiple sources
- Check for manipulation resistance (TWAP vs spot)

---

#### 3.2.12 REENTRY_GUARD — Reentrancy Protection

**Definition:** Mutex lock or reentrancy guard pattern.

**Security Relevance:** Presence indicates awareness of reentrancy; check if correctly implemented.

**Solidity Patterns:**

```solidity
// OpenZeppelin
nonReentrant modifier

// Manual
require(!locked, "Reentrant");
locked = true;
...
locked = false;
```

**Annotation Notes:**

- Note if guard covers all vulnerable paths
- Check for correct placement (before external calls)
- Note if guard can be bypassed (cross-function reentrancy)

---

#### 3.2.13 STORAGE_READ — Storage Read

**Definition:** Reading from storage variable.

**Security Relevance:** Usually benign alone, but order relative to STATE_MOD matters.

**Solidity Patterns:**

```solidity
uint balance = balances[msg.sender];
address currentOwner = owner;
```

**Annotation Notes:**

- Relevant when read-then-modify patterns exist
- Note if cached value could become stale
- Usually BENIGN or PREREQ, rarely ROOT_CAUSE alone

---

### 3.3 Quick Reference Table

| Code Act      | Abbrev             | Key Question                                     |
| ------------- | ------------------ | ------------------------------------------------ |
| EXT_CALL      | External Call      | Does it transfer control to untrusted code?      |
| STATE_MOD     | State Modification | Is the order correct relative to external calls? |
| ACCESS_CTRL   | Access Control     | Is authorization sufficient?                     |
| ARITHMETIC    | Arithmetic         | Can it overflow/underflow/divide by zero?        |
| INPUT_VAL     | Input Validation   | Are all inputs properly validated?               |
| CTRL_FLOW     | Control Flow       | Can the condition be manipulated?                |
| FUND_XFER     | Fund Transfer      | Are funds protected throughout?                  |
| DELEGATE      | Delegate Call      | Is the target trusted and access controlled?     |
| TIMESTAMP     | Timestamp          | Is the time tolerance acceptable?                |
| RANDOM        | Randomness         | Is the entropy source manipulable?               |
| ORACLE        | Oracle             | Is the price feed manipulation-resistant?        |
| REENTRY_GUARD | Reentrancy Guard   | Does it cover all paths correctly?               |
| STORAGE_READ  | Storage Read       | Could the cached value become stale?             |

---

## 4. Security Function Taxonomy

### 4.1 Definition

A **Security Function** is the role a Code Act plays in the context of a specific vulnerability. The same Code Act type (e.g., EXT_CALL) may have different Security Functions in different contexts.

### 4.2 Security Function Types

#### 4.2.1 ROOT_CAUSE

**Definition:** The Code Act directly enables exploitation of the vulnerability.

**Characteristics:**

- Removing or fixing this element would eliminate the vulnerability
- The vulnerability cannot be exploited without this element
- Multiple Code Acts can share ROOT_CAUSE status (e.g., ordering issues)

**Examples:**

- The external call that enables reentrancy
- The missing access control check
- The arithmetic operation that overflows
- The state modification in wrong order

**Annotation Decision:** Ask "If I fixed ONLY this Code Act, would the vulnerability be eliminated?" If yes → ROOT_CAUSE.

---

#### 4.2.2 PREREQ (Prerequisite)

**Definition:** A Code Act necessary for exploitation but not exploitable on its own.

**Characteristics:**

- Enables or sets up the ROOT_CAUSE
- Fixing the ROOT_CAUSE makes this element harmless
- Alone, this element is not a vulnerability

**Examples:**

- Storage read that caches a value later used in exploit
- Condition check that passes (enabling vulnerable path)
- Value assignment that sets up the vulnerable state

**Annotation Decision:** Ask "Is this necessary for the exploit, but not the actual vulnerability?" If yes → PREREQ.

---

#### 4.2.3 INSUFF_GUARD (Insufficient Guard)

**Definition:** An attempted protection that fails to prevent the vulnerability.

**Characteristics:**

- Developer intended this as a security measure
- The protection is incomplete, bypassable, or incorrectly implemented
- Shows awareness of risk but incorrect mitigation

**Examples:**

- Access control that checks wrong condition
- Input validation that doesn't cover all cases
- Reentrancy guard that doesn't cover all functions
- Check that can be bypassed by attacker

**Annotation Decision:** Ask "Was this meant to prevent an attack but fails?" If yes → INSUFF_GUARD.

---

#### 4.2.4 DECOY

**Definition:** A Code Act that looks suspicious but is actually safe in context.

**Characteristics:**

- Matches a known vulnerability pattern superficially
- Contextual factors make it unexploitable
- A pattern-matching model might flag this incorrectly

**Examples:**

- External call with no funds at risk
- External call protected by reentrancy guard
- Arithmetic in unchecked block where overflow is impossible due to bounds
- External call to verified/immutable trusted contract
- State modification that appears out of order but isn't reachable

**Annotation Decision:** Ask "Does this look dangerous but is actually safe? Would a pattern-matching model flag this?" If yes → DECOY.

**Critical Note:** DECOY annotation is essential for measuring pattern matching vs. understanding. Be thorough in identifying elements that LOOK vulnerable but AREN'T.

---

#### 4.2.5 BENIGN

**Definition:** A security-relevant Code Act that is correctly implemented and safe.

**Characteristics:**

- Follows security best practices
- Could be a Code Act type that is often vulnerable, but isn't here
- No exploitation potential

**Examples:**

- External call AFTER state update (correct CEI pattern)
- Proper access control check
- Arithmetic with SafeMath or in Solidity 0.8.0+
- Complete input validation

**Annotation Decision:** Ask "Is this security-relevant but correctly implemented?" If yes → BENIGN.

---

#### 4.2.6 UNRELATED

**Definition:** A Code Act present in the code but irrelevant to the documented vulnerability.

**Characteristics:**

- Different function from the vulnerability
- No interaction with vulnerable code path
- Including for completeness but not central to analysis

**Examples:**

- External call in admin function when vulnerability is in user function
- State modification in unrelated subsystem
- Access control for different privilege level

**Annotation Decision:** Ask "Does this have any connection to the documented vulnerability?" If no → UNRELATED.

---

### 4.3 Security Function Decision Tree

```
Is this Code Act in the vulnerable code path?
│
├── No → UNRELATED
│
└── Yes → Does removing/fixing this eliminate the vulnerability?
    │
    ├── Yes → ROOT_CAUSE
    │
    └── No → Is it necessary for the exploit to work?
        │
        ├── Yes → PREREQ
        │
        └── No → Was it intended as a protection?
            │
            ├── Yes (but fails) → INSUFF_GUARD
            │
            └── No → Does it LOOK vulnerable but is actually safe?
                │
                ├── Yes → DECOY
                │
                └── No → BENIGN
```

### 4.4 Quick Reference Table

| Security Function | Symbol | Key Question                                      | Want Models to Flag? |
| ----------------- | ------ | ------------------------------------------------- | -------------------- |
| ROOT_CAUSE        | 🔴     | Does this directly cause the vulnerability?       | Yes                  |
| PREREQ            | 🟡     | Does this enable but not cause the vulnerability? | Partial credit       |
| INSUFF_GUARD      | 🟠     | Is this a failed protection attempt?              | Yes (if explained)   |
| DECOY             | 🔵     | Does this look dangerous but is actually safe?    | No (pattern trap)    |
| BENIGN            | 🟢     | Is this correctly implemented?                    | No                   |
| UNRELATED         | ⚪     | Is this irrelevant to the vulnerability?          | No                   |

---

## 5. Annotation Scope

### 5.1 Samples to Annotate

| Dataset Subset | Sample Count | Annotation Type                                   |
| -------------- | ------------ | ------------------------------------------------- |
| Differential   | 50 pairs     | Full Code Act + Security Function (both versions) |
| Trojan         | 50 samples   | Injected DECOY elements only                      |

### 5.2 Differential Samples

**Structure:**

```
Differential Sample
├── Vulnerable Version (MinimalSanitized)
│   └── Original code with revealing comments removed
│   └── Contains the vulnerability
│
└── Fixed Version
    └── Patched code from audit/commit
    └── Vulnerability resolved
```

**MinimalSanitized Explained:**

The vulnerable version uses "MinimalSanitized" — the original vulnerable code with revealing comments and obvious hints removed, but code logic unchanged. This prevents models from:

- Reading comments like "// TODO: fix reentrancy bug"
- Seeing variable names like `unsafeWithdraw`
- Getting hints from NatSpec documentation mentioning issues

The actual vulnerability remains intact; only documentation hints are removed.

**Annotation Covers:**

- All security-relevant Code Acts in vulnerable version
- Security Functions for each Code Act (vulnerable version)
- Security Functions for each Code Act (fixed version)
- Transitions: How each Code Act's Security Function changed

### 5.3 Trojan Samples

**Structure:**

```
Trojan Sample
├── Base Vulnerable Code
│   └── Contains real vulnerability (annotated elsewhere)
│
└── Injected DECOY Elements
    └── Suspicious-looking but safe code additions
    └── Designed to trigger pattern matching
```

**Annotation Covers:**

- Only the INJECTED elements
- All injections are DECOY by design
- Document why each injection looks dangerous but is safe

---

## 6. Differential Sample Annotation

### 6.1 Annotation Steps

#### Step 1: Gather Context

Collect the following information:

| Information            | Source                      |
| ---------------------- | --------------------------- |
| Vulnerability type     | Audit report / ground truth |
| Severity               | Audit report                |
| Affected function(s)   | Audit report                |
| Root cause description | Audit report                |
| Fix description        | Commit message / audit      |
| Vulnerable code        | MinimalSanitized version    |
| Fixed code             | Fixed version               |

#### Step 2: Identify All Code Acts

Read through the vulnerable version and list every Code Act in or near the vulnerable function(s). Use this template:

```yaml
code_acts:
  - id: CA1
    type: [CODE_ACT_TYPE]
    location_vulnerable:
      file: 'Contract.sol'
      function: 'functionName()'
      line: 45
    code_snippet: 'exact code'
```

**Guidelines:**

- Include all Code Acts in the vulnerable function
- Include Code Acts in related functions that interact with the vulnerability
- Include DECOY-like elements that might trigger false positives
- Err on the side of inclusion — better to annotate too many than miss important ones

#### Step 3: Assign Security Functions (Vulnerable Version)

For each Code Act, determine its Security Function:

```yaml
code_acts:
  - id: CA1
    type: EXT_CALL
    security_function_vulnerable: ROOT_CAUSE
    rationale_vulnerable: 'External call before state update enables reentrancy'
```

**Guidelines:**

- Use the audit report to confirm ROOT_CAUSE identification
- Ask "what would fixing this element change?" for each
- Identify DECOY elements that look vulnerable but aren't

#### Step 4: Map to Fixed Version

For each Code Act, find its counterpart in the fixed version:

```yaml
code_acts:
  - id: CA1
    type: EXT_CALL
    location_vulnerable:
      line: 45
    location_fixed:
      line: 52 # Moved after state update
    code_snippet_fixed: 'same code, new location'
```

**Possibilities:**

- Code Act moved (different line)
- Code Act modified (changed code)
- Code Act removed (deleted)
- Code Act added (new in fixed version)
- Code Act unchanged (same line, same code)

#### Step 5: Assign Security Functions (Fixed Version)

For each Code Act, determine its new Security Function:

```yaml
code_acts:
  - id: CA1
    type: EXT_CALL
    security_function_vulnerable: ROOT_CAUSE
    security_function_fixed: BENIGN
    transition: 'ROOT_CAUSE → BENIGN'
    transition_reason: 'Now occurs after state update, following CEI pattern'
```

#### Step 6: Document Transitions

Create a summary of all Security Function transitions:

| Transition            | Meaning                            | Example                      |
| --------------------- | ---------------------------------- | ---------------------------- |
| ROOT_CAUSE → BENIGN   | Fix neutralized the vulnerability  | EXT_CALL now after STATE_MOD |
| ROOT_CAUSE → REMOVED  | Vulnerable code deleted            | Function removed entirely    |
| INSUFF_GUARD → BENIGN | Guard strengthened                 | Added missing condition      |
| DECOY → DECOY         | Still looks suspicious, still safe | Unrelated external call      |
| BENIGN → BENIGN       | No change                          | Safe code remained safe      |

### 6.2 Differential Annotation Template

```yaml
--- # --- METADATA ---
# ============================================
# DIFFERENTIAL SAMPLE ANNOTATION
# ============================================

sample_id: 'DIFF-001'
source: 'Code4rena'
contest: '2024-05-example-protocol'
commit_vulnerable: 'abc1234'
commit_fixed: 'def5678'

# --- VULNERABILITY INFO ---
vulnerability:
  type: 'Reentrancy'
  severity: 'High'
  title: 'Reentrancy in withdraw() allows fund drainage'
  affected_function: 'withdraw()'
  file: 'Vault.sol'
  root_cause_summary: 'External call before state update'
  fix_summary: 'Reordered to update state before external call'

# --- CODE ACTS ---
code_acts:
  # Code Act 1: Storage Read
  - id: CA1
    type: STORAGE_READ
    description: 'Read user balance from storage'

    location_vulnerable:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 42
    code_snippet_vulnerable: 'uint256 amount = balances[msg.sender];'
    security_function_vulnerable: PREREQ
    rationale_vulnerable: 'Reads balance that will be drained; necessary for exploit but not the cause'

    location_fixed:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 42
    code_snippet_fixed: 'uint256 amount = balances[msg.sender];'
    security_function_fixed: BENIGN
    rationale_fixed: 'Same read, now safe due to correct ordering'

    transition: 'PREREQ → BENIGN'

  # Code Act 2: Input Validation
  - id: CA2
    type: INPUT_VAL
    description: 'Check for non-zero balance'

    location_vulnerable:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 43
    code_snippet_vulnerable: 'require(amount > 0, "No balance");'
    security_function_vulnerable: BENIGN
    rationale_vulnerable: 'Correct validation, not related to reentrancy'

    location_fixed:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 43
    code_snippet_fixed: 'require(amount > 0, "No balance");'
    security_function_fixed: BENIGN
    rationale_fixed: 'Unchanged, still correct'

    transition: 'BENIGN → BENIGN'

  # Code Act 3: External Call (ROOT CAUSE)
  - id: CA3
    type: EXT_CALL
    description: 'Send ETH to user'

    location_vulnerable:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 45
    code_snippet_vulnerable: '(bool success, ) = msg.sender.call{value: amount}("");'
    security_function_vulnerable: ROOT_CAUSE
    rationale_vulnerable: 'External call BEFORE state update enables reentrancy'

    location_fixed:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 48
    code_snippet_fixed: '(bool success, ) = msg.sender.call{value: amount}("");'
    security_function_fixed: BENIGN
    rationale_fixed: 'External call now AFTER state update, safe'

    transition: 'ROOT_CAUSE → BENIGN'

  # Code Act 4: State Modification (ROOT CAUSE)
  - id: CA4
    type: STATE_MOD
    description: 'Zero out user balance'

    location_vulnerable:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 48
    code_snippet_vulnerable: 'balances[msg.sender] = 0;'
    security_function_vulnerable: ROOT_CAUSE
    rationale_vulnerable: 'State update AFTER external call is the ordering bug'

    location_fixed:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 45
    code_snippet_fixed: 'balances[msg.sender] = 0;'
    security_function_fixed: BENIGN
    rationale_fixed: 'State update now BEFORE external call, correct CEI'

    transition: 'ROOT_CAUSE → BENIGN'

  # Code Act 5: Unrelated External Call (DECOY)
  - id: CA5
    type: EXT_CALL
    description: 'Oracle price update in different function'

    location_vulnerable:
      file: 'Vault.sol'
      function: 'updatePrice()'
      line: 78
    code_snippet_vulnerable: 'oracle.sync();'
    security_function_vulnerable: DECOY
    rationale_vulnerable: 'External call but in unrelated function, no funds at risk'

    location_fixed:
      file: 'Vault.sol'
      function: 'updatePrice()'
      line: 78
    code_snippet_fixed: 'oracle.sync();'
    security_function_fixed: DECOY
    rationale_fixed: 'Still looks suspicious, still safe'

    transition: 'DECOY → DECOY'
    is_decoy: true
    decoy_reason: 'External call pattern but different function, no user funds, onlyOwner protected'

# --- SUMMARY ---
annotation_summary:
  total_code_acts: 5
  root_causes: 2
  prerequisites: 1
  decoys: 1
  benign: 1

  transitions:
    root_cause_to_benign: 2
    prereq_to_benign: 1
    decoy_to_decoy: 1
    benign_to_benign: 1

# --- ANNOTATOR INFO ---
annotator: 'annotator_name'
annotation_date: '2026-01-15'
review_status: 'pending' # pending | reviewed | verified
```

---

## 7. Trojan Sample Annotation

### 7.1 Purpose

Trojan samples test whether models get distracted by suspicious-looking but safe code injections. The annotation documents what was injected and why it's actually safe.

### 7.2 Annotation Scope

**Annotate ONLY:**

- The injected DECOY elements
- Why each injection looks suspicious
- Why each injection is actually safe

**Do NOT annotate:**

- The base vulnerability (already annotated in standard dataset)
- Other Code Acts in the original code

### 7.3 Annotation Steps

#### Step 1: Identify All Injections

List every code element that was added to create the Trojan variant:

```yaml
injections:
  - id: INJ1
    type: [CODE_ACT_TYPE]
    location:
      file: 'Contract.sol'
      function: 'functionName()'
      line: 67
    code_snippet: 'injected code'
```

#### Step 2: Document Suspicious Appearance

For each injection, explain why it looks dangerous:

```yaml
injections:
  - id: INJ1
    type: EXT_CALL
    looks_suspicious_because: 'External call pattern is a classic reentrancy trigger'
    pattern_triggered: 'Reentrancy'
```

#### Step 3: Document Why It's Safe

Explain the contextual factors that make the injection safe:

```yaml
injections:
  - id: INJ1
    type: EXT_CALL
    actually_safe_because: 'Call is to an immutable trusted contract, no user funds involved, protected by onlyOwner modifier'
    safety_factors:
      - 'Trusted callee (immutable address)'
      - 'No funds at risk'
      - 'Access controlled'
```

#### Step 4: Note Relationship to Real Vulnerability

Document whether the injection is in the same function/area as the real vulnerability:

```yaml
injections:
  - id: INJ1
    proximity_to_vulnerability: 'same_function' # same_function | same_file | different_file
    distraction_risk: 'high' # high | medium | low
```

### 7.4 Trojan Annotation Template

```yaml
--- # --- METADATA ---
# ============================================
# TROJAN SAMPLE ANNOTATION
# ============================================

sample_id: 'TROJ-001'
base_sample_id: 'DS-042' # Reference to original sample
trojan_strategy: 'suspicious_external_calls'

# --- BASE VULNERABILITY (Reference Only) ---
base_vulnerability:
  type: 'Reentrancy'
  function: 'withdraw()'
  note: 'See DS-042 for full vulnerability annotation'

# --- INJECTED DECOYS ---
injections:
  # Injection 1: External call that looks dangerous
  - id: INJ1
    type: EXT_CALL
    security_function: DECOY

    location:
      file: 'Vault.sol'
      function: 'withdraw()' # Same function as vulnerability
      line: 52
    code_snippet: 'feeCollector.notifyWithdrawal(msg.sender, amount);'

    looks_suspicious_because: |
      - External call in the same function as a reentrancy vulnerability
      - Called during a withdrawal operation
      - Passes user address and amount

    actually_safe_because: |
      - feeCollector is an immutable address set in constructor
      - notifyWithdrawal is a view/pure function (no state changes)
      - Even if reentered, no funds are at risk at this point

    safety_factors:
      - 'Immutable trusted address'
      - 'No callback risk (view function)'
      - 'No funds at risk'

    pattern_triggered: 'reentrancy'
    proximity_to_vulnerability: 'same_function'
    distraction_risk: 'high'

  # Injection 2: Unchecked arithmetic that looks dangerous
  - id: INJ2
    type: ARITHMETIC
    security_function: DECOY

    location:
      file: 'Vault.sol'
      function: 'calculateFees()'
      line: 89
    code_snippet: 'unchecked { totalFees += fee; }'

    looks_suspicious_because: |
      - Uses unchecked block which disables overflow protection
      - Involves addition which could overflow

    actually_safe_because: |
      - fee is bounded by basis points (max 10000)
      - totalFees is reset each epoch (max ~100 transactions)
      - Maximum possible value << uint256 max

    safety_factors:
      - 'Bounded input values'
      - 'Periodic reset'
      - 'Mathematical impossibility of overflow'

    pattern_triggered: 'arithmetic_overflow'
    proximity_to_vulnerability: 'different_function'
    distraction_risk: 'low'

  # Injection 3: Missing access control (apparent)
  - id: INJ3
    type: ACCESS_CTRL
    security_function: DECOY

    location:
      file: 'Vault.sol'
      function: 'getVaultStats()'
      line: 112
    code_snippet: 'function getVaultStats() external returns (uint256, uint256) {'

    looks_suspicious_because: |
      - No access control modifier (no onlyOwner, etc.)
      - External visibility
      - Returns potentially sensitive data

    actually_safe_because: |
      - Pure read function, no state modifications
      - Information is already publicly readable on-chain
      - No security impact from unrestricted access

    safety_factors:
      - 'Read-only function'
      - 'Public information'
      - 'No state changes'

    pattern_triggered: 'missing_access_control'
    proximity_to_vulnerability: 'same_file'
    distraction_risk: 'medium'

# --- SUMMARY ---
annotation_summary:
  total_injections: 3
  injection_types:
    EXT_CALL: 1
    ARITHMETIC: 1
    ACCESS_CTRL: 1
  distraction_risk_breakdown:
    high: 1
    medium: 1
    low: 1

# --- ANNOTATOR INFO ---
annotator: 'annotator_name'
annotation_date: '2026-01-15'
review_status: 'pending'
```

---

## 8. Annotation Procedure

### 8.1 Preparation

1. **Set up annotation environment**

   - Code editor with Solidity syntax highlighting
   - Access to vulnerable and fixed code versions
   - Access to audit reports / ground truth
   - This annotation guide

2. **Gather materials per sample**
   - Vulnerable code (MinimalSanitized for Differential)
   - Fixed code (for Differential)
   - Trojan code (for Trojan samples)
   - Audit report excerpt or vulnerability description
   - Fix description / commit message

### 8.2 Annotation Workflow

```
┌─────────────────────────────────────────────────────┐
│                 START SAMPLE                         │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  1. Read audit report / vulnerability description   │
│     - Understand what the vulnerability is          │
│     - Understand how it was fixed                   │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  2. Read vulnerable code                            │
│     - Identify the vulnerable function(s)           │
│     - Identify all security-relevant code elements  │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  3. List all Code Acts                              │
│     - Use taxonomy from Section 3                   │
│     - Include potential DECOYs                      │
│     - Record locations and snippets                 │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  4. Assign Security Functions (vulnerable)          │
│     - Use decision tree from Section 4.3            │
│     - Document rationale for each                   │
└─────────────────────────────────────────────────────┘
                         │
           ┌─────────────┴─────────────┐
           │                           │
           ▼                           ▼
┌───────────────────┐       ┌───────────────────┐
│   DIFFERENTIAL    │       │      TROJAN       │
└───────────────────┘       └───────────────────┘
           │                           │
           ▼                           ▼
┌───────────────────┐       ┌───────────────────┐
│ 5a. Map to fixed  │       │ 5b. Document each │
│     version       │       │     injection     │
│ 6a. Assign new    │       │     - Why looks   │
│     Security      │       │       dangerous   │
│     Functions     │       │     - Why safe    │
│ 7a. Document      │       │                   │
│     transitions   │       │                   │
└───────────────────┘       └───────────────────┘
           │                           │
           └─────────────┬─────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  8. Review and validate                             │
│     - Check for missed Code Acts                    │
│     - Verify rationales are clear                   │
│     - Ensure DECOYs are identified                  │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  9. Save annotation file                            │
│     - Use naming convention: {TYPE}-{ID}.yaml       │
│     - DIFF-001.yaml, TROJ-001.yaml                  │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                   END SAMPLE                         │
└─────────────────────────────────────────────────────┘
```

### 8.3 Time Estimates

| Sample Type            | Estimated Time | Notes                          |
| ---------------------- | -------------- | ------------------------------ |
| Differential (simple)  | 15-20 minutes  | Clear fix, few Code Acts       |
| Differential (complex) | 30-45 minutes  | Multiple functions, subtle fix |
| Trojan                 | 10-15 minutes  | Only annotating injections     |

**Total for full dataset:**

- 50 Differential samples: ~20-30 hours
- 50 Trojan samples: ~8-12 hours
- Total: ~28-42 hours

### 8.4 Common Pitfalls

| Pitfall                  | How to Avoid                                                          |
| ------------------------ | --------------------------------------------------------------------- |
| Missing DECOYs           | Actively look for suspicious-looking safe code                        |
| Over-annotating          | Focus on security-relevant Code Acts only                             |
| Vague rationales         | Be specific: "External call before state update" not "Ordering issue" |
| Inconsistent granularity | One Code Act = one discrete operation                                 |
| Forgetting transitions   | Always document how Security Function changed                         |

---

## 9. Quality Control

### 9.1 Self-Review Checklist

Before considering a sample complete, verify:

**For All Samples:**

- [ ] All Code Acts in vulnerable function(s) are listed
- [ ] Each Code Act has correct type
- [ ] Each Code Act has clear location (file, function, line)
- [ ] Each Code Act has code snippet
- [ ] Security Function assigned with rationale
- [ ] At least one ROOT_CAUSE identified
- [ ] Potential DECOYs explicitly marked

**For Differential Samples:**

- [ ] All Code Acts mapped to fixed version (or marked REMOVED)
- [ ] Fixed version Security Functions assigned
- [ ] All transitions documented
- [ ] Transitions are logically consistent with fix description

**For Trojan Samples:**

- [ ] All injections documented
- [ ] Each injection has "looks suspicious because"
- [ ] Each injection has "actually safe because"
- [ ] Proximity to real vulnerability noted
- [ ] Distraction risk assessed

### 9.2 Inter-Annotator Reliability

**Process:**

1. Select 15-20 samples (10 Differential, 5-10 Trojan)
2. Second annotator annotates independently
3. Compare annotations
4. Calculate agreement metrics
5. Reconcile disagreements through discussion

**Agreement Metrics:**

| Metric                    | What It Measures                                  | Target |
| ------------------------- | ------------------------------------------------- | ------ |
| Code Act identification κ | Do annotators identify same Code Acts?            | ≥ 0.80 |
| Security Function κ       | Do annotators assign same Security Functions?     | ≥ 0.75 |
| ROOT_CAUSE agreement      | Do annotators agree on what causes vulnerability? | ≥ 0.85 |
| DECOY agreement           | Do annotators identify same DECOYs?               | ≥ 0.70 |

**Calculating Cohen's κ:**

```
κ = (observed agreement - chance agreement) / (1 - chance agreement)
```

**Interpretation:**

- κ ≥ 0.80: Almost perfect agreement
- κ ≥ 0.60: Substantial agreement
- κ ≥ 0.40: Moderate agreement
- κ < 0.40: Fair to poor agreement

### 9.3 Reconciliation Process

When annotators disagree:

1. **Identify disagreement type**

   - Missing Code Act
   - Different Security Function
   - Different rationale

2. **Discuss with reference to**

   - Audit report / ground truth
   - This annotation guide definitions
   - Code context

3. **Reach consensus and document**

   - Final decision
   - Reasoning for decision
   - Any guide clarifications needed

4. **Update guide if needed**
   - Add examples for edge cases
   - Clarify definitions

---

## 10. Dataset Release Format

### 10.1 Directory Structure

```
blockbench/
├── README.md
├── LICENSE
│
├── samples/
│   ├── difficulty_stratified/
│   │   └── [existing structure]
│   │
│   ├── temporal_contamination/
│   │   └── [existing structure]
│   │
│   ├── gold_standard/
│   │   └── [existing structure]
│   │
│   ├── differential/
│   │   ├── DIFF-001/
│   │   │   ├── vulnerable.sol          # MinimalSanitized version
│   │   │   ├── fixed.sol               # Patched version
│   │   │   ├── metadata.yaml           # Vulnerability info
│   │   │   └── code_acts.yaml          # Code Act annotations
│   │   ├── DIFF-002/
│   │   │   └── ...
│   │   └── ...
│   │
│   └── trojan/
│       ├── TROJ-001/
│       │   ├── trojaned.sol            # Code with injections
│       │   ├── metadata.yaml           # Base vulnerability info
│       │   └── decoys.yaml             # DECOY annotations
│       ├── TROJ-002/
│       │   └── ...
│       └── ...
│
├── annotations/
│   ├── code_act_guide.md               # This document
│   ├── schema/
│   │   ├── differential_schema.json    # JSON Schema for validation
│   │   └── trojan_schema.json          # JSON Schema for validation
│   └── statistics/
│       ├── annotation_stats.yaml       # Summary statistics
│       └── agreement_metrics.yaml      # Inter-annotator reliability
│
└── evaluation/
    └── [model evaluation results]
```

### 10.2 File Formats

#### 10.2.1 Differential code_acts.yaml

```yaml
# Schema version for future compatibility
schema_version: '1.0'

# Sample identification
sample_id: 'DIFF-001'
base_sample_id: 'TC-042' # Link to parent TC sample

# Vulnerability summary
vulnerability:
  type: 'Reentrancy'
  severity: 'High'
  cwe_id: 'CWE-841'
  affected_functions:
    - 'withdraw()'
  root_cause_summary: 'External call before state update'
  fix_summary: 'Reordered to checks-effects-interactions pattern'

# Code Act annotations
code_acts:
  - id: 'CA1'
    type: 'EXT_CALL'

    vulnerable:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 45
      column_start: 9
      column_end: 58
      code: '(bool success, ) = msg.sender.call{value: amount}("");'
      security_function: 'ROOT_CAUSE'
      rationale: 'External call before balance zeroed enables reentrancy'

    fixed:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 48
      column_start: 9
      column_end: 58
      code: '(bool success, ) = msg.sender.call{value: amount}("");'
      security_function: 'BENIGN'
      rationale: 'Now after state update, follows CEI pattern'

    transition: 'ROOT_CAUSE → BENIGN'
    is_decoy: false

  # ... more Code Acts

# Decoy inventory (subset of code_acts where is_decoy: true)
decoy_summary:
  count: 1
  ids: ['CA5']

# Annotation metadata
annotation:
  annotator_id: 'annotator_1'
  date: '2026-01-15'
  time_spent_minutes: 25
  review_status: 'verified'
  reviewer_id: 'annotator_2'
```

#### 10.2.2 Trojan decoys.yaml

```yaml
# Schema version
schema_version: '1.0'

# Sample identification
sample_id: 'TROJ-001'
base_sample_id: 'DS-042'

# Base vulnerability reference
base_vulnerability:
  type: 'Reentrancy'
  function: 'withdraw()'
  reference: '../difficulty_stratified/DS-042/metadata.yaml'

# Trojan strategy used
trojan_strategy: 'suspicious_external_calls'
injection_count: 3

# Injected DECOY elements
injections:
  - id: 'INJ1'
    type: 'EXT_CALL'
    security_function: 'DECOY'

    location:
      file: 'Vault.sol'
      function: 'withdraw()'
      line: 52
      column_start: 9
      column_end: 55
    code: 'feeCollector.notifyWithdrawal(msg.sender, amount);'

    suspicious_because:
      - 'External call in same function as reentrancy vulnerability'
      - 'Called during withdrawal operation'
      - 'Passes user address and amount as parameters'

    safe_because:
      - 'feeCollector is immutable address set in constructor'
      - 'notifyWithdrawal is a view function, no state changes'
      - 'Cannot trigger reentrancy even if called back'

    pattern_triggered: 'reentrancy'
    proximity: 'same_function'
    distraction_risk: 'high'

  # ... more injections

# Annotation metadata
annotation:
  annotator_id: 'annotator_1'
  date: '2026-01-15'
  time_spent_minutes: 12
  review_status: 'verified'
```

### 10.3 JSON Schema for Validation

Provide JSON Schema files so users can validate their own annotations or extensions:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "BlockBench Differential Code Act Annotation",
  "type": "object",
  "required": ["schema_version", "sample_id", "vulnerability", "code_acts"],
  "properties": {
    "schema_version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+$"
    },
    "sample_id": {
      "type": "string",
      "pattern": "^DIFF-\\d{3}$"
    },
    "code_acts": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "type", "vulnerable", "fixed", "transition"],
        "properties": {
          "type": {
            "enum": [
              "EXT_CALL",
              "STATE_MOD",
              "ACCESS_CTRL",
              "ARITHMETIC",
              "INPUT_VAL",
              "CTRL_FLOW",
              "FUND_XFER",
              "DELEGATE",
              "TIMESTAMP",
              "RANDOM",
              "ORACLE",
              "REENTRY_GUARD",
              "STORAGE_READ"
            ]
          },
          "vulnerable": {
            "type": "object",
            "required": [
              "file",
              "function",
              "line",
              "code",
              "security_function",
              "rationale"
            ],
            "properties": {
              "security_function": {
                "enum": [
                  "ROOT_CAUSE",
                  "PREREQ",
                  "INSUFF_GUARD",
                  "DECOY",
                  "BENIGN",
                  "UNRELATED"
                ]
              }
            }
          }
        }
      }
    }
  }
}
```

### 10.4 Statistics File

```yaml
# annotations/statistics/annotation_stats.yaml

dataset_statistics:
  differential:
    sample_count: 50
    total_code_acts: 287
    avg_code_acts_per_sample: 5.74

    security_function_distribution:
      ROOT_CAUSE: 78
      PREREQ: 45
      INSUFF_GUARD: 12
      DECOY: 34
      BENIGN: 98
      UNRELATED: 20

    transition_distribution:
      ROOT_CAUSE_to_BENIGN: 78
      ROOT_CAUSE_to_REMOVED: 0
      PREREQ_to_BENIGN: 45
      INSUFF_GUARD_to_BENIGN: 12
      DECOY_to_DECOY: 34
      BENIGN_to_BENIGN: 98

    code_act_type_distribution:
      EXT_CALL: 52
      STATE_MOD: 67
      ACCESS_CTRL: 43
      ARITHMETIC: 28
      INPUT_VAL: 35
      CTRL_FLOW: 22
      FUND_XFER: 18
      DELEGATE: 5
      TIMESTAMP: 8
      RANDOM: 2
      ORACLE: 4
      REENTRY_GUARD: 3

  trojan:
    sample_count: 50
    total_injections: 142
    avg_injections_per_sample: 2.84

    injection_type_distribution:
      EXT_CALL: 48
      ARITHMETIC: 32
      ACCESS_CTRL: 28
      INPUT_VAL: 18
      STATE_MOD: 16

    distraction_risk_distribution:
      high: 45
      medium: 62
      low: 35

    proximity_distribution:
      same_function: 38
      same_file: 64
      different_file: 40

agreement_metrics:
  sample_size: 20

  code_act_identification:
    cohens_kappa: 0.84
    percent_agreement: 91.2

  security_function_assignment:
    cohens_kappa: 0.79
    percent_agreement: 86.5

  root_cause_agreement:
    cohens_kappa: 0.88
    percent_agreement: 94.1

  decoy_identification:
    cohens_kappa: 0.76
    percent_agreement: 84.3
```

---

## 11. Examples

### 11.1 Complete Differential Example

**Scenario:** Reentrancy vulnerability in a lending protocol's withdraw function.

**Vulnerable Code (MinimalSanitized):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingPool {
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;

    IERC20 public token;
    IPriceOracle public oracle;

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        require(getHealthFactor(msg.sender) > 1e18, "Unhealthy position");

        // Transfer tokens to user
        token.transfer(msg.sender, amount);

        // Update deposit balance
        deposits[msg.sender] -= amount;

        emit Withdrawal(msg.sender, amount);
    }

    function updateOraclePrice() external {
        oracle.update();
    }

    function getHealthFactor(address user) public view returns (uint256) {
        // ... calculation
    }
}
```

**Fixed Code:**

```solidity
function withdraw(uint256 amount) external {
    require(deposits[msg.sender] >= amount, "Insufficient balance");
    require(getHealthFactor(msg.sender) > 1e18, "Unhealthy position");

    // Update deposit balance FIRST (CEI pattern)
    deposits[msg.sender] -= amount;

    // Transfer tokens to user
    token.transfer(msg.sender, amount);

    emit Withdrawal(msg.sender, amount);
}
```

**Annotation:**

```yaml
schema_version: '1.0'
sample_id: 'DIFF-015'
base_sample_id: 'TC-015'

vulnerability:
  type: 'Reentrancy'
  severity: 'High'
  cwe_id: 'CWE-841'
  affected_functions: ['withdraw()']
  root_cause_summary: 'ERC20 transfer before balance update allows callback-based reentrancy'
  fix_summary: 'Reordered to update balance before transfer'

code_acts:
  # Input validation - checks balance
  - id: 'CA1'
    type: 'INPUT_VAL'
    vulnerable:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 12
      code: 'require(deposits[msg.sender] >= amount, "Insufficient balance");'
      security_function: 'BENIGN'
      rationale: 'Correct validation of sufficient balance'
    fixed:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 12
      code: 'require(deposits[msg.sender] >= amount, "Insufficient balance");'
      security_function: 'BENIGN'
      rationale: 'Unchanged, still correct'
    transition: 'BENIGN → BENIGN'
    is_decoy: false

  # Health factor check
  - id: 'CA2'
    type: 'INPUT_VAL'
    vulnerable:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 13
      code: 'require(getHealthFactor(msg.sender) > 1e18, "Unhealthy position");'
      security_function: 'INSUFF_GUARD'
      rationale: 'Check happens before state change, can be bypassed via reentrancy'
    fixed:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 13
      code: 'require(getHealthFactor(msg.sender) > 1e18, "Unhealthy position");'
      security_function: 'BENIGN'
      rationale: 'Now checked before state is modified, effective'
    transition: 'INSUFF_GUARD → BENIGN'
    is_decoy: false

  # External call (ROOT CAUSE)
  - id: 'CA3'
    type: 'EXT_CALL'
    vulnerable:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 16
      code: 'token.transfer(msg.sender, amount);'
      security_function: 'ROOT_CAUSE'
      rationale: 'ERC20 transfer before balance update; token with callback enables reentrancy'
    fixed:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 19
      code: 'token.transfer(msg.sender, amount);'
      security_function: 'BENIGN'
      rationale: 'Now after balance update, CEI pattern followed'
    transition: 'ROOT_CAUSE → BENIGN'
    is_decoy: false

  # State modification (ROOT CAUSE)
  - id: 'CA4'
    type: 'STATE_MOD'
    vulnerable:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 19
      code: 'deposits[msg.sender] -= amount;'
      security_function: 'ROOT_CAUSE'
      rationale: 'Balance update after external call completes the reentrancy vulnerability'
    fixed:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 16
      code: 'deposits[msg.sender] -= amount;'
      security_function: 'BENIGN'
      rationale: 'Now happens before transfer, correct ordering'
    transition: 'ROOT_CAUSE → BENIGN'
    is_decoy: false

  # Oracle update - DECOY
  - id: 'CA5'
    type: 'EXT_CALL'
    vulnerable:
      file: 'LendingPool.sol'
      function: 'updateOraclePrice()'
      line: 24
      code: 'oracle.update();'
      security_function: 'DECOY'
      rationale: 'External call but in separate function, no funds at risk, no reentrancy vector'
    fixed:
      file: 'LendingPool.sol'
      function: 'updateOraclePrice()'
      line: 24
      code: 'oracle.update();'
      security_function: 'DECOY'
      rationale: 'Still looks suspicious but remains safe'
    transition: 'DECOY → DECOY'
    is_decoy: true
    decoy_explanation:
      looks_suspicious: 'External call pattern, potential reentrancy'
      actually_safe: 'Different function, no state dependencies, no funds handled'

decoy_summary:
  count: 1
  ids: ['CA5']

annotation:
  annotator_id: 'paul'
  date: '2026-01-15'
  time_spent_minutes: 22
  review_status: 'verified'
  reviewer_id: 'arvind'
```

### 11.2 Complete Trojan Example

**Scenario:** Base vulnerability is reentrancy, with injected suspicious-looking safe code.

**Trojan Code:**

```solidity
contract LendingPool {
    mapping(address => uint256) public deposits;

    IERC20 public token;
    IFeeCollector public immutable feeCollector;  // INJECTED
    IAnalytics public immutable analytics;         // INJECTED

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");

        // INJECTED: Notify fee collector (looks like external call risk)
        feeCollector.recordWithdrawal(msg.sender, amount);

        // Actual vulnerability: transfer before state update
        token.transfer(msg.sender, amount);
        deposits[msg.sender] -= amount;

        // INJECTED: Analytics tracking (looks suspicious)
        analytics.logEvent("withdrawal", abi.encode(msg.sender, amount));

        emit Withdrawal(msg.sender, amount);
    }

    function calculateFees(uint256 amount) internal pure returns (uint256) {
        // INJECTED: Unchecked arithmetic (looks like overflow risk)
        unchecked {
            return amount * 30 / 10000;  // 0.3% fee
        }
    }
}
```

**Annotation:**

```yaml
schema_version: '1.0'
sample_id: 'TROJ-015'
base_sample_id: 'DS-015'

base_vulnerability:
  type: 'Reentrancy'
  function: 'withdraw()'
  reference: '../difficulty_stratified/DS-015/metadata.yaml'

trojan_strategy: 'mixed_decoys'
injection_count: 3

injections:
  - id: 'INJ1'
    type: 'EXT_CALL'
    security_function: 'DECOY'

    location:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 12
    code: 'feeCollector.recordWithdrawal(msg.sender, amount);'

    suspicious_because:
      - 'External call in withdraw function'
      - 'Called before main transfer logic'
      - 'Passes user address and amount'
      - 'Located near actual reentrancy vulnerability'

    safe_because:
      - 'feeCollector is immutable (set in constructor)'
      - 'recordWithdrawal only updates internal fee accounting'
      - 'No callback mechanism, no funds transferred'
      - 'Even if it called back, deposits not yet modified'

    pattern_triggered: 'reentrancy'
    proximity: 'same_function'
    distraction_risk: 'high'

  - id: 'INJ2'
    type: 'EXT_CALL'
    security_function: 'DECOY'

    location:
      file: 'LendingPool.sol'
      function: 'withdraw()'
      line: 19
    code: 'analytics.logEvent("withdrawal", abi.encode(msg.sender, amount));'

    suspicious_because:
      - 'External call after state changes'
      - 'Could potentially be reentrancy vector'
      - 'Receives user data as parameter'

    safe_because:
      - 'analytics is immutable trusted contract'
      - 'logEvent is append-only logging, no callbacks'
      - 'Called after state is updated (would be safe pattern anyway)'
      - 'No funds or critical state can be affected'

    pattern_triggered: 'reentrancy'
    proximity: 'same_function'
    distraction_risk: 'medium'

  - id: 'INJ3'
    type: 'ARITHMETIC'
    security_function: 'DECOY'

    location:
      file: 'LendingPool.sol'
      function: 'calculateFees()'
      line: 25
    code: 'return amount * 30 / 10000;'

    suspicious_because:
      - 'Uses unchecked block, disables overflow protection'
      - 'Multiplication could theoretically overflow'
      - 'Part of financial calculation'

    safe_because:
      - 'amount is bounded by total token supply'
      - '30 / 10000 reduces the value, not increases'
      - 'Maximum possible result << uint256 max'
      - 'Pure function, no state impact even if somehow wrong'

    pattern_triggered: 'arithmetic_overflow'
    proximity: 'same_file'
    distraction_risk: 'low'

annotation:
  annotator_id: 'paul'
  date: '2026-01-15'
  time_spent_minutes: 15
  review_status: 'pending'
```

---

## Appendix A: Cheat Sheet

### A.1 Code Act Quick Reference

| If you see...                       | Code Act Type |
| ----------------------------------- | ------------- |
| `.call()`, `.transfer()`, `.send()` | EXT_CALL      |
| `contract.function()`               | EXT_CALL      |
| `variable = value` (storage)        | STATE_MOD     |
| `require(msg.sender == ...)`        | ACCESS_CTRL   |
| `onlyOwner`, `onlyRole`             | ACCESS_CTRL   |
| `+`, `-`, `*`, `/`                  | ARITHMETIC    |
| `unchecked { ... }`                 | ARITHMETIC    |
| `require(x > 0)`, `require(x != 0)` | INPUT_VAL     |
| `if`, `for`, `while`                | CTRL_FLOW     |
| `.transfer(amount)` with funds      | FUND_XFER     |
| `.delegatecall()`                   | DELEGATE      |
| `block.timestamp`                   | TIMESTAMP     |
| `blockhash`, `prevrandao`           | RANDOM        |
| `oracle.getPrice()`                 | ORACLE        |
| `nonReentrant`, `locked = true`     | REENTRY_GUARD |
| `uint x = mapping[key]` (storage)   | STORAGE_READ  |

### A.2 Security Function Quick Reference

| Question                                       | If Yes →     |
| ---------------------------------------------- | ------------ |
| Does fixing this eliminate the vulnerability?  | ROOT_CAUSE   |
| Is this needed for exploit but not the cause?  | PREREQ       |
| Was this meant to prevent attack but fails?    | INSUFF_GUARD |
| Does this look dangerous but is actually safe? | DECOY        |
| Is this security-relevant but correctly done?  | BENIGN       |
| Is this unrelated to the vulnerability?        | UNRELATED    |

### A.3 Common Transitions

| Fix Type                 | Typical Transition    |
| ------------------------ | --------------------- |
| Reordering (CEI pattern) | ROOT_CAUSE → BENIGN   |
| Adding access control    | ROOT_CAUSE → BENIGN   |
| Adding reentrancy guard  | ROOT_CAUSE → BENIGN   |
| Strengthening validation | INSUFF_GUARD → BENIGN |
| No change to safe code   | BENIGN → BENIGN       |
| No change to decoy       | DECOY → DECOY         |
| Removing vulnerable code | ROOT_CAUSE → REMOVED  |

---

## Appendix B: Glossary

| Term                  | Definition                                      |
| --------------------- | ----------------------------------------------- |
| **Code Act**          | Discrete, security-relevant code operation      |
| **Security Function** | Role a Code Act plays in a vulnerability        |
| **ROOT_CAUSE**        | Code Act that directly enables exploitation     |
| **DECOY**             | Safe code that looks suspicious                 |
| **Transition**        | Change in Security Function between versions    |
| **MinimalSanitized**  | Vulnerable code with revealing comments removed |
| **Differential**      | Pair of vulnerable and fixed versions           |
| **Trojan**            | Vulnerable code with injected DECOY elements    |
| **CEI Pattern**       | Checks-Effects-Interactions (secure ordering)   |

---

_End of Document_
