# Manual Adversarial Strategies: Team Preparation Guide

## Decoy & Differential - Consolidated Manual Transformations

**Version:** 2.0 (Consolidated)  
**Purpose:** Guide for team members preparing manual adversarial transformations  
**Audience:** Annotators working on Decoy and Differential strategies

---

## Table of Contents

1. [Introduction & Context](#1-introduction--context)
2. [Strategy Overview](#2-strategy-overview)
3. [Strategy 5: Decoy (Detailed)](#3-strategy-5-decoy-detailed)
4. [Strategy 6: Differential (Detailed)](#4-strategy-6-differential-detailed)
5. [Workflow & Process](#5-workflow--process)
6. [Quality Standards](#6-quality-standards)
7. [Output Templates](#7-output-templates)
8. [Examples Gallery](#8-examples-gallery)

---

## 1. Introduction & Context

### 1.1 What We're Building

We're creating a benchmark to test whether AI models truly understand smart contract security vulnerabilities or merely pattern-match on surface features. Your manual work is critical because some adversarial transformations require human judgment and creativity that cannot be automated.

### 1.2 Why Manual Strategies Matter

| Automated Strategies                                          | Manual Strategies                     |
| ------------------------------------------------------------- | ------------------------------------- |
| Test mechanical pattern recognition                           | Test deeper reasoning                 |
| Can produce thousands of samples                              | Produce high-quality targeted samples |
| Consistent but predictable                                    | Creative and unpredictable            |
| 4 strategies (Chameleon, Shapeshifter, Restructure, Guardian) | 2 strategies (Decoy, Differential)    |

### 1.3 Strategy Consolidation

We consolidated 10+ strategies into 6. For manual work, this means:

| New Strategy     | Combines                                   | Why Combined                  |
| ---------------- | ------------------------------------------ | ----------------------------- |
| **Decoy**        | False Prophet + Trojan Horse               | Both add misleading elements  |
| **Differential** | Counterfactual Probe + Reconstruction Test | Both create comparative pairs |

This document explains **both the original components AND how they work together**.

---

## 2. Strategy Overview

### 2.1 The Two Manual Strategies

| Strategy         | What You Create                                           | Vulnerability Changes?                   | Difficulty  |
| ---------------- | --------------------------------------------------------- | ---------------------------------------- | ----------- |
| **Decoy**        | Misleading comments OR misleading code added to contracts | No (preserved)                           | Medium      |
| **Differential** | Pairs of contracts with minimal differences               | Creates pairs (one vulnerable, one safe) | Medium-Hard |

### 2.2 Time Investment

| Strategy     | Component         | Time per Contract |
| ------------ | ----------------- | ----------------- |
| Decoy        | Comments variant  | 20-35 minutes     |
| Decoy        | Code variant      | 25-40 minutes     |
| Differential | Minimal variant   | 15-25 minutes     |
| Differential | Introduce variant | 30-45 minutes     |

### 2.3 Your Assignment Structure

You will be assigned:

1. A list of `.sol` files to transform
2. Which strategy to apply
3. Which variant(s) to use

**Important:** Complete ALL assigned contracts for ONE strategy before moving to another.

---

## 3. Strategy 5: Decoy (Detailed)

### 3.1 What is Decoy?

Decoy adds **misleading elements** to contracts that might distract or confuse AI models. The vulnerability status stays the same—you're testing whether models can focus on what matters.

### 3.2 The Two Original Components

Decoy combines two previously separate strategies:

| Component    | Original Name | What It Does                 |
| ------------ | ------------- | ---------------------------- |
| **Comments** | False Prophet | Add misleading documentation |
| **Code**     | Trojan Horse  | Add misleading code elements |

### 3.3 Component A: Comments (False Prophet)

#### What It Is

Add professional-looking comments that **lie** about the security status of the code.

#### Two Directions

| Direction        | Input           | Output                            | Comments Say         |
| ---------------- | --------------- | --------------------------------- | -------------------- |
| **False Safety** | Vulnerable code | Vulnerable code + "safe" comments | "This is secure"     |
| **False Danger** | Safe code       | Safe code + "danger" comments     | "This is vulnerable" |

#### False Safety: Detailed Instructions

**Goal:** Make vulnerable code look safe through documentation.

**Step 1: Understand the Vulnerability**

Before writing comments, you must understand:

- What type of vulnerability exists
- Where exactly it is (function, line)
- Why it's exploitable

**Step 2: Choose Comment Locations**

Add comments at multiple levels for maximum effect:

```
Level 1: Contract-level (NatSpec header)
   ↓
Level 2: Function-level (function documentation)
   ↓
Level 3: Inline (specific line comments)
```

**Step 3: Write Convincing False Claims**

Your comments should:

- Sound professional and authoritative
- Reference real security concepts
- Provide (flawed) technical justifications
- Mention audits, reviews, or best practices

**Step 4: Apply the Comments**

**Contract-Level Template:**

```solidity
/**
 * @title [ContractName]
 * @author [Team/Company Name]
 * @notice [Business description]
 * @dev Security Features:
 *      - [Claim 1 about security]
 *      - [Claim 2 about security]
 *      - [Claim 3 about security]
 *
 *      Audit Status: [Fake audit claim]
 *      Last Review: [Date]
 */
contract [ContractName] {
```

**Function-Level Template:**

```solidity
/**
 * @notice [What function does]
 * @dev Security Analysis:
 *      [Detailed false explanation of why this is secure]
 *
 *      Vulnerability Assessment: NONE
 *      - [Reentrancy]: Protected by [false claim]
 *      - [Access Control]: Enforced by [false claim]
 *
 * @param [param] [Description]
 */
function vulnerableFunction(...) {
```

**Inline Template:**

```solidity
function withdraw(uint256 amount) external {
    // SECURITY: Validate caller has sufficient balance
    require(balances[msg.sender] >= amount);

    // SAFE: External call with proper error handling
    // Note: Reentrancy not possible due to balance check above
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");

    // STATE UPDATE: Applied after successful transfer
    // Following established secure patterns
    balances[msg.sender] -= amount;
}
```

#### False Danger: Detailed Instructions

**Goal:** Make safe code look vulnerable through documentation.

**Step 1: Understand the Protections**

Identify what makes the code actually safe:

- ReentrancyGuard?
- CEI pattern?
- Access controls?
- Safe math?

**Step 2: Write Scary But False Comments**

Your comments should:

- Warn about vulnerabilities that don't exist
- Question protections that actually work
- Suggest the code needs fixes it doesn't need

**Template for False Danger:**

```solidity
/**
 * @title Vault
 * @notice WARNING: This contract has known security issues
 * @dev SECURITY ADVISORY:
 *      - Potential reentrancy in withdraw() [FALSE - has nonReentrant]
 *      - Access control may be bypassable [FALSE - properly implemented]
 *      - State consistency not guaranteed [FALSE - CEI followed]
 *
 *      Status: PENDING SECURITY REVIEW
 *      Risk Level: HIGH
 */
contract Vault is ReentrancyGuard {

    /**
     * @notice Withdraw funds - USE WITH CAUTION
     * @dev VULNERABILITY NOTES:
     *      The nonReentrant modifier may not provide complete protection
     *      in cross-function scenarios. Consider additional safeguards.
     *
     *      TODO: Implement proper CEI pattern
     *      TODO: Add additional access controls
     */
    function withdraw(uint256 amount) external nonReentrant {
        // WARNING: Balance check alone insufficient
        require(balances[msg.sender] >= amount);

        // DANGER: State update timing may allow attacks
        balances[msg.sender] -= amount;

        // RISK: External call to untrusted address
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }
}
```

Note: This code IS actually safe! The nonReentrant + CEI pattern protects it.

#### Comment Quality Rubric

| Aspect                 | Poor (1)               | Acceptable (3)          | Excellent (5)               |
| ---------------------- | ---------------------- | ----------------------- | --------------------------- |
| **Professionalism**    | Casual, unprofessional | Formal tone             | Enterprise documentation    |
| **Technical Accuracy** | Obviously wrong        | Plausible misstatements | Sophisticated misdirection  |
| **Specificity**        | Vague claims           | References patterns     | Detailed technical analysis |
| **Coverage**           | Single comment         | 2 levels                | All 3 levels                |
| **Believability**      | Easily spotted         | Might fool beginners    | Could fool intermediates    |

---

### 3.4 Component B: Code (Trojan Horse)

#### What It Is

Add **irrelevant code elements** that might distract models from the real vulnerability.

#### Distractor Types

| Type                     | Description                                   | Example                                   |
| ------------------------ | --------------------------------------------- | ----------------------------------------- |
| **Fake Vulnerabilities** | Code that looks vulnerable but isn't          | `staticcall` that looks like `call`       |
| **Complex Safe Code**    | Scary-looking code that's actually fine       | Assembly that just returns a value        |
| **Irrelevant Security**  | Security features unrelated to the real issue | Access control when the bug is reentrancy |
| **Suspicious Names**     | Variable names that suggest problems          | `_unsafeValue`, `_dangerousTarget`        |
| **Decoy Functions**      | Functions that look problematic but aren't    | `unsafeTransfer()` that's actually safe   |

#### Detailed Instructions

**Step 1: Identify the Real Vulnerability**

Before adding distractors, know exactly what the actual vulnerability is.

**Step 2: Choose 3-5 Distractors**

Select distractors that:

- Are plausible (could exist in real code)
- Don't introduce NEW real vulnerabilities
- Are spread throughout the contract
- Have varying "scariness" levels

**Step 3: Implement Distractors**

**Type 1: Fake Vulnerability Pattern**

```solidity
// DISTRACTOR: Looks like unchecked external call
// Actually safe because it's a staticcall (read-only)
function getExternalPrice() internal view returns (uint256) {
    (bool success, bytes memory data) = oracle.staticcall(
        abi.encodeWithSignature("getPrice()")
    );
    // Looks like unchecked return, but staticcall can't modify state
    return abi.decode(data, (uint256));
}
```

**Type 2: Complex Safe Code**

```solidity
// DISTRACTOR: Scary assembly that's actually just math
function _calculateFee(uint256 amount) internal pure returns (uint256) {
    uint256 result;
    assembly {
        // Looks dangerous but just calculates 0.3%
        result := div(mul(amount, 3), 1000)

        // This scary-looking block just does bounds checking
        if gt(result, amount) {
            result := amount
        }
    }
    return result;
}
```

**Type 3: Irrelevant Security Mechanisms**

```solidity
contract Vault {
    // DISTRACTORS: Security features that don't address the real bug
    address public owner;
    bool public paused;
    uint256 public constant MAX_WITHDRAWAL = 100 ether;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }

    modifier validAmount(uint256 amount) {
        require(amount > 0 && amount <= MAX_WITHDRAWAL, "Invalid amount");
        _;
    }

    // REAL VULNERABILITY: Reentrancy (none of the above modifiers help!)
    function withdraw(uint256 amount) external whenNotPaused validAmount(amount) {
        require(balances[msg.sender] >= amount);

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);

        balances[msg.sender] -= amount;  // Still vulnerable!
    }
}
```

**Type 4: Suspicious Variable Names**

```solidity
contract Vault {
    mapping(address => uint256) public balances;

    // DISTRACTORS: Scary names for innocent variables
    uint256 private _unsafeCounter;      // Just counts operations
    address private _attackerAddress;    // Just stores last depositor
    bool private _vulnerableFlag;        // Just a status flag
    bytes private _dangerousData;        // Just cached data

    function deposit() external payable {
        _unsafeCounter++;                    // Innocent increment
        _attackerAddress = msg.sender;       // Innocent assignment
        _vulnerableFlag = true;              // Innocent flag
        balances[msg.sender] += msg.value;   // Normal operation
    }

    // REAL VULNERABILITY IS HERE
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;
    }
}
```

**Type 5: Decoy Functions**

```solidity
contract Vault {
    // DISTRACTOR: Looks vulnerable but actually follows CEI
    function unsafeEmergencyWithdraw() external {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;  // State update FIRST (safe!)

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }

    // DISTRACTOR: Scary name but it's just a view function
    function dangerousBalanceCheck(address user) external view returns (uint256) {
        return balances[user];
    }

    // REAL VULNERABILITY
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount);
        (bool success, ) = msg.sender.call{value: amount}("");  // Call before state update
        require(success);
        balances[msg.sender] -= amount;
    }
}
```

#### Code Distractor Quality Rubric

| Aspect           | Poor (1)            | Acceptable (3)  | Excellent (5)                    |
| ---------------- | ------------------- | --------------- | -------------------------------- |
| **Plausibility** | Obviously fake      | Could be real   | Indistinguishable from real code |
| **Quantity**     | 1 distractor        | 3-4 distractors | 5-7 well-placed                  |
| **Variety**      | All same type       | 2-3 types       | Multiple types                   |
| **Placement**    | Clustered together  | Somewhat spread | Strategically distributed        |
| **Safety**       | Introduces new bugs | Mostly safe     | No new vulnerabilities           |

---

### 3.5 Combined Decoy Strategy

#### How Components Work Together

You can use **Comments only**, **Code only**, or **Both together**:

| Approach      | When to Use            | Complexity |
| ------------- | ---------------------- | ---------- |
| Comments only | Quick distraction      | Low        |
| Code only     | Structural distraction | Medium     |
| Both          | Maximum confusion      | High       |

#### Combined Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SecureVault
 * @author Security Team
 * @notice Production-ready vault with comprehensive protections
 * @dev Security Audit: PASSED (ChainSecurity, Oct 2024)
 *
 *      Implemented Protections:
 *      - Reentrancy: CEI pattern + mutex locks
 *      - Access Control: Role-based with timelock
 *      - Integer Safety: Solidity 0.8+ built-in
 *
 *      Formal Verification: Complete
 */
contract SecureVault {
    mapping(address => uint256) public balances;
    mapping(address => uint256) private _lastAction;  // "Rate limiting"

    // DISTRACTOR: Scary state variables
    uint256 private _criticalValue;
    address private _emergencyTarget;
    bool private _dangerMode;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event DangerModeActivated(address indexed trigger);  // DISTRACTOR: Scary event

    /**
     * @notice Deposit ETH securely
     * @dev Fully protected operation with state validation
     */
    function deposit() external payable {
        _criticalValue = msg.value;  // DISTRACTOR
        _lastAction[msg.sender] = block.timestamp;

        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // DISTRACTOR: Complex but safe function
    function _validateOperation(address user) internal view returns (bool) {
        assembly {
            // Looks scary but just checks if user has balance
            let bal := sload(add(balances.slot, user))
            if iszero(bal) {
                mstore(0x00, 0)
                return(0x00, 0x20)
            }
        }
        return true;
    }

    /**
     * @notice Withdraw ETH from vault
     * @dev Secure withdrawal with multiple protections:
     *      - Balance validation prevents underflow
     *      - Success check ensures transfer completion
     *      - Event emission for transparency
     *
     *      Reentrancy Status: PROTECTED
     *      The validation flow ensures atomic execution.
     */
    function withdraw(uint256 amount) external {
        // COMMENT LIE: Claims this is protected
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Run distractor validation
        require(_validateOperation(msg.sender), "Validation failed");

        // REAL VULNERABILITY: External call before state update!
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // State update AFTER call = REENTRANCY BUG
        balances[msg.sender] -= amount;

        emit Withdrawal(msg.sender, amount);
    }

    // DISTRACTOR: Looks dangerous but actually safe
    function unsafeEmergencyAction() external {
        _dangerMode = true;
        _emergencyTarget = msg.sender;
        emit DangerModeActivated(msg.sender);
        // Actually does nothing harmful
    }

    // DISTRACTOR: Scary name, safe implementation
    function dangerousWithdrawAll() external {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;  // State update FIRST (safe!)

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }
}
```

**Analysis:**

- FALSE SAFETY comments claim the contract is audited and protected
- CODE distractors include scary names, complex assembly, irrelevant functions
- REAL vulnerability is in `withdraw()` - external call before state update
- `dangerousWithdrawAll()` is actually SAFER than `withdraw()`!

---

### 3.6 Decoy Variant Summary

| Variant                         | Components Used | Input      | Output                              | Vulnerability |
| ------------------------------- | --------------- | ---------- | ----------------------------------- | ------------- |
| **decoy_comments_false_safety** | Comments only   | Vulnerable | Vulnerable + "safe" comments        | Preserved     |
| **decoy_comments_false_danger** | Comments only   | Safe       | Safe + "danger" comments            | Preserved     |
| **decoy_code**                  | Code only       | Vulnerable | Vulnerable + distractors            | Preserved     |
| **decoy_combined**              | Both            | Vulnerable | Vulnerable + comments + distractors | Preserved     |

---

## 4. Strategy 6: Differential (Detailed)

### 4.1 What is Differential?

Differential creates **pairs of contracts** for comparative analysis. Each pair has one vulnerable and one safe version, differing by minimal or controlled changes.

### 4.2 The Two Original Components

| Component     | Original Name        | What It Does                                   |
| ------------- | -------------------- | ---------------------------------------------- |
| **Minimal**   | Counterfactual Probe | Create pairs with smallest possible difference |
| **Introduce** | Reconstruction Test  | Take safe code, introduce vulnerability        |

### 4.3 Component A: Minimal (Counterfactual Probe)

#### What It Is

Create two versions of a contract that differ by the **smallest possible change** that affects security status.

#### The Key Insight

```
Version A (Vulnerable):  Missing one line / wrong order / missing check
                         ↕ (minimal diff)
Version B (Safe):        Has the line / correct order / has check
```

#### Types of Minimal Changes

**Type 1: Line Position (Most Common)**

```solidity
// VULNERABLE: External call before state update
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount;  // <-- Line position is the only diff
}

// SAFE: State update before external call
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount;  // <-- Same line, different position
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
}
```

**Type 2: Single Line Addition**

```solidity
// VULNERABLE: No reentrancy protection
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount;
}

// SAFE: Has reentrancy check (one line added)
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    require(!locked, "No reentrancy");  // <-- Only this line added
    locked = true;                       // <-- And this
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount;
    locked = false;                      // <-- And this
}
```

**Type 3: Single Modifier Addition**

```solidity
// VULNERABLE: No modifier
function withdraw(uint256 amount) external {
    // ... vulnerable code
}

// SAFE: Has nonReentrant modifier
function withdraw(uint256 amount) external nonReentrant {  // <-- Only diff
    // ... same code
}
```

**Type 4: Operator Change**

```solidity
// VULNERABLE: Wrong comparison
function withdraw(uint256 amount) external {
    require(balances[msg.sender] > amount);  // > means can't withdraw exact balance
    // ...
}

// SAFE: Correct comparison
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);  // >= is correct
    // ...
}
```

**Type 5: Function Type Change**

```solidity
// VULNERABLE: Uses call() with unlimited gas
(bool success, ) = msg.sender.call{value: amount}("");

// SAFE: Uses transfer() with limited gas
payable(msg.sender).transfer(amount);
```

#### Detailed Instructions

**Step 1: Identify the Critical Element**

For the vulnerability in your assigned contract, identify:

- What EXACTLY makes it vulnerable?
- What's the SMALLEST change to fix it?

**Step 2: Create Version A (Vulnerable)**

Keep or create the vulnerable version. This is usually your starting point.

**Step 3: Create Version B (Safe)**

Apply ONLY the minimal fix. Do not:

- Add extra protections
- Refactor other code
- Change anything unrelated

**Step 4: Document the Exact Difference**

Record precisely:

```
DIFFERENTIAL PAIR DOCUMENTATION
================================
Pair ID: [unique identifier]

Version A: vulnerable_001.sol
Version B: safe_001.sol

Difference Type: [line_position / line_addition / modifier / operator / function_type]

Exact Change:
- File: [filename]
- Function: [function name]
- Line(s): [line number(s)]
- Before: [exact text]
- After: [exact text]

Why This Fixes It:
[1-2 sentence explanation]
```

**Step 5: Verify Both Versions**

- [ ] Both compile
- [ ] Version A IS vulnerable (verify you understand the attack)
- [ ] Version B IS safe (verify the fix works)
- [ ] NO other differences exist

#### Minimal Diff Quality Rubric

| Aspect            | Poor (1)                       | Acceptable (3)         | Excellent (5)                |
| ----------------- | ------------------------------ | ---------------------- | ---------------------------- |
| **Minimality**    | Many changes                   | 2-5 lines differ       | 1 line or smallest possible  |
| **Clarity**       | Hard to spot diff              | Diff is findable       | Diff is precisely documented |
| **Isolation**     | Change affects multiple things | Change mostly isolated | Change ONLY affects security |
| **Correctness**   | One version broken             | Both compile           | Both behave correctly        |
| **Documentation** | Missing info                   | Basic description      | Complete with rationale      |

---

### 4.4 Component B: Introduce (Reconstruction Test)

#### What It Is

Take **secure code** and introduce vulnerabilities in a realistic way—the kind of mistake a developer might actually make.

#### The Key Insight

This is the REVERSE of normal security work:

```
Normal: Find vulnerability → Fix it
Introduce: Start with fix → Remove it realistically
```

#### Types of Introductions

**Type 1: Remove Protection Mechanism**

```solidity
// SAFE (Original)
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    function withdraw(uint256 amount) external nonReentrant {
        // ...
    }
}

// VULNERABLE (After Introduction)
// Removed: import statement
// Removed: inheritance
// Removed: modifier

contract Vault {
    function withdraw(uint256 amount) external {
        // Same implementation, no protection
    }
}
```

**Realistic Scenario:** Developer removes ReentrancyGuard during refactoring thinking "I'll add it back later" and forgets.

**Type 2: Reorder Operations**

```solidity
// SAFE (Original) - CEI Pattern
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount;  // Effect first
    (bool success, ) = msg.sender.call{value: amount}("");  // Interaction second
    require(success);
}

// VULNERABLE (After Introduction) - Broken CEI
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");  // Interaction first
    require(success);
    balances[msg.sender] -= amount;  // Effect second - VULNERABLE!
}
```

**Realistic Scenario:** Developer reorders for "readability" or "gas optimization" without understanding security implications.

**Type 3: Remove Validation**

```solidity
// SAFE (Original)
function setWithdrawalLimit(uint256 newLimit) external {
    require(msg.sender == owner, "Not owner");
    require(newLimit >= MIN_LIMIT, "Below minimum");
    require(newLimit <= MAX_LIMIT, "Above maximum");
    withdrawalLimit = newLimit;
}

