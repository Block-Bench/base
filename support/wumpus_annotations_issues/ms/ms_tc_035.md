Below is a **strict issues-only review** of **ms_tc_035 (Wise Lending Rounding Error)**, evaluated **only** along your three review axes.

Anything **not explicitly listed is correct**.

---

## 1️⃣ Metadata ↔ Contract Consistency

### ❌ Issue 1.1 — `vulnerable_lines` incomplete relative to modeled exploit

**Metadata:**

```json
"vulnerable_lines": [68, 100]
```

**Problem:**

* Lines **68–70** and **100–102** capture only **two** arithmetic sites
* The exploit **also relies on**:

  * line **123–125** (`withdrawExactAmount()` share burn calculation)
* The metadata attack flow explicitly includes **both withdrawal paths**

➡️ Metadata models this as a **two-function bug**, while the exploit spans **three symmetric calculations**.

**Fix:**

* Include `[68–70, 100–102, 123–125]`, or
* Explicitly state that line 123–125 is the *same invariant violation* expressed via an alternate API

---

### ❌ Issue 1.2 — `vulnerable_function` under-scoped

**Metadata:**

```json
"vulnerable_function": "depositExactAmount"
```

**Problem:**

* The exploit is **not deposit-only**
* Value extraction requires:

  * `withdrawExactShares()` **or**
  * `withdrawExactAmount()`
* Deposit alone cannot produce loss

➡️ This understates the exploit lifecycle.

**Fix:**

* List all three:

  * `depositExactAmount`
  * `withdrawExactShares`
  * `withdrawExactAmount`
* Or reframe as **pool share accounting invariant violation**

---

## 2️⃣ Code Act Correctness (Code Act ↔ Security Function)

### ❌ Issue 2.1 — ROOT_CAUSE incorrectly duplicated (CA1 + CA2)

```yaml
CA1: deposit share calculation
CA2: withdrawExactShares calculation
```

**Problem:**

* These are **not independent root causes**
* Both express the **same invariant failure**:

> *Share value becomes undefined under extreme pool ratios due to integer division*

➡️ Modeling them as two ROOT_CAUSEs **inflates causal count**.

**Correct modeling:**

* **Single ROOT_CAUSE** spanning:

  * deposit share mint
  * share redemption math

---

### ❌ Issue 2.2 — CA8 misclassified as PREREQ

```yaml
CA8: withdrawExactAmount shareBurned calculation
```

**Problem:**

* This is **not a prerequisite**
* It is a **third expression of the same rounding invariant**
* The exploit works even if this function is removed

➡️ Treating CA8 as PREREQ splits one invariant into stages.

**Correct classification:** `ROOT_CAUSE (shared rounding invariant)`

---

### ❌ Issue 2.3 — Missing invariant unification across three paths

**Observed pattern:**

```text
depositExactAmount      → shares = amount * shares / pool
withdrawExactShares     → amount = shares * pool / shares
withdrawExactAmount     → shares = amount * shares / pool
```

**Problem:**

* All three violate the **same arithmetic invariant**
* Annotation fragments this across ROOT_CAUSE + PREREQ

➡️ This obscures the **systemic nature** of the rounding flaw.

---

## 3️⃣ Scoring / Taxonomy Rigor

### ❌ Issue 3.1 — PREREQ inflation (1 listed, 0 required)

**True minimal causal set:**

* Integer division with manipulable extreme ratios
* No minimum pool size / ratio bounds

Current PREREQ:

* alternate withdrawal math path

➡️ This is **not gating exploitability**.

---

### ❌ Issue 3.2 — ROOT_CAUSE framed procedurally, not invariant-based

**Current framing:**

* “Rounding vulnerability in calculation”

**Missing invariant framing:**

> *Share ↔ pool value mapping must remain monotonic and lossless across all paths*

➡️ Without invariant encoding, this appears as **isolated math bugs** rather than a **broken accounting model**.

---

### ❌ Issue 3.3 — Pool state manipulation not explicitly modeled

The exploit depends on **pathological pool state**:

* `pseudoTotalPool = 2`
* `totalDepositShares = 1`

➡️ Missing taxonomy dimensions:

* `STATE_PRECONDITION: extreme ratio`
* `MIN_POOL_SIZE: unbounded`

---

## ✅ Final Verdict

| Axis                            | Result                |
| ------------------------------- | --------------------- |
| Metadata ↔ Contract consistency | ⚠️ Under-scoped       |
| Code Act correctness            | ❌ ROOT/PREREQ misuse  |
| Scoring / taxonomy rigor        | ❌ Invariant splitting |

---

### Bottom line

This annotation **correctly identifies rounding exploitation**, but:

* ROOT_CAUSE is **duplicated instead of unified**
* PREREQ is used for **another manifestation of the same flaw**
* Metadata understates the **multi-path nature** of the exploit

A clean model would have:

* **1 ROOT_CAUSE**: unbounded share–pool ratio with integer division
* **0 PREREQs**
* Explicit encoding of **extreme-state arithmetic invariants**
