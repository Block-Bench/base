#!/usr/bin/env python3
"""
Annotation Skeleton Generator

Generates a pre-filled YAML annotation skeleton from a .sol contract file.
Automatically identifies empty lines and creates the correct structure.

Usage:
    python generate_annotation_skeleton.py <variant> <sample_id>
    python generate_annotation_skeleton.py ms_tc 021
    python generate_annotation_skeleton.py df_tc 021
    python generate_annotation_skeleton.py tr_tc 021
"""

import re
import sys
import json
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent.parent

VARIANT_CONFIG = {
    "ms_tc": {
        "contract_dir": "dataset/temporal_contamination/minimalsanitized/contracts",
        "annotation_dir": "dataset/temporal_contamination/minimalsanitized/code_acts_annotation",
        "metadata_dir": "dataset/temporal_contamination/minimalsanitized/metadata",
        "template": "ms_tc"
    },
    "df_tc": {
        "contract_dir": "dataset/temporal_contamination/differential/contracts",
        "annotation_dir": "dataset/temporal_contamination/differential/code_acts_annotation",
        "metadata_dir": "dataset/temporal_contamination/differential/metadata",
        "template": "df_tc"
    },
    "tr_tc": {
        "contract_dir": "dataset/temporal_contamination/trojan/contracts",
        "annotation_dir": "dataset/temporal_contamination/trojan/code_acts_annotation",
        "metadata_dir": "dataset/temporal_contamination/trojan/metadata",
        "template": "tr_tc"
    }
}


def analyze_contract(sol_path: Path) -> dict:
    """Analyze a .sol file and return line information."""
    lines = sol_path.read_text().split('\n')

    empty_lines = []
    non_empty_lines = []

    for i, line in enumerate(lines, 1):
        # Remove /*LN-X*/ prefix
        cleaned = re.sub(r'/\*LN-\d+\*/\s*', '', line)
        if cleaned.strip() == '':
            empty_lines.append(i)
        else:
            non_empty_lines.append(i)

    return {
        "total_lines": len(lines),
        "empty_lines": empty_lines,
        "non_empty_lines": non_empty_lines,
        "non_empty_count": len(non_empty_lines)
    }


def get_metadata(variant: str, sample_id: str) -> dict:
    """Get metadata for the sample if available."""
    config = VARIANT_CONFIG[variant]
    metadata_path = BASE_DIR / config["metadata_dir"] / f"{variant}_{sample_id}.json"

    if metadata_path.exists():
        return json.loads(metadata_path.read_text())
    return {}


def generate_ms_tc_skeleton(sample_id: str, analysis: dict, metadata: dict) -> str:
    """Generate skeleton for minimalsanitized variant."""
    vuln_type = metadata.get("vulnerability_type", "TODO_VULNERABILITY_TYPE")
    vuln_lines = metadata.get("vulnerable_lines", [])

    # Build line_to_code_act section
    line_mappings = []
    for i in range(1, analysis["total_lines"] + 1):
        if i in analysis["empty_lines"]:
            line_mappings.append(f"  # Line {i}: empty")
        else:
            line_mappings.append(f"  {i}: \"TODO\"  # TODO: assign code_act")

    skeleton = f'''schema_version: "1.0"
sample_id: "ms_tc_{sample_id}"
vulnerability_type: "{vuln_type}"
vulnerable_lines: {vuln_lines}

# Full line coverage for scoring. UNRELATED items are batched for efficiency.
# Detailed rationales only for security-relevant code acts.

code_acts:

  # ============================================
  # SECURITY-RELEVANT CODE ACTS (detailed)
  # ============================================

  # TODO: Add ROOT_CAUSE code_acts
  # - id: "CA1"
  #   type: "TODO"
  #   lines: []
  #   code: |
  #     TODO
  #   security_function: "ROOT_CAUSE"
  #   rationale: "ROOT_CAUSE - TODO"

  # TODO: Add PREREQ code_acts

  # TODO: Add BENIGN code_acts

  # ============================================
  # BATCHED UNRELATED CODE ACTS (for scoring)
  # ============================================

  - id: "CA_DIRECTIVES"
    type: "DIRECTIVE"
    lines: [1, 2]  # TODO: verify
    security_function: "UNRELATED"
    rationale: "License and pragma statements"

  - id: "CA_COMMENTS"
    type: "COMMENT"
    lines: []  # TODO: fill in comment lines
    security_function: "UNRELATED"
    rationale: "Inline comments and NatSpec documentation"

  - id: "CA_DECLARATIONS"
    type: "DECLARATION"
    lines: []  # TODO: fill in declaration lines
    security_function: "UNRELATED"
    rationale: "Interface, contract, and function signature declarations"

  - id: "CA_SYNTAX"
    type: "SYNTAX"
    lines: []  # TODO: fill in closing brace lines
    security_function: "UNRELATED"
    rationale: "Closing braces"

summary:
  total_code_acts: 0  # TODO: update
  total_lines_covered: {analysis["non_empty_count"]}

  by_security_function:
    ROOT_CAUSE: 0  # TODO
    PREREQ: 0      # TODO
    BENIGN: 0      # TODO
    UNRELATED: 4   # batched

  root_causes: []  # TODO

  prerequisites: []  # TODO

line_to_code_act:
{chr(10).join(line_mappings)}

code_act_security_functions:
  # TODO: Add all code_acts here
  CA_DIRECTIVES: "UNRELATED"
  CA_COMMENTS: "UNRELATED"
  CA_DECLARATIONS: "UNRELATED"
  CA_SYNTAX: "UNRELATED"
'''
    return skeleton