// VULNERABLE (After Introduction)
function setWithdrawalLimit(uint256 newLimit) external {
    // Removed: owner check
    // Removed: bounds checks
    withdrawalLimit = newLimit;
}
```

**Realistic Scenario:** Developer removes checks during testing and forgets to restore them.

**Type 4: Change Function Type**

```solidity
// SAFE (Original) - Limited gas
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);  // 2300 gas limit
}

// VULNERABLE (After Introduction) - Unlimited gas + wrong order
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");  // Unlimited gas
    require(success);
    balances[msg.sender] -= amount;  // And reordered to be after call
}
```

**Realistic Scenario:** Developer changes from `transfer()` to `call()` because they heard "transfer is deprecated" and reorders "for clarity."

**Type 5: Downgrade Solidity Version**

```solidity
// SAFE (Original) - 0.8+ with overflow protection
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

function transfer(uint256 amount) external {
    balances[msg.sender] -= amount;  // Safe: reverts on underflow
    balances[recipient] += amount;   // Safe: reverts on overflow
}

// VULNERABLE (After Introduction) - Pre-0.8 without protection
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

function transfer(uint256 amount) external {
    balances[msg.sender] -= amount;  // VULNERABLE: underflow wraps
    balances[recipient] += amount;   // VULNERABLE: overflow wraps
}
```

**Realistic Scenario:** Project needs to use older Solidity version for compatibility and developer forgets to add SafeMath.

#### Detailed Instructions

**Step 1: Understand the Original Protection**

Before introducing vulnerabilities, document:

- What protections exist?
- What patterns are followed?
- What vulnerabilities are prevented?

**Step 2: Choose Introduction Method**

Select an introduction that:

- Creates a real, exploitable vulnerability
- Represents a realistic developer mistake
- Can be clearly documented

**Step 3: Implement the Introduction**

Make the changes while:

- Keeping code otherwise functional
- Maintaining compilation
- Making it look like plausible "before security review" code

**Step 4: Document the Introduction**

```
INTRODUCTION DOCUMENTATION
===========================
Original: secure_vault.sol
Introduced: vulnerable_vault.sol

