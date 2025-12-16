#!/usr/bin/env python3
"""
Transform Gold Standard JSON files into labelled_data format.

Reads vulnerability data from dataset/goldstandard/*.json and creates:
- labelled_data/gold_standard/contracts/gs_XXX.sol (primary vulnerable files)
- labelled_data/gold_standard/context/gs_XXX/ (context files if any)
- labelled_data/gold_standard/metadata/gs_XXX.json (metadata)
- labelled_data/gold_standard/index.json (dataset index)
"""

import json
import os
import re
from pathlib import Path
from datetime import datetime


# Paths
BASE_DIR = Path(__file__).parent.parent.parent
GOLDSTANDARD_DIR = BASE_DIR / "dataset" / "goldstandard"
OUTPUT_DIR = BASE_DIR / "labelled_data" / "gold_standard"


def sanitize_filename(path: str) -> str:
    """Extract a safe filename from a path."""
    # Get just the filename without path
    name = Path(path).name
    # Remove .sol extension if present
    if name.endswith('.sol'):
        name = name[:-4]
    # Replace non-alphanumeric chars with underscore
    name = re.sub(r'[^a-zA-Z0-9_]', '_', name)
    return name


def load_all_vulnerabilities():
    """Load all vulnerability items from all JSON files."""
    vulnerabilities = []

    for json_file in sorted(GOLDSTANDARD_DIR.glob("*.json")):
        print(f"Loading {json_file.name}...")
        with open(json_file, 'r', encoding='utf-8') as f:
            items = json.load(f)
            for item in items:
                item['_source_file'] = json_file.name
            vulnerabilities.extend(items)

    return vulnerabilities


def transform_vulnerability(item: dict, index: int) -> dict:
    """Transform a single vulnerability item into the target format."""

    gs_id = f"gs_{index:03d}"

    # Extract primary file content
    primary_file = item.get('primary_file', {})
    primary_content = primary_file.get('content', '')
    primary_path = primary_file.get('path', 'unknown.sol')
    vulnerable_lines = primary_file.get('vulnerable_lines', [])
    vulnerable_functions = primary_file.get('vulnerable_functions', [])

    # Extract context files
    context_files = item.get('context_files', [])
    context_info = []

    for i, ctx in enumerate(context_files):
        ctx_path = ctx.get('path', f'context_{i}.sol')
        ctx_content = ctx.get('content', '')
        ctx_relevance = ctx.get('relevance', '')

        if ctx_content:  # Only include non-empty context files
            ctx_filename = f"context_{i+1:02d}_{sanitize_filename(ctx_path)}.sol"
            context_info.append({
                'filename': ctx_filename,
                'original_path': ctx_path,
                'relevance': ctx_relevance,
                'content': ctx_content
            })

    # Build metadata
    metadata = {
        'id': gs_id,
        'original_id': item.get('id', ''),
        'source_dataset': 'gold_standard',
        'source_file': item.get('_source_file', ''),
        'language': item.get('language', 'solidity'),
        'chain': item.get('chain', 'ethereum'),

        # Source information
        'source_platform': item.get('source_platform', ''),
        'source_report': item.get('source_report', ''),
        'source_finding_id': item.get('source_finding_id', ''),
        'report_url': item.get('report_url', ''),
        'github_repo_url': item.get('github_repo_url', ''),
        'contest_date': item.get('contest_date', ''),

        # Vulnerability details
        'vulnerability_type': item.get('vulnerability_type', ''),
        'severity': item.get('severity', ''),
        'difficulty_tier': item.get('difficulty_tier', 0),
        'context_level': item.get('context_level', 'single_file'),
        'is_vulnerable': item.get('is_vulnerable', True),

        # Finding details
        'finding_title': item.get('finding_title', ''),
        'finding_description': item.get('finding_description', ''),
        'attack_scenario': item.get('attack_scenario', ''),
        'fix_description': item.get('fix_description', ''),
        'call_flow': item.get('call_flow', ''),
        'context_hint': item.get('context_hint', ''),

        # File information
        'primary_file_path': primary_path,
        'vulnerable_lines': vulnerable_lines,
        'vulnerable_functions': vulnerable_functions,

        # Context files (paths only, content stored separately)
        'context_files': [
            {
                'filename': ctx['filename'],
                'original_path': ctx['original_path'],
                'relevance': ctx['relevance']
            }
            for ctx in context_info
        ],
        'has_context': len(context_info) > 0
    }

    return {
        'id': gs_id,
        'primary_content': primary_content,
        'context_files': context_info,
        'metadata': metadata
    }


