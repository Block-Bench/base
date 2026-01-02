#!/usr/bin/env python3
"""
Sanitize Trojan Contracts

This script sanitizes protocol names in trojan contracts while preserving
the distractor code (the core feature of trojan).

Input: dataset/temporal_contamination/trojan/
Output: Same directory (in-place update)

What it does:
- Replaces protocol names in contract names (CompoundMarket -> LendingMarket)
- Replaces protocol names in interface names (ICurvePool -> IStablePool)
- Replaces protocol names in function names
- Removes protocol names from comments
- Updates metadata to match sanitized contract/function names
- Preserves distractor code structure

Usage:
    python strategies/trojan/sanitize_trojan.py
"""

import sys
import re
import json
from pathlib import Path
from datetime import datetime

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

# Protocol name mappings (same as other sanitization scripts)
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

# Specific contract name replacements
CONTRACT_REPLACEMENTS = {
    'NomadReplica': 'BridgeReplica',
    'BeanstalkGovernance': 'Governance',
    'ParityWalletLibrary': 'WalletLibrary',
    'ParityWalletProxy': 'WalletProxy',
    'HarvestVault': 'YieldVault',
    'CurvePool': 'StablePool',
    'CurveOracle': 'PoolOracle',
    'RoninBridge': 'GameBridge',
    'EthCrossChainManager': 'CrossChainManager',
    'EthCrossChainData': 'CrossChainData',
    'CreamLending': 'ForkLending',
    'KyberSwapPool': 'ConcentratedPool',
    'RariFuse': 'LendingHub',
    'HunnyMinter': 'RewardMinter',
    'YearnVault': 'YieldVault',
    'CompoundCToken': 'CToken',
    'CompoundMarket': 'LendingMarket',
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
    # Interface replacements
    'ICurvePool': 'IStablePool',
    'ICurve3Pool': 'IStable3Pool',
    'ICompoundToken': 'ILendToken',
    'IPendleMarket': 'IYieldMarket',
}

# Function name replacements
FUNCTION_REPLACEMENTS = {
    '_investInCurve': '_investInPool',
    '_withdrawFromCurve': '_withdrawFromPool',
    'anySwapOutUnderlyingWithPermit': 'bridgeOutWithPermit',
    '_anySwapOut': '_bridgeOut',
}

# Variable name replacements
VARIABLE_REPLACEMENTS = {
    'curvePool': 'stablePool',
    'curve3Pool': 'stable3Pool',
    'curveBalance': 'poolBalance',
    'hunnyRewardAmount': 'rewardAmount',
}


def sanitize_code(code: str) -> tuple:
    """Sanitize protocol names in code."""
    result = code
    changes = {}

    # Replace contract/interface names
    for old_name, new_name in CONTRACT_REPLACEMENTS.items():
        if old_name in result:
            result = re.sub(r'\b' + re.escape(old_name) + r'\b', new_name, result)
            changes[old_name] = new_name

    # Replace function names
    for old_name, new_name in FUNCTION_REPLACEMENTS.items():
        if old_name in result:
            result = re.sub(r'\b' + re.escape(old_name) + r'\b', new_name, result)
            changes[old_name] = new_name

    # Replace variable names
    for old_name, new_name in VARIABLE_REPLACEMENTS.items():
        if old_name in result:
            result = re.sub(r'\b' + re.escape(old_name) + r'\b', new_name, result)
            changes[old_name] = new_name

    return result, changes


def sanitize_comments(code: str) -> str:
    """Remove protocol names from comments."""
    lines = code.split('\n')
    result_lines = []

    for line in lines:
        # Check if line contains a comment
        if '//' in line or '/*' in line or '*' in line.strip()[:2] if line.strip() else False:
            sanitized_line = line
            for protocol, replacement in PROTOCOL_MAPPINGS.items():
                pattern = re.compile(r'\b' + re.escape(protocol) + r'\b', re.IGNORECASE)
                sanitized_line = pattern.sub(replacement, sanitized_line)
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


def sanitize_trojan():
    """Sanitize all trojan contracts in place."""

    tr_dir = PROJECT_ROOT / "dataset" / "temporal_contamination" / "trojan"
    tr_contracts = tr_dir / "contracts"
    tr_metadata = tr_dir / "metadata"

    # Get sanitized metadata for reference
    sn_metadata = PROJECT_ROOT / "dataset" / "temporal_contamination" / "sanitized" / "metadata"

    print(f"Sanitizing trojan contracts in: {tr_dir}")
    print(f"Using sanitized metadata from: {sn_metadata}")

    results = []

    for tr_file in sorted(tr_contracts.glob("tr_tc_*.sol")):
        file_stem = tr_file.stem  # tr_tc_001
        num = file_stem.replace('tr_tc_', '')  # 001

        # Read original code
        original_code = tr_file.read_text()

        # Step 1: Sanitize contract/interface/function/variable names
        sanitized_code, code_changes = sanitize_code(original_code)

        # Step 2: Sanitize protocol names in comments
        sanitized_code = sanitize_comments(sanitized_code)

        # Get actual contracts/functions from sanitized code
        actual_contracts = get_contracts_from_code(sanitized_code)
        actual_functions = get_functions_from_code(sanitized_code)

        # Save sanitized contract
        tr_file.write_text(sanitized_code)

        # Update metadata
        tr_meta_file = tr_metadata / f"{file_stem}.json"
        sn_meta_file = sn_metadata / f"sn_tc_{num}.json"

        if tr_meta_file.exists():
            tr_data = json.loads(tr_meta_file.read_text())

            # Get vulnerable_contract and vulnerable_function from sanitized
            if sn_meta_file.exists():
                sn_data = json.loads(sn_meta_file.read_text())
                # Only update if the current value needs sanitization
                current_vc = tr_data.get('vulnerable_contract', '')
                if current_vc in CONTRACT_REPLACEMENTS:
                    tr_data['vulnerable_contract'] = CONTRACT_REPLACEMENTS[current_vc]
                elif current_vc not in actual_contracts and sn_data.get('vulnerable_contract') in actual_contracts:
                    tr_data['vulnerable_contract'] = sn_data.get('vulnerable_contract')

                current_vf = tr_data.get('vulnerable_function', '')
                if current_vf in FUNCTION_REPLACEMENTS:
                    tr_data['vulnerable_function'] = FUNCTION_REPLACEMENTS[current_vf]

            # Add sanitization note to transformation
            if 'transformation' not in tr_data:
                tr_data['transformation'] = {}

            tr_data['transformation']['sanitized'] = True
            tr_data['transformation']['sanitization_date'] = datetime.now().isoformat()
            tr_data['transformation']['code_renames'] = code_changes

            # Save updated metadata
            tr_meta_file.write_text(json.dumps(tr_data, indent=2))

        changes_count = len(code_changes)
        results.append({
            'file': file_stem,
            'changes': code_changes,
            'actual_contracts': actual_contracts
        })

        status = f"[ok] {changes_count} renames" if changes_count else "[ok] no renames needed"
        print(f"  {file_stem}: {status}")
        if code_changes:
            for old, new in list(code_changes.items())[:3]:
                print(f"      {old} -> {new}")

    # Summary
    print(f"\n{'='*50}")
    print(f"Trojan Sanitization Complete")
    print(f"{'='*50}")
    print(f"Processed: {len(results)} files")
    print(f"Files with renames: {sum(1 for r in results if r['changes'])}")

    return results


if __name__ == "__main__":
    sanitize_trojan()
