#!/usr/bin/env python3
"""
Renumber temporal_contamination samples to remove gaps after removing 004, 006, 014, 046.
"""

import os
import json
import re
import shutil

BASE_DIR = "/Users/poamen/projects/grace/blockbench/base/dataset/temporal_contamination"

# Current IDs (with gaps) -> New sequential IDs
CURRENT_IDS = [
    "001", "002", "003", "005", "007", "008", "009", "010", "011", "012", "013",
    "015", "016", "017", "018", "019", "020", "021", "022", "023", "024", "025",
    "026", "027", "028", "029", "030", "031", "032", "033", "034", "035", "036",
    "037", "038", "039", "040", "041", "042", "043", "044", "045", "047", "048",
    "049", "050"
]

# Create mapping: old_id -> new_id
MAPPING = {}
for i, old_id in enumerate(CURRENT_IDS):
    new_id = f"{i+1:03d}"
    MAPPING[old_id] = new_id

# Variant configurations: (folder_name, prefix)
VARIANTS = [
    ("minimalsanitized", "ms_tc_"),
    ("sanitized", "sn_tc_"),
    ("nocomments", "nc_tc_"),
    ("chameleon_medical", "ch_medical_tc_"),
    ("differential", "df_tc_"),
    ("falseProphet", "fp_tc_"),
    ("original", "tc_"),
    ("shapeshifter_l3", "ss_tc_"),
    ("trojan", "tr_tc_"),
]

def update_json_content(content, old_id, new_id, prefix):
    """Update IDs inside JSON content."""
    old_sample_id = f"{prefix}{old_id}"
    new_sample_id = f"{prefix}{new_id}"

    # Replace sample_id
    content = content.replace(f'"sample_id": "{old_sample_id}"', f'"sample_id": "{new_sample_id}"')
    content = content.replace(f'"id": "{old_sample_id}"', f'"id": "{new_sample_id}"')

    # Replace variant_parent_id references (e.g., "tc_005" -> "tc_004")
    for var_name, var_prefix in VARIANTS:
        old_ref = f"{var_prefix}{old_id}"
        new_ref = f"{var_prefix}{MAPPING.get(old_id, old_id)}"
        content = content.replace(f'"{old_ref}"', f'"{new_ref}"')

    # Replace contract file paths
    content = content.replace(f"contracts/{prefix}{old_id}.sol", f"contracts/{prefix}{new_id}.sol")

    return content

def update_yaml_content(content, old_id, new_id, prefix):
    """Update IDs inside YAML content."""
    old_sample_id = f"{prefix}{old_id}"
    new_sample_id = f"{prefix}{new_id}"

    # Replace sample_id
    content = content.replace(f'sample_id: "{old_sample_id}"', f'sample_id: "{new_sample_id}"')
    content = content.replace(f"sample_id: {old_sample_id}", f"sample_id: {new_sample_id}")

    return content

def renumber_variant(variant_dir, prefix):
    """Renumber all files in a variant directory."""
    print(f"\n=== Processing {variant_dir} (prefix: {prefix}) ===")

    contracts_dir = os.path.join(BASE_DIR, variant_dir, "contracts")
    metadata_dir = os.path.join(BASE_DIR, variant_dir, "metadata")
    codeacts_dir = os.path.join(BASE_DIR, variant_dir, "code_acts_annotation")

    # Phase 1: Rename to temporary names (to avoid collisions)
    print("Phase 1: Renaming to temporary names...")
    for old_id, new_id in MAPPING.items():
        if old_id == new_id:
            continue

        # Contracts
        old_contract = os.path.join(contracts_dir, f"{prefix}{old_id}.sol")
        tmp_contract = os.path.join(contracts_dir, f"TMP_{prefix}{new_id}.sol")
        if os.path.exists(old_contract):
            shutil.move(old_contract, tmp_contract)

        # Metadata
        old_meta = os.path.join(metadata_dir, f"{prefix}{old_id}.json")
        tmp_meta = os.path.join(metadata_dir, f"TMP_{prefix}{new_id}.json")
        if os.path.exists(old_meta):
            shutil.move(old_meta, tmp_meta)

        # Code acts annotation
        old_yaml = os.path.join(codeacts_dir, f"{prefix}{old_id}.yaml")
        tmp_yaml = os.path.join(codeacts_dir, f"TMP_{prefix}{new_id}.yaml")
        if os.path.exists(old_yaml):
            shutil.move(old_yaml, tmp_yaml)

    # Phase 2: Rename from temporary to final names
    print("Phase 2: Renaming to final names...")
    for old_id, new_id in MAPPING.items():
        if old_id == new_id:
            continue

        # Contracts
        tmp_contract = os.path.join(contracts_dir, f"TMP_{prefix}{new_id}.sol")
        new_contract = os.path.join(contracts_dir, f"{prefix}{new_id}.sol")
        if os.path.exists(tmp_contract):
            shutil.move(tmp_contract, new_contract)

        # Metadata
        tmp_meta = os.path.join(metadata_dir, f"TMP_{prefix}{new_id}.json")
        new_meta = os.path.join(metadata_dir, f"{prefix}{new_id}.json")
        if os.path.exists(tmp_meta):
            shutil.move(tmp_meta, new_meta)

        # Code acts annotation
        tmp_yaml = os.path.join(codeacts_dir, f"TMP_{prefix}{new_id}.yaml")
        new_yaml = os.path.join(codeacts_dir, f"{prefix}{new_id}.yaml")
        if os.path.exists(tmp_yaml):
            shutil.move(tmp_yaml, new_yaml)

    # Phase 3: Update content inside files
    print("Phase 3: Updating file contents...")
    for old_id, new_id in MAPPING.items():
        # Update metadata JSON
        meta_file = os.path.join(metadata_dir, f"{prefix}{new_id}.json")
        if os.path.exists(meta_file):
            with open(meta_file, 'r') as f:
                content = f.read()
            content = update_json_content(content, old_id, new_id, prefix)
            with open(meta_file, 'w') as f:
                f.write(content)

        # Update code acts YAML
        yaml_file = os.path.join(codeacts_dir, f"{prefix}{new_id}.yaml")
        if os.path.exists(yaml_file):
            with open(yaml_file, 'r') as f:
                content = f.read()
            content = update_yaml_content(content, old_id, new_id, prefix)
            with open(yaml_file, 'w') as f:
                f.write(content)

    print(f"Done with {variant_dir}")

def main():
    print("Renumbering temporal_contamination samples...")
    print(f"Mapping: {len(MAPPING)} samples")

    # Show mapping for verification
    print("\nMapping (samples that change):")
    for old_id, new_id in MAPPING.items():
        if old_id != new_id:
            print(f"  {old_id} -> {new_id}")

    # Process each variant
    for variant_dir, prefix in VARIANTS:
        renumber_variant(variant_dir, prefix)

    print("\n=== Renumbering complete! ===")

if __name__ == "__main__":
    main()
