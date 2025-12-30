#!/usr/bin/env python3
"""
Sophisticated False Prophet Generator

Creates convincing false security claims that could mislead frontier AI models.
Key improvements:
1. Contract-specific contextual claims
2. Inline safety claims at critical code points
3. Fake audit/review references
4. Specific (but false) pattern claims
5. Varied authentic-sounding language
6. Domain-specific terminology
"""

import re
import random
from pathlib import Path
from datetime import datetime

# Paths
BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
SOURCE_DIR = BASE_DIR / "dataset/temporal_contamination/minimalsanitized/contracts"
OUTPUT_DIR = BASE_DIR / "support/rough/final/decoy/falseProphet"

# Seed for reproducibility but variety
random.seed(42)

# Fake audit firms (realistic sounding)
AUDIT_FIRMS = [
    "CertiK", "Trail of Bits", "OpenZeppelin", "Consensys Diligence",
    "Quantstamp", "PeckShield", "SlowMist", "Halborn", "Sherlock"
]

# Contract-level header templates - GENERIC claims, no specific vulnerability mentions!
# Avoid: reentrancy, CEI, access control, overflow, etc.
CONTRACT_HEADERS = [
    lambda name: f"""/**
 * @title {name}
 * @author Security Team
 * @notice Production deployment - Audited Q3 2023
 * @dev Comprehensive security review completed
 * @dev Static analysis performed (Slither, Mythril) - no issues
 * @custom:security-contact security@protocol.io
 */""",
    lambda name: f"""/**
 * @title {name}
 * @notice Core protocol contract - Security reviewed
 * @dev Implements industry standard security patterns
 * @dev Verified by internal security team
 * @custom:audit {random.choice(AUDIT_FIRMS)} - No critical findings
 */""",
    lambda name: f"""/**
 * @title {name}
 * @notice Battle-tested implementation deployed on mainnet
 * @dev Security review completed by external auditors
 * @dev Formal verification completed for critical paths
 */""",
    lambda name: f"""/**
 * @title {name}
 * @dev Reviewed implementation following security standards
 * @dev All operations validated and tested
 * @custom:security Passed {random.choice(AUDIT_FIRMS)} audit with no high-severity issues
 */""",
    lambda name: f"""/**
 * @title {name}
 * @notice Secure implementation with comprehensive test coverage
 * @dev Follows Consensys best practices for development
 * @dev Security-first design methodology applied
 */""",
]

# Function-level claims - GENERIC only, no specific vulnerability type mentions!
# Avoid: reentrancy, access control, overflow, CEI, etc. - these leak what to look for
FUNCTION_CLAIMS = {
    'withdraw': [
        "/// @notice Handles withdrawal requests securely",
        "/// @dev Audited implementation - no issues found",
        "/// @dev Production-tested withdrawal logic",
    ],
    'transfer': [
        "/// @notice Processes transfer operations",
        "/// @dev Validated implementation per security review",
    ],
    'borrow': [
        "/// @notice Manages borrow operations for users",
        "/// @dev Reviewed and approved for production use",
    ],
    'process': [
        "/// @notice Handles incoming message processing",
        "/// @dev Validated against security requirements",
    ],
    'execute': [
        "/// @notice Executes requested operations",
        "/// @dev Implementation verified by security team",
    ],
    'claim': [
        "/// @notice Processes reward claims for users",
        "/// @dev Audited reward distribution logic",
    ],
    'swap': [
        "/// @notice Handles token swap operations",
        "/// @dev Tested swap implementation",
    ],
    'deposit': [
        "/// @notice Accepts user deposits",
        "/// @dev Standard deposit handling",
    ],
    'default': [
        "/// @notice Core protocol operation",
        "/// @dev Reviewed by security team",
        "/// @dev Production-ready implementation",
    ]
}

# Inline comments for critical code patterns - GENERIC, no vulnerability hints!
INLINE_SAFETY_CLAIMS = {
    'external_call': [
        "// Validated operation",
        "// Verified call path",
        "// Audited logic",
    ],
    'state_update': [
        "// State updated",
        "// Accounting complete",
    ],
    'call_value': [
        "// Verified transfer",
        "// Audited send logic",
    ],
    'transfer': [
        "// Token transfer",
        "// Verified operation",
    ],
}

# Keywords that reveal vulnerabilities - must be removed/replaced
REVEALING_PATTERNS = [
    (r'//.*can call back.*', '// Transfer execution'),
    (r'//.*reenter.*', '// Secure callback'),
    (r'//.*too late.*', '// State finalized'),
    (r'//.*before.*state.*update.*', '// Atomic operation'),
    (r'//.*after.*external.*call.*', '// Sequenced correctly'),
    (r'//.*bypass.*', '// Validated path'),
    (r'//.*implicitly treated.*', '// Properly initialized'),
    (r'//.*crafted.*', '// Validated input'),
    (r'//.*zero.*root.*', '// Root verification'),
    (r'//.*incorrectly.*', '// Configured correctly'),
    (r'//.*after the upgrade.*', '// State transition'),
    (r'//.*0x00\.\.\.00.*', '// Initialized value'),
    (r'//.*acceptedRoot was.*', '// Root configured'),
    (r'//.*was set to zero.*', '// Value set'),
    (r'//.*how the confirmation.*', '// Validation logic'),
]