Original Protections:
1. [Protection 1]
2. [Protection 2]
3. [Protection 3]

Protections Removed:
1. [What was removed and why it matters]

Vulnerability Introduced:
- Type: [reentrancy / overflow / access_control / etc.]
- Location: [function name, line numbers]
- Exploitability: [How an attacker would exploit it]

Realistic Mistake Explanation:
[1-3 sentences explaining how a developer might make this mistake]

Attack Scenario:
1. [Step 1 of attack]
2. [Step 2 of attack]
3. [Expected outcome]
```

**Step 5: Verify**

- [ ] Original version IS safe
- [ ] Introduced version IS vulnerable
- [ ] Vulnerability is realistic and exploitable
- [ ] Both compile
- [ ] Documentation is complete

#### Introduction Quality Rubric

| Aspect             | Poor (1)            | Acceptable (3)            | Excellent (5)            |
| ------------------ | ------------------- | ------------------------- | ------------------------ |
| **Realism**        | Unrealistic mistake | Plausible                 | Common developer error   |
| **Impact**         | Minor issue         | Significant vulnerability | Critical vulnerability   |
| **Subtlety**       | Obvious sabotage    | Noticeable                | Could be "before review" |
| **Documentation**  | Minimal             | Changes listed            | Full attack scenario     |
| **Attack Clarity** | Vague               | Described                 | Step-by-step exploit     |

---

### 4.5 Combined Differential Strategy

#### How Components Work Together

| Approach  | Description                               | Output                      |
| --------- | ----------------------------------------- | --------------------------- |
| Minimal   | Start with vulnerable, create minimal fix | Pair with smallest diff     |
| Introduce | Start with safe, introduce vulnerability  | Pair with realistic mistake |
| Both      | Create both directions                    | Two pairs per contract      |

#### When to Use Which

| Use Minimal When                 | Use Introduce When              |
| -------------------------------- | ------------------------------- |
| You have vulnerable code already | You have secure code already    |
| Testing precise understanding    | Testing recognition of mistakes |
| Want smallest possible diff      | Want realistic mistake patterns |
| Original vulnerability is clear  | Want to document common errors  |

#### Complete Differential Pair Example

**Original Safe Contract:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title SecureVault
 * @notice A properly secured vault implementation
 */
contract SecureVault is ReentrancyGuard {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // CEI Pattern: Effects before Interactions
        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
```

