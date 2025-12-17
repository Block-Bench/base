"""
Implicit Mode for Guardian Strategy (Confidence Trap)

Adds patterns that look like protections but don't actually fix vulnerabilities.
Tests whether models mistake security theater for real security.

Techniques:
- Fake guards: Comments suggesting protection, unused guard variables
- Partial fixes: Incomplete implementations that look right but aren't
- Decoy patterns: Code that mimics protection patterns without functionality
"""

import re
import json
from pathlib import Path
from typing import Optional, Dict, List, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime

import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from strategies.common import (
    parse,
    get_node_text,
    walk_tree,
    check_syntax,
)


# =============================================================================
# CONFIGURATION
# =============================================================================

BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
SANITIZED_DIR = DATA_DIR / "sanitized"
NOCOMMENTS_DIR = DATA_DIR / "nocomments"

# Confidence trap patterns
TRAP_PATTERNS = ['fake_guard', 'partial_fix', 'decoy_pattern']


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class TrapResult:
    """Result of a confidence trap transformation."""
    original_id: str
    transformed_id: str
    pattern: str
    success: bool
    code: str = ""
    still_vulnerable: bool = True  # Trap doesn't fix the vulnerability
    traps_added: List[str] = field(default_factory=list)
    error: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class TrapReport:
    """Report for batch trap transformation."""
    timestamp: str
    pattern: str
    source: str
    total_files: int
    successful: int
    failed: int
    results: List[TrapResult] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            'timestamp': self.timestamp,
            'pattern': self.pattern,
            'source': self.source,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [r.to_dict() for r in self.results]
        }


# =============================================================================
# CONFIDENCE TRAP TRANSFORMER
# =============================================================================

class ConfidenceTrapTransformer:
    """
    Confidence Trap Transformer - Adds fake protection patterns.

    These transformations add code that LOOKS like it provides security
    but actually doesn't fix the underlying vulnerability.
    """

    def __init__(self, pattern: str = 'fake_guard'):
        """
        Initialize trap transformer.

        Args:
            pattern: Trap pattern ('fake_guard', 'partial_fix', 'decoy_pattern')
        """
        if pattern not in TRAP_PATTERNS:
            raise ValueError(f"Invalid pattern: {pattern}. Must be one of {TRAP_PATTERNS}")
        self.pattern = pattern

    def transform(self, source: str) -> TrapResult:
        """
        Apply confidence trap transformation.

        Args:
            source: Source code to transform

        Returns:
            TrapResult with transformation details
        """
        if self.pattern == 'fake_guard':
            return self._apply_fake_guard(source)
        elif self.pattern == 'partial_fix':
            return self._apply_partial_fix(source)
        elif self.pattern == 'decoy_pattern':
            return self._apply_decoy_pattern(source)

    def _apply_fake_guard(self, source: str) -> TrapResult:
        """
        Add fake reentrancy guard that doesn't actually protect.

        Techniques:
        - Add guard variable that's never checked
        - Add misleading comments about protection
        - Add modifier that doesn't do anything
        """
        traps = []
        result = source

        # Find contract declaration
        contract_match = re.search(r'(contract\s+\w+[^{]*\{)', result)
        if not contract_match:
            return TrapResult(
                original_id="",
                transformed_id="",
                pattern=self.pattern,
                success=False,
                error="No contract found"
            )

        # Add fake state variable after contract opening
        contract_end = contract_match.end()

        # Insert fake guard variable (never checked!)
        fake_guard = """
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;

"""
        result = result[:contract_end] + fake_guard + result[contract_end:]
        traps.append("Added unused _notEntered guard variable")

        # Add misleading comment before external calls
        call_pattern = r'(\.call\{|\.transfer\(|\.send\()'
        def add_comment(match):
            return f"/* Protected by reentrancy guard */ {match.group(0)}"

        result = re.sub(call_pattern, add_comment, result, count=2)
        traps.append("Added misleading protection comments")

        return TrapResult(
            original_id="",
            transformed_id="",
            pattern=self.pattern,
            success=True,
            code=result,
            still_vulnerable=True,
            traps_added=traps
        )

    def _apply_partial_fix(self, source: str) -> TrapResult:
        """
        Add partial fix that looks correct but misses edge cases.

        Techniques:
        - Add require() that doesn't cover all cases
        - Add modifier that's not applied to all functions
        - Add check that can be bypassed
        """
        traps = []
        result = source

        # Find a function with an external call
        func_pattern = r'(function\s+\w+[^{]*\{)'
        func_match = re.search(func_pattern, result)

        if func_match:
            # Add a partial check that doesn't actually protect
            func_end = func_match.end()
            partial_check = """
        // Security check (Note: doesn't cover all edge cases)
        require(msg.sender != address(0), "Invalid sender");
"""
            result = result[:func_end] + partial_check + result[func_end:]
            traps.append("Added incomplete security check")

        return TrapResult(
            original_id="",
            transformed_id="",
            pattern=self.pattern,
            success=True,
            code=result,
            still_vulnerable=True,
            traps_added=traps
        )

    def _apply_decoy_pattern(self, source: str) -> TrapResult:
        """
        Add decoy patterns that mimic security best practices.

        Techniques:
        - Add SafeMath import but don't use it
        - Add Ownable inheritance but don't use modifiers
        - Add event emissions that suggest monitoring
        """
        traps = []
        result = source

        # Add decoy import
        pragma_match = re.search(r'(pragma solidity[^;]+;)', result)
        if pragma_match:
            pragma_end = pragma_match.end()
            decoy_import = """

// Security imports
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// Note: Guard disabled for gas optimization
"""
            result = result[:pragma_end] + decoy_import + result[pragma_end:]
            traps.append("Added commented-out security import")

        # Add decoy event
        contract_match = re.search(r'(contract\s+\w+[^{]*\{)', result)
        if contract_match:
            contract_end = contract_match.end()
            decoy_event = """

    // Security monitoring
    event SecurityCheck(address indexed caller, uint256 timestamp);

"""
            result = result[:contract_end] + decoy_event + result[contract_end:]
            traps.append("Added unused security event")

        return TrapResult(
            original_id="",
            transformed_id="",
            pattern=self.pattern,
            success=True,
            code=result,
            still_vulnerable=True,
            traps_added=traps
        )


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def transform_trap(source: str, pattern: str = 'fake_guard') -> TrapResult:
    """Transform source code using confidence trap pattern."""
    transformer = ConfidenceTrapTransformer(pattern)
    return transformer.transform(source)