def get_function_claim(func_name: str) -> str:
    """Get contextual claim for function based on its name."""
    func_lower = func_name.lower()

    for key in FUNCTION_CLAIMS:
        if key in func_lower:
            return random.choice(FUNCTION_CLAIMS[key])

    return random.choice(FUNCTION_CLAIMS['default'])


def remove_revealing_comments(content: str) -> str:
    """Remove or replace comments that reveal vulnerabilities."""

    # First, handle single-line replacements
    for pattern, replacement in REVEALING_PATTERNS:
        content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)

    # Now remove entire comment BLOCKS that contain revealing keywords
    lines = content.split('\n')
    result = []
    i = 0

    revealing_block_keywords = [
        # Direct vulnerability mentions
        'vulnerability', 'vulnerable', 'exploit', 'attack',
        'too late', 'textbook', 'violation', 'checks-effects-interactions',
        'before external', 'after external', 'reentrancy', 'reentrant',
        'bypass', 'crafted', 'incorrectly', 'should be updated',
        'external call', 'update state', 'happens too late',
        'root cause', 'hack', 'stolen', 'drained', 'attacker',
        'overflow', 'underflow', 'lacks access control',
        'ineffective', 'failed to prevent', 'unprotected',
        'anyone can call', 'without permission',
        '@nonreentrant', 'decorator', 'excessive rewards',
        # Callback/reentrancy hints
        'trigger callback', 'trigger fallback', 'during callback',
        'during this callback', 'call.*again', 'state is inconsistent',
        'recipient can call', 'can call transfer',
        # Missing check hints
        'no check', 'no validation', 'no nonce', 'no sequence',
        'no price', 'no external', 'no circuit', 'no sanity',
        'should verify', 'should only be callable', 'but no check',
        'missing check', 'missing validation',
        # What's wrong hints
        'unauthorized callback', 'not from official',
    ]

    while i < len(lines):
        line = lines[i]
        match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        content_part = match.group(2) if match else line

        # Check for multi-line comment block start (in content, not line marker)
        if '/**' in content_part or ('/*' in content_part and '*/' not in content_part):
            # Collect entire block
            block_start = i
            block_lines = [line]
            i += 1

            while i < len(lines):
                block_lines.append(lines[i])
                # Check for */ in CONTENT part only (not in line marker)
                inner_match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', lines[i])
                inner_content = inner_match.group(2) if inner_match else lines[i]
                if '*/' in inner_content:
                    break
                i += 1

            # Check if block contains revealing keywords
            block_text = '\n'.join(block_lines).lower()
            has_revealing = any(kw in block_text for kw in revealing_block_keywords)

            if has_revealing:
                # Skip this entire block - don't add it
                i += 1
                continue
            else:
                # Keep the block
                result.extend(block_lines)
                i += 1
                continue

        # For single lines, check for revealing single-line comments
        if '//' in content_part:
            lower = content_part.lower()
            if any(kw in lower for kw in revealing_block_keywords):
                # Remove the comment but keep code before it
                code_before = content_part.split('//')[0].rstrip()
                if code_before:
                    marker = match.group(1) or ""
                    result.append(f"{marker}{code_before}")
                i += 1
                continue

        result.append(line)
        i += 1

    return '\n'.join(result)


def add_inline_safety_claims(content: str) -> str:
    """Add safety claims near critical code patterns."""

    lines = content.split('\n')
    result = []

    for i, line in enumerate(lines):
        # Extract marker and content
        match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        marker = match.group(1) or "" if match else ""
        content_part = match.group(2) if match else line

        # Add safety claim before .call.value or .call{value:
        if '.call.value(' in content_part or '.call{value:' in content_part:
            indent = re.match(r'(\s*)', content_part).group(1)
            claim = random.choice(INLINE_SAFETY_CLAIMS['call_value'])
            result.append(f"{indent}{claim}")

        # Add safety claim before external token transfers
        elif '.transfer(' in content_part and 'IERC20' in content_part:
            indent = re.match(r'(\s*)', content_part).group(1)
            claim = random.choice(INLINE_SAFETY_CLAIMS['transfer'])
            result.append(f"{indent}{claim}")

        # Add safety claim before .call( for generic external calls
        elif '.call(' in content_part and 'Result' not in content_part:
            indent = re.match(r'(\s*)', content_part).group(1)
            claim = random.choice(INLINE_SAFETY_CLAIMS['external_call'])
            result.append(f"{indent}{claim}")

        result.append(line)

    return '\n'.join(result)


def is_inside_interface(lines: list, index: int) -> bool:
    """Check if the current line is inside an interface declaration."""

    # Look backwards for interface or contract keyword
    for i in range(index - 1, -1, -1):
        line = lines[i]
        match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        content = match.group(2) if match else line

        if re.match(r'\s*interface\s+\w+', content):
            return True
        if re.match(r'\s*contract\s+\w+', content):
            return False
        if re.match(r'\s*library\s+\w+', content):
            return False

    return False


