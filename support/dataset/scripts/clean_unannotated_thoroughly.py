#!/usr/bin/env python3
"""
Thoroughly clean unannotated samples by removing all vulnerability hints.
"""

import json
import re
from pathlib import Path

def thoroughly_clean_code(code: str) -> str:
    """Aggressively remove all vulnerability markers from code."""
    lines = code.split('\n')
    cleaned_lines = []
    in_multiline_comment = False
    skip_next_line = False
    
    for line in lines:
        # Track multiline comments
        if '/*' in line:
            in_multiline_comment = True
        
        # Skip lines with vulnerability markers
        if any(marker in line.lower() for marker in [
            '@vulnerable',
            'vulnerable_at',
            '<yes>',
            '<report>',
            '@source:',
            '@author:',
'SWC-',
            'capturetheether',
            'smart-contract-best-practices'
        ]):
            if '*/' in line:
                in_multiline_comment = False
            continue
        
        if '*/' in line:
            in_multiline_comment = False
            # If this is a closing comment with vulnerability marker, skip
            if in_multiline_comment:
                continue
        
        # Skip if inside a multiline comment that started with vulnerability marker
        if not in_multiline_comment:
            cleaned_lines.append(line)
    
    return '\n'.join(cleaned_lines)

def clean_all_unannotated():
    """Clean all unannotated files."""
    base_path = Path('/Users/poamen/projects/grace/blockbench/base/dataset/processed/difficulty_stratified')
    
    for tier_dir in base_path.iterdir():
        if not tier_dir.is_dir():
            continue
        
        unannotated_dir = tier_dir / 'unannotated'
        if not unannotated_dir.exists():
            continue
        
        print(f"Cleaning {tier_dir.name}...")
        
        for lang_dir in unannotated_dir.iterdir():
            if not lang_dir.is_dir():
                continue
            
            for json_file in lang_dir.glob('*.json'):
                print(f"  {lang_dir.name}/{json_file.name}")
                
                with open(json_file, 'r') as f:
                    samples = json.load(f)
                
                # Clean each sample
                for sample in samples:
                    sample['file_content'] = thoroughly_clean_code(sample['file_content'])
                
                # Write back
                with open(json_file, 'w') as f:
                    json.dump(samples, f, indent=2)
    
    print("Done!")

if __name__ == '__main__':
    clean_all_unannotated()
