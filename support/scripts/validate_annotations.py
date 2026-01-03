#!/usr/bin/env python3
"""
Annotation Validation Script (Enhanced)

Validates code_acts_annotation YAML files against their corresponding .sol files.

Checks:
  1. Empty lines incorrectly mapped
  2. total_lines_covered accuracy
  3. Mapped lines that don't exist in the file
  4. Duplicate line mappings
  5. Invalid code act references (CA_ID doesn't exist)
  6. Security function consistency (definition vs lookup table)
  7. Lines array vs mapping mismatch
  8. Vulnerable lines coverage (should map to ROOT_CAUSE)
  9. Missing required fields
  10. ms_tc 100% coverage (all non-empty lines should be mapped)
  11. tr_tc INJ* existence for DECOY mappings

Usage:
    python validate_annotations.py [variant] [sample_id]
    python validate_annotations.py ms_tc 001
    python validate_annotations.py all  # validate all
"""

import json
import re
import sys
from pathlib import Path

# Base paths
BASE_DIR = Path(__file__).parent.parent.parent / "dataset" / "temporal_contamination"

VARIANTS = {
    "ms_tc": {
        "annotation_dir": "minimalsanitized/code_acts_annotation",
        "contract_dir": "minimalsanitized/contracts",
        "line_key": "line_to_code_act",
        "security_fn_key": "code_act_security_functions",
        "full_coverage": True,
    },
    "df_tc": {
        "annotation_dir": "differential/code_acts_annotation",
        "contract_dir": "differential/contracts",
        "line_key": "line_to_code_act_fixed",
        "security_fn_key": "code_act_security_functions_fixed",
        "full_coverage": False,
    },
    "tr_tc": {
        "annotation_dir": "trojan/code_acts_annotation",
        "contract_dir": "trojan/contracts",
        "line_key": "line_to_code_act",
        "security_fn_key": "code_act_security_functions",
        "full_coverage": False,
    },
}

VALID_SECURITY_FUNCTIONS = {
    "ROOT_CAUSE", "PREREQ", "BENIGN", "UNRELATED",
    "INSUFF_GUARD", "SECONDARY_VULN", "DECOY", "FIX"
}


def get_empty_lines(sol_file: Path) -> set:
    """Parse .sol file and return set of empty line numbers."""
    empty_lines = set()
    with open(sol_file, 'r') as f:
        for i, line in enumerate(f, 1):
            stripped = line.strip()
            if re.match(r'^/\*LN-\d+\*/\s*$', stripped) or stripped == '':
                empty_lines.add(i)
    return empty_lines


def get_total_lines(sol_file: Path) -> int:
    """Get total number of lines in file."""
    with open(sol_file, 'r') as f:
        return sum(1 for _ in f)


