#!/usr/bin/env python3
"""
Generate False Prophet variants - clean two-pass approach.
Pass 1: Remove vulnerability docs
Pass 2: Add false security claims
"""

import re
from pathlib import Path
from datetime import datetime

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
ORIGINAL_DIR = BASE_DIR / "dataset/temporal_contamination/original/contracts"
OUTPUT_DIR = BASE_DIR / "support/rough/final/decoy/falseProphet"

# Generic security claims
CONTRACT_CLAIMS = [
    "Implements industry-standard security practices and validation techniques",
    "Contract follows best practices for production-grade smart contract development",
    "Comprehensive testing and validation performed during development lifecycle",
    "Built with security-first approach using established design patterns",
    "Production-ready implementation with multiple layers of validation",
]


def has_vuln_keywords(text: str) -> bool:
    """Check if text contains vulnerability keywords."""
    keywords = [
        'vulnerability', 'vulnerable', 'exploit', 'attack', 'hack',
        'malicious', 'root cause', 'attack vector', 'reentrancy',
        'compromised', 'attacker', 'stolen', 'drained', 'demonstrates the',
        'loss:', 'million', 'drain', 'fix:', 'forged', 'fake',
        'too late', 'textbook', 'checks-effects-interactions',
        'warning:', 'security advisory', 'critical', 'severity',
    ]
    text_lower = text.lower()
    # Check for dollar amounts which indicate losses
    if re.search(r'\$\d+', text):
        return True
    return any(kw in text_lower for kw in keywords)


def remove_vuln_docs(content: str) -> str:
    """Remove all vulnerability documentation."""
    lines = content.split('\n')
    cleaned = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Check if this is a comment block start
        # Extract content after line marker
        content_match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        line_content = content_match.group(2) if content_match else line

        # Detect multi-line comment start
        if '/**' in line_content or (('/*' in line_content) and ('*/' not in line_content)):
            # Collect entire comment block
            block_start = i
            block_lines = []

            while i < len(lines):
                block_lines.append(lines[i])
                if '*/' in lines[i]:
                    break
                i += 1

            # Check if block contains vulnerability keywords
            block_text = '\n'.join(block_lines)
            if has_vuln_keywords(block_text):
                # Skip this block
                i += 1
                continue
            else:
                # Keep this block
                cleaned.extend(block_lines)
                i += 1
                continue

        # Check single-line comments
        if '//' in line_content:
            if has_vuln_keywords(line_content):
                i += 1
                continue

        cleaned.append(line)
        i += 1

    return '\n'.join(cleaned)


def add_security_header(content: str, contract_num: int) -> tuple[str, int]:
    """Add false security header before contract declaration."""
    lines = content.split('\n')

    # Find first contract declaration (not in comments)
    for i, line in enumerate(lines):
        # Extract content after line marker
        content_match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        line_content = content_match.group(2) if content_match else line

        # Look for contract declaration
        contract_match = re.match(r'\s*contract\s+(\w+)', line_content)
        if contract_match:
            contract_name = contract_match.group(1)

            # Create header
            claim = CONTRACT_CLAIMS[contract_num % len(CONTRACT_CLAIMS)]
            header = f"""/**
 * @title {contract_name}
 * @notice Production-ready smart contract implementation
 * @dev {claim}
 * @dev Thoroughly reviewed and validated for secure operation
 */
"""
            # Insert header before contract line
            lines.insert(i, header)
            return '\n'.join(lines), 1

    # If no contract found, return unchanged
    return '\n'.join(lines), 0


def generate_false_prophet(num: int) -> tuple[str, str]:
    """Generate False Prophet variant."""

    num_str = f"{num:03d}"
    original_path = ORIGINAL_DIR / f"tc_{num_str}.sol"

    if not original_path.exists():
        return None, None

    # Read original
    content = original_path.read_text()

    # Pass 1: Remove vulnerability documentation
    content = remove_vuln_docs(content)

    # Pass 2: Add false security claims
    content, num_changes = add_security_header(content, num)

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
