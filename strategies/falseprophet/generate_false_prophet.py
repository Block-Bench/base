#!/usr/bin/env python3
"""
Generate False Prophet variants for temporal contamination contracts.
Adds misleading "secure" comments to vulnerable code without changing logic.
"""

import re
from pathlib import Path
from datetime import datetime

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
ORIGINAL_DIR = BASE_DIR / "dataset/temporal_contamination/original/contracts"
OUTPUT_DIR = BASE_DIR / "support/rough/final/decoy/falseProphet"

# Generic security claims that don't leak specific vulnerabilities
CONTRACT_LEVEL_CLAIMS = [
    "Implements industry-standard security practices and validation techniques",
    "Contract follows best practices for production-grade smart contract development",
    "Comprehensive testing and validation performed during development lifecycle",
    "Built with security-first approach using established design patterns",
    "Production-ready implementation with multiple layers of validation",
]

FUNCTION_LEVEL_CLAIMS = [
    "Implements secure transaction processing with proper validation",
    "Follows established patterns for safe state management",
    "Validated through comprehensive testing and analysis",
    "Secure implementation of critical functionality",
    "Production-tested logic with proper error handling",
]

INLINE_CLAIMS = [
    "Validated operation following security best practices",
    "Secure state update using established patterns",
    "Properly validated transaction flow",
    "Production-grade validation logic",
    "Security-tested implementation",
]


def add_contract_header(content: str, contract_name: str) -> str:
    """Add misleading security claims to contract-level documentation."""

    # Find existing contract declaration
    contract_match = re.search(r'contract\s+(\w+)', content)
    if not contract_match:
        return content

    existing_name = contract_match.group(1)

    # Check if there's already a contract-level comment
    header_pattern = r'/\*\*[\s\S]*?\*/\s*contract\s+' + existing_name

    if re.search(header_pattern, content):
        # Replace existing header with false claims
        new_header = f"""/**
 * @title {existing_name}
 * @notice Production-ready smart contract implementation
 * @dev {CONTRACT_LEVEL_CLAIMS[hash(existing_name) % len(CONTRACT_LEVEL_CLAIMS)]}
 * @dev Thoroughly reviewed and validated for secure operation
 */
contract {existing_name}"""
        content = re.sub(header_pattern, new_header, content)
    else:
        # Add new header before contract declaration
        new_header = f"""/**
 * @title {existing_name}
 * @notice Production-ready smart contract implementation
 * @dev {CONTRACT_LEVEL_CLAIMS[hash(existing_name) % len(CONTRACT_LEVEL_CLAIMS)]}
 * @dev Thoroughly reviewed and validated for secure operation
 */
contract {existing_name}"""
        content = re.sub(r'contract\s+' + existing_name, new_header, content, count=1)

    return content


def add_function_claims(content: str) -> tuple[str, list[dict]]:
    """Add misleading security claims to function-level documentation."""

    changes = []
    lines = content.split('\n')
    new_lines = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Check if this is a function declaration
        if re.match(r'\s*function\s+\w+', line) and 'external' in line or 'public' in line:
            func_match = re.search(r'function\s+(\w+)', line)
            if func_match:
                func_name = func_match.group(1)

                # Check if there's already a comment above
                has_comment = (i > 0 and '/*' in lines[i-1]) or (i > 1 and '/*' in lines[i-2])

                if not has_comment:
                    # Add false security claim
                    indent = re.match(r'(\s*)', line).group(1)
                    claim = FUNCTION_LEVEL_CLAIMS[hash(func_name) % len(FUNCTION_LEVEL_CLAIMS)]

                    comment = f"{indent}/**\n{indent} * @notice {claim}\n{indent} * @dev Production-validated implementation\n{indent} */"
                    new_lines.append(comment)
                    changes.append({
                        "location": f"function {func_name}",
                        "claim": claim
                    })

        new_lines.append(line)
        i += 1

    return '\n'.join(new_lines), changes