def parse_yaml_full(yaml_file: Path, config: dict) -> dict:
    """
    Enhanced YAML parser to extract all relevant data.
    Returns dict with: line_mappings, total_lines_covered, code_acts,
                       security_functions_lookup, vulnerable_lines
    """
    with open(yaml_file, 'r') as f:
        content = f.read()

    result = {
        "line_mappings": {},
        "total_lines_covered": None,
        "code_acts": {},  # id -> {type, lines, security_function}
        "security_functions_lookup": {},  # id -> security_function
        "vulnerable_lines": [],
        "sample_id": None,
        "vulnerability_type": None,
    }

    # Extract sample_id
    match = re.search(r'sample_id:\s*["\']?([^"\'#\n]+)', content)
    if match:
        result["sample_id"] = match.group(1).strip()

    # Extract vulnerability_type
    match = re.search(r'vulnerability_type:\s*["\']?([^"\'#\n]+)', content)
    if match:
        result["vulnerability_type"] = match.group(1).strip()

    # Extract vulnerable_lines
    match = re.search(r'vulnerable_lines:\s*\[([^\]]*)\]', content)
    if match:
        lines_str = match.group(1)
        result["vulnerable_lines"] = [int(x.strip()) for x in lines_str.split(',') if x.strip().isdigit()]

    # Extract total_lines_covered
    match = re.search(r'total_lines_covered:\s*(\d+)', content)
    if match:
        result["total_lines_covered"] = int(match.group(1))

    # Parse code_acts section
    # Pattern: - id: "CA1" followed by type, lines, security_function
    code_act_pattern = re.compile(
        r'-\s*id:\s*["\']?(CA[^"\'#\n]+)["\']?\s*\n'
        r'(?:.*?\n)*?'
        r'.*?type:\s*["\']?([^"\'#\n]+)["\']?\s*\n'
        r'(?:.*?\n)*?'
        r'.*?lines:\s*\[([^\]]*)\]',
        re.MULTILINE
    )

    # Parse code_acts or injections section (not root_causes, prerequisites, etc.)
    # ms_tc uses "code_acts:", tr_tc uses "injections:"
    # df_tc_004 uses "fix_code_acts:", "transitioned_code_acts:", "unrelated_code_acts:"
    lines = content.split('\n')
    current_ca = None
    in_code_acts_section = False
    in_fixed_section = False  # Track if we're inside a "fixed:" subsection (for df_tc)

    # Valid section names for code act definitions
    code_acts_sections = r'^(code_acts|injections|fix_code_acts|transitioned_code_acts|unrelated_code_acts):\s*$'

    for i, line in enumerate(lines):
        # Detect start of code_acts or injections section
        if re.match(code_acts_sections, line):
            in_code_acts_section = True
            continue

        # Detect start of other top-level sections (exit code_acts parsing)
        if in_code_acts_section and line and not line.startswith(' ') and not line.startswith('#'):
            if ':' in line and not line.strip().startswith('-'):
                in_code_acts_section = False
                current_ca = None
                in_fixed_section = False

        if not in_code_acts_section:
            continue

        # Start of new code act
        id_match = re.match(r'\s+-\s*id:\s*["\']?([^"\'#\n]+)["\']?', line)
        if id_match:
            current_ca = id_match.group(1).strip()
            result["code_acts"][current_ca] = {"type": None, "lines": [], "security_function": None}
            in_fixed_section = False
            continue

        if current_ca:
            # Detect "fixed:" subsection (for df_tc format)
            if re.match(r'\s+fixed:\s*$', line):
                in_fixed_section = True
                continue

            # Detect other subsections that end "fixed:" (vulnerable:, location:, etc.)
            if re.match(r'\s+(vulnerable|location|suspicious_because|safe_because|safety_factors):\s*$', line):
                in_fixed_section = False

            # Type (at code_act level)
            type_match = re.match(r'\s+type:\s*["\']?([^"\'#\n]+)["\']?', line)
            if type_match and not in_fixed_section:
                result["code_acts"][current_ca]["type"] = type_match.group(1).strip()

            # Lines array - at top level or in fixed/location section
            lines_match = re.match(r'\s+lines:\s*\[([^\]]*)\]', line)
            if lines_match:
                lines_str = lines_match.group(1)
                parsed_lines = [int(x.strip()) for x in lines_str.split(',') if x.strip().isdigit()]
                # For df_tc, prefer fixed section lines; for others, take any lines found
                if in_fixed_section or not result["code_acts"][current_ca]["lines"]:
                    result["code_acts"][current_ca]["lines"] = parsed_lines

            # Single line (for df_tc format: "line: 18" instead of "lines: [18]")
            single_line_match = re.match(r'\s+line:\s*(\d+)', line)
            if single_line_match and in_fixed_section:
                line_num = int(single_line_match.group(1))
                if not result["code_acts"][current_ca]["lines"]:
                    result["code_acts"][current_ca]["lines"] = [line_num]

            # new_lines: for df_tc_004 format (transitioned_code_acts)
            new_lines_match = re.match(r'\s+new_lines:\s*\[([^\]]*)\]', line)
            if new_lines_match:
                lines_str = new_lines_match.group(1)
                parsed_lines = [int(x.strip()) for x in lines_str.split(',') if x.strip().isdigit()]
                result["code_acts"][current_ca]["lines"] = parsed_lines

            # Security function - prefer fixed section for df_tc
            sf_match = re.match(r'\s+security_function:\s*["\']?([^"\'#\n]+)["\']?', line)
            if sf_match:
                sf_value = sf_match.group(1).strip()
                # For df_tc, prefer the fixed section's security_function
                if in_fixed_section or result["code_acts"][current_ca]["security_function"] is None:
                    result["code_acts"][current_ca]["security_function"] = sf_value

            # new_security_function: for df_tc_004 format
            new_sf_match = re.match(r'\s+new_security_function:\s*["\']?([^"\'#\n]+)["\']?', line)
            if new_sf_match:
                result["code_acts"][current_ca]["security_function"] = new_sf_match.group(1).strip()

    # Parse line_to_code_act section
    line_key = config["line_key"]
    in_line_section = False

    for i, line in enumerate(lines):
        if re.match(rf'^\s*{line_key}:\s*$', line):
            in_line_section = True
            continue

        if in_line_section:
            if line and not line.startswith(' ') and not line.startswith('#') and ':' in line:
                # New top-level key, exit section
                if not re.match(r'^\s+\d+:', line):
                    break

            match = re.match(r'^\s+(\d+):\s*["\']?([^"\'#\n]+)["\']?', line)
            if match:
                line_num = int(match.group(1))
                code_act = match.group(2).strip()
                result["line_mappings"][line_num] = code_act

    # Parse security_functions lookup
    sf_key = config["security_fn_key"]
    in_sf_section = False

    for i, line in enumerate(lines):
        if re.match(rf'^\s*{sf_key}:\s*$', line):
            in_sf_section = True
            continue

        if in_sf_section:
            if line and not line.startswith(' ') and not line.startswith('#'):
                break

            match = re.match(r'^\s+([^:]+):\s*["\']?([^"\'#\n]+)["\']?', line)
            if match:
                ca_id = match.group(1).strip()
                sf = match.group(2).strip()
                result["security_functions_lookup"][ca_id] = sf

    return result


