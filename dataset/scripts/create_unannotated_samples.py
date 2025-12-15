#!/usr/bin/env python3
"""
Script to create unannotated versions of difficulty-stratified dataset.
Removes vulnerability hints from code and metadata to prevent data leakage.
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Any

def strip_vulnerability_comments(code: str) -> str:
    """Remove vulnerability-revealing comments from code."""
    lines = code.split('\n')
    cleaned_lines = []
    
    for line in lines:
        # Remove lines with vulnerability markers
        if any(marker in line for marker in [
            '// <yes> <report>',
            '/* <yes> <report>',
            '@vulnerable_at_lines',
            'VULNERABLE',
            'vulnerability',
            'exploit',
            'attack'
        ]):
            # Keep the line but remove the comment
            code_part = re.sub(r'//.*', '', line)
            code_part = re.sub(r'/\*.*?\*/', '', code_part)
            if code_part.strip():
                cleaned_lines.append(code_part.rstrip())
            continue
        
        cleaned_lines.append(line)
    
    return '\n'.join(cleaned_lines)

def create_unannotated_sample(sample: Dict[str, Any], index: int, tier: str) -> Dict[str, Any]:
    """Create unannotated version of a sample."""
    # Strip code comments
    cleaned_code = strip_vulnerability_comments(sample['file_content'])
    
    # Create minimal metadata
    unannotated = {
        "id": f"sample_{tier}_{''.join(filter(str.isdigit, str(index))).zfill(4)}",
        "language": sample['language'],
        "chain": sample.get('chain', 'evm'),
        "file_content": cleaned_code,
        "pragma": sample.get('pragma', ''),
        "difficulty_tier": sample['difficulty_tier'],
        "context_level": sample.get('context_level', 'single_file')
    }
    
    return unannotated

def process_dataset():
    """Process all difficulty stratified datasets."""
    base_path = Path('/Users/poamen/projects/grace/blockbench/base/dataset/processed/difficulty_stratified')
    
    # Create annotated and unannotated directories
    for tier_dir in base_path.iterdir():
        if not tier_dir.is_dir():
            continue
            
        print(f"Processing {tier_dir.name}...")
        
        # Create annotated/unannotated structure
        annotated_dir = tier_dir / 'annotated'
        unannotated_dir = tier_dir / 'unannotated'
        annotated_dir.mkdir(exist_ok=True)
        unannotated_dir.mkdir(exist_ok=True)
        
        # Process each language directory
        for lang_dir in tier_dir.iterdir():
            if lang_dir.name in ['annotated', 'unannotated'] or not lang_dir.is_dir():
                continue
            
            print(f"  {lang_dir.name}/")
            
            # Create lang subdirectories in annotated/unannotated
            (annotated_dir / lang_dir.name).mkdir(exist_ok=True)
            (unannotated_dir / lang_dir.name).mkdir(exist_ok=True)
            
            # Process each JSON file
            for json_file in lang_dir.glob('*.json'):
                print(f"    {json_file.name}")
                
                with open(json_file, 'r') as f:
                    samples = json.load(f)
                
                # Move original to annotated
                annotated_path = annotated_dir / lang_dir.name / json_file.name
                with open(annotated_path, 'w') as f:
                    json.dump(samples, f, indent=2)
                
                # Create unannotated version
                unannotated_samples = []
                for idx, sample in enumerate(samples):
                    unannotated = create_unannotated_sample(sample, idx, tier_dir.name.split('_')[1])
                    unannotated_samples.append(unannotated)
                
                unannotated_path = unannotated_dir / lang_dir.name / json_file.name
                with open(unannotated_path, 'w') as f:
                    json.dump(unannotated_samples, f, indent=2)
                
                # Remove original file
                json_file.unlink()
            
            # Remove original language directory if empty
            if not list(lang_dir.glob('*')):
                lang_dir.rmdir()

if __name__ == '__main__':
    process_dataset()
    print("Done!")
