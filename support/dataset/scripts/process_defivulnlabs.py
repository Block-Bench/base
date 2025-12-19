#!/usr/bin/env python3
"""
Process DeFiVulnLabs dataset into standardized format with difficulty tiers.
These are more complex, DeFi-specific vulnerabilities with PoCs.
"""

import json
import os
import re
from pathlib import Path
from typing import Dict, List, Any, Optional


# Vulnerability type mapping based on file names
VULN_MAPPING = {
    "reentrancy": "reentrancy",
    "readonly": "reentrancy",  # Read-only reentrancy
    "erc777-reentrancy": "reentrancy",
    "overflow": "integer_issues",
    "underflow": "integer_issues",
    "selfdestruct": "selfdestruct",
    "delegatecall": "delegatecall_injection",
    "dos": "dos",
    "randomness": "weak_randomness",
    "visibility": "access_control",
    "txorigin": "tx_origin_auth",
    "storage-collision": "storage_collision",
    "approve": "approval_scam",
    "signaturereplay": "signature_replay",
    "datalocation": "storage_misuse",
    "backdoor": "backdoor",
    "bypasscontract": "contract_check_bypass",
    "privatedata": "data_exposure",
    "callback": "unprotected_callback",
    "flashloan": "flash_loan_attack",
    "oracle": "oracle_manipulation",
    "price": "oracle_manipulation",
    "precision": "precision_loss",
    "fee-on-transfer": "token_incompatibility",
    "first-deposit": "inflation_attack",
    "unsafe": "unchecked_call",
    "frontrun": "front_running",
}