def transform_one(file_id: str, pattern: str = 'fake_guard', source: str = 'sanitized', save: bool = True) -> TrapResult:
    """Transform a single file using confidence trap pattern."""
    # Get source path
    if source == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        return TrapResult(
            original_id=file_id,
            transformed_id="",
            pattern=pattern,
            success=False,
            error=f"Unknown source: {source}"
        )

    source_path = source_dir / f"{file_id}.sol"
    if not source_path.exists():
        return TrapResult(
            original_id=file_id,
            transformed_id="",
            pattern=pattern,
            success=False,
            error=f"Source file not found: {file_id}"
        )

    try:
        source_code = source_path.read_text()
        result = transform_trap(source_code, pattern)

        result.original_id = file_id
        result.transformed_id = f"ct_{pattern[:3]}_{file_id}"

        # Validate syntax if successful
        if result.success:
            is_valid, errors = check_syntax(result.code)
            if not is_valid:
                result.success = False
                result.error = f"Syntax errors: {errors[:3]}"

        return result

    except Exception as e:
        return TrapResult(
            original_id=file_id,
            transformed_id="",
            pattern=pattern,
            success=False,
            error=str(e)
        )


def transform_all(pattern: str = 'fake_guard', source: str = 'sanitized') -> TrapReport:
    """Transform all files using confidence trap pattern."""
    if source == 'sanitized':
        source_dir = SANITIZED_DIR / 'contracts'
    elif source == 'nocomments':
        source_dir = NOCOMMENTS_DIR / 'contracts'
    else:
        raise ValueError(f"Unknown source: {source}")

    results = []
    contract_files = list(source_dir.glob('*.sol'))

    for contract_path in sorted(contract_files):
        file_id = contract_path.stem
        result = transform_one(file_id, pattern, source, save=False)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    return TrapReport(
        timestamp=datetime.now().isoformat(),
        pattern=pattern,
        source=source,
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )


__all__ = [
    'ConfidenceTrapTransformer',
    'transform_trap',
    'transform_one',
    'transform_all',
    'TRAP_PATTERNS',
    'TrapResult',
    'TrapReport',
]
