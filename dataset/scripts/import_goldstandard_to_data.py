#!/usr/bin/env python3
"""
Import Gold Standard data from labelled_data into data folder structure.

Copies contracts and transforms metadata to match the format used by
temporal_contamination (tc_XXX) files in data/base and data/annotated.
"""

import json
import shutil
from pathlib import Path
from datetime import datetime


# Paths
BASE_DIR = Path(__file__).parent.parent.parent
GOLD_STANDARD_DIR = BASE_DIR / "labelled_data" / "gold_standard"
DATA_BASE_DIR = BASE_DIR / "data" / "base"
DATA_ANNOTATED_DIR = BASE_DIR / "data" / "annotated"


def load_gold_standard_metadata(gs_id: str) -> dict:
    """Load metadata for a gold standard item."""
    metadata_path = GOLD_STANDARD_DIR / "metadata" / f"{gs_id}.json"
    with open(metadata_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def transform_to_base_format(gs_meta: dict) -> dict:
    """Transform gold standard metadata to data/base format."""
    gs_id = gs_meta['id']

    return {
        "id": gs_id,
        "contract_file": f"contracts/{gs_id}.sol",
        "subset": "base",
        "ground_truth": {
            "is_vulnerable": gs_meta.get('is_vulnerable', True),
            "vulnerability_type": gs_meta.get('vulnerability_type', ''),
            "severity": gs_meta.get('severity', ''),
            "vulnerable_location": {
                "contract_name": gs_meta.get('primary_file_path', '').split('/')[-1].replace('.sol', ''),
                "function_name": gs_meta.get('vulnerable_functions', [''])[0] if gs_meta.get('vulnerable_functions') else '',
                "line_numbers": gs_meta.get('vulnerable_lines', [])
            },
            "root_cause": gs_meta.get('finding_description', ''),
            "attack_vector": gs_meta.get('attack_scenario', ''),
            "impact": f"Severity: {gs_meta.get('severity', 'unknown')}",
            "correct_fix": gs_meta.get('fix_description', '')
        },
        "provenance": {
            "source": gs_meta.get('source_platform', ''),
            "original_id": gs_meta.get('original_id', ''),
            "url": gs_meta.get('report_url', ''),
            "date_discovered": gs_meta.get('contest_date', ''),
            "date_added": datetime.now().strftime('%Y-%m-%d'),
            "added_by": "benchmark_team"
        },
        "code_metadata": {
            "solidity_version": "^0.8.0",
            "num_lines": 0,  # Will be updated
            "num_contracts": 1,
            "contract_names": [],
            "num_functions": 0,
            "has_imports": False,
            "imports": [],
            "has_inheritance": False,
            "inherits_from": [],
            "has_modifiers": False,
            "has_events": False,
            "has_assembly": False,
            "compilation_verified": False,
            "compiler_version_used": None
        },
        "tags": [
            gs_meta.get('vulnerability_type', ''),
            gs_meta.get('source_platform', ''),
            "gold_standard",
            "audit_finding"
        ],
        "notes": gs_meta.get('context_hint', ''),
        "gold_standard_fields": {
            "source_report": gs_meta.get('source_report', ''),
            "source_finding_id": gs_meta.get('source_finding_id', ''),
            "finding_title": gs_meta.get('finding_title', ''),
            "difficulty_tier": gs_meta.get('difficulty_tier', 0),
            "context_level": gs_meta.get('context_level', 'single_file'),
            "has_context": gs_meta.get('has_context', False),
            "call_flow": gs_meta.get('call_flow', '')
        },
        "evaluation_support": {
            "annotated_contract": f"labelled_data/gold_standard/contracts/{gs_id}.sol",
            "detailed_metadata": f"labelled_data/gold_standard/metadata/{gs_id}.json",
            "original_finding_title": gs_meta.get('finding_title', '')
        },
        "original_subset": "gold_standard"
    }


def transform_to_annotated_format(gs_meta: dict) -> dict:
    """Transform gold standard metadata to data/annotated format."""
    gs_id = gs_meta['id']

    return {
        "sample_id": gs_meta.get('original_id', ''),
        "exploit_name": gs_meta.get('finding_title', ''),
        "date": gs_meta.get('contest_date', ''),
        "amount_lost_usd": None,
        "blockchain": gs_meta.get('chain', 'ethereum'),
        "language": gs_meta.get('language', 'solidity'),
        "vulnerability_type": gs_meta.get('vulnerability_type', ''),
        "vulnerability_subtype": gs_meta.get('source_finding_id', ''),
        "severity": gs_meta.get('severity', ''),
        "difficulty_tier": gs_meta.get('difficulty_tier', 0),
        "is_vulnerable": gs_meta.get('is_vulnerable', True),
        "temporal_category": "post_cutoff",  # Gold standard items are recent
        "description": gs_meta.get('finding_description', ''),
        "vulnerable_contract": gs_meta.get('primary_file_path', '').split('/')[-1].replace('.sol', ''),
        "vulnerable_function": gs_meta.get('vulnerable_functions', [''])[0] if gs_meta.get('vulnerable_functions') else '',
        "vulnerable_lines": gs_meta.get('vulnerable_lines', []),
        "attack_scenario": gs_meta.get('attack_scenario', ''),
        "root_cause": gs_meta.get('finding_description', ''),
        "fix_description": gs_meta.get('fix_description', ''),
        "source_reference": gs_meta.get('report_url', ''),
        "external_references": [
            gs_meta.get('github_repo_url', '')
        ] if gs_meta.get('github_repo_url') else [],
        "tags": [
            gs_meta.get('vulnerability_type', ''),
            gs_meta.get('source_platform', ''),
            "gold_standard",
            "audit_finding"
        ],
        "variant_type": "original",
        "variant_parent_id": None,
        "notes": gs_meta.get('context_hint', ''),
        "contract_file": f"contracts/{gs_id}.sol",
        "subset": "annotated",
        "original_subset": "gold_standard"
    }


def count_lines(file_path: Path) -> int:
    """Count lines in a file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return len(f.readlines())


def main():
    print("=" * 60)
    print("Import Gold Standard to Data Folder")
    print("=" * 60)

    # Load index to get all items
    index_path = GOLD_STANDARD_DIR / "index.json"
    with open(index_path, 'r', encoding='utf-8') as f:
        index = json.load(f)

    items = index['items']
    print(f"\nFound {len(items)} gold standard items to import")

    # Create output directories
    (DATA_BASE_DIR / "contracts").mkdir(parents=True, exist_ok=True)
    (DATA_BASE_DIR / "metadata").mkdir(parents=True, exist_ok=True)
    (DATA_ANNOTATED_DIR / "contracts").mkdir(parents=True, exist_ok=True)
    (DATA_ANNOTATED_DIR / "metadata").mkdir(parents=True, exist_ok=True)

    # Process each item
    for item in items:
        gs_id = item['id']
        print(f"  Processing {gs_id}...")

        # Load full metadata
        gs_meta = load_gold_standard_metadata(gs_id)

        # Copy contract files
        src_contract = GOLD_STANDARD_DIR / "contracts" / f"{gs_id}.sol"

        # Copy to base
        dst_base_contract = DATA_BASE_DIR / "contracts" / f"{gs_id}.sol"
        shutil.copy2(src_contract, dst_base_contract)

        # Copy to annotated
        dst_annotated_contract = DATA_ANNOTATED_DIR / "contracts" / f"{gs_id}.sol"
        shutil.copy2(src_contract, dst_annotated_contract)

        # Transform and write base metadata
        base_meta = transform_to_base_format(gs_meta)
        base_meta['code_metadata']['num_lines'] = count_lines(src_contract)

        dst_base_meta = DATA_BASE_DIR / "metadata" / f"{gs_id}.json"
        with open(dst_base_meta, 'w', encoding='utf-8') as f:
            json.dump(base_meta, f, indent=2)

        # Transform and write annotated metadata
        annotated_meta = transform_to_annotated_format(gs_meta)

        dst_annotated_meta = DATA_ANNOTATED_DIR / "metadata" / f"{gs_id}.json"
        with open(dst_annotated_meta, 'w', encoding='utf-8') as f:
            json.dump(annotated_meta, f, indent=2)

    # Summary
    print("\n" + "=" * 60)
    print("Import Complete!")
    print("=" * 60)
    print(f"Imported {len(items)} gold standard items")
    print(f"  - {DATA_BASE_DIR / 'contracts'}: {len(items)} .sol files")
    print(f"  - {DATA_BASE_DIR / 'metadata'}: {len(items)} .json files")
    print(f"  - {DATA_ANNOTATED_DIR / 'contracts'}: {len(items)} .sol files")
    print(f"  - {DATA_ANNOTATED_DIR / 'metadata'}: {len(items)} .json files")


if __name__ == "__main__":
    main()
