#!/usr/bin/env python3
"""
Process Not-So-Smart-Contracts dataset into standardized format.
These are educational examples with both vulnerable and fixed versions.
"""

import json
import os
import re
from pathlib import Path
from typing import Dict, List, Any, Optional


VULN_MAPPING = {
    "bad_randomness": "weak_randomness",
    "denial_of_service": "dos",
    "forced_ether_reception": "forced_ether",
    "incorrect_interface": "interface_mismatch",
    "integer_overflow": "integer_issues",
    "race_condition": "front_running",
    "reentrancy": "reentrancy",
    "unchecked_external_call": "unchecked_return",
    "unprotected_function": "access_control",
    "variable shadowing": "variable_shadowing",
    "wrong_constructor_name": "access_control",
    "honeypots": "honeypot",
}


class NotSoSmartContractsProcessor:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.raw_path = self.base_path / "raw" / "not-so-smart-contracts"
        self.output_path = self.base_path / "processed" / "difficulty_stratified"
        self.metadata_path = self.base_path / "metadata"
    
    def read_category_readme(self, category_dir: Path) -> Dict[str, str]:
        """Read README from vulnerability category directory."""
        readme_path = category_dir / "README.md"
        if not readme_path.exists():
            return {"description": "", "mitigation": "", "references": []}
        
        try:
            with open(readme_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
        except:
            return {"description": "", "mitigation": "", "references": []}
        
        metadata = {"description": "", "mitigation": "", "references": []}
        
        # Extract description (usually first paragraph or section)
        desc_match = re.search(r'## Description\s*\n(.*?)(?=##|\Z)', content, re.DOTALL)
        if not desc_match:
            desc_match = re.search(r'^(.+?)\n\n', content, re.DOTALL)
        if desc_match:
            metadata["description"] = desc_match.group(1).strip()
        
        # Extract recommendations/mitigation
        mitigation_match = re.search(r'## Recommend(?:ations|ed)?\s*\n(.*?)(?=##|\Z)', content, re.DOTALL)
        if mitigation_match:
            metadata["mitigation"] = mitigation_match.group(1).strip()
        
        # Extract references
        refs = re.findall(r'\[.*?\]\((https?://[^\)]+)\)', content)
        metadata["references"] = refs
        
        return metadata
    
    def extract_vulnerable_functions(self, file_content: str) -> List[str]:
        """Extract function names that are vulnerable (not marked as _fixed)."""
        functions = re.findall(r'function\s+(\w+)\s*\(', file_content)
        # Filter out fixed/safe versions
        vulnerable = [f for f in functions if not any(keyword in f.lower() for keyword in ['fixed', 'safe', 'secure', 'remediated'])]
        return vulnerable
    
    def assign_difficulty_tier(self, category: str, file_content: str) -> int:
        """Assign difficulty tier. Most not-so-smart-contracts are educational (Tier 1-2)."""
        # Count complexity indicators
        function_count = len(re.findall(r'function\s+\w+', file_content))
        lines_of_code = len([l for l in file_content.split('\n') if l.strip() and not l.strip().startswith('//')])
        has_multiple_contracts = len(re.findall(r'contract\s+\w+', file_content)) > 1
        
        # Honeypots and race conditions are more complex
        if category in ["honeypots", "race_condition"]:
            return 3
        
        # Large files or multiple contracts
        if lines_of_code > 300 or has_multiple_contracts:
            return 2
        
        # Most are straightforward examples
        return 1
    
    def determine_severity(self, vuln_type: str) -> str:
        """Determine severity based on vulnerability type."""
        critical_types = ["reentrancy", "integer_issues", "access_control"]
        high_types = ["unchecked_return", "dos", "front_running"]
        medium_types = ["weak_randomness", "variable_shadowing", "interface_mismatch", "forced_ether"]
        
        if vuln_type in critical_types:
            return "high"
        elif vuln_type in high_types:
            return "medium"
        else:
            return "low"
    
    def process_file(self, file_path: Path, category: str, category_metadata: Dict) -> Optional[Dict[str, Any]]:
        """Process a single contract file."""
        file_name = file_path.name
        
        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                file_content = f.read()
        except Exception as e:
            print(f"Error reading {file_name}: {e}")
            return None
        
        # Get vulnerability type
        vuln_type = VULN_MAPPING.get(category, "logic_error")
        
        # Extract vulnerable functions
        vulnerable_functions = self.extract_vulnerable_functions(file_content)
        vulnerable_function = vulnerable_functions[0] if vulnerable_functions else "multiple"
        
        # Assign difficulty tier
        difficulty_tier = self.assign_difficulty_tier(category, file_content)
        
        # Determine severity
        severity = self.determine_severity(vuln_type)
        
        # Check if has both vulnerable and fixed versions
        has_remediation = bool(re.search(r'function\s+\w+.*?(?:fixed|safe|secure)', file_content, re.IGNORECASE))
        
        # Extract pragma version
        pragma_match = re.search(r'pragma solidity\s+([^;]+);', file_content)
        pragma = pragma_match.group(1) if pragma_match else "unknown"
        
        # Create entry
        entry = {
            "id": f"notso_{category}_{file_name.replace('.sol', '').lower()}",
            "source_dataset": "not-so-smart-contracts",
            "language": "solidity",
            "chain": "evm",
            
            "file_name": file_name,
            "file_content": file_content,
            "vulnerable_function": vulnerable_function,
            "vulnerable_lines": [],
            
            "vulnerability_type": vuln_type,
            "category": category,
            "severity": severity,
            "difficulty_tier": difficulty_tier,
            
            "description": category_metadata.get("description", f"{category.replace('_', ' ').title()} vulnerability"),
            "fix_description": category_metadata.get("mitigation", "See fixed version in same file"),
            "references": category_metadata.get("references", []),
            
            "is_vulnerable": True,
            "has_remediation": has_remediation,
            "context_level": "single_file",
            
            "original_source_path": str(file_path.relative_to(self.raw_path)),
            "pragma": pragma,
            "source": "Trail of Bits",
        }
        
        return entry
    
    def process_all(self) -> List[Dict]:
        """Process all not-so-smart-contracts files."""
        processed_entries = []
        
        # Get all category directories
        category_dirs = [d for d in self.raw_path.iterdir() if d.is_dir() and not d.name.startswith('.')]
        
        print(f"Processing {len(category_dirs)} categories from not-so-smart-contracts...")
        
        for category_dir in category_dirs:
            category = category_dir.name
            
            # Read category README
            category_metadata = self.read_category_readme(category_dir)
            
            # Find all .sol files in this category (including subdirectories)
            sol_files = list(category_dir.rglob("*.sol"))
            
            print(f"  {category}: {len(sol_files)} files")
            
            for file_path in sol_files:
                try:
                    entry = self.process_file(file_path, category, category_metadata)
                    if entry:
                        processed_entries.append(entry)
                except Exception as e:
                    print(f"    Error processing {file_path.name}: {e}")
                    continue
        
        print(f"\nSuccessfully processed {len(processed_entries)} entries")
        return processed_entries
    
    def save_processed_data(self, processed_entries: List[Dict]):
        """Save processed entries organized by difficulty tier."""
        self.output_path.mkdir(parents=True, exist_ok=True)
        self.metadata_path.mkdir(parents=True, exist_ok=True)
        
        # Group by difficulty tier
        by_tier = {1: [], 2: [], 3: []}
        for entry in processed_entries:
            tier = entry["difficulty_tier"]
            if tier in by_tier:
                by_tier[tier].append(entry)
        
        # Save by tier
        tier_names = {1: "tier_1_easy", 2: "tier_2_medium", 3: "tier_3_hard"}
        for tier, entries in by_tier.items():
            if not entries:
                continue
            
            tier_dir = self.output_path / tier_names[tier] / "solidity"
            tier_dir.mkdir(parents=True, exist_ok=True)
            
            tier_file = tier_dir / "not_so_smart.json"
            with open(tier_file, "w") as f:
                json.dump(entries, f, indent=2)
            
            print(f"Tier {tier} ({tier_names[tier]}): {len(entries)} entries saved to {tier_file}")
        
        # Save master index
        master_file = self.metadata_path / "not_so_smart_processed.json"
        with open(master_file, "w") as f:
            json.dump(processed_entries, f, indent=2)
        
        print(f"\nMaster index saved to {master_file}")
        
        # Print statistics
        self.print_statistics(processed_entries)
    
    def print_statistics(self, processed_entries: List[Dict]):
        """Print dataset statistics."""
        print("\n" + "="*60)
        print("Not-So-Smart-Contracts Processing Statistics")
        print("="*60)
        
        # By vulnerability type
        by_type = {}
        for entry in processed_entries:
            vtype = entry["vulnerability_type"]
            by_type[vtype] = by_type.get(vtype, 0) + 1
        
        print("\nBy Vulnerability Type:")
        for vtype, count in sorted(by_type.items(), key=lambda x: -x[1]):
            print(f"  {vtype:30} {count:3}")
        
        # By difficulty tier
        by_tier = {}
        for entry in processed_entries:
            tier = entry["difficulty_tier"]
            by_tier[tier] = by_tier.get(tier, 0) + 1
        
        print("\nBy Difficulty Tier:")
        tier_names = {1: "Tier 1 (Easy)", 2: "Tier 2 (Medium)", 3: "Tier 3 (Hard)"}
        for tier in sorted(by_tier.keys()):
            print(f"  {tier_names[tier]:20} {by_tier[tier]:3}")
        
        # By severity
        by_severity = {}
        for entry in processed_entries:
            sev = entry["severity"]
            by_severity[sev] = by_severity.get(sev, 0) + 1
        
        print("\nBy Severity:")
        for sev, count in sorted(by_severity.items()):
            print(f"  {sev:20} {count:3}")
        
        print("\n" + "="*60)


def main():
    base_path = "/Users/poamen/projects/grace/blockbench/base/dataset"
    processor = NotSoSmartContractsProcessor(base_path)
    
    # Process all entries
    processed_entries = processor.process_all()
    
    # Save organized data
    processor.save_processed_data(processed_entries)


if __name__ == "__main__":
    main()