def generate_df_tc_skeleton(sample_id: str, analysis: dict, metadata: dict) -> str:
    """Generate skeleton for differential (fixed) variant."""
    vuln_type = metadata.get("vulnerability_type", "TODO_VULNERABILITY_TYPE")

    # Build line_to_code_act_fixed section
    line_mappings = []
    for i in range(1, analysis["total_lines"] + 1):
        if i in analysis["empty_lines"]:
            line_mappings.append(f"  # Line {i}: empty")
        else:
            line_mappings.append(f"  {i}: \"TODO\"  # TODO: assign code_act")

    skeleton = f'''schema_version: "1.0"
sample_id: "df_tc_{sample_id}"
base_sample_id: "ms_tc_{sample_id}"
vulnerability_type: "{vuln_type}"
is_fixed: true

fix_summary:
  description: "TODO: Describe the fix applied"
  fix_type: "TODO"
  vulnerable_pattern: "TODO"
  fixed_pattern: "TODO"

vulnerable_version:
  reference: "../minimalsanitized/code_acts_annotation/ms_tc_{sample_id}.yaml"
  # vulnerable_lines (reference only): []
  root_cause_description: "TODO"

fixed_version:
  fix_lines: []  # TODO: lines where fix was applied
  fix_description: "TODO"

code_acts:

  # ============================================
  # FIX CODE ACTS
  # ============================================

  # TODO: Add CA_FIX* code_acts for the fix
  # - id: "CA_FIX1"
  #   type: "TODO"
  #   lines: []
  #   code: |
  #     TODO
  #   security_function: "FIX"
  #   rationale: "FIX - TODO"

  # ============================================
  # OTHER CODE ACTS
  # ============================================

  # TODO: Add other relevant code_acts

  # ============================================
  # BATCHED UNRELATED CODE ACTS
  # ============================================

  - id: "CA_DIRECTIVES"
    type: "DIRECTIVE"
    lines: [1, 2]  # TODO: verify
    security_function: "UNRELATED"
    rationale: "License and pragma statements"

  - id: "CA_COMMENTS"
    type: "COMMENT"
    lines: []  # TODO
    security_function: "UNRELATED"
    rationale: "NatSpec documentation"

  - id: "CA_DECLARATIONS"
    type: "DECLARATION"
    lines: []  # TODO
    security_function: "UNRELATED"
    rationale: "Interface, contract, and function signature declarations"

  - id: "CA_SYNTAX"
    type: "SYNTAX"
    lines: []  # TODO
    security_function: "UNRELATED"
    rationale: "Closing braces"

summary:
  total_code_acts_fixed: 0  # TODO

  fix_applied:
    type: "TODO"
    description: "TODO"
    lines_changed: []

  by_security_function_fixed:
    FIX: 0       # TODO
    BENIGN: 0    # TODO
    UNRELATED: 4 # batched

line_to_code_act_fixed:
{chr(10).join(line_mappings)}

code_act_security_functions_fixed:
  # TODO: Add all code_acts here
  CA_DIRECTIVES: "UNRELATED"
  CA_COMMENTS: "UNRELATED"
  CA_DECLARATIONS: "UNRELATED"
  CA_SYNTAX: "UNRELATED"
'''
    return skeleton


