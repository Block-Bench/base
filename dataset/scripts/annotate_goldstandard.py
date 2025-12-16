#!/usr/bin/env python3
"""
Create annotated versions of Gold Standard contracts.

Adds vulnerability headers and inline comments to contracts in data/annotated/contracts/.
The base contracts remain clean without annotations.
"""

import json
import re
from pathlib import Path


# Paths
BASE_DIR = Path(__file__).parent.parent.parent
GOLD_STANDARD_DIR = BASE_DIR / "labelled_data" / "gold_standard"
DATA_ANNOTATED_DIR = BASE_DIR / "data" / "annotated"


def load_metadata(gs_id: str) -> dict:
    """Load metadata for a gold standard item."""
    metadata_path = GOLD_STANDARD_DIR / "metadata" / f"{gs_id}.json"
    with open(metadata_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def create_header_comment(meta: dict) -> str:
    """Create a header comment block with vulnerability information."""
    lines = [
        "/**",
        f" * @title {meta.get('finding_title', 'Vulnerable Contract')}",
        f" * @notice VULNERABLE CONTRACT - Gold Standard Benchmark Item {meta['id']}",
        f" * @dev Source: {meta.get('source_platform', 'unknown').upper()} - {meta.get('source_report', '')}",
        " *",
        " * VULNERABILITY INFORMATION:",
        f" * - Type: {meta.get('vulnerability_type', 'unknown')}",
        f" * - Severity: {meta.get('severity', 'unknown').upper()}",
        f" * - Finding ID: {meta.get('source_finding_id', 'N/A')}",
        " *",
        " * DESCRIPTION:",
    ]

    # Wrap description
    desc = meta.get('finding_description', '')
    if desc:
        # Split into ~80 char lines
        words = desc.split()
        current_line = " *"
        for word in words:
            if len(current_line) + len(word) + 1 > 85:
                lines.append(current_line)
                current_line = " * " + word
            else:
                current_line += " " + word
        if current_line.strip() != "*":
            lines.append(current_line)

    lines.append(" *")
    lines.append(" * VULNERABLE FUNCTIONS:")
    for func in meta.get('vulnerable_functions', []):
        lines.append(f" * - {func}()")

    lines.append(" *")
    lines.append(" * VULNERABLE LINES:")
    vuln_lines = meta.get('vulnerable_lines', [])
    if vuln_lines:
        lines.append(f" * - Lines: {', '.join(map(str, vuln_lines[:10]))}" +
                    (f"... (+{len(vuln_lines)-10} more)" if len(vuln_lines) > 10 else ""))

    # Add attack scenario if present
    attack = meta.get('attack_scenario', '')
    if attack and len(attack) < 500:
        lines.append(" *")
        lines.append(" * ATTACK SCENARIO:")
        attack_lines = attack.split('\n')
        for al in attack_lines[:5]:
            if al.strip():
                lines.append(f" * {al.strip()[:80]}")

    # Add fix description
    fix = meta.get('fix_description', '')
    if fix:
        lines.append(" *")
        lines.append(" * RECOMMENDED FIX:")
        fix_words = fix.split()[:50]  # First 50 words
        current_line = " *"
        for word in fix_words:
            if len(current_line) + len(word) + 1 > 85:
                lines.append(current_line)
                current_line = " * " + word
            else:
                current_line += " " + word
        if current_line.strip() != "*":
            lines.append(current_line)
        if len(fix.split()) > 50:
            lines.append(" * ...")

    lines.append(" */")
    lines.append("")

    return "\n".join(lines)


def add_inline_comments(content: str, meta: dict) -> str:
    """Add inline vulnerability comments at vulnerable lines."""
    vulnerable_lines = set(meta.get('vulnerable_lines', []))
    vulnerable_functions = meta.get('vulnerable_functions', [])

    if not vulnerable_lines:
        return content

    lines = content.split('\n')
    result = []

    # Track if we've added function-level comment
    added_function_comment = set()

    for i, line in enumerate(lines):
        line_num = i + 1

        # Check if this line contains a vulnerable function definition
        for func in vulnerable_functions:
            if f"function {func}" in line and func not in added_function_comment:
                result.append(f"    // @audit-issue VULNERABLE FUNCTION: {func}")
                added_function_comment.add(func)
                break

        result.append(line)

        # Add comment after vulnerable lines (not before, to preserve line numbers)
        if line_num in vulnerable_lines:
            # Only add if the line has actual code (not empty/comment)
            stripped = line.strip()
            if stripped and not stripped.startswith('//') and not stripped.startswith('/*') and not stripped.startswith('*'):
                indent = len(line) - len(line.lstrip())
                result.append(' ' * indent + '// ^^^ VULNERABLE LINE ^^^')

    return '\n'.join(result)


def annotate_contract(gs_id: str, meta: dict):
    """Create annotated version of a contract."""
    # Read original contract
    src_path = GOLD_STANDARD_DIR / "contracts" / f"{gs_id}.sol"
    with open(src_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Create header comment
    header = create_header_comment(meta)

    # Find where to insert header (after SPDX and pragma)
    lines = content.split('\n')
    insert_idx = 0

    for i, line in enumerate(lines):
        if line.strip().startswith('// SPDX') or line.strip().startswith('pragma'):
            insert_idx = i + 1
        elif line.strip() and not line.strip().startswith('//'):
            break

    # Insert header
    lines.insert(insert_idx, '')
    lines.insert(insert_idx + 1, header)

    content = '\n'.join(lines)

    # Add inline comments at vulnerable lines
    content = add_inline_comments(content, meta)

    # Write annotated contract
    dst_path = DATA_ANNOTATED_DIR / "contracts" / f"{gs_id}.sol"
    with open(dst_path, 'w', encoding='utf-8') as f:
        f.write(content)


def main():
    print("=" * 60)
    print("Annotate Gold Standard Contracts")
    print("=" * 60)

    # Load index
    index_path = GOLD_STANDARD_DIR / "index.json"
    with open(index_path, 'r', encoding='utf-8') as f:
        index = json.load(f)

    items = index['items']
    print(f"\nAnnotating {len(items)} contracts...")

    for item in items:
        gs_id = item['id']
        print(f"  {gs_id}...", end=' ')

        meta = load_metadata(gs_id)
        annotate_contract(gs_id, meta)

        print("done")

    print("\n" + "=" * 60)
    print("Annotation Complete!")
    print("=" * 60)
    print(f"Annotated {len(items)} contracts in {DATA_ANNOTATED_DIR / 'contracts'}")


if __name__ == "__main__":
    main()
