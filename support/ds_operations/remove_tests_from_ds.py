#!/usr/bin/env python3
"""
Remove Test Framework Elements from Difficulty Stratified Dataset

This script removes Foundry/Forge test framework elements from Solidity files:
1. Removes `import "forge-std/..."` lines
2. Removes entire contracts whose names end with "Test" (e.g., ContractTest)
3. For other contracts that inherit from Test/DSTest:
   - Removes Test/DSTest from inheritance list
   - Removes setUp() and testXxx() functions
   - Removes vm.* calls and console.log statements
4. Keeps the vulnerable contract code intact

Usage:
    python remove_tests_from_ds.py [--dry-run] [--verbose]
"""

import os
import re
import argparse
from pathlib import Path
from typing import Tuple, List, Optional


def find_matching_brace(content: str, start_pos: int) -> int:
    """
    Find the position of the closing brace that matches the opening brace at start_pos.
    Returns -1 if no matching brace is found.
    """
    if start_pos >= len(content) or content[start_pos] != '{':
        return -1

    depth = 0
    in_string = False
    string_char = None
    i = start_pos

    while i < len(content):
        char = content[i]

        # Handle escape sequences in strings
        if in_string and char == '\\' and i + 1 < len(content):
            i += 2
            continue

        # Handle string literals
        if char in ['"', "'"] and not in_string:
            in_string = True
            string_char = char
        elif char == string_char and in_string:
            in_string = False
            string_char = None

        # Handle comments (only when not in string)
        if not in_string:
            # Single line comment
            if i < len(content) - 1 and content[i:i+2] == '//':
                newline = content.find('\n', i)
                if newline == -1:
                    i = len(content)
                else:
                    i = newline + 1
                continue

            # Multi-line comment
            if i < len(content) - 1 and content[i:i+2] == '/*':
                end_comment = content.find('*/', i + 2)
                if end_comment == -1:
                    i = len(content)
                else:
                    i = end_comment + 2
                continue

        # Count braces (only when not in string)
        if not in_string:
            if char == '{':
                depth += 1
            elif char == '}':
                depth -= 1
                if depth == 0:
                    return i

        i += 1

    return -1


def remove_forge_imports(content: str) -> Tuple[str, int]:
    """
    Remove forge-std import statements.
    Returns the modified content and count of removed imports.
    """
    patterns = [
        r'^import\s+"forge-std/[^"]+"\s*;?\s*\n?',
        r'^import\s+\'forge-std/[^\']+\'\s*;?\s*\n?',
        r'^import\s+\{[^}]*\}\s+from\s+"forge-std/[^"]+"\s*;?\s*\n?',
    ]

    count = 0
    for pattern in patterns:
        matches = re.findall(pattern, content, re.MULTILINE)
        count += len(matches)
        content = re.sub(pattern, '', content, flags=re.MULTILINE)

    return content, count


def is_test_contract_name(name: str) -> bool:
    """
    Check if a contract name indicates it's a pure test contract.
    """
    # Names that end with Test or are clearly test harnesses
    test_patterns = [
        r'.*Test$',           # ContractTest, SomeTest
        r'.*Tests$',          # ContractTests
        r'.*Exploit$',        # SomeExploit
        r'.*ExploitTest$',    # SomeExploitTest
        r'.*Attack$',         # SomeAttack (attacker contracts)
        r'.*Attacker$',       # SomeAttacker
        r'.*Operator$',       # FailedOperator, EtherStoreOperator (test helpers)
    ]

    for pattern in test_patterns:
        if re.match(pattern, name):
            return True
    return False


def find_contracts_with_test_inheritance(content: str) -> List[dict]:
    """
    Find all contracts that inherit from Test or DSTest.
    Returns list of dicts with contract info.
    """
    # Pattern to find contract declarations with inheritance
    pattern = r'contract\s+(\w+)\s+is\s+([^{]+)\{'

    contracts = []

    for match in re.finditer(pattern, content):
        contract_name = match.group(1)
        inheritance = match.group(2).strip()

        # Parse inheritance list
        inheritance_parts = [p.strip() for p in inheritance.split(',')]

        # Check if Test or DSTest is in the inheritance list
        has_test = False
        test_index = -1
        for i, part in enumerate(inheritance_parts):
            # Match Test or DSTest (possibly with whitespace)
            if re.match(r'^(Test|DSTest)\s*$', part):
                has_test = True
                test_index = i
                break

        if has_test:
            # Find the opening and closing braces
            brace_pos = match.end() - 1
            end_pos = find_matching_brace(content, brace_pos)

            if end_pos != -1:
                contracts.append({
                    'name': contract_name,
                    'start': match.start(),
                    'end': end_pos + 1,
                    'inheritance': inheritance_parts,
                    'test_index': test_index,
                    'brace_start': brace_pos,
                    'is_pure_test': is_test_contract_name(contract_name),
                    'match': match
                })

    return contracts


