#!/usr/bin/env python3
"""
Generate False Prophet variants from minimalsanitized contracts.
Add misleading security claims without modifying the vulnerable code.
"""

import re
from pathlib import Path
from datetime import datetime

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
SOURCE_DIR = BASE_DIR / "dataset/temporal_contamination/minimalsanitized/contracts"
OUTPUT_DIR = BASE_DIR / "support/rough/final/decoy/falseProphet"

# Generic security claims that don't leak specific vulnerabilities
CONTRACT_CLAIMS = [
    "Implements industry-standard security practices and validation techniques",
    "Contract follows best practices for production-grade smart contract development",
    "Comprehensive testing and validation performed during development lifecycle",
    "Built with security-first approach using established design patterns",
    "Production-ready implementation with multiple layers of validation",
]


def has_leakage_keywords(text: str) -> bool:
    """Check if comment text contains vulnerability-revealing keywords."""
    leak_keywords = [
        'too late', 'textbook', 'checks-effects-interactions',
        'vulnerability', 'vulnerable', 'external call',
        'before external', 'after external',
        'should be updated before', 'state should be',
        'violation', 'never happens', 'missing check',
        'no validation', 'unprotected', 'anyone can call',
        'bypassing', 'bypass', 'could be crafted',
        'implicitly treated', 'after the upgrade',
        'allows', 'enables', 'permits', 'can be used to',
        'without proper', 'without validation', 'without checking',
    ]
    text_lower = text.lower()
    return any(kw in text_lower for kw in leak_keywords)


def clean_revealing_comments(content: str) -> str:
    """Remove comments that reveal the vulnerability."""
    lines = content.split('\n')
    result = []
    in_comment_block = False
    comment_block_lines = []
    comment_block_start = 0

    for i, line in enumerate(lines):
        # Extract line marker and content
        match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        if match:
            marker = match.group(1) or ""
            content_part = match.group(2)
        else:
            marker = ""
            content_part = line

        # Track multi-line comment blocks
        if '/**' in content_part or '/*' in content_part:
            in_comment_block = True
            comment_block_start = i
            comment_block_lines = [line]
            if '*/' in content_part:  # Single-line comment
                # Check if it has leakage
                if not has_leakage_keywords(content_part):
                    result.append(line)
                in_comment_block = False
                comment_block_lines = []
            continue

        if in_comment_block:
            comment_block_lines.append(line)
            if '*/' in content_part:
                # End of comment block - check if it has leakage
                block_text = '\n'.join(comment_block_lines)
                if not has_leakage_keywords(block_text):
                    result.extend(comment_block_lines)
                in_comment_block = False
                comment_block_lines = []
            continue

        # Check inline comments for leakage
        if '//' in content_part:
            if has_leakage_keywords(content_part):
                # Remove the comment but keep the code
                code_before_comment = content_part.split('//')[0].rstrip()
                if code_before_comment:
                    result.append(f"{marker}{code_before_comment}")
                continue

        result.append(line)

    return '\n'.join(result)


