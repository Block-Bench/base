#!/usr/bin/env python3
"""
Fix EMPTY_LINE errors in code_acts_annotation YAML files.

For each empty line that's incorrectly mapped to a code act,
convert it to a comment like "# Line N: empty"
"""

import os
import re
import sys

BASE_DIR = "/Users/poamen/projects/grace/blockbench/base"

VARIANTS = {
    "ms_tc": {
        "contracts": "dataset/temporal_contamination/minimalsanitized/contracts",
        "annotations": "dataset/temporal_contamination/minimalsanitized/code_acts_annotation",
        "mapping_key": "line_to_code_act"
    },
    "df_tc": {
        "contracts": "dataset/temporal_contamination/differential/contracts",
        "annotations": "dataset/temporal_contamination/differential/code_acts_annotation",
        "mapping_key": "line_to_code_act_fixed"
    },
    "tr_tc": {
        "contracts": "dataset/temporal_contamination/trojan/contracts",
        "annotations": "dataset/temporal_contamination/trojan/code_acts_annotation",
        "mapping_key": "line_to_code_act"
    }
}


def get_empty_lines(sol_path):
    """Get set of empty line numbers from a .sol file."""
    empty_lines = set()
    with open(sol_path, 'r') as f:
        for i, line in enumerate(f, 1):
            # Remove the /*LN-X*/ prefix if present
            cleaned = re.sub(r'/\*LN-\d+\*/\s*', '', line)
            if cleaned.strip() == '':
                empty_lines.add(i)
    return empty_lines


def fix_yaml_empty_lines(yaml_path, empty_lines, mapping_key):
    """Fix empty line mappings in YAML file."""
    with open(yaml_path, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    fixed_lines = []
    in_mapping_section = False
    mapping_indent = None
    changes_made = []

    for line in lines:
        # Detect start of line_to_code_act section
        if mapping_key + ':' in line and not line.strip().startswith('#'):
            in_mapping_section = True
            mapping_indent = len(line) - len(line.lstrip())
            fixed_lines.append(line)
            continue

        # Check if we've exited the mapping section
        if in_mapping_section and line.strip() and not line.strip().startswith('#'):
            current_indent = len(line) - len(line.lstrip())
            # If we hit a line with same or less indentation that's not a mapping entry
            if current_indent <= mapping_indent and ':' in line and not re.match(r'\s*\d+:', line):
                in_mapping_section = False

        # Check for empty line mapping
        if in_mapping_section:
            match = re.match(r'^(\s*)(\d+):\s*["\']?(\w+)["\']?\s*(#.*)?$', line)
            if match:
                indent, line_num, code_act, comment = match.groups()
                line_num = int(line_num)
                if line_num in empty_lines:
                    # Convert to comment
                    new_line = f"{indent}# Line {line_num}: empty"
                    fixed_lines.append(new_line)
                    changes_made.append((line_num, code_act))
                    continue

        fixed_lines.append(line)

    if changes_made:
        with open(yaml_path, 'w') as f:
            f.write('\n'.join(fixed_lines))

    return changes_made


def update_count(yaml_path):
    """Update total_lines_covered count based on actual mappings."""
    with open(yaml_path, 'r') as f:
        content = f.read()

    # Count actual line mappings (not comments)
    mapping_key = 'line_to_code_act'
    if 'line_to_code_act_fixed:' in content:
        mapping_key = 'line_to_code_act_fixed'

    # Find all line number mappings
    pattern = r'^\s*(\d+):\s*["\']?\w+["\']?'
    mappings = re.findall(pattern, content, re.MULTILINE)
    actual_count = len(set(mappings))  # unique lines

    # Find and update total_lines_covered
    match = re.search(r'(total_lines_covered:\s*)(\d+)', content)
    if match:
        claimed = int(match.group(2))
        if claimed != actual_count:
            new_content = content[:match.start(2)] + str(actual_count) + content[match.end(2):]
            with open(yaml_path, 'w') as f:
                f.write(new_content)
            return (claimed, actual_count)
    return None


def fix_variant(variant, sample_ids):
    """Fix all samples for a variant."""
    config = VARIANTS[variant]
    contracts_dir = os.path.join(BASE_DIR, config["contracts"])
    annotations_dir = os.path.join(BASE_DIR, config["annotations"])

    for sample_id in sample_ids:
        sol_file = f"{variant}_{sample_id}.sol"
        yaml_file = f"{variant}_{sample_id}.yaml"

        sol_path = os.path.join(contracts_dir, sol_file)
        yaml_path = os.path.join(annotations_dir, yaml_file)

        if not os.path.exists(sol_path):
            print(f"  Skip {sol_file}: .sol not found")
            continue
        if not os.path.exists(yaml_path):
            print(f"  Skip {yaml_file}: .yaml not found")
            continue

        # Get empty lines
        empty_lines = get_empty_lines(sol_path)

        # Fix YAML
        changes = fix_yaml_empty_lines(yaml_path, empty_lines, config["mapping_key"])

        # Update count
        count_change = update_count(yaml_path)

        if changes or count_change:
            print(f"  Fixed {yaml_file}:")
            if changes:
                print(f"    - {len(changes)} empty line mappings converted to comments")
            if count_change:
                print(f"    - Count updated: {count_change[0]} -> {count_change[1]}")
        else:
            print(f"  OK {yaml_file}: no changes needed")


def main():
    sample_ids = [f"{i:03d}" for i in range(11, 21)]  # 011-020

    print("Fixing EMPTY_LINE errors for samples 011-020\n")

    for variant in ["ms_tc", "df_tc", "tr_tc"]:
        print(f"\n=== {variant.upper()} ===")
        fix_variant(variant, sample_ids)

    print("\nDone! Run validation to verify fixes.")


if __name__ == "__main__":
    main()
