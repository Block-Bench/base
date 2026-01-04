## Chameleon Medical metadata ↔ code alignment issues (temporal_contamination/chameleon_medical)

### Dataset-level

- **README count mismatch**:
  - `dataset/temporal_contamination/chameleon_medical/README.md` claims “50 Solidity contracts (ch_medical_tc_001.sol - ch_medical_tc_050.sol)”.
  - Actual dataset contains `ch_medical_tc_001`–`ch_medical_tc_046` (46 contracts + 46 metadata), consistent with `index.json total_files: 46`.

- **README claim about `vulnerable_lines` is false**:
  - README states `vulnerable_lines`: “Empty (requires manual annotation)”.
  - `metadata/ch_medical_tc_*.json` currently contains non-empty `vulnerable_lines` (example: `ch_medical_tc_001` has `[15, 40]`).

---

### Systematic issues (critical)

- **Metadata schema inconsistency: `is_vulnerable` missing in 39/46 files**:
  - `ch_medical_tc_001`–`ch_medical_tc_007` include `is_vulnerable: true`.
  - `ch_medical_tc_008`–`ch_medical_tc_046` omit `is_vulnerable` entirely.
  - **Impact**: any pipeline expecting a consistent `is_vulnerable` boolean across variants will behave inconsistently.

- **Chameleon transformation broke Solidity built-ins: `.length` renamed to `.duration` (non-compiling code)**
  - `index.json` claims “Preserved Solidity keywords and built-ins”, but multiple contracts contain member access like `array.duration` / `bytes.duration`.
  - In Solidity, dynamic arrays / `bytes` / `string` use the built-in property `.length`; `.duration` is invalid and will not compile.
  - **Impact**: these samples are not executable Solidity and will fail any tooling that compiles/contracts-parses the dataset.

#### Affected contracts (`.duration` member access present)

- `contracts/ch_medical_tc_001.sol` (e.g., `_message.duration`)
- `contracts/ch_medical_tc_003.sol`
- `contracts/ch_medical_tc_006.sol` (e.g., `markets.duration`)
- `contracts/ch_medical_tc_014.sol` (e.g., `_targets.duration`, `_data.duration`)
- `contracts/ch_medical_tc_015.sol`
- `contracts/ch_medical_tc_024.sol`
- `contracts/ch_medical_tc_035.sol`
- `contracts/ch_medical_tc_042.sol`

---

### Metadata internal consistency issue (high impact)

- **`vulnerable_lines` do not align with `vulnerable_function` in 20 samples**:
  - In these samples, at least one `vulnerable_lines` entry is inside a **different function** than the one(s) listed in `vulnerable_function` (post-rename).
  - **Impact**: if scoring or evaluation assumes `vulnerable_function` localizes the vulnerable line(s), these metadata entries are internally inconsistent.

#### Mismatches (sample: line → actual function, but `vulnerable_function` lists ...)

- `ch_medical_tc_002`: LN 48–49 → `submitPayment`, but `vulnerable_function` is `criticalFinalize`
- `ch_medical_tc_003`: LN 19 → `initializesystemWallet`, but `vulnerable_function` is `deactivateSystem`
- `ch_medical_tc_004`: LN 102 → `_handleEthTransfercare`, but `vulnerable_function` is `append_availableresources`
- `ch_medical_tc_010`: LN 71 → `checkoutMarket`, but `vulnerable_function` is `requestAdvance`
- `ch_medical_tc_013`: LN 55 → `_notifyTransfercare`, but `vulnerable_function` is `transfer`
- `ch_medical_tc_015`: LN 53 → `exchangeCredentials`, but `vulnerable_function` is `_updaterecordsWeights`
- `ch_medical_tc_017`: LN 68 → `acquireLpCredentialMeasurement`, but `vulnerable_function` is `requestAdvance`
- `ch_medical_tc_021`: LN 33 → `retrieveCost`, and LN 84 → `obtainSecuritydepositMeasurement`, but `vulnerable_function` is `requestAdvance`
- `ch_medical_tc_024`: LN 35 → `_diagnoseDuo`, but `vulnerable_function` is `exchangecredentialsExactCredentialsForCredentials`
- `ch_medical_tc_026`: LN 44 → `dischargeFunds`, but `vulnerable_function` is `submitPayment`
- `ch_medical_tc_029`: LN 55 → `submitPayment`, and LN 136 → `rayDiv`, but `vulnerable_function` is `emergencyLoan`
- `ch_medical_tc_032`: LN 86 → `dischargefundsExactAllocations`, but `vulnerable_function` is `submitpaymentExactQuantity`
- `ch_medical_tc_035`: LN 65 → `requestAdvance`, but `vulnerable_function` is `issueCredential`
- `ch_medical_tc_037`: LN 78 → `acquireConvertcredentialsFactor`, but `vulnerable_function` is `issueCredential`
- `ch_medical_tc_041`: LN 75 → `collectBenefit`, but `vulnerable_function` is `enhancesystemPool`
- `ch_medical_tc_042`: LN 39 → `collectBenefits`, but `vulnerable_function` is `enrollMarket`
- `ch_medical_tc_045`: LN 110 → `requestAdvance`, but `vulnerable_function` is `previewOutstandingbalance`