**Minimal Variant - Vulnerable (Just remove modifier):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecureVault is ReentrancyGuard {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {  // <-- ONLY CHANGE: removed nonReentrant
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
```

**Diff:** Single word removed (`nonReentrant`)

**Introduce Variant - Vulnerable (Multiple realistic changes):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// REMOVED: import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Vault
 * @notice Basic vault implementation
 */
contract Vault {  // REMOVED: is ReentrancyGuard
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {  // REMOVED: nonReentrant
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // REORDERED: Interaction before Effects (broken CEI)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        emit Withdrawal(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
```

**Changes:**

1. Removed ReentrancyGuard import
2. Removed inheritance
3. Removed nonReentrant modifier
4. Reordered statements (broken CEI)

**Realistic Explanation:** Developer started with a "clean" implementation and planned to "add security later" but shipped without it.

---

### 4.6 Differential Variant Summary

| Variant                    | Starting Point  | Action                            | Output                 |
| -------------------------- | --------------- | --------------------------------- | ---------------------- |
| **differential_minimal**   | Vulnerable code | Create smallest fix               | Vulnerable + Safe pair |
| **differential_introduce** | Safe code       | Introduce realistic vulnerability | Safe + Vulnerable pair |

---

## 5. Workflow & Process

### 5.1 Before You Start

1. **Set up your environment**

   - Solidity-aware editor (VS Code + Solidity extension)
   - `solc` compiler installed
   - Templates downloaded

2. **Read your assignment**

   - Which strategy?
   - Which variant(s)?
   - Which contracts?

3. **Understand the contracts**
   - Read each one completely
   - Identify vulnerabilities/protections
   - Take notes

### 5.2 For Each Contract

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR WORKFLOW                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. READ                                                    │
│     └── Understand the contract completely                  │
│     └── Identify vulnerability type and location            │
│     └── Note any existing protections                       │
│                                                             │
│  2. PLAN                                                    │
│     └── Choose specific variant approach                    │
│     └── Sketch out your changes                             │
│     └── Consider edge cases                                 │
│                                                             │
│  3. IMPLEMENT                                               │
│     └── Make your transformations                           │
│     └── Keep original for reference                         │
│     └── Save with correct naming                            │
│                                                             │
│  4. VERIFY                                                  │
│     └── Compile with solc                                   │
│     └── Check vulnerability status is correct               │
│     └── Review against quality rubric                       │
│                                                             │
│  5. DOCUMENT                                                │
│     └── Fill out metadata template                          │
│     └── Include all required fields                         │
│     └── Add notes for unusual cases                         │
│                                                             │
│  6. NEXT                                                    │
│     └── Move to next contract                               │
│     └── DON'T switch strategies mid-batch                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 Quality Gates

Before submitting any contract:

**Gate 1: Compilation**

```bash
solc --bin your_contract.sol
```

Must compile with no errors.

**Gate 2: Correctness**

- Decoy: Vulnerability status unchanged
- Differential: Both versions have correct status

**Gate 3: Documentation**

- All template fields filled
- No placeholder text remaining

**Gate 4: Self-Review**

- Rate yourself on the quality rubric
- Minimum acceptable score: 3 on all aspects

---

## 6. Quality Standards

### 6.1 Universal Requirements

| Requirement       | Description                                      |
| ----------------- | ------------------------------------------------ |
| **Compilation**   | ALL output files must compile                    |
| **Correctness**   | Vulnerability status must be accurate            |
| **Documentation** | ALL metadata fields must be filled               |
| **Originality**   | No copy-paste from examples without modification |

### 6.2 Strategy-Specific Requirements

**Decoy Requirements:**

- Comments must sound professional
- Distractors must not introduce new vulnerabilities
- Real vulnerability must still be detectable by careful analysis

**Differential Requirements:**

- Pairs must be clearly linked
- Differences must be precisely documented
- Both versions must be independently valid

### 6.3 Common Rejection Reasons

| Issue                      | How to Avoid                                 |
| -------------------------- | -------------------------------------------- |
| Doesn't compile            | Always test with `solc` before submitting    |
| Wrong vulnerability status | Double-check your understanding              |
| Incomplete documentation   | Use checklist before submitting              |
| Introduced new bugs        | Review distractors carefully                 |
| Minimal diff isn't minimal | Remove all unnecessary changes               |
| Unrealistic introduction   | Think "what mistake would a developer make?" |

---

## 7. Output Templates

### 7.1 Decoy Metadata Template

```json
{
  "transformation_info": {
    "strategy": "decoy",
    "variant": "[comments_false_safety | comments_false_danger | code | combined]",
    "annotator": "[Your Name]",
    "date": "[YYYY-MM-DD]",
    "time_spent_minutes": 0
  },

  "source": {
    "original_id": "[ID from assignment]",
    "original_file": "[original_filename.sol]",
    "original_vulnerable": true,
    "vulnerability_type": "[reentrancy | overflow | access_control | ...]",
    "vulnerability_location": {
      "function": "[function_name]",
      "lines": "[line numbers]"
    }
  },

  "output": {
    "transformed_id": "[new_id]",
    "transformed_file": "[new_filename.sol]",
    "transformed_vulnerable": true,
    "vulnerability_preserved": true
  },

  "decoy_details": {
    "components_used": ["comments", "code"],

    "comments_added": {
      "direction": "[false_safety | false_danger | null]",
      "levels": ["contract", "function", "inline"],
      "false_claims": ["[Claim 1]", "[Claim 2]", "[Claim 3]"]
    },

    "distractors_added": [
      {
        "type": "[fake_vulnerability | complex_safe | irrelevant_security | suspicious_names | decoy_function]",
        "location": "[where in code]",
        "description": "[what it is]"
      }
    ]
  },

  "quality_self_assessment": {
    "professionalism": "[1-5]",
    "believability": "[1-5]",
    "coverage": "[1-5]",
    "safety": "[1-5]"
  },

  "notes": "[Any additional notes]"
}
```

### 7.2 Differential Metadata Template

```json
{
  "transformation_info": {
    "strategy": "differential",
    "variant": "[minimal | introduce]",
    "annotator": "[Your Name]",
    "date": "[YYYY-MM-DD]",
    "time_spent_minutes": 0
  },

  "pair_info": {
    "pair_id": "[unique pair ID]",
    "vulnerable_version": {
      "id": "[ID]",
      "file": "[filename.sol]",
      "is_vulnerable": true,
      "vulnerability_type": "[type]",
      "vulnerability_location": {
        "function": "[function_name]",
        "lines": "[line numbers]"
      }
    },
    "safe_version": {
      "id": "[ID]",
      "file": "[filename.sol]",
      "is_vulnerable": false,
      "protection_mechanism": "[what makes it safe]"
    }
  },

  "differential_details": {
    "difference_type": "[line_position | line_addition | modifier | operator | function_type | protection_removal]",

    "exact_changes": [
      {
        "location": "[function/line]",
        "vulnerable_version": "[exact text]",
        "safe_version": "[exact text]"
      }
    ],

    "why_this_matters": "[explanation of security impact]",

    "for_introduce_variant": {
      "original_protections": ["[Protection 1]", "[Protection 2]"],
      "protections_removed": ["[What was removed]"],
      "realistic_mistake_explanation": "[How a developer might make this error]",
      "attack_scenario": ["[Step 1]", "[Step 2]", "[Expected outcome]"]
    }
  },

  "quality_self_assessment": {
    "minimality": "[1-5]",
    "correctness": "[1-5]",
    "documentation": "[1-5]",
    "realism": "[1-5]"
  },

  "notes": "[Any additional notes]"
}
```

---

## 8. Examples Gallery

### 8.1 Decoy Examples

#### Example D1: Comments False Safety (Reentrancy)

**Vulnerability:** Reentrancy in withdraw()

**Added Comments:**

```solidity
/**
 * @title SecureVault
 * @dev Audit: PASSED - Trail of Bits (Sep 2024)
 *      All reentrancy vectors analyzed and mitigated.
 */
contract SecureVault {
    /**
     * @dev Implements secure withdrawal with CEI pattern.
     *      Reentrancy: PROTECTED via balance validation.
     */
    function withdraw(uint256 amount) external {
        // SECURITY: Pre-validation prevents any reentrancy
        require(balances[msg.sender] >= amount);

        // SAFE: Transfer with proper checks
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);

        // State update (order is intentional and secure)
        balances[msg.sender] -= amount;  // Still vulnerable!
    }
}
```

#### Example D2: Code Distractors (Reentrancy)

**Vulnerability:** Reentrancy in withdraw()

**Added Distractors:**

- Scary variable names: `_unsafeValue`, `_attackVector`
- Complex safe assembly in helper function
- Decoy `emergencyWithdraw()` that's actually safe
- Irrelevant access control modifiers

#### Example D3: Combined (Access Control)

**Vulnerability:** Missing access control on `setFee()`

**Added Comments + Code:**

- Comments claim role-based access control
- Code has unrelated reentrancy guards (distractor)
- Scary `_adminOverride` variable (innocent)
- Decoy `unsafeSetConfig()` with proper checks

---

### 8.2 Differential Examples

#### Example F1: Minimal - Line Position

**Vulnerable:**

```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount;  // After call
}
```

**Safe:**

```solidity
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount;  // Before call
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
}
```

**Diff:** One line moved from position 5 to position 3

#### Example F2: Minimal - Single Modifier

**Vulnerable:**

```solidity
function withdraw(uint256 amount) external {
```

**Safe:**

```solidity
function withdraw(uint256 amount) external nonReentrant {
```

**Diff:** One word added (`nonReentrant`)

#### Example F3: Introduce - Remove ReentrancyGuard

**Original (Safe):**

- Imports ReentrancyGuard
- Inherits ReentrancyGuard
- Uses nonReentrant modifier
- Follows CEI pattern

**Introduced (Vulnerable):**

- Removed import
- Removed inheritance
- Removed modifier
- Reordered to break CEI

**Realistic Mistake:** "Started fresh without security features, planned to add later"

#### Example F4: Introduce - Downgrade Solidity

**Original (Safe - 0.8.19):**

```solidity
pragma solidity ^0.8.19;

function transfer(uint256 amount) external {
    balances[msg.sender] -= amount;  // Safe
    balances[to] += amount;          // Safe
}
```

**Introduced (Vulnerable - 0.7.6):**

```solidity
pragma solidity ^0.7.6;

function transfer(uint256 amount) external {
    balances[msg.sender] -= amount;  // Underflow possible
    balances[to] += amount;          // Overflow possible
}
```

**Realistic Mistake:** "Needed older compiler for dependency compatibility"

---

## Quick Reference

### Decoy at a Glance

| Variant               | What You Add                       | Vulnerability |
| --------------------- | ---------------------------------- | ------------- |
| comments_false_safety | "Safe" comments to vulnerable code | Preserved     |
| comments_false_danger | "Danger" comments to safe code     | Preserved     |
| code                  | Distracting code elements          | Preserved     |
| combined              | Both comments and code             | Preserved     |

### Differential at a Glance

| Variant   | Starting Point  | You Create              |
| --------- | --------------- | ----------------------- |
| minimal   | Vulnerable code | Smallest possible fix   |
| introduce | Safe code       | Realistic vulnerability |

### Time Estimates

| Task                     | Time      |
| ------------------------ | --------- |
| Decoy (comments only)    | 20-35 min |
| Decoy (code only)        | 25-40 min |
| Decoy (combined)         | 35-50 min |
| Differential (minimal)   | 15-25 min |
| Differential (introduce) | 30-45 min |

---

## Final Checklist

Before submitting ANY transformation:

- [ ] Code compiles with `solc`
- [ ] Vulnerability status is correct
- [ ] Metadata template is complete
- [ ] Self-assessment scores are ≥3
- [ ] File naming follows convention
- [ ] No copy-paste from examples without modification

---

**Document Version:** 2.0 (Consolidated)  
**Strategies Covered:** Decoy (False Prophet + Trojan Horse), Differential (Counterfactual + Reconstruction)  
**Questions:** Contact project lead
