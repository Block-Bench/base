#!/usr/bin/env python3
"""
Line Marker Utility for Strategy Outputs

Adds stable line reference markers (/*LN-N*/) to Solidity code.
These markers provide consistent line references across different versions
of the same contract, independent of display line numbers.

Usage:
    from strategies.common.line_markers import add_line_markers

    marked_code = add_line_markers(code)

The markers use format /*LN-N*/ where N is an integer (1-indexed).
The "LN-" prefix reduces collision probability with existing comments.
"""

from pathlib import Path


def add_line_markers(code: str) -> str:
    """
    Add line markers to each line of code.

    Format: /*LN-N*/ where N is the line number (1-indexed).
    This provides stable line references that don't depend on display line numbers.

    Args:
        code: The Solidity source code

    Returns:
        Code with /*LN-N*/ markers prepended to each line

    Example:
        Input:
            pragma solidity ^0.8.0;

            contract Foo {

        Output:
            /*LN-1*/ pragma solidity ^0.8.0;
            /*LN-2*/
            /*LN-3*/ contract Foo {
    """
    lines = code.split('\n')
    marked_lines = []

    for i, line in enumerate(lines, start=1):
        marker = f'/*LN-{i}*/ '
        marked_lines.append(marker + line)

    return '\n'.join(marked_lines)


def add_line_markers_to_file(input_path: Path, output_path: Path = None) -> int:
    """
    Add line markers to a Solidity file.

    Args:
        input_path: Path to input .sol file
        output_path: Path for output (defaults to overwriting input)

    Returns:
        Number of lines processed
    """
    if output_path is None:
        output_path = input_path

    code = input_path.read_text()
    marked_code = add_line_markers(code)
    output_path.write_text(marked_code)

    return len(code.split('\n'))


def add_line_markers_to_directory(contracts_dir: Path) -> dict:
    """
    Add line markers to all .sol files in a directory.

    Args:
        contracts_dir: Path to directory containing .sol files

    Returns:
        Dict mapping filename to line count
    """
    results = {}

    for sol_file in sorted(contracts_dir.glob("*.sol")):
        line_count = add_line_markers_to_file(sol_file)
        results[sol_file.name] = line_count
        print(f"  {sol_file.name}: {line_count} lines marked")

    return results


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python line_markers.py <contracts_directory>")
        print("       python line_markers.py <file.sol>")
        sys.exit(1)

    path = Path(sys.argv[1])

    if path.is_dir():
        print(f"Adding line markers to all .sol files in {path}")
        results = add_line_markers_to_directory(path)
        print(f"\nProcessed {len(results)} files")
    elif path.is_file() and path.suffix == '.sol':
        print(f"Adding line markers to {path}")
        count = add_line_markers_to_file(path)
        print(f"Processed {count} lines")
    else:
        print(f"Error: {path} is not a directory or .sol file")
        sys.exit(1)
