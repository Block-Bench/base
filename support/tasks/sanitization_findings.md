# Sanitization Leakage Findings Report

## Status: RESOLVED

All identified leakages have been fixed in `strategies/base/sanitize.py`. The sanitizer now handles:
- 280+ NAME_REPLACEMENT patterns
- 100+ COMMENT_PATTERNS_TO_REMOVE patterns
- Console.log and emit statement sanitization
- Raw text file content replacements
- Method calls, ABI signatures, and variable references

## Original Findings (Now Fixed)

Manual review of both raw and sanitized contract data revealed several patterns that were **not being caught** by the original `sanitize.py` implementation. These leakages could provide hints to LLMs about vulnerability types.

---

## Critical Leakages Found in Sanitized Contracts

### 1. Contract/Variable Names Still Containing Hints

| Pattern Found | File(s) | Issue |
|--------------|---------|-------|
| `VulnerableBankContract` | sn_ds_110.sol | Contract name with "Vulnerable" prefix |
| `vulnerable_contract` | sn_ds_003.sol | Variable name explicitly says "vulnerable" |
| `attackModeIsOn` | sn_ds_003.sol | Boolean reveals attack context |
| `HashCollisionBugContract` | Multiple | Contains "Bug" suffix |
| `ArrayDeletionBugContract` | Multiple | Contains "Bug" suffix |
| `pwned` | sn_ds_108.sol | Variable name reveals exploit outcome |
| `DrainMe` | sn_ds_172.sol | Contract name implies funds extraction |
| `VulnerableRoute` | sn_tc_033.sol | Contract name with "Vulnerable" prefix |

### 2. Function Names Still Containing Hints

| Pattern Found | File(s) | Issue |
|--------------|---------|-------|
| `attack()` | Multiple files | Lowercase function name not caught |
| `testReentrancy()` | sn_ds_199.sol, sn_ds_231.sol | Function name reveals vulnerability type |
| `testPwn()` | sn_ds_231.sol | Function name reveals exploit intent |
| `testUnsafeDowncast()` | Multiple | Contains "Unsafe" |
| `testOverflow()` | Multiple | Reveals vulnerability type |
| `testExploit()` | Some files | Some instances remain |

### 3. Console.log Messages Leaking Info

| Pattern Found | File(s) | Issue |
|--------------|---------|-------|
| `"Before exploiting"` | Test files | Console output reveals exploit flow |
| `"After exploiting"` | Test files | Console output reveals exploit flow |
| `"attacker"` | Multiple test files | Identifies attacker entity in logs |

### 4. Metadata Files (CRITICAL)

The sanitized metadata files **still contain full vulnerability descriptions**:

```json
{
  "root_cause": "Missing access control on mint function",
  "attack_vector": "Call mint() directly to mint arbitrary tokens",
  "detection_hints": ["Check for missing onlyOwner modifier", "Look for unrestricted mint"]
}
```

These fields completely reveal the vulnerability type and exploitation method.

---

## Recommended Additions to `sanitize.py`

### A. Additional NAME_REPLACEMENTS Patterns

```python
# Add to NAME_REPLACEMENTS list:

# More aggressive Vulnerable* patterns (camelCase compounds)
(r'\bVulnerable([A-Z][a-zA-Z]+)Contract\b', r'Basic\1Contract', 0),
(r'\bVulnerable([A-Z][a-zA-Z]+)\b', r'Basic\1', 0),

# Bug suffix patterns (compounds not caught)
(r'\b([A-Z][a-zA-Z]+)BugContract\b', r'\1Contract', 0),
(r'\b([A-Z][a-zA-Z]+)Bug\b', r'\1Alt', 0),

# DrainMe / Drain patterns
(r'\bDrainMe\b', 'FundManager', 0),
(r'\bDrain([A-Z][a-zA-Z]*)\b', r'Transfer\1', 0),

# Lowercase attack/exploit as function names
(r'\bfunction\s+attack\s*\(', 'function operate(', 0),
(r'\bfunction\s+exploit\s*\(', 'function execute(', 0),

# attackModeIsOn and similar booleans
(r'\battackModeIsOn\b', 'operationActive', 0),
(r'\battackMode\b', 'operationMode', 0),
(r'\bisAttacker\b', 'isOperator', 0),
(r'\bisAttack\b', 'isOperation', 0),

# pwned/pwn variables
(r'\bpwned\b', 'completed', 0),
(r'\bisPwned\b', 'isCompleted', 0),

# vulnerable_contract variable (snake_case)
(r'\bvulnerable_contract\b', 'target_contract', 0),
(r'\bvulnerable_\b', 'target_', 0),

# Test function names with vulnerability types
(r'\btestReentrancy\b', 'testWithdrawal', 0),
(r'\btestOverflow\b', 'testCalculation', 0),
(r'\btestUnderflow\b', 'testCalculation', 0),
(r'\btestPwn\b', 'testExecution', 0),
(r'\btestUnsafe\b', 'testOperation', 0),
(r'\btestVulnerable\b', 'testBasic', 0),

# Route patterns
(r'\bVulnerableRoute\b', 'BasicRoute', 0),
```