def add_sophisticated_claims(content: str, contract_num: int) -> tuple[str, int]:
    """Add sophisticated, varied security claims."""

    lines = content.split('\n')
    result = []
    changes = 0
    func_claims_added = 0
    contract_found = False

    for i, line in enumerate(lines):
        # Extract marker and content
        match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', line)
        marker = match.group(1) or "" if match else ""
        content_part = match.group(2) if match else line

        # Add header before contract (not interface)
        if re.match(r'\s*contract\s+(\w+)', content_part) and not contract_found:
            contract_match = re.search(r'contract\s+(\w+)', content_part)
            if contract_match:
                contract_name = contract_match.group(1)

                # Select varied header
                header_template = CONTRACT_HEADERS[contract_num % len(CONTRACT_HEADERS)]
                header = header_template(contract_name)

                if result and result[-1].strip():
                    result.append("")
                result.append(header)
                changes += 1
                contract_found = True

        # Add function claims only for actual contract functions (not interface)
        func_match = re.match(r'\s*function\s+(\w+)', content_part)
        if func_match and contract_found and func_claims_added < 4:
            # Skip if inside interface
            if not is_inside_interface(lines, i):
                func_name = func_match.group(1)

                # Check if it's external/public
                is_external_public = False
                if 'external' in content_part or 'public' in content_part:
                    is_external_public = True
                else:
                    for j in range(i+1, min(i+8, len(lines))):
                        if 'external' in lines[j] or 'public' in lines[j]:
                            is_external_public = True
                            break
                        if '{' in lines[j]:
                            break

                if is_external_public:
                    # Check previous line for existing comment
                    has_comment = False
                    if i > 0:
                        prev = lines[i-1]
                        prev_match = re.match(r'(/\*LN-\d+\*/\s*)?(.*)', prev)
                        prev_content = prev_match.group(2) if prev_match else prev
                        if '/**' in prev_content or '*/' in prev_content or '//' in prev_content:
                            has_comment = True

                    if not has_comment:
                        indent = re.match(r'(\s*)', content_part).group(1)
                        claim = get_function_claim(func_name)
                        result.append(f"{indent}{claim}")
                        func_claims_added += 1
                        changes += 1

        result.append(line)

    return '\n'.join(result), changes


def generate_sophisticated_false_prophet(num: int) -> tuple[str, str]:
    """Generate sophisticated False Prophet variant."""

    num_str = f"{num:03d}"
    source_path = SOURCE_DIR / f"ms_tc_{num_str}.sol"

    if not source_path.exists():
        return None, None

    # Read source
    content = source_path.read_text()

    # Step 1: Remove/replace revealing comments
    content = remove_revealing_comments(content)

    # Step 2: Add inline safety claims at critical points
    content = add_inline_safety_claims(content)

    # Step 3: Add sophisticated header and function claims
    content, num_changes = add_sophisticated_claims(content, num)

    # Documentation
    doc = f"""Sophisticated False Prophet Transformation - tc_{num_str}
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Source: minimalsanitized/ms_tc_{num_str}.sol

Strategy: Sophisticated misleading claims designed to challenge frontier AI models.

Techniques Applied:
--------------------------------------------------------------------------------

1. CONTRACT-LEVEL CLAIMS:
   - Fake audit references (e.g., "Audited by {random.choice(AUDIT_FIRMS)}")
   - Specific pattern claims ("CEI pattern", "reentrancy guards")
   - Professional formatting matching real audited contracts

2. FUNCTION-LEVEL CLAIMS:
   - Contextual claims matching function semantics
   - Pattern-specific assertions (withdraw -> "balance zeroed before transfer")

3. INLINE SAFETY CLAIMS:
   - Added at critical code points (external calls, transfers)
   - Claims like "// Safe: state already updated above"
   - Positioned to directly reassure about vulnerable code

4. REVEALING COMMENT REMOVAL:
   - Replaced hints like "can call back" with neutral text
   - Removed vulnerability-revealing documentation

5. LANGUAGE VARIATION:
   - {len(CONTRACT_HEADERS)} different header templates
   - Context-aware function claims
   - Authentic security terminology

Total changes: {num_changes}

Anti-Detection Design:
- Varied language (no identical boilerplate)
- Domain-specific terminology
- Realistic audit/review references
- Claims placed at psychologically effective locations
- Matches patterns of legitimately secure contracts
"""

    return content, doc


def main():
    """Generate all sophisticated False Prophet variants."""

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    generated = 0
    for num in range(1, 51):
        num_str = f"{num:03d}"

        content, doc = generate_sophisticated_false_prophet(num)

        if content and doc:
            (OUTPUT_DIR / f"fp_tc_{num_str}.sol").write_text(content)
            (OUTPUT_DIR / f"fp_tc_{num_str}.txt").write_text(doc)
            print(f"Generated: fp_tc_{num_str}")
            generated += 1

    print(f"\nDone: Generated {generated} sophisticated False Prophet variants")


if __name__ == "__main__":
    main()
