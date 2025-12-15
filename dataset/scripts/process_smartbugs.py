#!/usr/bin/env python3
"""
Process SmartBugs Curated dataset into standardized format with difficulty tiers.
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Any
import re


# Vulnerability type mapping to standardized taxonomy
VULN_TYPE_MAPPING = {
    "reentrancy": "reentrancy",
    "access_control": "access_control",
    "arithmetic": "integer_issues",
    "unchecked_low_level_calls": "unchecked_return",
    "denial_of_service": "dos",
    "time_manipulation": "timestamp_dependency",
    "bad_randomness": "weak_randomness",
    "front_running": "front_running",
    "short_addresses": "short_address",
    "other": "logic_error"
}

# Difficulty tier assignment heuristics
DIFFICULTY_HEURISTICS = {
    # Tier 1: Classic patterns, single function
    "tier_1": {
        "reentrancy": ["withdrawAll", "withdraw", "simple"],
        "access_control": ["constructor", "onlyOwner", "tx.origin"],
        "integer_issues": ["overflow", "underflow"],
        "unchecked_return": ["call", "send"],
    },
    # Tier 2: Multiple functions or state tracking needed
    "tier_2": {
        "dos": ["gas", "revert", "unbounded"],
        "timestamp_dependency": ["block.timestamp", "now"],
        "weak_randomness": ["blockhash", "random"],
    },
    # Tier 3+: Complex or cross-contract (we'll manually adjust these)
    "tier_3": {
        "front_running": ["race"],
        "logic_error": ["business"],
    }
}


class SmartBugsProcessor:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.raw_path = self.base_path / "raw" / "smartbugs-curated"
        self.output_path = self.base_path / "processed" / "difficulty_stratified"
        self.metadata_path = self.base_path / "metadata"
        
        # Load vulnerabilities JSON
        with open(self.raw_path / "vulnerabilities.json", "r") as f:
            self.vulnerabilities_data = json.load(f)
    
    def extract_file_content(self, file_path: str) -> str:
        """Read the Solidity file content."""
        full_path = self.raw_path / file_path
        with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read()
    
    def assign_difficulty_tier(self, vuln_data: Dict, file_content: str) -> int:
        """
        Assign difficulty tier based on heuristics.
        
        Tier 1: Single function, textbook pattern
        Tier 2: Multiple functions or state tracking
        Tier 3: Cross-contract or business logic
        Tier 4: Expert-level (rare in SmartBugs)
        """
        vuln_type = vuln_data.get("category", "")
        standardized_type = VULN_TYPE_MAPPING.get(vuln_type, "logic_error")
        
        # Count functions and complexity indicators
        function_count = len(re.findall(r'function\s+\w+', file_content))
        has_external_calls = 'call.value' in file_content or '.call(' in file_content
        has_modifiers = 'modifier' in file_content
        lines_of_code = len([l for l in file_content.split('\n') if l.strip()])
        
        # Default tier based on vulnerability type
        if standardized_type in ["reentrancy", "access_control", "unchecked_return"]:
            base_tier = 1
        elif standardized_type in ["integer_issues", "dos", "timestamp_dependency"]:
            base_tier = 2
        else:
            base_tier = 2
        
        # Adjust based on complexity
        if lines_of_code > 200:
            base_tier = min(base_tier + 1, 4)
        if function_count > 10:
            base_tier = min(base_tier + 1, 4)
        if has_modifiers and standardized_type == "access_control":
            base_tier = max(base_tier, 2)  # More sophisticated access control
        
        return base_tier
    
    def extract_vulnerable_function(self, file_content: str, vulnerable_lines: List[int]) -> str:
        """Extract the name of the vulnerable function."""
        if not vulnerable_lines:
            return "unknown"
        
        lines = file_content.split('\n')
        target_line = vulnerable_lines[0] - 1  # 0-indexed
        
        # Search backwards from vulnerable line to find function declaration
        for i in range(target_line, max(0, target_line - 50), -1):
            match = re.search(r'function\s+(\w+)', lines[i])
            if match:
                return match.group(1)
        
        return "unknown"
    
    def generate_description(self, vuln_data: Dict, file_content: str) -> str:
        """Generate a description of the vulnerability."""
        category = vuln_data.get("category", "unknown")
        lines = vuln_data.get("lines", [])
        
        descriptions = {
            "reentrancy": "Reentrancy vulnerability - external call before state update allows recursive calls",
            "access_control": "Access control vulnerability - missing or incorrect authorization checks",
            "arithmetic": "Integer overflow/underflow vulnerability - arithmetic operations without bounds checking",
            "unchecked_low_level_calls": "Unchecked return value - low-level call result not validated",
            "denial_of_service": "Denial of service vulnerability - resource exhaustion or revert conditions",
            "time_manipulation": "Timestamp dependency - reliance on block.timestamp for critical logic",
            "bad_randomness": "Weak randomness - predictable random number generation",
            "front_running": "Front-running vulnerability - transaction ordering dependence",
        }
        
        base_description = descriptions.get(category, "Security vulnerability")
        if lines:
            return f"{base_description} at line(s) {', '.join(map(str, lines))}"
        return base_description
    
    def generate_fix_description(self, vuln_type: str) -> str:
        """Generate fix description based on vulnerability type."""
        fixes = {
            "reentrancy": "Apply checks-effects-interactions pattern: update state before external calls, or use ReentrancyGuard",
            "access_control": "Add proper access control modifiers (onlyOwner, require statements) or avoid tx.origin",
            "integer_issues": "Use SafeMath library or Solidity 0.8+ with built-in overflow checks",
            "unchecked_return": "Check return value and handle failures appropriately",
            "dos": "Avoid unbounded loops, implement pull payment pattern, add gas limits",
            "timestamp_dependency": "Use block.number for time-based logic or accept timestamp manipulation risk",
            "weak_randomness": "Use Chainlink VRF or commit-reveal scheme for randomness",
            "front_running": "Use commit-reveal scheme or submarine sends",
        }
        return fixes.get(vuln_type, "Apply security best practices to fix this vulnerability")
    
    def process_entry(self, entry: Dict) -> Dict[str, Any]:
        """Process a single vulnerability entry."""
        file_path = entry.get("path", "")
        file_name = entry.get("name", "")
        
        # Extract category from first vulnerability (most files have one category)
        vulns = entry.get("vulnerabilities", [])
        if not vulns:
            return None
        
        first_vuln = vulns[0]
        category = first_vuln.get("category", "")
        vulnerable_lines = first_vuln.get("lines", [])
        
        # Read file content
        file_content = self.extract_file_content(file_path)
        
        # Map to standardized vulnerability type
        standardized_type = VULN_TYPE_MAPPING.get(category, "logic_error")
        
        # Assign difficulty tier
        difficulty_tier = self.assign_difficulty_tier(first_vuln, file_content)
        
        # Extract vulnerable function
        vulnerable_function = self.extract_vulnerable_function(file_content, vulnerable_lines)
        
        # Generate descriptions
        description = self.generate_description(first_vuln, file_content)
        fix_description = self.generate_fix_description(standardized_type)
        
        # Determine severity based on vulnerability type
        severity_map = {
            "reentrancy": "high",
            "access_control": "high",
            "integer_issues": "high",
            "unchecked_return": "medium",
            "dos": "medium",
            "timestamp_dependency": "low",
            "weak_randomness": "medium",
            "front_running": "medium",
        }
        severity = severity_map.get(standardized_type, "medium")
        
        # Create standardized entry
        processed_entry = {
            "id": f"smartbugs_{category}_{file_name.replace('.sol', '')}",
            "source_dataset": "smartbugs-curated",
            "language": "solidity",
            "chain": "evm",
            
            "file_name": file_name,
            "file_content": file_content,
            "vulnerable_function": vulnerable_function,
            "vulnerable_lines": vulnerable_lines,
            
            "vulnerability_type": standardized_type,
            "original_category": category,
            "severity": severity,
            "difficulty_tier": difficulty_tier,
            
            "description": description,
            "fix_description": fix_description,
            
            "is_vulnerable": True,
            "context_level": "single_file",
            
            "original_source_path": file_path,
            "pragma": entry.get("pragma", "unknown"),
            "source_url": entry.get("source", ""),
        }
        
        return processed_entry
    
    def process_all(self) -> List[Dict]:
        """Process all vulnerabilities in the dataset."""
        processed_entries = []
        
        print(f"Processing {len(self.vulnerabilities_data)} entries from SmartBugs...")
        
        for entry in self.vulnerabilities_data:
            try:
                processed = self.process_entry(entry)
                if processed:
                    processed_entries.append(processed)
            except Exception as e:
                print(f"Error processing {entry.get('name', 'unknown')}: {e}")
                continue
        
        print(f"Successfully processed {len(processed_entries)} entries")
        return processed_entries
    
    def save_processed_data(self, processed_entries: List[Dict]):
        """Save processed entries organized by difficulty tier."""
        # Create output directories
        self.output_path.mkdir(parents=True, exist_ok=True)
        self.metadata_path.mkdir(parents=True, exist_ok=True)
        
        # Group by difficulty tier
        by_tier = {1: [], 2: [], 3: [], 4: []}
        for entry in processed_entries:
            tier = entry["difficulty_tier"]
            by_tier[tier].append(entry)
        
        # Save by tier
        tier_names = {1: "tier_1_easy", 2: "tier_2_medium", 3: "tier_3_hard", 4: "tier_4_expert"}
        for tier, entries in by_tier.items():
            tier_dir = self.output_path / tier_names[tier] / "solidity"
            tier_dir.mkdir(parents=True, exist_ok=True)
            
            tier_file = tier_dir / "smartbugs.json"
            with open(tier_file, "w") as f:
                json.dump(entries, f, indent=2)
            
            print(f"Tier {tier} ({tier_names[tier]}): {len(entries)} entries saved to {tier_file}")
        
        # Save master index
        master_file = self.metadata_path / "smartbugs_processed.json"
        with open(master_file, "w") as f:
            json.dump(processed_entries, f, indent=2)
        
        print(f"\nMaster index saved to {master_file}")
        
        # Print statistics
        self.print_statistics(processed_entries)
    
    def print_statistics(self, processed_entries: List[Dict]):
        """Print dataset statistics."""
        print("\n" + "="*60)
        print("SmartBugs Processing Statistics")
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
        tier_names = {1: "Tier 1 (Easy)", 2: "Tier 2 (Medium)", 3: "Tier 3 (Hard)", 4: "Tier 4 (Expert)"}
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
    processor = SmartBugsProcessor(base_path)
    
    # Process all entries
    processed_entries = processor.process_all()
    
    # Save organized data
    processor.save_processed_data(processed_entries)


if __name__ == "__main__":
    main()
