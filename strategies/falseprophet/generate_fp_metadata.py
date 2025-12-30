#!/usr/bin/env python3
"""
Generate False Prophet metadata files based on minimalsanitized metadata
and the transformation documentation in .txt files.
"""

import json
import os
import re
from datetime import datetime
from pathlib import Path

BASE_DIR = Path("/Users/poamen/projects/grace/blockbench/base")
MS_METADATA_DIR = BASE_DIR / "dataset/temporal_contamination/minimalsanitized/metadata"
FP_SOURCE_DIR = BASE_DIR / "support/rough/final/decoy/falseProphet"
FP_DEST_DIR = BASE_DIR / "dataset/temporal_contamination/falseProphet"
FP_CONTRACTS_DIR = FP_DEST_DIR / "contracts"
FP_METADATA_DIR = FP_DEST_DIR / "metadata"


def parse_txt_file(txt_path: Path) -> dict:
    """Parse the False Prophet transformation .txt file to extract changes."""
    if not txt_path.exists():
        return {"changes": [], "strategy": "false_prophet", "manual_enhancements": 0}

    content = txt_path.read_text()

    changes = []
    manual_enhancements = 0
    contract_type = ""

    # Extract contract type
    type_match = re.search(r'Contract Type:\s*(.+)', content)
    if type_match:
        contract_type = type_match.group(1).strip()

    # Extract manual enhancements section
    enhancements_section = re.search(
        r'MANUAL ENHANCEMENTS APPLIED:\s*=+\s*(.*?)(?:=+|ANTI-DETECTION)',
        content, re.DOTALL
    )

    if enhancements_section:
        section_text = enhancements_section.group(1)
        # Parse numbered items like "1. CONTRACT HEADER - Enhanced with..."
        items = re.findall(r'\d+\.\s+([A-Z][A-Z\s]+)\s*-\s*(.+?)(?=\n\s*\d+\.|\n\s*$|\n={3,})',
                          section_text, re.DOTALL)

        for location, description in items:
            # Clean up the description
            desc_lines = description.strip().split('\n')
            # Get the main description and any added items
            added_items = []
            main_desc = desc_lines[0].strip() if desc_lines else ""

            for line in desc_lines[1:]:
                line = line.strip()
                if line.startswith('- Added:') or line.startswith('- Changed:'):
                    added_items.append(line[2:].strip())

            change = {
                "location": location.strip(),
                "description": main_desc,
                "comments_added": added_items if added_items else [main_desc]
            }
            changes.append(change)
            manual_enhancements += 1

    # Extract total manual changes count
    total_match = re.search(r'Total manual changes:\s*(\d+)', content)
    if total_match:
        manual_enhancements = int(total_match.group(1))

    return {
        "changes": changes,
        "strategy": "false_prophet",
        "contract_type": contract_type,
        "manual_enhancements": manual_enhancements
    }


def generate_fp_metadata(ms_metadata: dict, txt_info: dict, idx: int) -> dict:
    """Generate False Prophet metadata from minimalsanitized metadata."""

    # Create new sample ID
    sample_id = f"fp_tc_{idx:03d}"

    # Copy base metadata from minimalsanitized
    fp_metadata = {
        "sample_id": sample_id,
        "exploit_name": ms_metadata.get("exploit_name", ""),
        "date": ms_metadata.get("date", ""),
        "amount_lost_usd": ms_metadata.get("amount_lost_usd", ""),
        "blockchain": ms_metadata.get("blockchain", "ethereum"),
        "language": ms_metadata.get("language", "solidity"),
        "vulnerability_type": ms_metadata.get("vulnerability_type", ""),
        "vulnerability_subtype": ms_metadata.get("vulnerability_subtype", ""),
        "severity": ms_metadata.get("severity", ""),
        "difficulty_tier": ms_metadata.get("difficulty_tier", 0),
        "is_vulnerable": True,  # False Prophet preserves vulnerability
        "temporal_category": ms_metadata.get("temporal_category", ""),
        "description": ms_metadata.get("description", ""),
        "vulnerable_contract": ms_metadata.get("vulnerable_contract", ""),
        "vulnerable_function": ms_metadata.get("vulnerable_function", ""),
        "vulnerable_lines": ms_metadata.get("vulnerable_lines", []),
        "attack_scenario": ms_metadata.get("attack_scenario", ""),
        "root_cause": ms_metadata.get("root_cause", ""),
        "fix_description": ms_metadata.get("fix_description", ""),
        "source_reference": ms_metadata.get("source_reference", ""),
        "external_references": ms_metadata.get("external_references", []),
        "tags": list(set(ms_metadata.get("tags", []) + ["false_prophet", "decoy"])),
        "variant_type": "false_prophet",
        "variant_parent_id": f"tc_{idx:03d}",
        "notes": ms_metadata.get("notes", ""),
        "contract_file": f"contracts/fp_tc_{idx:03d}.sol",
        "subset": "annotated",
        "original_subset": "temporal_contamination",
        "transformation": {
            "type": "false_prophet",
            "strategy": "decoy",
            "source_dir": str(BASE_DIR / "dataset/temporal_contamination/minimalsanitized"),
            "source_contract": str(BASE_DIR / f"dataset/temporal_contamination/minimalsanitized/contracts/ms_tc_{idx:03d}.sol"),
            "source_metadata": str(BASE_DIR / f"dataset/temporal_contamination/minimalsanitized/metadata/ms_tc_{idx:03d}.json"),
            "script": "manual",
            "changes": [
                "Added misleading security comments and NatSpec documentation",
                "Added fake audit claims and security attestations",
                "Added reassuring comments near vulnerable code sections",
                "Preserved original vulnerability without modification"
            ],
            "false_prophet_enhancements": txt_info.get("changes", []),
            "manual_enhancements_count": txt_info.get("manual_enhancements", 0),
            "contract_type": txt_info.get("contract_type", ""),
            "vulnerability_preserved": True,
            "misleading_comments_added": True,
            "created_date": datetime.now().isoformat()
        }
    }

    return fp_metadata


def main():
    """Generate metadata for all 50 False Prophet contracts."""

    # Ensure output directory exists
    FP_METADATA_DIR.mkdir(parents=True, exist_ok=True)

    processed = 0
    errors = []

    for idx in range(1, 51):
        ms_metadata_path = MS_METADATA_DIR / f"ms_tc_{idx:03d}.json"
        txt_path = FP_SOURCE_DIR / f"fp_tc_{idx:03d}.txt"
        fp_metadata_path = FP_METADATA_DIR / f"fp_tc_{idx:03d}.json"

        try:
            # Load minimalsanitized metadata
            if not ms_metadata_path.exists():
                errors.append(f"Missing ms_tc_{idx:03d}.json")
                continue

            with open(ms_metadata_path) as f:
                ms_metadata = json.load(f)

            # Parse transformation documentation
            txt_info = parse_txt_file(txt_path)

            # Generate False Prophet metadata
            fp_metadata = generate_fp_metadata(ms_metadata, txt_info, idx)

            # Write metadata file
            with open(fp_metadata_path, 'w') as f:
                json.dump(fp_metadata, f, indent=2)

            processed += 1
            print(f"Generated: fp_tc_{idx:03d}.json")

        except Exception as e:
            errors.append(f"Error processing tc_{idx:03d}: {str(e)}")

    print(f"\nProcessed: {processed}/50")
    if errors:
        print(f"Errors: {len(errors)}")
        for err in errors:
            print(f"  - {err}")


if __name__ == "__main__":
    main()