def write_outputs(transformed_items: list):
    """Write all transformed items to the output directory."""

    # Create output directories
    contracts_dir = OUTPUT_DIR / "contracts"
    context_dir = OUTPUT_DIR / "context"
    metadata_dir = OUTPUT_DIR / "metadata"

    contracts_dir.mkdir(parents=True, exist_ok=True)
    metadata_dir.mkdir(parents=True, exist_ok=True)

    index_entries = []

    for item in transformed_items:
        gs_id = item['id']

        # Write primary contract
        contract_path = contracts_dir / f"{gs_id}.sol"
        with open(contract_path, 'w', encoding='utf-8') as f:
            f.write(item['primary_content'])

        # Write context files if any
        if item['context_files']:
            ctx_subdir = context_dir / gs_id
            ctx_subdir.mkdir(parents=True, exist_ok=True)

            for ctx in item['context_files']:
                ctx_path = ctx_subdir / ctx['filename']
                with open(ctx_path, 'w', encoding='utf-8') as f:
                    f.write(ctx['content'])

        # Write metadata
        metadata_path = metadata_dir / f"{gs_id}.json"
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(item['metadata'], f, indent=2)

        # Add to index
        index_entries.append({
            'id': gs_id,
            'original_id': item['metadata']['original_id'],
            'vulnerability_type': item['metadata']['vulnerability_type'],
            'severity': item['metadata']['severity'],
            'difficulty_tier': item['metadata']['difficulty_tier'],
            'context_level': item['metadata']['context_level'],
            'has_context': item['metadata']['has_context'],
            'source_platform': item['metadata']['source_platform']
        })

    # Write index
    index_path = OUTPUT_DIR / "index.json"
    index_data = {
        'name': 'Gold Standard Dataset',
        'description': 'Curated vulnerability samples from professional security audits',
        'total_items': len(index_entries),
        'generated_at': datetime.now().isoformat(),
        'items': index_entries
    }

    with open(index_path, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, indent=2)

    return len(index_entries)


def main():
    print("=" * 60)
    print("Gold Standard Dataset Transformation")
    print("=" * 60)

    # Load all vulnerabilities
    print("\nLoading vulnerability data...")
    vulnerabilities = load_all_vulnerabilities()
    print(f"Found {len(vulnerabilities)} vulnerability items")

    # Transform each item
    print("\nTransforming items...")
    transformed = []
    for i, item in enumerate(vulnerabilities, start=1):
        result = transform_vulnerability(item, i)
        transformed.append(result)

        # Show progress
        ctx_count = len(result['context_files'])
        ctx_info = f" (+{ctx_count} context files)" if ctx_count > 0 else ""
        print(f"  {result['id']}: {item.get('finding_title', 'Unknown')[:50]}...{ctx_info}")

    # Write outputs
    print(f"\nWriting outputs to {OUTPUT_DIR}...")
    count = write_outputs(transformed)

    # Summary
    print("\n" + "=" * 60)
    print("Transformation Complete!")
    print("=" * 60)
    print(f"Total items: {count}")
    print(f"Output directory: {OUTPUT_DIR}")
    print(f"  - contracts/: {count} .sol files")
    print(f"  - metadata/: {count} .json files")

    items_with_context = sum(1 for t in transformed if t['context_files'])
    print(f"  - context/: {items_with_context} items with context files")

    # Stats by severity
    severity_counts = {}
    for t in transformed:
        sev = t['metadata'].get('severity', 'unknown')
        severity_counts[sev] = severity_counts.get(sev, 0) + 1

    print("\nBy severity:")
    for sev, count in sorted(severity_counts.items()):
        print(f"  {sev}: {count}")

    # Stats by source
    source_counts = {}
    for t in transformed:
        src = t['metadata'].get('source_platform', 'unknown')
        source_counts[src] = source_counts.get(src, 0) + 1

    print("\nBy source platform:")
    for src, count in sorted(source_counts.items()):
        print(f"  {src}: {count}")


if __name__ == "__main__":
    main()
