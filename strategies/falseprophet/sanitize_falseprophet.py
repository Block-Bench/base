#!/usr/bin/env python3
"""
Sanitize FalseProphet Contracts

This script sanitizes protocol names in falseProphet contracts while preserving
the misleading security comments (the core feature of falseProphet).

Input: dataset/temporal_contamination/falseProphet/
Output: Same directory (in-place update)

What it does:
- Replaces protocol names in contract names (NomadReplica -> BridgeReplica)
- Replaces protocol names in comments (keeps structure, removes protocol refs)
- Updates metadata to match sanitized contract/function names
- Preserves fake audit claims and misleading comments structure

Usage:
    python strategies/falseprophet/sanitize_falseprophet.py
"""

import sys
import re
import json
from pathlib import Path
from datetime import datetime

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from strategies.sanitize.sanitize import sanitize_code
from strategies.common.line_markers import strip_line_markers, add_line_markers

# Protocol name mappings (same as sanitize_on_minimal_sanitize.py)
PROTOCOL_MAPPINGS = {
    'nomad': 'bridge',
    'beanstalk': 'governance',
    'parity': 'wallet',
    'ronin': 'gamebridge',
    'harvest': 'yield',
    'yearn': 'yield',
    'curve': 'stable',
    'compound': 'lending',
    'cream': 'fork',
    'kyber': 'concentrated',
    'rari': 'lending',
    'bzx': 'margin',
    'hunny': 'reward',
    'pickle': 'yield',
    'alpha': 'leveraged',
    'homora': 'leveraged',
    'anyswap': 'cross',
    'bedrock': 'staking',
    'belt': 'yield',
    'blueberry': 'leveraged',
    'burgerswap': 'swap',
    'burger': 'swap',
    'dodo': 'liquidity',
    'exactly': 'lending',
    'fixedfloat': 'exchange',
    'gamma': 'liquidity',
    'hedgey': 'token',
    'hundred': 'lending',
    'inverse': 'synthetic',
    'munchables': 'game',
    'orbit': 'cross',
    'pendle': 'yield',
    'penpie': 'staking',
    'playdapp': 'game',
    'qbridge': 'quantum',
    'radiant': 'crosslending',
    'seneca': 'cdp',
    'shezmu': 'collateral',
    'socket': 'bridge',
    'sonne': 'comp',
    'spartan': 'liquidity',
    'uranium': 'swap',
    'uwu': 'lending',
    'warp': 'collateral',
    'wise': 'isolated',
    'poly': 'cross',
    'dao': 'community',
    'lendf': 'lending',
    'indexed': 'index',
    'cow': 'batch',
}

# Specific contract name replacements to match sanitized variant
CONTRACT_REPLACEMENTS = {
    'NomadReplica': 'BridgeReplica',
    'BeanstalkGovernance': 'Governance',
    'ParityWalletLibrary': 'WalletLibrary',
    'ParityWalletProxy': 'WalletProxy',
    'HarvestVault': 'YieldVault',
    'CurvePool': 'StablePool',
    'RoninBridge': 'GameBridge',
    'EthCrossChainManager': 'CrossChainManager',
    'EthCrossChainData': 'CrossChainData',
    'CreamLending': 'ForkLending',
    'KyberSwapPool': 'ConcentratedPool',
    'RariFuse': 'LendingHub',
    'HunnyMinter': 'RewardMinter',
    'YearnVault': 'YieldVault',
    'CompoundCToken': 'CToken',
    'CompoundMarket': 'CToken',
    'BZXLoanToken': 'MarginToken',
    'PickleStrategy': 'YieldStrategy',
    'PickleController': 'YieldController',
    'AlphaHomoraBank': 'LeveragedBank',
    'InverseLending': 'SyntheticLending',
    'HundredFinanceMarket': 'LendingMarket',
    'AnyswapRouter': 'CrossRouter',
    'BurgerSwapRouter': 'SwapRouter',
    'BeltStrategy': 'YieldStrategy',
    'SpartanPool': 'LiquidityPool',
    'OrbitBridge': 'CrossBridge',
    'RadiantLendingPool': 'CrossLendingPool',
    'SocketGateway': 'BridgeGateway',
    'GammaHypervisor': 'LiquidityHypervisor',
    'WiseLending': 'IsolatedLending',
    'UwuLendingPool': 'LendingPool',
    'BlueberryLending': 'LeveragedLending',
    'CowSolver': 'BatchSolver',
    'BedrockVault': 'StakingVault',
    'ShezmuCollateralToken': 'CollateralToken',
    'ShezmuVault': 'CollateralVault',
    'HedgeyClaimCampaigns': 'TokenClaimCampaigns',
    'SenecaChamber': 'CDPChamber',
    'PendleMarketRegister': 'YieldMarketRegister',
    'PenpieStaking': 'VeTokenStaking',
    'PlayDappToken': 'GameToken',
    'SonneMarket': 'CompMarket',
    'ExactlyMarket': 'LendingMarket',
    'MunchablesLockManager': 'GameLockManager',
    'DODOPool': 'LiquidityPool',
    'UraniumPair': 'SwapPair',
    'WarpVault': 'CollateralVault',
    'QBridgeHandler': 'BridgeHandler',
    'QBridge': 'QuantumBridge',
    'IndexPool': 'IndexPool',
    'ICurvePool': 'IStablePool',
    'ICurve3Pool': 'IStable3Pool',
    'ICompoundToken': 'ILendToken',
    'CurveOracle': 'PoolOracle',
    'FixedFloatHotWallet': 'FloatHotWallet',
}


