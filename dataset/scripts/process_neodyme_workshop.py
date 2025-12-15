#!/usr/bin/env python3
"""
Process Neodyme Workshop CTF challenges into standardized dataset format.

Source: https://github.com/neodyme-labs/solana-ctf/neodyme-breakpoint-workshop
Documentation: https://workshop.neodyme.io
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Optional

# Neodyme Workshop metadata
# Based on analysis of docs/ directory and source code
LEVEL_METADATA = {
    "level1": {
        "id": "neodyme_level1_missing_signer",
        "title": "Personal Vault",
        "vulnerability_type": "missing_signer_check",
        "severity": "critical",
        "difficulty_tier": 2,
        "description": "Missing signer check allows unauthorized users to withdraw funds from any wallet. The withdraw function checks that the authority key matches but does not verify the authority has signed the transaction.",
        "fix_description": "Add is_signer check: assert!(authority_info.is_signer, ErrorCode::Unauthorized). This ensures that only the authority who has signed the transaction can withdraw funds.",
        "vulnerable_function": "withdraw",
        "vulnerable_lines": [85, 90],  # Lines in processor.rs where authority is used without signer check
        "category": "authorization",
    },
    "level2": {
        "id": "neodyme_level2_integer_overflow",
        "title": "Secure Personal Vault",
        "vulnerability_type": "arithmetic_overflow",
        "severity": "high",
        "difficulty_tier": 2,
        "description": "Integer overflow/underflow in withdraw function when updating lamport balances. The operation `**wallet_info.lamports.borrow_mut() -= amount` can underflow for large amounts, and `**destination_info.lamports.borrow_mut() += amount` can overflow.",
        "fix_description": "Use checked arithmetic operations: checked_sub() and checked_add() instead of direct subtraction and addition. Return error on overflow/underflow.",
        "vulnerable_function": "withdraw",
        "vulnerable_lines": [96, 97],  # Lines with unsafe arithmetic
        "category": "arithmetic",
    },
    "level3": {
        "id": "neodyme_level3_type_confusion",
        "title": "Tip Pool",
        "vulnerability_type": "type_cosplay",
        "severity": "critical",
        "difficulty_tier": 3,
        "description": "Type confusion vulnerability where a Vault struct can be deserialized as a TipPool struct. Only the account owner is checked in withdraw function, not the account type discriminator, allowing an attacker to withdraw from the global vault by passing it as their tip pool.",
        "fix_description": "Add proper type discriminators and validate account types. Check the account discriminator before deserializing. Use Anchor's account type checking to prevent type confusion attacks.",
        "vulnerable_function": "withdraw",
        "vulnerable_lines": [85, 90],  # Approximate lines where type confusion occurs
        "category": "account_validation",
    },
    "level4": {
        "id": "neodyme_level4_arbitrary_cpi",
        "title": "SPL Token Vault",
        "vulnerability_type": "arbitrary_cpi",
        "severity": "critical",
        "difficulty_tier": 3,
        "description": "Arbitrary Cross-Program Invocation (CPI) vulnerability. The program allows the caller to control which program is invoked during token withdraw, enabling an attacker to invoke a malicious program instead of the legitimate SPL token program.",
        "fix_description": "Hardcode the SPL token program ID and validate that the provided token_program matches spl_token::ID. Never allow user-controlled program IDs in CPI calls.",
        "vulnerable_function": "withdraw",
        "vulnerable_lines": [95, 100],  # Approximate lines with CPI
        "category": "cpi_validation",
    },
}

def read_file_content(file_path: str) -> str:
    """Read file content, return empty string if file doesn't exist."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return ""
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return ""

def extract_poc_from_solution(solution_md_path: str) -> Optional[str]:
    """Extract PoC code from solution markdown file."""
    content = read_file_content(solution_md_path)
    if not content:
        return None
    
    # Look for code blocks with PoC
    in_code_block = False
    poc_lines = []
    
    for line in content.split('\n'):
        if line.strip().startswith('```rust') or line.strip().startswith('```rs'):
            in_code_block = True
            continue
        elif line.strip() == '```' and in_code_block:
            in_code_block = False
            if poc_lines:  # Save first code block as PoC
                return '\n'.join(poc_lines)
        elif in_code_block:
            poc_lines.append(line)
    
    return None

def combine_source_files(level_dir: Path) -> str:
    """Combine lib.rs and processor.rs into single file content."""
    src_dir = level_dir / "src"
    
    lib_content = read_file_content(str(src_dir / "lib.rs"))
    processor_content = read_file_content(str(src_dir / "processor.rs"))
    
    if processor_content:
        # Combine both files
        combined = f"// lib.rs\n{lib_content}\n\n// processor.rs\n{processor_content}"
        return combined
    else:
        # Only lib.rs exists
        return lib_content