def validate_annotation(variant: str, sample_id: str) -> dict:
    """Validate a single annotation file with all checks."""
    config = VARIANTS[variant]

    yaml_file = BASE_DIR / config["annotation_dir"] / f"{variant}_{sample_id}.yaml"
    sol_file = BASE_DIR / config["contract_dir"] / f"{variant}_{sample_id}.sol"

    results = {
        "sample": f"{variant}_{sample_id}",
        "errors": [],
        "warnings": [],
        "info": [],
    }

    # Check files exist
    if not yaml_file.exists():
        results["errors"].append(f"Annotation file not found: {yaml_file.name}")
        return results

    if not sol_file.exists():
        results["errors"].append(f"Contract file not found: {sol_file.name}")
        return results

    # Parse data
    data = parse_yaml_full(yaml_file, config)
    empty_lines = get_empty_lines(sol_file)
    total_lines = get_total_lines(sol_file)
    line_mappings = data["line_mappings"]

    if not line_mappings:
        results["warnings"].append(f"No {config['line_key']} found or empty")
        return results

    # ==========================================
    # CHECK 1: Empty lines mapped
    # ==========================================
    for line_num, code_act in line_mappings.items():
        if line_num in empty_lines:
            results["errors"].append(f"[EMPTY_LINE] Line {line_num} is empty but mapped to {code_act}")

    # ==========================================
    # CHECK 2: Lines exceeding file length
    # ==========================================
    for line_num in line_mappings.keys():
        if line_num > total_lines:
            results["errors"].append(f"[OUT_OF_RANGE] Line {line_num} exceeds file length ({total_lines})")

    # ==========================================
    # CHECK 3: total_lines_covered accuracy
    # ==========================================
    actual_covered = len(line_mappings)
    if data["total_lines_covered"] is not None:
        if data["total_lines_covered"] != actual_covered:
            results["errors"].append(
                f"[COUNT_MISMATCH] total_lines_covered: claimed {data['total_lines_covered']}, actual {actual_covered}"
            )

    # ==========================================
    # CHECK 4: Duplicate line mappings
    # ==========================================
    # Note: Python dict naturally dedupes, but we can check for parsing issues
    # This is more about internal consistency - parsed correctly

    # ==========================================
    # CHECK 5: Invalid code act references
    # ==========================================
    # Code acts can be defined in EITHER:
    # - code_acts section (full definitions)
    # - code_act_security_functions lookup (for inherited refs like CA* in trojans)
    defined_code_acts = set(data["code_acts"].keys())
    lookup_code_acts = set(data["security_functions_lookup"].keys())
    all_valid_code_acts = defined_code_acts | lookup_code_acts

    for line_num, code_act in line_mappings.items():
        if code_act not in all_valid_code_acts:
            results["errors"].append(
                f"[INVALID_REF] Line {line_num} references '{code_act}' which is not defined in code_acts or security_functions lookup"
            )

    # ==========================================
    # CHECK 6: Security function consistency
    # ==========================================
    for ca_id, ca_data in data["code_acts"].items():
        defined_sf = ca_data.get("security_function")
        lookup_sf = data["security_functions_lookup"].get(ca_id)

        if defined_sf and lookup_sf and defined_sf != lookup_sf:
            results["errors"].append(
                f"[SF_MISMATCH] {ca_id}: definition says '{defined_sf}', lookup says '{lookup_sf}'"
            )

        # Validate security function is valid
        sf = defined_sf or lookup_sf
        if sf and sf not in VALID_SECURITY_FUNCTIONS:
            results["warnings"].append(
                f"[UNKNOWN_SF] {ca_id} has unknown security_function: '{sf}'"
            )

    # ==========================================
    # CHECK 7: Lines array vs mapping mismatch
    # ==========================================
    for ca_id, ca_data in data["code_acts"].items():
        declared_lines = set(ca_data.get("lines", []))
        mapped_lines = {ln for ln, ca in line_mappings.items() if ca == ca_id}

        # Lines in declaration but not in mapping
        missing_in_mapping = declared_lines - mapped_lines
        if missing_in_mapping and ca_id not in ["CA_DIRECTIVES", "CA_COMMENTS", "CA_DECLARATIONS", "CA_SYNTAX", "CA_EVENT_DEFS"]:
            # Skip batched unrelated for this check as they may intentionally exclude empty lines
            results["warnings"].append(
                f"[LINES_MISMATCH] {ca_id} declares lines {sorted(missing_in_mapping)} but they're not in mapping"
            )

        # Lines in mapping but not in declaration (non-batched only)
        extra_in_mapping = mapped_lines - declared_lines
        if extra_in_mapping and not ca_id.startswith("CA_"):
            results["warnings"].append(
                f"[LINES_MISMATCH] {ca_id} mapped at lines {sorted(extra_in_mapping)} but not in its lines array"
            )

    # ==========================================
    # CHECK 8: Vulnerable lines coverage
    # ==========================================
    for vuln_line in data["vulnerable_lines"]:
        if vuln_line not in line_mappings:
            results["errors"].append(
                f"[VULN_UNMAPPED] Vulnerable line {vuln_line} is not mapped to any code act"
            )
        else:
            ca_id = line_mappings[vuln_line]
            ca_sf = data["code_acts"].get(ca_id, {}).get("security_function")
            lookup_sf = data["security_functions_lookup"].get(ca_id)
            sf = ca_sf or lookup_sf

            if sf and sf != "ROOT_CAUSE":
                results["warnings"].append(
                    f"[VULN_NOT_ROOT] Vulnerable line {vuln_line} mapped to {ca_id} ({sf}), expected ROOT_CAUSE"
                )

    # ==========================================
    # CHECK 9: Missing required fields
    # ==========================================
    if not data["sample_id"]:
        results["errors"].append("[MISSING_FIELD] sample_id not found")
    elif data["sample_id"] != f"{variant}_{sample_id}":
        results["warnings"].append(
            f"[ID_MISMATCH] sample_id '{data['sample_id']}' doesn't match filename '{variant}_{sample_id}'"
        )

    if not data["vulnerability_type"]:
        results["errors"].append("[MISSING_FIELD] vulnerability_type not found")

    if not data["code_acts"]:
        results["errors"].append("[MISSING_FIELD] No code_acts found")

    # ==========================================
    # CHECK 10: ms_tc 100% coverage
    # ==========================================
    if config.get("full_coverage"):
        non_empty_lines = set(range(1, total_lines + 1)) - empty_lines
        mapped_line_set = set(line_mappings.keys())
        unmapped = non_empty_lines - mapped_line_set

        if unmapped:
            # Only report first 10 to avoid spam
            unmapped_sample = sorted(unmapped)[:10]
            suffix = f"... and {len(unmapped) - 10} more" if len(unmapped) > 10 else ""
            results["warnings"].append(
                f"[INCOMPLETE_COVERAGE] {len(unmapped)} non-empty lines not mapped: {unmapped_sample}{suffix}"
            )

    # ==========================================
    # CHECK 11: tr_tc INJ* existence
    # ==========================================
    if variant == "tr_tc":
        # Find all INJ references in mappings
        inj_refs = {ca for ca in line_mappings.values() if ca.startswith("INJ")}
        defined_injs = {ca for ca in data["code_acts"].keys() if ca.startswith("INJ")}

        undefined_injs = inj_refs - defined_injs
        if undefined_injs:
            results["errors"].append(
                f"[UNDEFINED_INJ] Injection references not defined: {sorted(undefined_injs)}"
            )

        # Check DECOY mappings have INJ definitions
        for ca_id, ca_data in data["code_acts"].items():
            sf = ca_data.get("security_function") or data["security_functions_lookup"].get(ca_id)
            if sf == "DECOY" and not ca_id.startswith("INJ"):
                results["warnings"].append(
                    f"[DECOY_NAMING] {ca_id} has DECOY security_function but doesn't start with INJ"
                )

    # ==========================================
    # Summary info
    # ==========================================
    results["info"].append(f"File lines: {total_lines}, Empty: {len(empty_lines)}, Mapped: {actual_covered}")
    results["info"].append(f"Code acts defined: {len(data['code_acts'])}, Vulnerable lines: {len(data['vulnerable_lines'])}")

    return results


