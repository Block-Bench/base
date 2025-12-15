#!/usr/bin/env python3
"""
Process Sealevel Attacks (Solana/Anchor) dataset into standardized format.
These are Solana-specific vulnerabilities with insecure/secure versions.
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Any, Optional


# Vulnerability type mapping for Solana
SOLANA_VULN_MAPPING = {
    "0-signer-authorization": "missing_signer_check",
    "1-account-data-matching": "account_validation",
    "2-owner-checks": "missing_owner_check",
    "3-type-cosplay": "type_cosplay",
    "4-initialization": "missing_initialization_check",
    "5-arbitrary-cpi": "cpi_injection",
    "6-duplicate-mutable-accounts": "duplicate_mutable_accounts",
    "7-bump-seed-canonicalization": "pda_manipulation",
    "8-pda-sharing": "pda_sharing",
    "9-closing-accounts": "unclosed_accounts",
    "10-sysvar-address-checking": "sysvar_validation",
}


class SealevelAttacksProcessor:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.raw_path = self.base_path / "raw" / "sealevel-attacks"
        self.programs_path = self.raw_path / "programs"
        self.output_path = self.base_path / "processed" / "difficulty_stratified"
        self.metadata_path = self.base_path / "metadata"
    
    def get_vulnerability_description(self, vuln_dir: str) -> str:
        """Generate description based on vulnerability directory name."""
        descriptions = {
            "0-signer-authorization": "Missing signer check allows unauthorized users to call functions that should be restricted",
            "1-account-data-matching": "Lack of account data validation allows account substitution attacks",
            "2-owner-checks": "Missing owner validation allows use of accounts owned by wrong programs",
            "3-type-cosplay": "Account type confusion - accounts can impersonate other account types",
            "4-initialization": "Missing initialization checks allow reinitialization attacks",
            "5-arbitrary-cpi": "Unconstrained Cross-Program Invocation (CPI) allows arbitrary program calls",
            "6-duplicate-mutable-accounts": "Passing the same account twice as mutable can cause unexpected behavior",
            "7-bump-seed-canonicalization": "Non-canonical bump seeds in PDA derivation can be exploited",
            "8-pda-sharing": "Improper PDA seed design allows accounts to be controlled by unintended parties",
            "9-closing-accounts": "Improper account closure leaves accounts open to revival attacks",
            "10-sysvar-address-checking": "Missing sysvar address validation allows fake sysvar injection",
        }
        return descriptions.get(vuln_dir, "Solana security vulnerability")
    
    def get_fix_description(self, vuln_dir: str) -> str:
        """Generate fix description based on vulnerability type."""
        fixes = {
            "0-signer-authorization": "Add is_signer check: require!(ctx.accounts.authority.is_signer, ErrorCode::Unauthorized)",
            "1-account-data-matching": "Validate account data matches expected values before use",
            "2-owner-checks": "Check account owner: require!(account.owner == expected_program_id, ErrorCode::InvalidOwner)",
            "3-type-cosplay": "Use Anchor's Account<'info, T> type to enforce account type validation",
            "4-initialization": "Add initialization flag and check: require!(!account.is_initialized, ErrorCode::AlreadyInitialized)",
            "5-arbitrary-cpi": "Constrain target program in CPI: require!(ctx.accounts.target_program.key() == expected_program_id)",
            "6-duplicate-mutable-accounts": "Add constraint to ensure accounts are different: #[account(constraint = account1.key() != account2.key())]",
            "7-bump-seed-canonicalization": "Use canonical bump: let (pda, bump) = Pubkey::find_program_address(&[seed], program_id); require!(bump == provided_bump)",
            "8-pda-sharing": "Use unique seeds per user: &[b\"prefix\", user.key().as_ref(), &[bump]]",
            "9-closing-accounts": "Zero out data and transfer lamports to recipient, use close constraint in Anchor",
            "10-sysvar-address-checking": "Validate sysvar address: require!(sysvar.key() == expected_sysvar_address)",
        }
        return fixes.get(vuln_dir, "Apply Solana security best practices")
    
    def assign_difficulty_tier(self, vuln_type: str, file_content: str) -> int:
        """
        Assign difficulty tier for Solana vulnerabilities.
        Generally Tier 2-3 as Solana programming model is more complex than EVM.
        """
        # Solana-specific complexity indicators
        lines = len([l for l in file_content.split('\n') if l.strip()])
        has_cpi = 'invoke' in file_content or 'invoke_signed' in file_content
        has_pda = 'Pubkey::find_program_address' in file_content or 'create_program_address' in file_content
        struct_count = len(re.findall(r'struct\s+\w+', file_content))
        
        # Type cosplay, PDA issues, CPI issues are advanced
        if vuln_type in ["type_cosplay", "pda_manipulation", "pda_sharing", "cpi_injection"]:
            return 3
        
        # Duplicate mutable accounts is expert-level
        if vuln_type == "duplicate_mutable_accounts":
            return 4
        
        # Complex files with CPI or PDA logic
        if has_cpi or has_pda or struct_count > 3:
            return 3
        
        # Basic checks are medium difficulty
        return 2
    
    def determine_severity(self, vuln_type: str) -> str:
        """Determine severity for Solana vulnerabilities."""
        critical_types = ["missing_signer_check", "missing_owner_check", "cpi_injection", 
                         "missing_initialization_check"]
        high_types = ["account_validation", "type_cosplay", "pda_manipulation", 
                     "unclosed_accounts", "duplicate_mutable_accounts"]
        medium_types = ["pda_sharing", "sysvar_validation"]
        
        if vuln_type in critical_types:
            return "critical"
        elif vuln_type in high_types:
            return "high"
        else:
            return "medium"
    
    def process_vulnerability(self, vuln_dir: Path) -> Optional[Dict[str, Any]]:
        """Process a vulnerability directory (only the insecure version)."""
        vuln_name = vuln_dir.name
        
        # Look for insecure version
        insecure_path = vuln_dir / "insecure" / "src" / "lib.rs"
        if not insecure_path.exists():
            print(f"  Warning: No insecure version found for {vuln_name}")
            return None
        
        try:
            with open(insecure_path, "r", encoding="utf-8") as f:
                file_content = f.read()
        except Exception as e:
            print(f"  Error reading {vuln_name}: {e}")
            return None
        
        # Map vulnerability type
        vuln_type = SOLANA_VULN_MAPPING.get(vuln_name, "logic_error")
        
        # Get metadata
        description = self.get_vulnerability_description(vuln_name)
        fix_description = self.get_fix_description(vuln_name)
        
        # Assign difficulty and severity
        difficulty_tier = self.assign_difficulty_tier(vuln_type, file_content)
        severity = self.determine_severity(vuln_type)
        
        # Check if secure version exists
        secure_path = vuln_dir / "secure" / "src" / "lib.rs"
        recommended_path = vuln_dir / "recommended" / "src" / "lib.rs"
        has_remediation = secure_path.exists() or recommended_path.exists()
        
        # Extract module name from content
        module_match = re.search(r'pub mod (\w+)', file_content)
        module_name = module_match.group(1) if module_match else "unknown"
        
        # Create entry
        entry = {
            "id": f"sealevel_{vuln_name.replace('-', '_')}",
            "source_dataset": "sealevel-attacks",
            "language": "rust",
            "chain": "solana",
            "framework": "anchor",
            
            "file_name": f"{vuln_name}_insecure.rs",
            "file_content": file_content,
            "vulnerable_function": module_name,
            "vulnerable_lines": [],
            
            "vulnerability_type": vuln_type,
            "category": vuln_name,
            "severity": severity,
            "difficulty_tier": difficulty_tier,
            
            "description": description,
            "fix_description": fix_description,
            "references": ["https://github.com/coral-xyz/sealevel-attacks"],
            
            "is_vulnerable": True,
            "has_remediation": has_remediation,
            "has_poc": False,  # These are examples, not full PoCs
            "context_level": "single_file",
            
            "original_source_path": str(insecure_path.relative_to(self.raw_path)),
            "source": "Coral XYZ / Sealevel Attacks",
        }
        
        return entry
    
    def process_all(self) -> List[Dict]:
        """Process all Sealevel attacks."""
        processed_entries = []
        
        # Get all vulnerability directories
        vuln_dirs = sorted([d for d in self.programs_path.iterdir() if d.is_dir()])
        
        print(f"Processing {len(vuln_dirs)} Solana vulnerabilities from sealevel-attacks...")
        
        for vuln_dir in vuln_dirs:
            try:
                entry = self.process_vulnerability(vuln_dir)
                if entry:
                    processed_entries.append(entry)
                    print(f"  ✓ {vuln_dir.name}")
            except Exception as e:
                print(f"  ✗ Error processing {vuln_dir.name}: {e}")
                continue
        
        print(f"\nSuccessfully processed {len(processed_entries)} entries")
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
            
            tier_dir = self.output_path / tier_names[tier] / "rust"
            tier_dir.mkdir(parents=True, exist_ok=True)
            
            tier_file = tier_dir / "sealevel_attacks.json"
            with open(tier_file, "w") as f:
                json.dump(entries, f, indent=2)
            
            print(f"Tier {tier} ({tier_names[tier]}): {len(entries)} entries saved to {tier_file}")
        
        # Save master index
        master_file = self.metadata_path / "sealevel_attacks_processed.json"
        with open(master_file, "w") as f:
            json.dump(processed_entries, f, indent=2)
        
        print(f"\nMaster index saved to {master_file}")
        
        # Print statistics
        self.print_statistics(processed_entries)
    
    def print_statistics(self, processed_entries: List[Dict]):
        """Print dataset statistics."""
        print("\n" + "="*60)
        print("Sealevel Attacks Processing Statistics")
        print("="*60)
        
        # By vulnerability type
        by_type = {}
        for entry in processed_entries:
            vtype = entry["vulnerability_type"]
            by_type[vtype] = by_type.get(vtype, 0) + 1
        
        print("\nBy Vulnerability Type:")
        for vtype, count in sorted(by_type.items()):
            print(f"  {vtype:35} {count:2}")
        
        # By difficulty tier
        by_tier = {}
        for entry in processed_entries:
            tier = entry["difficulty_tier"]
            by_tier[tier] = by_tier.get(tier, 0) + 1
        
        print("\nBy Difficulty Tier:")
        tier_names = {2: "Tier 2 (Medium)", 3: "Tier 3 (Hard)", 4: "Tier 4 (Expert)"}
        for tier in sorted(by_tier.keys()):
            print(f"  {tier_names[tier]:20} {by_tier[tier]:2}")
        
        # By severity
        by_severity = {}
        for entry in processed_entries:
            sev = entry["severity"]
            by_severity[sev] = by_severity.get(sev, 0) + 1
        
        print("\nBy Severity:")
        for sev, count in sorted(by_severity.items()):
            print(f"  {sev:20} {count:2}")
        
        print("\n" + "="*60)


def main():
    base_path = "/Users/poamen/projects/grace/blockbench/base/dataset"
    processor = SealevelAttacksProcessor(base_path)
    
    # Process all entries
    processed_entries = processor.process_all()
    
    # Save organized data
    processor.save_processed_data(processed_entries)


if __name__ == "__main__":
    main()
