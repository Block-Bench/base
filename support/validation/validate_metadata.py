#!/usr/bin/env python3
"""
Metadata Validation Script

Validates that metadata files correctly reference actual contract code:
- Contract names exist in .sol files
- Function names exist in contracts
- Line numbers are within bounds
- Vulnerable locations point to actual code

Usage:
    python validate_metadata.py data/base
    python validate_metadata.py data/sanitized
    python validate_metadata.py data/chameleon/medical_nc
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import sys


class MetadataValidator:
    def __init__(self, dataset_path: Path):
        self.dataset_path = Path(dataset_path)
        self.metadata_dir = self.dataset_path / "metadata"
        self.contracts_dir = self.dataset_path / "contracts"
        self.errors = []
        self.warnings = []

    def validate_all(self) -> Tuple[int, int, int]:
        """
        Validate all metadata files in the dataset.
        Returns (total_files, files_with_errors, files_with_warnings)
        """
        if not self.metadata_dir.exists():
            print(f"❌ Metadata directory not found: {self.metadata_dir}")
            return 0, 0, 0

        if not self.contracts_dir.exists():
            print(f"❌ Contracts directory not found: {self.contracts_dir}")
            return 0, 0, 0

        metadata_files = sorted(self.metadata_dir.glob("*.json"))

        if not metadata_files:
            print(f"⚠️  No metadata files found in {self.metadata_dir}")
            return 0, 0, 0

        print(f"📂 Validating {len(metadata_files)} metadata files in {self.dataset_path}")
        print("=" * 80)

        total_files = 0
        files_with_errors = 0
        files_with_warnings = 0

        for metadata_file in metadata_files:
            total_files += 1
            sample_id = metadata_file.stem

            errors_before = len(self.errors)
            warnings_before = len(self.warnings)

            self.validate_sample(sample_id, metadata_file)

            errors_added = len(self.errors) - errors_before
            warnings_added = len(self.warnings) - warnings_before

            if errors_added > 0:
                files_with_errors += 1
                print(f"❌ {sample_id}: {errors_added} error(s)")
            elif warnings_added > 0:
                files_with_warnings += 1
                print(f"⚠️  {sample_id}: {warnings_added} warning(s)")
            else:
                print(f"✅ {sample_id}: OK")

        return total_files, files_with_errors, files_with_warnings

    def validate_sample(self, sample_id: str, metadata_file: Path):
        """Validate a single metadata file against its contract."""
        # Load metadata
        try:
            with open(metadata_file, 'r') as f:
                metadata = json.load(f)
        except Exception as e:
            self.errors.append(f"{sample_id}: Failed to load metadata: {e}")
            return

        # Check contract file exists
        contract_file = metadata.get("contract_file", "")
        if not contract_file:
            self.errors.append(f"{sample_id}: Missing 'contract_file' field in metadata")
            return

        # Handle relative paths
        contract_path = self.dataset_path / contract_file
        if not contract_path.exists():
            # Try just filename
            contract_path = self.contracts_dir / Path(contract_file).name
            if not contract_path.exists():
                self.errors.append(f"{sample_id}: Contract file not found: {contract_file}")
                return

        # Load contract code
        try:
            with open(contract_path, 'r') as f:
                contract_code = f.read()
                contract_lines = contract_code.split('\n')
        except Exception as e:
            self.errors.append(f"{sample_id}: Failed to load contract: {e}")
            return

        # Validate ground_truth section
        ground_truth = metadata.get("ground_truth", {})
        if not ground_truth:
            self.warnings.append(f"{sample_id}: Missing 'ground_truth' section")
            return

        # Validate vulnerable_location
        vuln_location = ground_truth.get("vulnerable_location", {})
        if not vuln_location:
            self.warnings.append(f"{sample_id}: Missing 'vulnerable_location' in ground_truth")
            return

        # Check contract name
        contract_name = vuln_location.get("contract_name")
        if contract_name and isinstance(contract_name, str):
            if not self.contract_exists(contract_code, contract_name):
                self.errors.append(
                    f"{sample_id}: Contract '{contract_name}' not found in {contract_path.name}"
                )
        elif contract_name and not isinstance(contract_name, str):
            self.errors.append(f"{sample_id}: 'contract_name' must be a string, got {type(contract_name).__name__}")
        else:
            self.warnings.append(f"{sample_id}: Missing 'contract_name' in vulnerable_location")

        # Check function name
        function_name = vuln_location.get("function_name")
        if function_name and isinstance(function_name, str):
            # Handle multiple functions separated by comma
            function_names = [f.strip() for f in function_name.split(',')]
            for func_name in function_names:
                if not self.function_exists(contract_code, func_name):
                    self.errors.append(
                        f"{sample_id}: Function '{func_name}' not found in {contract_path.name}"
                    )
        elif function_name and not isinstance(function_name, str):
            self.errors.append(f"{sample_id}: 'function_name' must be a string, got {type(function_name).__name__}")
        else:
            self.warnings.append(f"{sample_id}: Missing 'function_name' in vulnerable_location")

        # Check line numbers
        line_numbers = vuln_location.get("line_numbers", [])
        if line_numbers:
            max_line = len(contract_lines)
            invalid_lines = [ln for ln in line_numbers if ln < 1 or ln > max_line]
            if invalid_lines:
                self.errors.append(
                    f"{sample_id}: Line numbers out of bounds (1-{max_line}): {invalid_lines}"
                )

            # Check if lines are empty or just whitespace
            empty_lines = []
            for ln in line_numbers:
                if 1 <= ln <= max_line:
                    line_content = contract_lines[ln - 1].strip()
                    if not line_content or line_content.startswith('//'):
                        empty_lines.append(ln)

            if empty_lines:
                self.warnings.append(
                    f"{sample_id}: Some line numbers point to empty/comment lines: {empty_lines}"
                )
        else:
            self.warnings.append(f"{sample_id}: Missing 'line_numbers' in vulnerable_location")

    def contract_exists(self, code: str, contract_name: str) -> bool:
        """Check if a contract declaration exists in the code."""
        # Match: contract ContractName, interface ContractName, or library ContractName
        pattern = rf'\b(contract|interface|library)\s+{re.escape(contract_name)}\b'
        return bool(re.search(pattern, code))

    def function_exists(self, code: str, function_name: str) -> bool:
        """Check if a function declaration exists in the code."""
        # Match: function functionName( or function functionName (
        pattern = rf'\bfunction\s+{re.escape(function_name)}\s*\('
        return bool(re.search(pattern, code))

    def print_summary(self, total: int, errors_count: int, warnings_count: int):
        """Print validation summary."""
        print("\n" + "=" * 80)
        print("VALIDATION SUMMARY")
        print("=" * 80)
        print(f"Total files validated: {total}")
        print(f"Files with errors: {errors_count}")
        print(f"Files with warnings: {warnings_count}")
        print(f"Files OK: {total - errors_count - warnings_count}")

        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            print("-" * 80)
            for error in self.errors:
                print(f"  • {error}")

        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            print("-" * 80)
            for warning in self.warnings:
                print(f"  • {warning}")

        if not self.errors and not self.warnings:
            print("\n✅ All metadata files are valid!")

        print("=" * 80)


def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_metadata.py <dataset_path>")
        print("\nExamples:")
        print("  python validate_metadata.py data/base")
        print("  python validate_metadata.py data/sanitized")
        print("  python validate_metadata.py data/chameleon/medical_nc")
        print("  python validate_metadata.py data/restructure/merge/dispatcher")
        sys.exit(1)

    dataset_path = Path(sys.argv[1])

    if not dataset_path.exists():
        print(f"❌ Dataset path does not exist: {dataset_path}")
        sys.exit(1)

    validator = MetadataValidator(dataset_path)
    total, errors_count, warnings_count = validator.validate_all()
    validator.print_summary(total, errors_count, warnings_count)

    # Exit with non-zero status if there are errors
    sys.exit(1 if errors_count > 0 else 0)


if __name__ == "__main__":
    main()