def generate_tr_tc_skeleton(sample_id: str, analysis: dict, metadata: dict) -> str:
    """Generate skeleton for trojan variant."""
    vuln_type = metadata.get("vulnerability_type", "TODO_VULNERABILITY_TYPE")
    vuln_lines = metadata.get("vulnerable_lines", [])

    # Build line_to_code_act section
    line_mappings = []
    for i in range(1, analysis["total_lines"] + 1):
        if i in analysis["empty_lines"]:
            line_mappings.append(f"  # Line {i}: empty")
        else:
            line_mappings.append(f"  {i}: \"TODO\"  # TODO: assign code_act")

    skeleton = f'''schema_version: "1.0"
sample_id: "tr_tc_{sample_id}"
base_sample_id: "ms_tc_{sample_id}"
vulnerability_type: "{vuln_type}"
is_vulnerable: true

# Trojan annotation documents INJECTED DECOY elements only.
# The base vulnerability is documented in ms_tc_{sample_id}.yaml.
# DECOYs are suspicious-looking code that is actually safe.

trojan_strategy: "config_and_metrics_distractors"
injection_count: 0  # TODO: update

base_vulnerability:
  type: "{vuln_type}"
  function: "TODO"
  vulnerable_lines: {vuln_lines}  # Line numbers in tr_tc_{sample_id}.sol
  reference: "../minimalsanitized/code_acts_annotation/ms_tc_{sample_id}.yaml"

injections:

  # ============================================
  # DECOY 1: TODO
  # ============================================

  # - id: "INJ1"
  #   type: "TODO"
  #   security_function: "DECOY"
  #   location:
  #     file: "tr_tc_{sample_id}.sol"
  #     function: "TODO"
  #     lines: []
  #   code: |
  #     TODO
  #   suspicious_because:
  #     - "TODO"
  #   safe_because:
  #     - "TODO"
  #   pattern_triggered: "TODO"
  #   distraction_risk: "medium"

summary:
  total_injections: 0  # TODO

  injection_types:
    ACCESS_CTRL: 0
    DECLARATION: 0
    STATE_MOD: 0
    COMPUTATION: 0

  distraction_risk_breakdown:
    high: 0
    medium: 0
    low: 0

  evaluation_notes:
    - "TODO"

# ============================================
# LINE TO CODE ACT MAPPINGS (for scoring)
# ============================================

line_to_code_act:
{chr(10).join(line_mappings)}

code_act_security_functions:
  # Real vulnerability code acts (from base ms_tc)
  # TODO: Add CA* entries
  # Injected decoys
  # TODO: Add INJ* entries
'''
    return skeleton


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)

    variant = sys.argv[1]
    sample_id = sys.argv[2]

    if variant not in VARIANT_CONFIG:
        print(f"Error: Unknown variant '{variant}'")
        print(f"Valid variants: {list(VARIANT_CONFIG.keys())}")
        sys.exit(1)

    config = VARIANT_CONFIG[variant]

    # Find contract file
    sol_path = BASE_DIR / config["contract_dir"] / f"{variant}_{sample_id}.sol"
    if not sol_path.exists():
        print(f"Error: Contract not found: {sol_path}")
        sys.exit(1)

    # Analyze contract
    analysis = analyze_contract(sol_path)
    print(f"Contract analysis for {variant}_{sample_id}:")
    print(f"  Total lines: {analysis['total_lines']}")
    print(f"  Empty lines: {len(analysis['empty_lines'])}")
    print(f"  Non-empty lines: {analysis['non_empty_count']}")
    print()

    # Get metadata
    metadata = get_metadata(variant, sample_id)
    if metadata:
        print(f"Metadata found:")
        print(f"  Vulnerability type: {metadata.get('vulnerability_type', 'N/A')}")
        print(f"  Vulnerable lines: {metadata.get('vulnerable_lines', 'N/A')}")
        print()

    # Generate skeleton
    if variant == "ms_tc":
        skeleton = generate_ms_tc_skeleton(sample_id, analysis, metadata)
    elif variant == "df_tc":
        skeleton = generate_df_tc_skeleton(sample_id, analysis, metadata)
    elif variant == "tr_tc":
        skeleton = generate_tr_tc_skeleton(sample_id, analysis, metadata)

    # Write skeleton
    output_path = BASE_DIR / config["annotation_dir"] / f"{variant}_{sample_id}.yaml"
    output_path.write_text(skeleton)

    print(f"Skeleton generated: {output_path}")
    print(f"\nNext steps:")
    print(f"  1. Read the contract: {sol_path}")
    print(f"  2. Identify ROOT_CAUSE, PREREQ, BENIGN code_acts")
    print(f"  3. Fill in TODO sections in the skeleton")
    print(f"  4. Run: python support/scripts/validate_annotations.py {variant} {sample_id}")


if __name__ == "__main__":
    main()
