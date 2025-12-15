#!/usr/bin/env python3
"""
Consolidate all processed datasets into a single master index.
Generate summary statistics and validate the dataset.
"""

import json
from pathlib import Path
from collections import defaultdict
from typing import List, Dict


class DatasetConsolidator:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.metadata_path = self.base_path / "metadata"
        self.output_path = self.base_path / "processed" / "difficulty_stratified"
    
    def load_all_datasets(self) -> Dict[str, List[Dict]]:
        """Load all processed datasets."""
        datasets = {}
        
        dataset_files = {
            "smartbugs": self.metadata_path / "smartbugs_processed.json",
            "defivulnlabs": self.metadata_path / "defivulnlabs_processed.json",
            "not_so_smart": self.metadata_path / "not_so_smart_processed.json",
            "sealevel_attacks": self.metadata_path / "sealevel_attacks_processed.json",
        }
        
        for name, path in dataset_files.items():
            if path.exists():
                with open(path, "r") as f:
                    datasets[name] = json.load(f)
                print(f"Loaded {len(datasets[name])} entries from {name}")
            else:
                print(f"Warning: {path} not found")
                datasets[name] = []
        
        return datasets
    
    def consolidate(self, datasets: Dict[str, List[Dict]]) -> List[Dict]:
        """Merge all datasets into one master list."""
        all_entries = []
        for dataset_name, entries in datasets.items():
            all_entries.extend(entries)
        
        print(f"\nTotal entries: {len(all_entries)}")
        return all_entries
    
    def generate_statistics(self, all_entries: List[Dict]):
        """Generate comprehensive statistics."""
        print("\n" + "="*70)
        print("CONSOLIDATED DATASET STATISTICS")
        print("="*70)
        
        print(f"\nTotal Entries: {len(all_entries)}")
        
        # By source dataset
        by_source = defaultdict(int)
        for entry in all_entries:
            by_source[entry["source_dataset"]] += 1
        
        print("\nBy Source Dataset:")
        for source, count in sorted(by_source.items()):
            print(f"  {source:30} {count:4} ({count/len(all_entries)*100:.1f}%)")
        
        # By language
        by_language = defaultdict(int)
        for entry in all_entries:
            by_language[entry["language"]] += 1
        
        print("\nBy Language:")
        for lang, count in sorted(by_language.items()):
            print(f"  {lang:30} {count:4} ({count/len(all_entries)*100:.1f}%)")
        
        # By difficulty tier
        by_tier = defaultdict(int)
        for entry in all_entries:
            by_tier[entry["difficulty_tier"]] += 1
        
        print("\nBy Difficulty Tier:")
        tier_names = {1: "Tier 1 (Easy)", 2: "Tier 2 (Medium)", 
                     3: "Tier 3 (Hard)", 4: "Tier 4 (Expert)"}
        for tier in sorted(by_tier.keys()):
            name = tier_names.get(tier, f"Tier {tier}")
            count = by_tier[tier]
            print(f"  {name:30} {count:4} ({count/len(all_entries)*100:.1f}%)")
        
        # By vulnerability type (top 15)
        by_vuln = defaultdict(int)
        for entry in all_entries:
            by_vuln[entry["vulnerability_type"]] += 1
        
        print("\nBy Vulnerability Type (Top 15):")
        for vuln_type, count in sorted(by_vuln.items(), key=lambda x: -x[1])[:15]:
            print(f"  {vuln_type:30} {count:4}")
        
        # By severity
        by_severity = defaultdict(int)
        for entry in all_entries:
            by_severity[entry["severity"]] += 1
        
        print("\nBy Severity:")
        for sev in ["critical", "high", "medium", "low"]:
            count = by_severity.get(sev, 0)
            if count > 0:
                print(f"  {sev:30} {count:4} ({count/len(all_entries)*100:.1f}%)")
        
        # Context level
        by_context = defaultdict(int)
        for entry in all_entries:
            by_context[entry.get("context_level", "single_file")] += 1
        
        print("\nBy Context Level:")
        for context, count in sorted(by_context.items()):
            print(f"  {context:30} {count:4}")
        
        # Entries with PoCs
        has_poc = sum(1 for e in all_entries if e.get("has_poc", False))
        print(f"\nEntries with PoC: {has_poc} ({has_poc/len(all_entries)*100:.1f}%)")
        
        # Entries with remediation
        has_remediation = sum(1 for e in all_entries if e.get("has_remediation", False))
        print(f"Entries with remediation: {has_remediation} ({has_remediation/len(all_entries)*100:.1f}%)")
        
        print("\n" + "="*70)
    
    def validate_dataset(self, all_entries: List[Dict]) -> List[str]:
        """Validate dataset entries and return warnings."""
        warnings = []
        
        required_fields = ["id", "language", "vulnerability_type", "difficulty_tier", 
                          "severity", "is_vulnerable", "file_content"]
        
        for i, entry in enumerate(all_entries):
            # Check required fields
            for field in required_fields:
                if field not in entry:
                    warnings.append(f"Entry {i} ({entry.get('id', 'unknown')}): Missing field '{field}'")
            
            # Check for duplicate IDs
            ids = [e["id"] for e in all_entries]
            if ids.count(entry["id"]) > 1:
                warnings.append(f"Duplicate ID: {entry['id']}")
            
            # Check difficulty tier range
            tier = entry.get("difficulty_tier", 0)
            if tier not in [1, 2, 3, 4]:
                warnings.append(f"Entry {entry.get('id')}: Invalid difficulty tier {tier}")
            
            # Check severity
            severity = entry.get("severity", "")
            if severity not in ["critical", "high", "medium", "low"]:
                warnings.append(f"Entry {entry.get('id')}: Invalid severity '{severity}'")
        
        return warnings
    
    def save_master_index(self, all_entries: List[Dict]):
        """Save the consolidated master index."""
        master_file = self.metadata_path / "difficulty_stratified_master.json"
        
        with open(master_file, "w") as f:
            json.dump(all_entries, f, indent=2)
        
        print(f"\nMaster index saved to: {master_file}")
        print(f"Total entries: {len(all_entries)}")
        
        # Also save a summary
        summary = {
            "total_entries": len(all_entries),
            "by_source": {},
            "by_language": {},
            "by_tier": {},
            "by_vulnerability_type": {},
            "by_severity": {},
        }
        
        for entry in all_entries:
            summary["by_source"][entry["source_dataset"]] = \
                summary["by_source"].get(entry["source_dataset"], 0) + 1
            summary["by_language"][entry["language"]] = \
                summary["by_language"].get(entry["language"], 0) + 1
            summary["by_tier"][str(entry["difficulty_tier"])] = \
                summary["by_tier"].get(str(entry["difficulty_tier"]), 0) + 1
            summary["by_vulnerability_type"][entry["vulnerability_type"]] = \
                summary["by_vulnerability_type"].get(entry["vulnerability_type"], 0) + 1
            summary["by_severity"][entry["severity"]] = \
                summary["by_severity"].get(entry["severity"], 0) + 1
        
        summary_file = self.metadata_path / "dataset_summary.json"
        with open(summary_file, "w") as f:
            json.dump(summary, f, indent=2)
        
        print(f"Summary saved to: {summary_file}")
    
    def run(self):
        """Main execution."""
        print("Consolidating all datasets...")
        
        # Load all datasets
        datasets = self.load_all_datasets()
        
        # Consolidate
        all_entries = self.consolidate(datasets)
        
        # Generate statistics
        self.generate_statistics(all_entries)
        
        # Validate
        warnings = self.validate_dataset(all_entries)
        if warnings:
            print(f"\n⚠️  Found {len(warnings)} validation warnings:")
            for warning in warnings[:10]:  # Show first 10
                print(f"  - {warning}")
            if len(warnings) > 10:
                print(f"  ... and {len(warnings) - 10} more")
        else:
            print("\n✅ No validation warnings")
        
        # Save master index
        self.save_master_index(all_entries)


def main():
    base_path = "/Users/poamen/projects/grace/blockbench/base/dataset"
    consolidator = DatasetConsolidator(base_path)
    consolidator.run()


if __name__ == "__main__":
    main()
