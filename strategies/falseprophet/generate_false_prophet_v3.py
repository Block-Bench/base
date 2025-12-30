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


def extract_line_marker(line: str) -> tuple[str, str]:
    """Extract line marker and content from a line."""
    match = re.match(r'(/\*LN-\d+\*/\s*)(.*)', line)
    if match:
        return match.group(1), match.group(2)
    return "", line


def has_vulnerability_keywords(text: str) -> bool:
    """Check if text contains vulnerability-related keywords."""
    vuln_keywords = [
        'vulnerability', 'exploit', 'attack', 'root cause', 'vulnerable',
        'attack vector', 'attack scenario', 'security advisory', 'warning:',
        'demonstrates the', 'this demonstrates', 'hack', 'malicious',
        'loss:', 'funds lost', 'million', 'critical', 'severity',
        'reentrancy', 'reenter', 'overflow', 'underflow', 'compromised',
        'attacker', 'stolen', 'drained', 'forged', 'fake withdrawal',
        'checks-effects-interactions', 'textbook', 'too late',
        'flash loan', 'drain', 'fix:', 'mitigation'
    ]

    text_lower = text.lower()
    return any(kw in text_lower for kw in vuln_keywords)


def remove_vulnerability_docs(content: str) -> str:
    """Remove all vulnerability documentation while preserving line markers."""

    lines = content.split('\n')
    cleaned = []
    i = 0

    while i < len(lines):
        line = lines[i]
        marker, line_content = extract_line_marker(line)

        # Check for start of multi-line comment
        if '/**' in line_content or '/*' in line_content:
            # Collect entire comment block
            block_start = i
            block_lines = []

            while i < len(lines):
                curr_line = lines[i]
                block_lines.append(curr_line)
                if '*/' in curr_line:
                    break
                i += 1

            # Check if block contains vulnerability content
            block_text = '\n'.join(block_lines)

            if has_vulnerability_keywords(block_text):
                # Skip this entire block
                i += 1
                continue
            else:
                # Keep the block
                cleaned.extend(block_lines)
                i += 1
                continue

        # Check single-line comments
        if '//' in line_content and has_vulnerability_keywords(line_content):
            i += 1
            continue

        # Keep the line
        cleaned.append(line)
        i += 1

    return '\n'.join(cleaned)


def add_false_claims(content: str, contract_num: int) -> tuple[str, int]:
    """Add misleading security claims at contract level."""

    changes = 0

    # Find actual contract declaration (not in comments)
    lines = content.split('\n')

    for i, line in enumerate(lines):
        # Skip if line is a comment
        marker, line_content = extract_line_marker(line)

        # Look for contract declaration
        contract_match = re.match(r'\s*contract\s+(\w+)', line_content)
        if contract_match:
            contract_name = contract_match.group(1)

            # Add false header before this line
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
            changes += 1
            break

    return '\n'.join(lines), changes


def generate_false_prophet(num: int) -> tuple[str, str]:
    """Generate False Prophet variant for a contract."""

    num_str = f"{num:03d}"
    original_path = ORIGINAL_DIR / f"tc_{num_str}.sol"

    if not original_path.exists():
        return None, None

    # Read and clean
    content = original_path.read_text()
    content = remove_vulnerability_docs(content)
    content, num_changes = add_false_claims(content, num)

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
