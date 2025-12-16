"""
Migration script to consolidate datasets into base folder structure.

This script:
1. Updates base metadata files with correct paths
2. Creates index.json for base dataset
3. Updates sanitized and nocomments metadata to reference base/contracts
"""

import json
from pathlib import Path
from datetime import datetime

BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "data"


def update_base_metadata():
    """Update metadata files in base folder."""
    metadata_dir = DATA_DIR / "base" / "metadata"

    for meta_file in metadata_dir.glob("*.json"):
        try:
            metadata = json.loads(meta_file.read_text())

            file_id = metadata.get('id', meta_file.stem)

            # Determine extension
            contracts_dir = DATA_DIR / "base" / "contracts"
            ext = '.sol'
            for e in ['.sol', '.rs']:
                if (contracts_dir / f"{file_id}{e}").exists():
                    ext = e
                    break

            # Update contract_file path
            metadata['contract_file'] = f"contracts/{file_id}{ext}"

            # Keep original subset info but add original_subset field
            original_subset = metadata.get('subset', 'unknown')
            if original_subset in ['difficulty_stratified', 'temporal_contamination']:
                metadata['original_subset'] = original_subset
            metadata['subset'] = 'base'

            meta_file.write_text(json.dumps(metadata, indent=2))

        except Exception as e:
            print(f"Error updating {meta_file}: {e}")


def create_base_index():
    """Create index.json for the base dataset."""
    metadata_dir = DATA_DIR / "base" / "metadata"

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'safe_count': 0,
        'by_vulnerability_type': {},
        'by_severity': {},
        'by_original_subset': {'difficulty_stratified': 0, 'temporal_contamination': 0}
    }

    for meta_file in sorted(metadata_dir.glob("*.json")):
        try:
            metadata = json.loads(meta_file.read_text())

            sample = {
                'id': metadata.get('id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
                'original_subset': metadata.get('original_subset', 'unknown'),
            }

            # Extract ground truth info
            ground_truth = metadata.get('ground_truth', {})
            sample['is_vulnerable'] = ground_truth.get('is_vulnerable', True)
            sample['vulnerability_type'] = ground_truth.get('vulnerability_type', 'unknown')
            sample['severity'] = ground_truth.get('severity', 'unknown')

            samples.append(sample)

            # Update stats
            stats['total_samples'] += 1
            if sample['is_vulnerable']:
                stats['vulnerable_count'] += 1
            else:
                stats['safe_count'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_vulnerability_type'][vuln_type] = stats['by_vulnerability_type'].get(vuln_type, 0) + 1

            severity = sample['severity']
            stats['by_severity'][severity] = stats['by_severity'].get(severity, 0) + 1

            # Track original subset
            orig_subset = metadata.get('original_subset', '')
            if orig_subset in stats['by_original_subset']:
                stats['by_original_subset'][orig_subset] += 1

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")

    index = {
        'dataset_name': 'base',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'last_updated': datetime.now().strftime('%Y-%m-%d'),
        'description': 'Base dataset containing all original vulnerable smart contracts. '
                       'Merged from difficulty_stratified (ds_*) and temporal_contamination (tc_*) subsets.',
        'composition': {
            'difficulty_stratified': {
                'prefix': 'ds_',
                'description': 'Contracts stratified by detection difficulty',
                'count': stats['by_original_subset']['difficulty_stratified']
            },
            'temporal_contamination': {
                'prefix': 'tc_',
                'description': 'Pre-cutoff famous DeFi exploits for testing memorization',
                'count': stats['by_original_subset']['temporal_contamination']
            }
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = DATA_DIR / "base" / "index.json"
    index_path.write_text(json.dumps(index, indent=2))
    print(f"Created base index.json with {stats['total_samples']} samples")


def update_derived_metadata(dataset_name: str):
    """Update metadata in derived datasets to reference base/contracts."""
    metadata_dir = DATA_DIR / dataset_name / "metadata"

    if not metadata_dir.exists():
        print(f"Warning: {metadata_dir} does not exist")
        return

    updated = 0
    for meta_file in metadata_dir.glob("*.json"):
        try:
            metadata = json.loads(meta_file.read_text())

            # Get the original ID
            if dataset_name == 'sanitized':
                orig_id = metadata.get('sanitized_from', '')
            elif dataset_name == 'nocomments':
                orig_id = metadata.get('original_id', metadata.get('sanitized_from', ''))
            else:
                continue

            if orig_id:
                # Determine extension
                ext = '.sol'
                for e in ['.sol', '.rs']:
                    if (DATA_DIR / "base" / "contracts" / f"{orig_id}{e}").exists():
                        ext = e
                        break

                # Update original_contract_file to point to base
                metadata['original_contract_file'] = f"base/contracts/{orig_id}{ext}"

                meta_file.write_text(json.dumps(metadata, indent=2))
                updated += 1

        except Exception as e:
            print(f"Error updating {meta_file}: {e}")

    print(f"Updated {updated} metadata files in {dataset_name}")


def update_derived_index(dataset_name: str):
    """Update index.json in derived datasets."""
    index_path = DATA_DIR / dataset_name / "index.json"

    if not index_path.exists():
        print(f"Warning: {index_path} does not exist")
        return

    try:
        index = json.loads(index_path.read_text())

        # Update samples to use new original_contract_file path
        for sample in index.get('samples', []):
            orig_file = sample.get('original_contract_file', '')
            if orig_file and not orig_file.startswith('base/'):
                # Extract just the filename
                filename = orig_file.split('/')[-1]
                sample['original_contract_file'] = f"base/contracts/{filename}"

        # Update source reference
        if 'transformation' in index:
            if dataset_name == 'sanitized':
                index['transformation']['source_dataset'] = 'base'
            elif dataset_name == 'nocomments':
                index['transformation']['source_dataset'] = 'sanitized'
                index['transformation']['original_dataset'] = 'base'

        index['last_updated'] = datetime.now().strftime('%Y-%m-%d')

        index_path.write_text(json.dumps(index, indent=2))
        print(f"Updated {dataset_name} index.json")

    except Exception as e:
        print(f"Error updating {index_path}: {e}")


def main():
    print("Step 1: Updating base metadata files...")
    update_base_metadata()

    print("\nStep 2: Creating base index.json...")
    create_base_index()

    print("\nStep 3: Updating sanitized metadata...")
    update_derived_metadata('sanitized')
    update_derived_index('sanitized')

    print("\nStep 4: Updating nocomments metadata...")
    update_derived_metadata('nocomments')
    update_derived_index('nocomments')

    print("\nMigration complete!")


if __name__ == '__main__':
    main()
