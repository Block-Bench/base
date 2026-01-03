Below is a **strict issues-only review** of **ms_tc_049 (Exactly Protocol — malicious market oracle manipulation)**, evaluated **only** along your three review axes.

Anything **not explicitly listed is correct**.

---

## 1️⃣ Metadata ↔ Contract Consistency

### ❌ Issue 1.1 — `vulnerable_contract` under-scoped

**Metadata:**

```json
"vulnerable_contract": "DebtPreviewer",
"vulnerable_function": "previewDebt"
```

**Problem:**

* The exploit is **not contained within `DebtPreviewer` alone**
* The **critical trust boundary failure** occurs when **`ExactlyMarket.borrow()`**:

  ```solidity
  previewer.previewMultipleMarkets(markets, msg.sender)
  ```

  accepts a **user-controlled `markets` array**
* Without `borrow()` forwarding unvalidated inputs, `DebtPreviewer` would be inert

➡️ Metadata collapses a **cross-contract trust violation** into a single contract.

**Fix:**

* Either:

  * mark both **`DebtPreviewer` and `ExactlyMarket`** as vulnerable contracts, or
  * explicitly state that `DebtPreviewer` is vulnerable **only because its output is trusted by ExactlyMarket**

---

## 2️⃣ Code Act Correctness (Code Act ↔ Security Function)

### ❌ Issue 2.1 — ROOT_CAUSE duplicated across CA1 and CA2

```yaml
CA1: previewDebt() trusting arbitrary market
CA2: borrow() forwarding user-controlled markets
```

**Problem:**

* These are **not independent causes**
* They form **one causal chain**:

  > *User-controlled market addresses are trusted for collateral computation*
* Splitting them into two ROOT_CAUSEs artificially inflates causality

➡️ Should be modeled as **one ROOT_CAUSE spanning both trust boundaries**

---

### ❌ Issue 2.2 — CA3 incorrectly classified as PREREQ

```yaml
CA3: previewMultipleMarkets() summation loop
security_function: PREREQ
```

**Problem:**

* The loop does **not enable** the exploit
* It merely **aggregates already-untrusted values**
* Even a single malicious market would suffice

➡️ This is **implementation logic**, not a prerequisite.

**Correct classification:** `BENIGN (aggregation of tainted data)`

---

### ❌ Issue 2.3 — CA4 and CA5 misclassified as PREREQ

```yaml
CA4: healthFactor calculation
CA5: overallHealth calculation
```

**Problem:**

* These calculations **consume manipulated inputs**
* They do not gate, enable, or condition the exploit
* Borrow authorization already depends on `totalCollateral` alone

➡️ These are **post-taint arithmetic**, not prerequisites.

**Correct classification:** `BENIGN (derived metrics)`

---

## 3️⃣ Scoring / Taxonomy Rigor

### ❌ Issue 3.1 — PREREQ inflation (3 listed, 0 required)

**True minimal prerequisite set:**

* None beyond the ROOT_CAUSE itself

Current PREREQs include:

* Aggregation loop
* Health calculations

➡️ This violates minimality and weakens exploit signal.

---

### ❌ Issue 3.2 — ROOT_CAUSE framed procedurally, not invariant-based

**Current framing:**

* “Calls getAccountSnapshot on user-provided market”

**Missing invariant:**

> *Collateral valuation must only trust protocol-approved markets*

➡️ Taxonomy should encode **trust-boundary violation**, not individual call sites.

---

## ✅ Final Verdict

| Axis                            | Result                 |
| ------------------------------- | ---------------------- |
| Metadata ↔ Contract consistency | ⚠️ Scope under-modeled |
| Code Act correctness            | ❌ ROOT / PREREQ misuse |
| Scoring / taxonomy rigor        | ❌ Causal inflation     |

---

### Bottom line

This annotation **correctly captures a malicious-market oracle attack**, but:

* Splits one trust-boundary failure into multiple ROOT_CAUSEs
* Mislabels pure data consumers as PREREQs
* Understates the cross-contract nature of the vulnerability

A clean model would contain:

* **1 ROOT_CAUSE (unvalidated external market trust)**
* **0 PREREQs**
* All downstream calculations marked **BENIGN (tainted data propagation)**