def add_inline_claims(content: str) -> tuple[str, list[dict]]:
    """Add misleading inline comments to critical operations."""

    changes = []
    lines = content.split('\n')
    new_lines = []

    # Patterns that might benefit from misleading inline comments
    patterns = [
        (r'\s*require\(', 'validation'),
        (r'\s*\w+\s*=\s*\w+', 'state update'),
        (r'\.call\{', 'external interaction'),
        (r'\.transfer\(', 'transfer operation'),
    ]

    for i, line in enumerate(lines):
        # Check if line matches critical patterns and doesn't already have a comment
        for pattern, operation_type in patterns:
            if re.search(pattern, line):
                # Don't add if previous line is a comment
                if i > 0 and '//' in lines[i-1]:
                    break

                # Add misleading inline comment
                indent = re.match(r'(\s*)', line).group(1)
                claim = INLINE_CLAIMS[i % len(INLINE_CLAIMS)]

                # Only add to ~30% of eligible lines to avoid over-commenting
                if hash(line) % 10 < 3:
                    new_lines.append(f"{indent}// @dev {claim}")
                    changes.append({
                        "location": f"line {i+1} ({operation_type})",
                        "claim": claim
                    })
                    break

        new_lines.append(line)

    return '\n'.join(new_lines), changes


def generate_false_prophet(contract_num: int) -> tuple[str, str]:
    """Generate a False Prophet variant for a given contract number."""

    num_str = f"{contract_num:03d}"
    original_path = ORIGINAL_DIR / f"tc_{num_str}.sol"

    if not original_path.exists():
        return None, None

    # Read original vulnerable contract
    content = original_path.read_text()

    # Remove all existing vulnerability documentation
    # Remove comment blocks that mention vulnerability, exploit, attack, etc.
    content = re.sub(
        r'/\*\*[\s\S]*?(VULNERABILITY|EXPLOIT|ATTACK|ROOT CAUSE|VULNERABLE|@dev.*vulnerable)[\s\S]*?\*/',
        '',
        content,
        flags=re.IGNORECASE
    )

    # Remove inline comments mentioning vulnerabilities
    content = re.sub(
        r'//.*?(VULNERABILITY|VULNERABLE|EXPLOIT|ATTACK|BUG|ISSUE|PROBLEM|DANGER|UNSAFE|INSECURE)',
        '',
        content,
        flags=re.IGNORECASE
    )

    # Track all changes
    all_changes = []

    # Add contract-level claims
    content = add_contract_header(content, f"tc_{num_str}")
    all_changes.append({
        "level": "contract",
        "claim": "Added professional contract-level documentation claiming security validation"
    })

    # Add function-level claims
    content, func_changes = add_function_claims(content)
    all_changes.extend([{"level": "function", **c} for c in func_changes])

    # Add inline claims
    content, inline_changes = add_inline_claims(content)
    all_changes.extend([{"level": "inline", **c} for c in inline_changes])

    # Generate documentation
    doc = f"""False Prophet Transformation - tc_{num_str}
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Strategy: Added misleading security claims to vulnerable code without modifying logic.

Changes Applied:
{'-' * 80}

Contract-Level Claims:
- Added professional documentation header claiming production-readiness
- Claimed security validation and best practices
- No specific vulnerability types mentioned to avoid leakage

Function-Level Claims:
"""

    for change in all_changes:
        if change['level'] == 'function':
            doc += f"- {change['location']}: {change['claim']}\n"

    doc += f"""
Inline Claims:
"""

    for change in all_changes:
        if change['level'] == 'inline':
            doc += f"- {change['location']}: {change['claim']}\n"

    doc += f"""
Total Changes: {len(all_changes)}

Anti-Leakage Measures:
- Used generic security terminology
- Avoided mentioning specific protections (e.g., "access control", "reentrancy guard")
- Did not reference missing validations
- Focused on general "best practices" and "validation"

The underlying vulnerability remains completely unchanged.
The false claims are designed to mislead without revealing the vulnerability type.
"""

    return content, doc


def main():
    """Generate all False Prophet variants."""

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    generated = 0
    errors = 0

    for num in range(1, 51):
        num_str = f"{num:03d}"

        try:
            content, doc = generate_false_prophet(num)

            if content and doc:
                # Write contract
                contract_path = OUTPUT_DIR / f"fp_tc_{num_str}.sol"
                contract_path.write_text(content)

                # Write documentation
                doc_path = OUTPUT_DIR / f"fp_tc_{num_str}.txt"
                doc_path.write_text(doc)

                print(f"Generated: fp_tc_{num_str}")
                generated += 1
            else:
                print(f"Skipped: tc_{num_str} (not found)")
                errors += 1

        except Exception as e:
            print(f"Error on tc_{num_str}: {e}")
            errors += 1

    print(f"\nDone: Generated {generated} False Prophet variants, {errors} errors")


if __name__ == "__main__":
    main()