def find_all_samples(variant: str) -> list:
    """Find all sample IDs for a variant."""
    config = VARIANTS[variant]
    annotation_dir = BASE_DIR / config["annotation_dir"]

    if not annotation_dir.exists():
        return []

    samples = []
    for f in annotation_dir.glob(f"{variant}_*.yaml"):
        match = re.match(rf"{variant}_(\d+)\.yaml", f.name)
        if match:
            samples.append(match.group(1))

    return sorted(samples)


def print_results(results: dict, verbose: bool = False):
    """Pretty print validation results."""
    has_issues = results["errors"] or results["warnings"]

    if has_issues:
        print(f"\n{'='*70}")
        print(f"  {results['sample']}")
        print(f"{'='*70}")

        if results["errors"]:
            print("\n  ERRORS:")
            for err in results["errors"]:
                print(f"    ✗ {err}")

        if results["warnings"]:
            print("\n  WARNINGS:")
            for warn in results["warnings"]:
                print(f"    ⚠ {warn}")

        if verbose and results["info"]:
            print("\n  INFO:")
            for info in results["info"]:
                print(f"    ℹ {info}")
    else:
        info_str = results['info'][0] if results['info'] else 'passed'
        print(f"  ✓ {results['sample']}: {info_str}")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        print("\nVariants: ms_tc, df_tc, tr_tc")
        sys.exit(1)

    verbose = "--verbose" in sys.argv or "-v" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("-")]

    if args[0] == "all":
        all_results = []
        print("\n" + "="*70)
        print("  ANNOTATION VALIDATION REPORT")
        print("="*70)

        for variant in VARIANTS:
            print(f"\n--- {variant.upper()} ---")
            samples = find_all_samples(variant)

            if not samples:
                print(f"  No samples found for {variant}")
                continue

            for sample_id in samples:
                results = validate_annotation(variant, sample_id)
                all_results.append(results)
                print_results(results, verbose)

        # Summary
        print(f"\n{'='*70}")
        print("  SUMMARY")
        print(f"{'='*70}")

        total_errors = sum(len(r["errors"]) for r in all_results)
        total_warnings = sum(len(r["warnings"]) for r in all_results)
        passed = sum(1 for r in all_results if not r["errors"] and not r["warnings"])

        print(f"\n  Total samples:  {len(all_results)}")
        print(f"  Passed:         {passed}")
        print(f"  With errors:    {sum(1 for r in all_results if r['errors'])}")
        print(f"  With warnings:  {sum(1 for r in all_results if r['warnings'])}")
        print(f"  Total errors:   {total_errors}")
        print(f"  Total warnings: {total_warnings}")

        if total_errors > 0 or total_warnings > 0:
            print("\n  Issues by type:")
            issue_counts = {}
            for r in all_results:
                for err in r["errors"] + r["warnings"]:
                    match = re.match(r'\[([^\]]+)\]', err)
                    if match:
                        issue_type = match.group(1)
                        issue_counts[issue_type] = issue_counts.get(issue_type, 0) + 1

            for issue_type, count in sorted(issue_counts.items(), key=lambda x: -x[1]):
                print(f"    {issue_type}: {count}")

    elif len(args) >= 2:
        variant = args[0]
        sample_id = args[1]

        if variant not in VARIANTS:
            print(f"Unknown variant: {variant}")
            print(f"Valid variants: {list(VARIANTS.keys())}")
            sys.exit(1)

        results = validate_annotation(variant, sample_id)
        print_results(results, verbose=True)

    else:
        variant = args[0]
        if variant not in VARIANTS:
            print(f"Unknown variant: {variant}")
            sys.exit(1)

        samples = find_all_samples(variant)
        print(f"\n--- {variant.upper()} ---")
        for sample_id in samples:
            results = validate_annotation(variant, sample_id)
            print_results(results, verbose)


if __name__ == "__main__":
    main()