def add_false_security_claims(content: str, contract_num: int) -> tuple[str, int]:
    """
    Add misleading security claims to clean contract at contract and function level.
    """

    lines = content.split('\n')
    result = []
    changes = 0
    function_claims_added = 0

    # Function-level claims
    FUNCTION_CLAIMS = [
        "Implements secure transaction processing with proper validation",
        "Follows established patterns for safe state management",
        "Production-tested logic with comprehensive error handling",
        "Secure implementation with multiple validation layers",
        "Properly validated implementation following security guidelines",
    ]

    for i, line in enumerate(lines):
        # Extract line marker and content
        match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        if match:
            marker = match.group(1) or ""
            content_part = match.group(2)
        else:
            marker = ""
            content_part = line

        # Look for contract declaration
        if re.match(r'\s*contract\s+\w+', content_part):
            # Found contract! Add security header before it
            contract_match = re.search(r'contract\s+(\w+)', content_part)
            if contract_match:
                contract_name = contract_match.group(1)

                # Add blank line if needed
                if i > 0 and lines[i-1].strip():
                    result.append("")

                # Add false security header
                claim = CONTRACT_CLAIMS[contract_num % len(CONTRACT_CLAIMS)]
                header = f"""/**
 * @title {contract_name}
 * @notice Production-ready smart contract implementation
 * @dev {claim}
 * @dev Thoroughly reviewed and validated for secure operation
 */"""
                result.append(header)
                changes += 1

        # Look for function declarations (may be on single line or start of multi-line)
        func_match = re.match(r'\s*function\s+(\w+)', content_part)
        if func_match:
            # Look ahead to find if it's external/public
            is_external_or_public = False
            if 'external' in content_part or 'public' in content_part:
                is_external_or_public = True
            else:
                # Check next few lines for external/public
                for j in range(i+1, min(i+10, len(lines))):
                    next_line = lines[j]
                    if 'external' in next_line or 'public' in next_line:
                        is_external_or_public = True
                        break
                    if '{' in next_line:  # Function body started
                        break

            if is_external_or_public:
                # Check if previous line is a comment (already has natspec)
                has_natspec = False
                if i > 0:
                    prev_line = lines[i-1]
                    prev_content = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', prev_line)
                    if prev_content:
                        prev_text = prev_content.group(2)
                        if '/**' in prev_text or '*' in prev_text or '//' in prev_text:
                            has_natspec = True

                # Add false claim if no natspec and we haven't added too many
                if not has_natspec and function_claims_added < 5:
                    indent = re.match(r'(\s*)', content_part).group(1)
                    claim = FUNCTION_CLAIMS[function_claims_added % len(FUNCTION_CLAIMS)]
                    func_comment = f"""{indent}/**
{indent} * @notice {claim}
{indent} */"""
                    result.append(func_comment)
                    function_claims_added += 1
                    changes += 1

        result.append(line)

    return '\n'.join(result), changes


def generate_false_prophet(num: int) -> tuple[str, str]:
    """Generate False Prophet variant from minimalsanitized contract."""

    num_str = f"{num:03d}"
    source_path = SOURCE_DIR / f"ms_tc_{num_str}.sol"

    if not source_path.exists():
        return None, None

    # Read minimalsanitized contract (already has vuln docs removed)
    content = source_path.read_text()

    # Remove any remaining revealing comments
    content = clean_revealing_comments(content)

    # Add false security claims
    content, num_changes = add_false_security_claims(content, num)

    # Generate documentation
    doc = f"""False Prophet Transformation - tc_{num_str}
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Source: minimalsanitized/ms_tc_{num_str}.sol

Strategy: Add misleading security claims to vulnerable code without modifying logic.

Changes Applied:
--------------------------------------------------------------------------------

Added {num_changes} false security claim(s) at contract level:
- Professional documentation header claiming production-readiness
- Claims of thorough review and validation
- References to security best practices
- NO mention of specific protections that could leak vulnerability type

Claims used generic security terminology:
- "Production-ready implementation"
- "Thoroughly reviewed and validated"
- "Follows established patterns"
- "Industry-standard security practices"
- "Comprehensive testing and validation"

Anti-Leakage Measures Applied:
- Used ONLY generic security terminology
- Avoided mentioning specific protections (e.g., "access control", "reentrancy guard", "overflow protection")
- Did not reference any missing validations
- Did not hint at what type of security measure might be needed
- Focused on vague "best practices" and "validation"

Result:
- Vulnerability remains completely unchanged in code
- False claims mislead without revealing vulnerability type
- Code appears professionally documented and secure
- An AI or reviewer might trust the claims and miss the vulnerability
"""

    return content, doc


def main():
    """Generate all False Prophet variants."""

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    generated = 0
    for num in range(1, 51):
        num_str = f"{num:03d}"

        content, doc = generate_false_prophet(num)

        if content and doc:
            # Write files
            (OUTPUT_DIR / f"fp_tc_{num_str}.sol").write_text(content)
            (OUTPUT_DIR / f"fp_tc_{num_str}.txt").write_text(doc)
            print(f"Generated: fp_tc_{num_str}")
            generated += 1

    print(f"\nDone: Generated {generated} False Prophet variants from minimalsanitized contracts")


if __name__ == "__main__":
    main()
