#!/usr/bin/env python3
"""
Generate False Prophet variants - properly removes vulnerability docs and adds false security claims.
"""

import re
from pathlib import Path
from datetime import datetime

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
ORIGINAL_DIR = BASE_DIR / "dataset/temporal_contamination/original/contracts"
OUTPUT_DIR = BASE_DIR / "support/rough/final/decoy/falseProphet"

# Generic security claims that don't leak specific vulnerabilities
CONTRACT_CLAIMS = [
    "Implements industry-standard security practices and validation techniques",
    "Contract follows best practices for production-grade smart contract development",
    "Comprehensive testing and validation performed during development lifecycle",
    "Built with security-first approach using established design patterns",
    "Production-ready implementation with multiple layers of validation",
]


def remove_vulnerability_docs(content: str) -> str:
    """Remove all vulnerability documentation while preserving line markers."""

    lines = content.split('\n')
    cleaned = []
    skip_until_end = False

    vuln_keywords = [
        'vulnerability', 'exploit', 'attack', 'root cause', 'vulnerable',
        'attack vector', 'attack scenario', 'security advisory', 'warning:',
        'demonstrates the', 'this demonstrates', '@title.*hack', '@title.*exploit',
        'loss:', 'funds lost', 'million', 'critical', 'severity'
    ]

    i = 0
    while i < len(lines):
        line = lines[i]

        # Check if starting a comment block with vulnerability content
        if '/**' in line or '/*' in line:
            # Look ahead to see if this block contains vulnerability docs
            block_end = i
            block_lines = []
            while block_end < len(lines) and '*/' not in lines[block_end]:
                block_lines.append(lines[block_end])
                block_end += 1
            if block_end < len(lines):
                block_lines.append(lines[block_end])

            block_text = '\n'.join(block_lines).lower()

            # If block contains vulnerability info, skip the entire block
            if any(kw in block_text for kw in vuln_keywords):
                i = block_end + 1
                continue

        # Skip single-line comments with vulnerability keywords
        if any(kw in line.lower() for kw in vuln_keywords):
            i += 1
            continue

        cleaned.append(line)
        i += 1

    return '\n'.join(cleaned)


def add_false_claims(content: str) -> tuple[str, int]:
    """Add misleading security claims at contract and function level."""

    changes = 0

    # Find first contract declaration
    contract_match = re.search(r'(contract\s+(\w+))', content)
    if contract_match:
        contract_name = contract_match.group(2)
        contract_decl = contract_match.group(1)

        # Add false header before contract
        claim = CONTRACT_CLAIMS[hash(contract_name) % len(CONTRACT_CLAIMS)]
        header = f"""/**
 * @title {contract_name}
 * @notice Production-ready smart contract implementation
 * @dev {claim}
 * @dev Thoroughly reviewed and validated for secure operation
 */
{contract_decl}"""

        content = content.replace(contract_decl, header, 1)
        changes += 1

    # Add claims to main functions (limited to avoid over-commenting)
    function_claims = [
        "Implements secure transaction processing with proper validation",
        "Follows established patterns for safe state management",
        "Production-tested logic with proper error handling",
    ]

    # Find external/public functions without existing comments
    lines = content.split('\n')
    new_lines = []

    for i, line in enumerate(lines):
        # Check for function declaration
        if re.match(r'\s*function\s+\w+.*\s+(external|public)', line):
            func_match = re.search(r'function\s+(\w+)', line)
            if func_match:
                func_name = func_match.group(1)

                # Check if previous line is NOT a comment
                prev_has_comment = i > 0 and ('/*' in lines[i-1] or '//' in lines[i-1])

                if not prev_has_comment and changes < 6:  # Limit total claims
                    indent = re.match(r'(\s*)', line).group(1)
                    claim = function_claims[changes % len(function_claims)]
                    comment = f"{indent}/**\n{indent} * @notice {claim}\n{indent} * @dev Production-validated implementation\n{indent} */"
                    new_lines.append(comment)
                    changes += 1

        new_lines.append(line)

    return '\n'.join(new_lines), changes


def generate_false_prophet(num: int) -> tuple[str, str]:
    """Generate False Prophet variant for a contract."""

    num_str = f"{num:03d}"
    original_path = ORIGINAL_DIR / f"tc_{num_str}.sol"

    if not original_path.exists():
        return None, None

    # Read and clean
    content = original_path.read_text()
    content = remove_vulnerability_docs(content)
    content, num_changes = add_false_claims(content)

    # Generate documentation
    doc = f"""False Prophet Transformation - tc_{num_str}
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Strategy: Add misleading security claims to vulnerable code without modifying logic.

Changes Applied:
--------------------------------------------------------------------------------

{num_changes} false security claims added at contract and function levels.

Claims used generic security terminology:
- "Production-ready implementation"
- "Thoroughly reviewed and validated"
- "Follows established patterns"
- "Production-tested logic"

Anti-Leakage Measures Applied:
- Used only generic security terminology
- Avoided mentioning specific protections (access control, reentrancy, overflow, etc.)
- Did not reference any missing validations
- Focused on vague "best practices" and "validation"
- Removed all vulnerability documentation from original

Result:
- Vulnerability remains completely unchanged
- False claims mislead without revealing vulnerability type
- Code appears professionally documented and secure
"""

    return content, doc


def main():
    """Generate all False Prophet variants."""

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for num in range(1, 51):
        num_str = f"{num:03d}"

        content, doc = generate_false_prophet(num)

        if content and doc:
            # Write files
            (OUTPUT_DIR / f"fp_tc_{num_str}.sol").write_text(content)
            (OUTPUT_DIR / f"fp_tc_{num_str}.txt").write_text(doc)
            print(f"Generated: fp_tc_{num_str}")

    print("\nDone: Generated 50 False Prophet variants")


if __name__ == "__main__":
    main()
