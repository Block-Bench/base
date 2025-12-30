#!/usr/bin/env python3
"""
Generate False Prophet variants - simpler approach: remove all docs before contract, add false claims.
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


def clean_contract(content: str, contract_num: int) -> tuple[str, int]:
    """
    Remove all comment blocks and add clean header before contract declaration.
    Simpler approach: remove everything before contract, add fresh header.
    """

    lines = content.split('\n')
    result_lines = []
    found_contract = False
    in_comment_block = False
    changes = 0

    # Keep license and pragma
    for line in lines:
        # Extract line marker if present
        marker_match = re.match(r'(/\*LN-\d+\*/\s*)(.*)', line)
        if marker_match:
            marker = marker_match.group(1)
            content_part = marker_match.group(2)
        else:
            marker = ""
            content_part = line

        # Keep SPDX license
        if 'SPDX-License-Identifier' in content_part:
            result_lines.append(line)
            continue

        # Keep pragma
        if content_part.strip().startswith('pragma '):
            result_lines.append(line)
            continue

        # Check for contract declaration
        if re.match(r'\s*contract\s+\w+', content_part) and not found_contract:
            # Extract contract name
            contract_match = re.search(r'contract\s+(\w+)', content_part)
            if contract_match:
                contract_name = contract_match.group(1)

                # Add empty line after pragma
                result_lines.append(f"{marker}")

                # Add false security header
                claim = CONTRACT_CLAIMS[contract_num % len(CONTRACT_CLAIMS)]
                header = f"""/**
 * @title {contract_name}
 * @notice Production-ready smart contract implementation
 * @dev {claim}
 * @dev Thoroughly reviewed and validated for secure operation
 */
"""
                result_lines.append(header)
                changes += 1

                # Add the contract line
                result_lines.append(line)
                found_contract = True
                continue

        # After finding contract, process rest of file
        if found_contract:
            # Check for vulnerability-related keywords in comments
            if has_vuln_keywords(content_part):
                # Skip this line if it's a comment with vuln keywords
                if '//' in content_part or in_comment_block:
                    continue

            # Track comment blocks
            if '/**' in content_part or '/*' in content_part:
                # Check if this comment has vulnerability keywords
                # by looking ahead
                block_text = get_comment_block(lines, lines.index(line))
                if has_vuln_keywords(block_text):
                    in_comment_block = True
                    continue

            if in_comment_block:
                if '*/' in content_part:
                    in_comment_block = False
                continue

            result_lines.append(line)

    return '\n'.join(result_lines), changes


def get_comment_block(lines: list, start_idx: int) -> str:
    """Get full comment block starting from start_idx."""
    block = []
    for i in range(start_idx, len(lines)):
        line = lines[i]
        block.append(line)
        if '*/' in line:
            break
    return '\n'.join(block)


def has_vuln_keywords(text: str) -> bool:
    """Check if text contains vulnerability-related keywords."""
    keywords = [
        'vulnerability', 'vulnerable', 'exploit', 'attack', 'hack',
        'malicious', 'root cause', 'attack vector', 'reentrancy',
        'reenter', 'compromised', 'attacker', 'stolen', 'drained',
        'loss:', 'million', 'drain', 'fix:', 'too late', 'textbook',
        'checks-effects-interactions', 'forged', 'fake', '$', 'demonstrates the'
    ]

    text_lower = text.lower()
    return any(kw in text_lower for kw in keywords)


def generate_false_prophet(num: int) -> tuple[str, str]:
    """Generate False Prophet variant for a contract."""

    num_str = f"{num:03d}"
    original_path = ORIGINAL_DIR / f"tc_{num_str}.sol"

    if not original_path.exists():
        return None, None

    # Read and process
    content = original_path.read_text()
    content, num_changes = clean_contract(content, num)

    # Generate documentation
    doc = f"""False Prophet Transformation - tc_{num_str}
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Strategy: Add misleading security claims to vulnerable code without modifying logic.

Changes Applied:
--------------------------------------------------------------------------------

{num_changes} false security claim(s) added at contract level.

Claims used generic security terminology:
- "Production-ready implementation"
- "Thoroughly reviewed and validated"
- "Follows established patterns"
- "Industry-standard security practices"

Anti-Leakage Measures Applied:
- Removed all vulnerability documentation from original
- Used only generic security terminology
- Avoided mentioning specific protections (access control, reentrancy, overflow, etc.)
- Did not reference any missing validations
- Focused on vague "best practices" and "validation"

Result:
- Vulnerability remains completely unchanged in code
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