def sanitize_text(text: str) -> str:
    """Remove protocol names from text while preserving structure."""
    result = text
    for protocol, replacement in PROTOCOL_MAPPINGS.items():
        # Case insensitive replacement
        pattern = re.compile(r'\b' + re.escape(protocol) + r'\b', re.IGNORECASE)
        result = pattern.sub(replacement, result)
    return result


def sanitize_contract_names(code: str) -> tuple:
    """Replace protocol-specific contract names with sanitized versions."""
    result = code
    changes = {}

    for old_name, new_name in CONTRACT_REPLACEMENTS.items():
        if old_name in result:
            result = re.sub(r'\b' + re.escape(old_name) + r'\b', new_name, result)
            changes[old_name] = new_name

    return result, changes


def sanitize_comments(code: str) -> str:
    """Sanitize protocol names in comments while keeping the misleading structure."""
    lines = code.split('\n')
    result_lines = []

    for line in lines:
        # Check if line contains a comment
        if '//' in line or '/*' in line or '*' in line.strip()[:2]:
            # Sanitize protocol names in the line
            sanitized_line = sanitize_text(line)
            # Also apply contract replacements to comments
            for old_name, new_name in CONTRACT_REPLACEMENTS.items():
                sanitized_line = re.sub(r'\b' + re.escape(old_name) + r'\b', new_name, sanitized_line)
            result_lines.append(sanitized_line)
        else:
            result_lines.append(line)

    return '\n'.join(result_lines)


def get_contracts_from_code(code: str) -> list:
    """Extract all contract names from Solidity code."""
    return re.findall(r'contract\s+(\w+)', code)


def get_functions_from_code(code: str) -> list:
    """Extract all function names from Solidity code."""
    return re.findall(r'function\s+(\w+)', code)


def sanitize_falseprophet():
    """Sanitize all falseProphet contracts in place."""

    fp_dir = PROJECT_ROOT / "dataset" / "temporal_contamination" / "falseProphet"
    fp_contracts = fp_dir / "contracts"
    fp_metadata = fp_dir / "metadata"

    # Get sanitized metadata for reference
    sn_metadata = PROJECT_ROOT / "dataset" / "temporal_contamination" / "sanitized" / "metadata"

    print(f"Sanitizing falseProphet contracts in: {fp_dir}")
    print(f"Using sanitized metadata from: {sn_metadata}")

    results = []

    for fp_file in sorted(fp_contracts.glob("fp_tc_*.sol")):
        file_stem = fp_file.stem  # fp_tc_001
        num = file_stem.replace('fp_tc_', '')  # 001

        # Read original code
        original_code = fp_file.read_text()

        # Step 1: Sanitize contract names
        sanitized_code, contract_changes = sanitize_contract_names(original_code)

        # Step 2: Sanitize protocol names in comments
        sanitized_code = sanitize_comments(sanitized_code)

        # Step 3: Apply general text sanitization to remaining protocol refs
        sanitized_code = sanitize_text(sanitized_code)

        # Get actual contracts/functions from sanitized code
        actual_contracts = get_contracts_from_code(sanitized_code)
        actual_functions = get_functions_from_code(sanitized_code)

        # Save sanitized contract
        fp_file.write_text(sanitized_code)

        # Update metadata
        fp_meta_file = fp_metadata / f"{file_stem}.json"
        sn_meta_file = sn_metadata / f"sn_tc_{num}.json"

        if fp_meta_file.exists():
            fp_data = json.loads(fp_meta_file.read_text())

            # Get vulnerable_contract and vulnerable_function from sanitized
            if sn_meta_file.exists():
                sn_data = json.loads(sn_meta_file.read_text())
                fp_data['vulnerable_contract'] = sn_data.get('vulnerable_contract', '')
                fp_data['vulnerable_function'] = sn_data.get('vulnerable_function', '')
                fp_data['vulnerable_lines'] = sn_data.get('vulnerable_lines', [])
            else:
                # Fallback: use first actual contract
                if actual_contracts:
                    fp_data['vulnerable_contract'] = actual_contracts[-1]

            # Add sanitization note to transformation
            if 'transformation' not in fp_data:
                fp_data['transformation'] = {}

            fp_data['transformation']['sanitized'] = True
            fp_data['transformation']['sanitization_date'] = datetime.now().isoformat()
            fp_data['transformation']['contract_renames'] = contract_changes

            # Save updated metadata
            fp_meta_file.write_text(json.dumps(fp_data, indent=2))

        changes_count = len(contract_changes)
        results.append({
            'file': file_stem,
            'changes': contract_changes,
            'actual_contracts': actual_contracts
        })

        status = f"[ok] {changes_count} renames" if changes_count else "[ok] no renames needed"
        print(f"  {file_stem}: {status}")
        if contract_changes:
            for old, new in list(contract_changes.items())[:2]:
                print(f"      {old} -> {new}")

    # Summary
    print(f"\n{'='*50}")
    print(f"FalseProphet Sanitization Complete")
    print(f"{'='*50}")
    print(f"Processed: {len(results)} files")
    print(f"Files with contract renames: {sum(1 for r in results if r['changes'])}")

    return results


if __name__ == "__main__":
    sanitize_falseprophet()