class DeFiVulnLabsProcessor:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.raw_path = self.base_path / "raw" / "DeFiVulnLabs"
        self.test_path = self.raw_path / "src" / "test"
        self.output_path = self.base_path / "processed" / "difficulty_stratified"
        self.metadata_path = self.base_path / "metadata"
    
    def extract_vulnerability_metadata(self, file_content: str) -> Dict[str, str]:
        """Extract metadata from file comments."""
        metadata = {
            "name": "",
            "description": "",
            "scenario": "",
            "mitigation": "",
            "references": []
        }
        
        # Extract Name
        name_match = re.search(r'Name:\s*(.+)', file_content)
        if name_match:
            metadata["name"] = name_match.group(1).strip()
        
        # Extract Description (multi-line)
        desc_match = re.search(r'Description:\s*\n((?:.*\n)*?)(?=\n\w+:|Scenario:|Mitigation:|REF|Contract)', file_content)
        if desc_match:
            metadata["description"] = desc_match.group(1).strip()
        
        # Extract Scenario
        scenario_match = re.search(r'Scenario:\s*\n((?:.*\n)*?)(?=\n\w+:|Mitigation:|REF|Contract)', file_content)
        if scenario_match:
            metadata["scenario"] = scenario_match.group(1).strip()
        
        # Extract Mitigation
        mitigation_match = re.search(r'Mitigation:\s*\n((?:.*\n)*?)(?=\nREF|Contract|\*\/)', file_content)
        if mitigation_match:
            metadata["mitigation"] = mitigation_match.group(1).strip()
        
        # Extract References
        ref_matches = re.findall(r'REF\d*\n(https?://[^\s\)]+)', file_content)
        metadata["references"] = ref_matches
        
        return metadata
    
    def extract_vulnerable_contract(self, file_content: str) -> Optional[str]:
        """Extract the vulnerable contract code (not the remediated or test contract)."""
        # Find the first contract that's not named "Remediated", "Fixed", "Secure", or "ContractTest"
        contracts = re.findall(
            r'contract\s+(\w+)(?:\s+is\s+[\w,\s]+)?\s*\{(.*?)(?=contract\s+\w+|\Z)',
            file_content,
            re.DOTALL
        )
        
        for name, body in contracts:
            if not any(keyword in name for keyword in ["Remediated", "Fixed", "Secure", "Test", "Attack"]):
                return f"contract {name} {{{body}"
        
        return None
    
    def classify_vulnerability_type(self, file_name: str, metadata: Dict) -> str:
        """Classify vulnerability type based on file name and metadata."""
        file_lower = file_name.lower().replace(".sol", "")
        
        for pattern, vuln_type in VULN_MAPPING.items():
            if pattern in file_lower:
                return vuln_type
        
        # Try to infer from metadata
        combined_text = (metadata.get("name", "") + " " + metadata.get("description", "")).lower()
        
        if "reentrancy" in combined_text or "reentrant" in combined_text:
            return "reentrancy"
        elif "overflow" in combined_text or "underflow" in combined_text:
            return "integer_issues"
        elif "access" in combined_text or "authorization" in combined_text:
            return "access_control"
        elif "oracle" in combined_text or "price" in combined_text:
            return "oracle_manipulation"
        elif "flash" in combined_text:
            return "flash_loan_attack"
        
        return "logic_error"
    
    def assign_difficulty_tier(self, file_name: str, metadata: Dict, file_content: str) -> int:
        """
        Assign difficulty tier. DeFiVulnLabs generally has more complex vulnerabilities.
        
        Tier 2: Standard DeFi patterns (basic reentrancy, access control)
        Tier 3: Complex interactions (flash loans, oracle manipulation, cross-contract)
        Tier 4: Expert-level (novel attacks, protocol-specific logic)
        """
        file_lower = file_name.lower()
        desc = metadata.get("description", "").lower()
        
        # Tier 4: Expert-level complexity
        expert_indicators = [
            "flash", "oracle", "price_manipulation", "readonly", "erc777",
            "storage-collision", "first-deposit", "signature", "invariant"
        ]
        if any(indicator in file_lower for indicator in expert_indicators):
            return 4
        
        # Tier 3: Hard - requires cross-contract understanding
        hard_indicators = [
            "callback", "delegatecall", "unsafe", "phantom", "nft",
            "precision", "fee-on-transfer"
        ]
        if any(indicator in file_lower for indicator in hard_indicators):
            return 3
        
        # Check complexity from content
        function_count = len(re.findall(r'function\s+\w+', file_content))
        has_interfaces = bool(re.search(r'interface\s+\w+', file_content))
        has_inheritance = bool(re.search(r'contract\s+\w+\s+is\s+', file_content))
        lines_of_code = len([l for l in file_content.split('\n') if l.strip() and not l.strip().startswith('//')])
        
        if lines_of_code > 200 or function_count > 8 or has_interfaces:
            return 3
        
        # Tier 2: Medium - standard vulnerabilities but still complex
        return 2
    
    def determine_severity(self, vuln_type: str, metadata: Dict) -> str:
        """Determine severity based on vulnerability type."""
        critical_types = ["reentrancy", "delegatecall_injection", "selfdestruct", 
                         "flash_loan_attack", "oracle_manipulation"]
        high_types = ["integer_issues", "access_control", "storage_collision", 
                     "unprotected_callback", "signature_replay"]
        medium_types = ["unchecked_call", "dos", "precision_loss", "weak_randomness"]
        
        if vuln_type in critical_types:
            return "critical"
        elif vuln_type in high_types:
            return "high"
        elif vuln_type in medium_types:
            return "medium"
        else:
            return "medium"
    
    def process_file(self, file_path: Path) -> Optional[Dict[str, Any]]:
        """Process a single DeFiVulnLabs test file."""
        file_name = file_path.name
        
        # Skip non-vulnerability files
        skip_files = ["utils", "helper", "interface", "import"]
        if any(skip in file_name.lower() for skip in skip_files):
            return None
        
        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                file_content = f.read()
        except Exception as e:
            print(f"Error reading {file_name}: {e}")
            return None
        
        # Extract metadata from comments
        metadata = self.extract_vulnerability_metadata(file_content)
        
        if not metadata["name"]:
            # Try to extract from comment header
            name_match = re.search(r'/\*+\s*\n\s*(.+?)\s*\n', file_content)
            if name_match:
                metadata["name"] = name_match.group(1)
        
        # Classify vulnerability type
        vuln_type = self.classify_vulnerability_type(file_name, metadata)
        
        # Assign difficulty tier
        difficulty_tier = self.assign_difficulty_tier(file_name, metadata, file_content)
        
        # Determine severity
        severity = self.determine_severity(vuln_type, metadata)
        
        # Extract vulnerable contract
        vulnerable_contract = self.extract_vulnerable_contract(file_content)
        
        # Create standardized entry
        entry = {
            "id": f"defivulnlabs_{file_name.replace('.sol', '').lower()}",
            "source_dataset": "DeFiVulnLabs",
            "language": "solidity",
            "chain": "evm",
            
            "file_name": file_name,
            "file_content": file_content,
            "vulnerable_contract_only": vulnerable_contract if vulnerable_contract else "see full file",
            "vulnerable_function": "multiple",  # Usually multiple functions shown
            "vulnerable_lines": [],  # Not explicitly marked
            
            "vulnerability_type": vuln_type,
            "severity": severity,
            "difficulty_tier": difficulty_tier,
            
            "vulnerability_name": metadata["name"],
            "description": metadata["description"] if metadata["description"] else metadata["name"],
            "scenario": metadata["scenario"],
            "fix_description": metadata["mitigation"],
            "references": metadata["references"],
            
            "is_vulnerable": True,
            "has_poc": True,  # All DeFiVulnLabs entries have PoCs
            "has_remediation": "Remediated" in file_content or "Fixed" in file_content,
            "context_level": "single_file" if difficulty_tier <= 2 else "intra_contract",
            
            "original_source_path": str(file_path.relative_to(self.raw_path)),
            "framework": "foundry",
        }
        
        return entry
    
    def process_all(self) -> List[Dict]:
        """Process all DeFiVulnLabs test files."""
        processed_entries = []
        
        # Get all .sol files in test directory
        sol_files = list(self.test_path.glob("*.sol"))
        
        print(f"Processing {len(sol_files)} files from DeFiVulnLabs...")
        
        for file_path in sol_files:
            try:
                entry = self.process_file(file_path)
                if entry:
                    processed_entries.append(entry)
            except Exception as e:
                print(f"Error processing {file_path.name}: {e}")
                continue
        
        print(f"Successfully processed {len(processed_entries)} entries")
        return processed_entries
    
    def save_processed_data(self, processed_entries: List[Dict]):
        """Save processed entries organized by difficulty tier."""
        self.output_path.mkdir(parents=True, exist_ok=True)
        self.metadata_path.mkdir(parents=True, exist_ok=True)
        
        # Group by difficulty tier
        by_tier = {2: [], 3: [], 4: []}
        for entry in processed_entries:
            tier = entry["difficulty_tier"]
            if tier in by_tier:
                by_tier[tier].append(entry)
        
        # Save by tier
        tier_names = {2: "tier_2_medium", 3: "tier_3_hard", 4: "tier_4_expert"}
        for tier, entries in by_tier.items():
            if not entries:
                continue
            
            tier_dir = self.output_path / tier_names[tier] / "solidity"
            tier_dir.mkdir(parents=True, exist_ok=True)
            
            tier_file = tier_dir / "defivulnlabs.json"
            with open(tier_file, "w") as f:
                json.dump(entries, f, indent=2)
            
            print(f"Tier {tier} ({tier_names[tier]}): {len(entries)} entries saved to {tier_file}")
        
        # Save master index
        master_file = self.metadata_path / "defivulnlabs_processed.json"
        with open(master_file, "w") as f:
            json.dump(processed_entries, f, indent=2)
        
        print(f"\nMaster index saved to {master_file}")
        
        # Print statistics
        self.print_statistics(processed_entries)
    
    def print_statistics(self, processed_entries: List[Dict]):
        """Print dataset statistics."""
        print("\n" + "="*60)
        print("DeFiVulnLabs Processing Statistics")
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
        tier_names = {2: "Tier 2 (Medium)", 3: "Tier 3 (Hard)", 4: "Tier 4 (Expert)"}
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
    processor = DeFiVulnLabsProcessor(base_path)
    
    # Process all entries
    processed_entries = processor.process_all()
    
    # Save organized data
    processor.save_processed_data(processed_entries)


if __name__ == "__main__":
    main()