### B. Additional COMMENT_PATTERNS_TO_REMOVE

```python
# Add to COMMENT_PATTERNS_TO_REMOVE list:

# console.log statements with hints
r'console\.log\s*\([^)]*([Ee]xploit|[Aa]ttack|[Aa]ttacker|[Vv]ulnerable)[^)]*\)',

# Foundry test comments
r'//.*test.*[Rr]eentrancy.*$',
r'//.*test.*[Oo]verflow.*$',
```

### C. New Console.log Sanitization (Add as Step 2.5)

```python
# Console.log message sanitization (between Step 2 and Step 3)
CONSOLE_LOG_REPLACEMENTS = [
    (r'console\.log\s*\(\s*"Before exploiting"', 'console.log("Before operation"', 0),
    (r'console\.log\s*\(\s*"After exploiting"', 'console.log("After operation"', 0),
    (r'console\.log\s*\([^)]*attacker[^)]*\)', 'console.log("operator action")', re.IGNORECASE),
    (r'console\.log\s*\([^)]*exploit[^)]*\)', 'console.log("execution")', re.IGNORECASE),
    (r'console\.log\s*\([^)]*attack[^)]*\)', 'console.log("operation")', re.IGNORECASE),
]
```

### D. Metadata Sanitization (NEW FUNCTION REQUIRED)

The most critical fix needed - metadata files should have sensitive fields removed or anonymized:

```python
# Fields to remove/anonymize in metadata
METADATA_FIELDS_TO_REMOVE = [
    'root_cause',
    'attack_vector',
    'detection_hints',
    'vulnerability_description',
    'exploit_explanation',
]

METADATA_FIELDS_TO_ANONYMIZE = {
    'vulnerability_type': 'contract_category',  # Rename field
}

def sanitize_metadata(metadata: dict) -> dict:
    """Sanitize metadata by removing/anonymizing sensitive fields."""
    result = metadata.copy()

    # Remove sensitive fields entirely
    for field in METADATA_FIELDS_TO_REMOVE:
        result.pop(field, None)

    # Anonymize field names
    for old_name, new_name in METADATA_FIELDS_TO_ANONYMIZE.items():
        if old_name in result:
            result[new_name] = result.pop(old_name)

    return result
```

Then update `_save_sanitized()` to call `sanitize_metadata(metadata)` before saving.

---

## Priority Order for Fixes

1. **HIGH**: Metadata sanitization - this is the most severe leak
2. **HIGH**: Console.log message sanitization
3. **MEDIUM**: Additional NAME_REPLACEMENTS for missed patterns
4. **MEDIUM**: Test function name patterns (testReentrancy, testOverflow, etc.)
5. **LOW**: Additional comment patterns

---

## Testing Recommendations

After implementing fixes, run:

```bash
# Re-sanitize all contracts
python -m strategies.base.sanitize all

# Verify no leakages remain
grep -rE "vulnerable|exploit|attack|overflow|reentr|pwn|drain|bug" data/sanitized/contracts/
grep -rE "root_cause|attack_vector|detection_hints" data/sanitized/metadata/
```

---

## Files Requiring Manual Review

These files had particularly egregious leakages and should be spot-checked after re-sanitization:

1. `sn_ds_003.sol` - Multiple variable name leakages
2. `sn_ds_108.sol` - `pwned` variable
3. `sn_ds_110.sol` - `VulnerableBankContract`
4. `sn_ds_172.sol` - `DrainMe` contract
5. `sn_ds_199.sol` - `testReentrancy` function
6. `sn_ds_231.sol` - Multiple leakages
7. `sn_tc_033.sol` - `VulnerableRoute` contract
8. All metadata files in `data/sanitized/metadata/`