def remove_test_from_inheritance(content: str, contract: dict) -> str:
    """
    Remove Test/DSTest from a contract's inheritance list.
    """
    inheritance = contract['inheritance']
    test_index = contract['test_index']

    # Remove Test/DSTest from inheritance list
    new_inheritance = [p for i, p in enumerate(inheritance) if i != test_index]

    # Replace in the original match
    match = contract['match']

    if not new_inheritance:
        # No inheritance left - remove the "is" clause entirely
        new_text = f"contract {contract['name']} {{"
    else:
        # Build new inheritance string
        new_inheritance_str = ', '.join(new_inheritance)
        new_text = f"contract {contract['name']} is {new_inheritance_str} {{"

    # Replace the contract declaration
    content = content[:match.start()] + new_text + content[match.end():]

    return content


def remove_function_from_contract(content: str, contract_start: int, contract_end: int,
                                   func_pattern: str) -> Tuple[str, int]:
    """
    Remove functions matching the pattern from within a contract.
    Returns modified content and count of removed functions.
    """
    contract_body = content[contract_start:contract_end]

    # Find functions matching the pattern
    pattern = rf'function\s+{func_pattern}\s*\([^)]*\)[^{{]*\{{'

    removed = 0
    offset = 0

    for match in re.finditer(pattern, contract_body):
        # Adjust for previous removals
        adjusted_start = contract_start + match.start() - offset

        # Find the opening brace in the full content
        brace_search_start = adjusted_start + match.end() - match.start() - 1
        brace_pos = content.rfind('{', adjusted_start, brace_search_start + 1)

        if brace_pos == -1:
            continue

        # Find matching closing brace
        end_pos = find_matching_brace(content, brace_pos)

        if end_pos == -1:
            continue

        # Find the start of the function (including any preceding whitespace/comments)
        func_start = adjusted_start
        while func_start > 0 and content[func_start - 1] in ' \t':
            func_start -= 1
        if func_start > 0 and content[func_start - 1] == '\n':
            func_start -= 1

        # Include trailing newline
        func_end = end_pos + 1
        while func_end < len(content) and content[func_end] in ' \t\n':
            func_end += 1

        # Remove the function
        removed_len = func_end - func_start
        content = content[:func_start] + content[func_end:]
        offset += removed_len
        removed += 1

        # Update contract_end
        contract_end -= removed_len

    return content, removed


def remove_vm_and_console_calls(content: str, start: int, end: int) -> str:
    """
    Remove vm.* and console.* calls from a section of code.
    """
    section = content[start:end]

    # Remove lines with vm.* calls
    section = re.sub(r'^[^\n]*\bvm\.[^\n]+\n?', '', section, flags=re.MULTILINE)

    # Remove lines with console.* calls
    section = re.sub(r'^[^\n]*\bconsole\d*\.[^\n]+\n?', '', section, flags=re.MULTILINE)

    return content[:start] + section + content[end:]


