# Metadata Validation

This directory contains tools to validate that metadata files correctly reference actual contract code.

## validate_metadata.py

Validates metadata files against their corresponding Solidity contracts.

### What it checks

1. **Contract names**: Verifies that contract names in metadata exist in the actual .sol files
2. **Function names**: Verifies that function names in metadata exist in the contracts
3. **Line numbers**: Ensures line numbers are within file bounds
4. **Empty lines**: Warns if vulnerable location line numbers point to empty or comment lines

### Usage

Basic usage:
```bash
python3 support/validation/validate_metadata.py data/base
```

Validate specific datasets:
```bash
# Base dataset
python3 support/validation/validate_metadata.py data/base

# Sanitized dataset
python3 support/validation/validate_metadata.py data/sanitized

# Strategy-transformed datasets
python3 support/validation/validate_metadata.py data/chameleon/medical_nc
python3 support/validation/validate_metadata.py data/restructure/merge/dispatcher
python3 support/validation/validate_metadata.py data/shapeshifter/l2/short
```

### Output

The script provides:
- Real-time validation status for each file (✅ OK, ⚠️ warnings, ❌ errors)
- Summary with counts of files validated, errors, and warnings
- Detailed list of all errors and warnings

### Exit codes

- `0`: All files valid (no errors)
- `1`: One or more files have errors

### Example output

```
📂 Validating 263 metadata files in data/base
================================================================================
✅ tc_001: OK
✅ tc_002: OK
⚠️  tc_003: 1 warning(s)
❌ tc_006: 1 error(s)
...

================================================================================
VALIDATION SUMMARY
================================================================================
Total files validated: 263
Files with errors: 75
Files with warnings: 89
Files OK: 99

❌ ERRORS (75):
  • tc_006: Contract 'VulnerableContract' not found in tc_006.sol
  ...

⚠️  WARNINGS (89):
  • tc_003: Some line numbers point to empty/comment lines: [38, 43]
  ...
```

## When to use

- After creating or modifying metadata files
- After applying transformation strategies that regenerate metadata
- Before running evaluations to ensure metadata quality
- As part of CI/CD validation pipeline

## Notes

### Warnings vs Errors

**Errors** indicate critical issues that will cause problems:
- Contract name doesn't exist in the code
- Function name doesn't exist in the code
- Line numbers out of bounds
- Missing required metadata fields

**Warnings** indicate potential issues but may be acceptable:
- Line numbers pointing to empty lines (might be for context)
- Line numbers pointing to comment lines (might be explanatory)
- Missing optional metadata fields

### Line number warnings

The script warns when vulnerable location line numbers point to empty or comment lines. This is often acceptable because:
- Vulnerability ranges may include surrounding context
- Function signatures span multiple lines
- Comments may explain the vulnerability

However, verify that the core vulnerable code is included in the range.