def process_neodyme_workshop(base_dir: str, output_dir: str):
    """Process Neodyme Workshop levels into standardized format."""
    
    workshop_path = Path(base_dir) / "raw" / "solana-ctf" / "neodyme-breakpoint-workshop"
    docs_path = workshop_path / "docs"
    
    if not workshop_path.exists():
        print(f"Error: Workshop directory not found at {workshop_path}")
        return
    
    samples = []
    
    for level_name, metadata in LEVEL_METADATA.items():
        print(f"\nProcessing {level_name}...")
        
        level_dir = workshop_path / level_name
        if not level_dir.exists():
            print(f"  Warning: Level directory not found: {level_dir}")
            continue
        
        # Read source code
        file_content = combine_source_files(level_dir)
        
        if not file_content or len(file_content.strip()) < 50:
            print(f"  Warning: No valid source code found for {level_name}")
            continue
        
        # Read documentation
        level_doc = read_file_content(str(docs_path / f"{level_name}.md"))
        bug_doc = read_file_content(str(docs_path / f"{level_name}-bug.md"))
        solution_doc = read_file_content(str(docs_path / f"{level_name}-solution.md"))
        
        # Extract PoC from solution
        poc_code = extract_poc_from_solution(str(docs_path / f"{level_name}-solution.md"))
        
        # Build sample entry
        sample = {
            "id": metadata["id"],
            "source_dataset": "neodyme-workshop",
            "language": "rust",
            "chain": "solana",
            "framework": "anchor" if level_name != "level4" else "native",
            "file_name": f"{level_name}/src/processor.rs",
            "file_content": file_content,
            "vulnerable_function": metadata["vulnerable_function"],
            "vulnerable_lines": metadata["vulnerable_lines"],
            "vulnerability_type": metadata["vulnerability_type"],
            "category": metadata["category"],
            "severity": metadata["severity"],
            "difficulty_tier": metadata["difficulty_tier"],
            "description": metadata["description"],
            "fix_description": metadata["fix_description"],
            "poc_code": poc_code,
            "references": [
                "https://workshop.neodyme.io",
                f"https://github.com/neodyme-labs/solana-ctf/tree/main/neodyme-breakpoint-workshop/{level_name}"
            ],
            "is_vulnerable": True,
            "has_remediation": True,
            "has_poc": poc_code is not None,
            "context_level": "single_file",
            "original_source_path": f"neodyme-breakpoint-workshop/{level_name}/src/",
            "source": "Neodyme / Solana Security Workshop",
            "educational_notes": {
                "challenge_description": level_doc[:500] if level_doc else "",
                "bug_hint": bug_doc.strip() if bug_doc else "",
                "has_progressive_hints": True,
                "workshop_level": level_name,
            }
        }
        
        samples.append(sample)
        print(f"  ✓ Processed {metadata['id']}")
        print(f"    Vulnerability: {metadata['vulnerability_type']}")
        print(f"    Severity: {metadata['severity']}")
        print(f"    Difficulty: Tier {metadata['difficulty_tier']}")
        print(f"    PoC available: {'Yes' if poc_code else 'No'}")
        print(f"    Code size: {len(file_content)} bytes")
    
    # Save processed samples
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, "neodyme_workshop.json")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(samples, f, indent=2, ensure_ascii=False)
    
    print(f"\n{'='*80}")
    print(f"Processing complete!")
    print(f"{'='*80}")
    print(f"Total samples processed: {len(samples)}")
    print(f"Output file: {output_file}")
    print(f"\nBreakdown:")
    
    by_tier = {}
    by_severity = {}
    with_poc = sum(1 for s in samples if s['has_poc'])
    
    for sample in samples:
        tier = sample['difficulty_tier']
        sev = sample['severity']
        by_tier[tier] = by_tier.get(tier, 0) + 1
        by_severity[sev] = by_severity.get(sev, 0) + 1
    
    print(f"  By difficulty tier:")
    for tier in sorted(by_tier.keys()):
        print(f"    Tier {tier}: {by_tier[tier]} samples")
    
    print(f"  By severity:")
    for sev, count in sorted(by_severity.items()):
        print(f"    {sev}: {count} samples")
    
    print(f"  With PoC: {with_poc}/{len(samples)}")
    print(f"\nNew vulnerability types added:")
    vuln_types = set(s['vulnerability_type'] for s in samples)
    for vtype in sorted(vuln_types):
        print(f"  • {vtype}")

if __name__ == "__main__":
    import sys
    
    # Default paths
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    output_dir = os.path.join(base_dir, "processed", "neodyme_workshop")
    
    if len(sys.argv) > 1:
        base_dir = sys.argv[1]
    if len(sys.argv) > 2:
        output_dir = sys.argv[2]
    
    process_neodyme_workshop(base_dir, output_dir)