def remove_console_log_statements(content: str) -> str:
    """
    Remove all console.log/console.logXxx statements including multi-line ones.
    Handles cases like:
        console.log(
            "message",
            value
        );
    """
    result = []
    lines = content.split('\n')
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Check if this line starts a console.log/emit log_named call
        if re.match(r'^console\d*\.\w+\s*\(', stripped) or re.match(r'^emit\s+log_named', stripped):
            # Check if it ends on the same line
            if stripped.endswith(';'):
                i += 1
                continue

            # Multi-line - find the closing );
            paren_depth = stripped.count('(') - stripped.count(')')
            i += 1
            while i < len(lines) and paren_depth > 0:
                next_line = lines[i]
                paren_depth += next_line.count('(') - next_line.count(')')
                i += 1
            continue

        # Check for orphaned string literals (leftover from partial console.log removal)
        # Pattern: just a string literal possibly followed by comma and another value
        if re.match(r'^\s*"[^"]*"\s*,?\s*$', line) or re.match(r'^\s*"[^"]*",\s*$', line):
            # Check if previous non-empty line ends with '(' or ','
            # and next non-empty line is just ');' or similar
            prev_idx = len(result) - 1
            while prev_idx >= 0 and not result[prev_idx].strip():
                prev_idx -= 1

            # Check next line
            next_idx = i + 1
            while next_idx < len(lines) and not lines[next_idx].strip():
                next_idx += 1

            if next_idx < len(lines):
                next_stripped = lines[next_idx].strip()
                # If next is closing paren with value, skip both
                if re.match(r'^[^)]*\);?\s*$', next_stripped) and not re.match(r'^\w', next_stripped):
                    i += 1
                    continue

            # If this looks like an orphaned argument, skip it
            if re.match(r'^\s+"[^"]*"\s*$', line) or re.match(r'^\s+"[^"]*",\s*$', line):
                # Check if next line also looks orphaned or is just );
                if next_idx < len(lines):
                    next_stripped = lines[next_idx].strip()
                    if next_stripped in [');', ')'] or re.match(r'^[a-zA-Z_]\w*\s*\);?$', next_stripped):
                        i += 1
                        continue

        result.append(line)
        i += 1

    return '\n'.join(result)


def process_contracts(content: str) -> Tuple[str, List[str], List[str]]:
    """
    Process all contracts with Test inheritance.
    Returns modified content, list of removed contracts, list of cleaned contracts.
    """
    contracts = find_contracts_with_test_inheritance(content)

    # Sort by position (reverse order to process from end to start)
    contracts.sort(key=lambda c: c['start'], reverse=True)

    removed_contracts = []
    cleaned_contracts = []

    for contract in contracts:
        if contract['is_pure_test']:
            # Remove the entire contract
            start = contract['start']
            end = contract['end']

            # Include preceding whitespace
            while start > 0 and content[start - 1] in ' \t\n':
                start -= 1

            # Include trailing whitespace
            while end < len(content) and content[end] in ' \t\n':
                end += 1

            content = content[:start] + '\n' + content[end:]
            removed_contracts.append(contract['name'])
        else:
            # This is a vulnerable contract with Test mixin
            # 1. Remove Test from inheritance
            content = remove_test_from_inheritance(content, contract)

            # Recalculate contract boundaries after inheritance change
            # (the contract should be at roughly the same position)
            new_contracts = find_contracts_with_test_inheritance(content)
            # The contract we just modified won't have Test inheritance anymore

            # Find the contract again by name (may or may not have inheritance now)
            pattern = rf'contract\s+{re.escape(contract["name"])}\s+(?:is\s+[^{{]+)?\{{'
            match = re.search(pattern, content)

            if match:
                brace_pos = match.end() - 1
                end_pos = find_matching_brace(content, brace_pos)

                if end_pos != -1:
                    # 2. Remove setUp function
                    content, _ = remove_function_from_contract(
                        content, match.start(), end_pos + 1, 'setUp'
                    )

                    # Recalculate end position
                    match = re.search(pattern, content)
                    if match:
                        brace_pos = match.end() - 1
                        end_pos = find_matching_brace(content, brace_pos)

                        if end_pos != -1:
                            # 3. Remove testXxx functions
                            content, _ = remove_function_from_contract(
                                content, match.start(), end_pos + 1, r'test\w+'
                            )

                            # 4. Remove vm.* and console.* calls
                            match = re.search(pattern, content)
                            if match:
                                brace_pos = match.end() - 1
                                end_pos = find_matching_brace(content, brace_pos)
                                if end_pos != -1:
                                    content = remove_vm_and_console_calls(
                                        content, match.start(), end_pos + 1
                                    )

            cleaned_contracts.append(contract['name'])

    return content, removed_contracts, cleaned_contracts


def clean_empty_lines(content: str) -> str:
    """
    Clean up excessive empty lines (more than 2 consecutive).
    """
    # Replace 3+ consecutive newlines with 2 newlines
    while '\n\n\n' in content:
        content = content.replace('\n\n\n', '\n\n')

    # Remove leading/trailing whitespace but keep one trailing newline
    content = content.strip() + '\n'

    return content


def process_file(filepath: Path, dry_run: bool = False, verbose: bool = False) -> dict:
    """
    Process a single Solidity file.
    Returns a dict with processing statistics.
    """
    stats = {
        'file': str(filepath),
        'imports_removed': 0,
        'contracts_removed': [],
        'contracts_cleaned': [],
        'modified': False,
        'error': None
    }

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            original_content = f.read()

        content = original_content

        # Remove forge-std imports
        content, import_count = remove_forge_imports(content)
        stats['imports_removed'] = import_count

        # Process contracts
        content, removed, cleaned = process_contracts(content)
        stats['contracts_removed'] = removed
        stats['contracts_cleaned'] = cleaned

        # Global pass: remove any remaining vm.* and console.* calls
        content = re.sub(r'^[^\n]*\bvm\.[^\n]+\n?', '', content, flags=re.MULTILINE)
        content = re.sub(r'^[^\n]*\bconsole\d*\.[^\n]+\n?', '', content, flags=re.MULTILINE)

        # Additional pass: remove multi-line console.log and orphaned string literals
        content = remove_console_log_statements(content)

        # Clean up empty lines
        content = clean_empty_lines(content)

        # Check if content changed
        if content != original_content:
            stats['modified'] = True

            if not dry_run:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

        if verbose and stats['modified']:
            print(f"  {filepath.name}:")
            if stats['imports_removed'] > 0:
                print(f"    - Removed {stats['imports_removed']} forge-std import(s)")
            if stats['contracts_removed']:
                print(f"    - Removed contracts: {', '.join(stats['contracts_removed'])}")
            if stats['contracts_cleaned']:
                print(f"    - Cleaned contracts (kept but removed Test): {', '.join(stats['contracts_cleaned'])}")

    except Exception as e:
        stats['error'] = str(e)
        if verbose:
            print(f"  ERROR processing {filepath}: {e}")
            import traceback
            traceback.print_exc()

    return stats


def process_directory(base_dir: Path, dry_run: bool = False, verbose: bool = False) -> dict:
    """
    Process all .sol files in the directory tree.
    """
    summary = {
        'total_files': 0,
        'modified_files': 0,
        'total_imports_removed': 0,
        'total_contracts_removed': 0,
        'total_contracts_cleaned': 0,
        'errors': 0,
        'files': []
    }

    for sol_file in sorted(base_dir.rglob('*.sol')):
        summary['total_files'] += 1

        stats = process_file(sol_file, dry_run, verbose)
        summary['files'].append(stats)

        if stats['modified']:
            summary['modified_files'] += 1
        if stats['imports_removed'] > 0:
            summary['total_imports_removed'] += stats['imports_removed']
        if stats['contracts_removed']:
            summary['total_contracts_removed'] += len(stats['contracts_removed'])
        if stats['contracts_cleaned']:
            summary['total_contracts_cleaned'] += len(stats['contracts_cleaned'])
        if stats['error']:
            summary['errors'] += 1

    return summary


def main():
    parser = argparse.ArgumentParser(
        description='Remove test framework elements from difficulty stratified dataset'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be changed without modifying files'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show detailed output for each file'
    )
    parser.add_argument(
        '--dir',
        type=str,
        default=None,
        help='Directory to process (default: dataset/difficulty_stratified)'
    )

    args = parser.parse_args()

    # Determine base directory
    script_dir = Path(__file__).parent
    base_dir = script_dir.parent.parent / 'dataset' / 'difficulty_stratified'

    if args.dir:
        base_dir = Path(args.dir)

    if not base_dir.exists():
        print(f"Error: Directory not found: {base_dir}")
        return 1

    print(f"{'[DRY RUN] ' if args.dry_run else ''}Processing: {base_dir}")
    print("=" * 60)

    # Process only the cleaned directory (not original)
    # The cleaned directory is what we use for evaluation
    target_dir = base_dir / 'cleaned'

    if not target_dir.exists():
        print(f"Error: Cleaned directory not found: {target_dir}")
        return 1

    print(f"\nProcessing cleaned/...")
    summary = process_directory(target_dir, args.dry_run, args.verbose)

    print(f"\n  Summary:")
    print(f"    Total files scanned: {summary['total_files']}")
    print(f"    Files modified: {summary['modified_files']}")
    print(f"    Imports removed: {summary['total_imports_removed']}")
    print(f"    Test contracts removed: {summary['total_contracts_removed']}")
    print(f"    Contracts cleaned (Test inheritance removed): {summary['total_contracts_cleaned']}")
    if summary['errors'] > 0:
        print(f"    Errors: {summary['errors']}")

    print("\n" + "=" * 60)
    if args.dry_run:
        print("DRY RUN complete. No files were modified.")
    else:
        print("Processing complete.")

    return 0


if __name__ == '__main__':
    exit(main())
