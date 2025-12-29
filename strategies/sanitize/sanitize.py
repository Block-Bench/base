"""
Baseline Sanitizer for BlockBench Contracts

Removes vulnerability hints from contract code including:
- Contract/function/variable names that reveal vulnerability type
- Comments that hint at vulnerabilities
- Other leaky patterns

Output naming: sn_{original_id} (e.g., sn_tc_001, sn_ds_001)
"""

import re
import json
import shutil
from pathlib import Path
from typing import Optional
from dataclasses import dataclass, field, asdict
from datetime import datetime

# Import shared reserved keywords to avoid accidentally modifying Solidity built-ins
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from strategies.common import (
    SOLIDITY_RESERVED,
    SOLIDITY_DOT_PROPERTIES,
    MSG_PROPERTIES,
    BLOCK_PROPERTIES,
    TX_PROPERTIES,
    ABI_FUNCTIONS,
    ADDRESS_MEMBERS,
    is_solidity_reserved,
    is_solidity_dot_property,
)
from strategies.common.line_markers import strip_line_markers, add_line_markers


# =============================================================================
# CONFIGURATION
# =============================================================================

# Base paths
BASE_DIR = Path(__file__).parent.parent.parent
DATA_DIR = BASE_DIR / "data"
BASE_DATA_DIR = DATA_DIR / "base"
SANITIZED_DIR = DATA_DIR / "sanitized"

# =============================================================================
# REPLACEMENT PATTERNS
# =============================================================================

# Contract/identifier name replacements
# Format: (pattern, replacement, flags)
# Patterns are case-insensitive where appropriate

NAME_REPLACEMENTS = [
    # Reentrancy patterns -> neutral names
    (r'\bReentrancy_cross_function\b', 'CrossFunctionVault', 0),
    (r'\bReentrancy_insecure\b', 'SimpleVault', 0),
    (r'\bReentrancy_bonus\b', 'BonusVault', 0),
    (r'\bReentrancyDAO\b', 'CommunityVault', 0),
    (r'\bReentranceExploit\b', 'VaultOperator', 0),
    (r'\bReentrance\b', 'TokenVault', 0),
    (r'\bModifierEntrancy\b', 'ModifierBank', 0),

    # Overflow/Underflow patterns -> neutral names
    (r'\bIntegerOverflowSingleTransaction\b', 'SingleTxCounter', 0),
    (r'\bIntegerOverflowMultiTxMultiFuncFeasible\b', 'MultiTxCalculator', 0),
    (r'\bIntegerOverflowMultiTxOneFuncFeasible\b', 'SingleFuncCalculator', 0),
    (r'\bIntegerOverflowMappingSym1\b', 'MappingCounter', 0),
    (r'\bIntegerOverflowBenign1\b', 'BenignCounter', 0),
    (r'\bIntegerOverflowMinimal\b', 'MinimalCounter', 0),
    (r'\bIntegerOverflowMul\b', 'MultiplyCounter', 0),
    (r'\bIntegerOverflowAdd\b', 'AdditionCounter', 0),
    (r'\bOverflow_Add\b', 'AdditionLedger', 0),
    (r'\bOverflow\b', 'Ledger', 0),

    # Vulnerable/Bug/Attack patterns -> neutral names
    (r'\bVulnerableERC721\b', 'BasicERC721', 0),
    (r'\bVulnerableBank\b', 'BasicBank', 0),
    (r'\bVulnContract\b', 'CoreContract', 0),
    (r'\bVulnStakingRewards\b', 'StakingRewards', 0),
    (r'\bVulnPermit\b', 'PermitToken', 0),
    (r'\bVulnVault\b', 'CoreVault', 0),
    (r'\bVuln\b', 'Core', 0),
    (r'\bVulnerable\b', 'Basic', 0),

    (r'\bBuggyBankManager\b', 'AlternateBankManager', 0),
    (r'\bSimpleBankBug\b', 'SimpleBankAlt', 0),
    (r'\bArrayDeletionBug\b', 'ArrayDeletion', 0),
    (r'\bStructDeletionBug\b', 'StructDeletion', 0),
    (r'\bHashCollisionBug\b', 'HashCollision', 0),
    (r'\bBuggy\b', 'Alternate', 0),

    (r'\bExploitContract\b', 'OperatorContract', 0),
    (r'\bExploitTest\b', 'OperatorTest', 0),
    (r'\bEtherStoreAttack\b', 'EtherStoreOperator', 0),
    (r'\bFailedAttack\b', 'FailedOperator', 0),
    (r'\bAttackerContract\b', 'OperatorContract', 0),
    (r'\bAttacker\b', 'Operator', 0),
    (r'\bAttack\b', 'Operator', 0),

    # DoS patterns -> neutral names
    (r'\bDosAuction\b', 'SimpleAuction', 0),
    (r'\bDosGas\b', 'GasAuction', 0),
    (r'\bDosNumber\b', 'NumberRegistry', 0),
    (r'\bDosOneFunc\b', 'SingleFuncRegistry', 0),
    (r'\brefundDos\b', 'refundAll', 0),
    (r'\bCrowdFundSafe\b', 'CrowdFundBatched', 0),
    (r'\brefundSafe\b', 'refundBatched', 0),

    # Front-running/Race condition patterns -> neutral names
    (r'\bRaceCondition\b', 'TokenExchange', 0),

    # Other hint patterns -> neutral names
    (r'\bUnprotected\b', 'OpenAccess', 0),
    (r'\bSimpleSuicide\b', 'SimpleDestruct', 0),
    (r'\bSuicidal\b', 'Destructible', 0),
    (r'\bCrowdFundBad\b', 'CrowdFundBasic', 0),

    # Function/variable name hints
    (r'\btestExploit\b', 'testOperation', 0),
    (r'\btestUnsafe\b', 'testOperation', 0),
    (r'\bexploit\b', 'operate', re.IGNORECASE),
    (r'\bhack\b', 'execute', re.IGNORECASE),
    (r'\bpwn\b', 'execute', re.IGNORECASE),

    # ===================
    # RUST/SOLANA PATTERNS
    # ===================

    # Rust module/function names with _insecure suffix
    (r'signer_authorization_insecure', 'signer_authorization', 0),
    (r'account_data_matching_insecure', 'account_data_matching', 0),
    (r'owner_checks_insecure', 'owner_checks', 0),
    (r'initialization_insecure', 'initialization', 0),
    (r'closing_accounts_insecure', 'closing_accounts', 0),
    (r'type_cosplay_insecure', 'type_cosplay', 0),
    (r'arbitrary_cpi_insecure', 'arbitrary_cpi', 0),
    (r'bump_seed_canonicalization_insecure', 'bump_seed_canonicalization', 0),
    (r'pda_sharing_insecure', 'pda_sharing', 0),
    (r'duplicate_mutable_accounts_insecure', 'duplicate_mutable_accounts', 0),

    # Generic Rust patterns (snake_case suffixes)
    (r'_insecure\b', '', 0),  # Remove _insecure suffix
    (r'_vulnerable\b', '', 0),  # Remove _vulnerable suffix
    (r'_attack\b', '_handler', 0),  # Replace _attack suffix
    (r'_exploit\b', '_handler', 0),  # Replace _exploit suffix

    # Standalone Rust module names
    (r'\bmod insecure\b', 'mod core_logic', 0),
    (r'\bmod vulnerable\b', 'mod core_logic', 0),
    (r'\bmod attack\b', 'mod handler', 0),

    # ===================
    # FIX/SECURE PATTERNS (reveal what was broken)
    # ===================

    # Function names with _fixed suffix
    (r'\bwithdrawBalance_fixed\b', 'withdrawBalanceV2', 0),
    (r'\bwithdrawBalance_fixed_2\b', 'withdrawBalanceV3', 0),
    (r'_fixed\b', 'V2', 0),  # Generic _fixed suffix
    (r'_secure\b', 'V2', 0),  # Generic _secure suffix
    (r'_safe\b', 'V2', 0),  # Generic _safe suffix
    (r'_remediated\b', 'V2', 0),  # Generic _remediated suffix

    # Contract names with Fixed/Secure prefix
    (r'\bFixedSimpleBank\b', 'SimpleBankV2', 0),
    (r'\bFixedArrayDeletion\b', 'ArrayDeletionV2', 0),
    (r'\bFixedStructDeletion\b', 'StructDeletionV2', 0),
    (r'\bFixedeBank\b', 'BankV2', 0),
    (r'\bFixedERC721\b', 'ERC721V2', 0),
    (r'\bFixedtakingRewards\b', 'StakingRewardsV2', 0),
    (r'\bSecureAuction\b', 'AuctionV2', 0),
    (r'\bTargetRemediated\b', 'TargetV2', 0),

    # Generic Fixed* and Secure* patterns (catch remaining)
    (r'\bFixed([A-Z][a-zA-Z]+)\b', r'\1V2', 0),

    # ===================
    # ADDITIONAL PATTERNS (from manual review)
    # ===================

    # More aggressive Vulnerable* patterns (camelCase compounds)
    (r'\bVulnerable([A-Z][a-zA-Z]+)Contract\b', r'Basic\1Contract', 0),
    (r'\bVulnerable([A-Z][a-zA-Z]+)\b', r'Basic\1', 0),

    # Bug suffix patterns (compounds not caught)
    (r'\b([A-Z][a-zA-Z]+)BugContract\b', r'\1Contract', 0),
    (r'\b([A-Z][a-zA-Z]+)Bug\b', r'\1Alt', 0),

    # DrainMe / Drain patterns
    (r'\bDrainMe\b', 'FundManager', 0),
    (r'\bDrain([A-Z][a-zA-Z]*)\b', r'Transfer\1', 0),

    # Lowercase attack/exploit as standalone function names
    (r'\bfunction\s+attack\s*\(', 'function operate(', 0),
    (r'\bfunction\s+exploit\s*\(', 'function execute(', 0),

    # attackModeIsOn and similar booleans
    (r'\battackModeIsOn\b', 'operationActive', 0),
    (r'\battackMode\b', 'operationMode', 0),
    (r'\bisAttacker\b', 'isOperator', 0),
    (r'\bisAttack\b', 'isOperation', 0),

    # pwned/pwn variables
    (r'\bpwned\b', 'completed', 0),
    (r'\bisPwned\b', 'isCompleted', 0),

    # vulnerable_contract variable (snake_case)
    (r'\bvulnerable_contract\b', 'target_contract', 0),
    (r'\bvulnerable_\b', 'target_', 0),

    # Test function names with vulnerability types
    (r'\btestReentrancy\b', 'testWithdrawal', 0),
    (r'\btestOverflow\b', 'testCalculation', 0),
    (r'\btestUnderflow\b', 'testCalculation', 0),
    (r'\btestPwn\b', 'testExecution', 0),
    (r'\btestUnsafe([A-Z][a-zA-Z]*)\b', r'testAlt\1', 0),
    (r'\btestVulnerable\b', 'testBasic', 0),
    (r'\btestExploit\b', 'testOperation', 0),

    # Route patterns
    (r'\bVulnerableRoute\b', 'BasicRoute', 0),

    # Steal/Hijack patterns
    (r'\bsteal([A-Z][a-zA-Z]*)\b', r'transfer\1', re.IGNORECASE),
    (r'\bhijack([A-Z][a-zA-Z]*)\b', r'redirect\1', re.IGNORECASE),

    # Malicious patterns
    (r'\bmalicious([A-Z][a-zA-Z]*)\b', r'external\1', re.IGNORECASE),
    (r'\bMalicious([A-Z][a-zA-Z]*)\b', r'External\1', 0),

    # ===================
    # REMAINING LEAKAGES (from verification)
    # ===================

    # Variable names with attack/Attack
    (r'\battackRemediated\b', 'operatorV2', 0),
    (r'\bFailedAttackContract\b', 'FailedOperatorContract', 0),
    (r'\bAttackContract\b', 'OperatorContract', 0),
    (r'\battacker\b', 'operator', 0),

    # Contract names still leaking
    (r'\bcontract\s+attack\s*\{', 'contract executor {', 0),
    (r'\bVulnerableERC721Contract\b', 'BasicERC721Contract', 0),

    # More test function names
    (r'\btestVulnerableBank\b', 'testBasicBank', 0),
    (r'\btestVulnerableERC721\b', 'testBasicERC721', 0),
    (r'\btestStorageExploit\b', 'testStorageOperation', 0),
    (r'\btestOverflow\d*\b', 'testCalculation', 0),

    # Exploit test contract names
    (r'\bUniswapV3ETHRefundExploitTest\b', 'UniswapV3ETHRefundOperationTest', 0),

    # Read-only reentrancy (typo variant)
    (r'\bperformReadOnlyReentrnacy\b', 'performReadOnlyCallback', 0),
    (r'\bperformReadOnlyReentrancy\b', 'performReadOnlyCallback', 0),

    # Overflow function names (snake_case)
    (r'\boverflowaddtostate\b', 'addtostate', 0),
    (r'\boverflowmultostate\b', 'multostate', 0),
    (r'\boverflowlocalonly\b', 'localcalc', 0),
    (r'\boverflow_\w+\b', 'calculate', 0),

    # _vulnerable_ in snake_case
    (r'_vulnerable_', '_target_', 0),

    # ===================
    # METHOD CALLS AND SIGNATURES
    # ===================

    # Method calls like .attack() or .attack{value}()
    (r'\.attack\s*\(', '.operate(', 0),
    (r'\.attack\s*\{', '.operate{', 0),
    (r'\.exploit\s*\(', '.execute(', 0),

    # abi.encodeWithSignature with attack/exploit
    (r'abi\.encodeWithSignature\s*\(\s*"attack\(\)"', 'abi.encodeWithSignature("operate()"', 0),
    (r'abi\.encodeWithSignature\s*\(\s*"exploit\(\)"', 'abi.encodeWithSignature("execute()"', 0),

    # this.attack pattern
    (r'\bthis\.attack\b', 'this.operate', 0),
    (r'\bthis\.exploit\b', 'this.execute', 0),

    # Variable named attack (standalone) - various contexts
    (r'\b(\w+)\s+attack\s*;', r'\1 operator;', 0),
    (r'\battack\s*=\s*new\b', 'operator = new', 0),
    (r'\battack\.', 'operator.', 0),
    (r'\(attack\)', '(operator)', 0),  # function argument
    (r'\(address\(attack\)', '(address(operator)', 0),  # address(attack)
    (r',\s*attack\s*\)', ', operator)', 0),  # trailing argument
    (r',\s*attack\s*,', ', operator,', 0),  # middle argument

    # More test function patterns
    (r'\btestERC777Reentrancy\b', 'testERC777Callback', 0),
    (r'\btestERC721Reentrancy\b', 'testERC721Callback', 0),

    # More overflow function variants
    (r'\boverflowmulocalonly\b', 'mullocalonly', 0),
    (r'\boverflow[a-z]+\b', 'calculate', 0),

    # ===================
    # PROTOCOL NAME REPLACEMENTS (Temporal Contamination)
    # These remove specific protocol/project names that could identify famous exploits
    # ===================

    # Protocol names after Basic* prefix (from Vulnerable* → Basic* transformation)
    (r'\bBasicNomadReplica\b', 'BasicBridgeReplica', 0),
    (r'\bBasicBeanstalkGovernance\b', 'BasicGovernance', 0),
    (r'\bBasicBZXLoanToken\b', 'BasicLoanToken', 0),
    (r'\bBasicCompoundCToken\b', 'BasicCToken', 0),
    (r'\bBasicCreamLending\b', 'BasicLending', 0),
    (r'\bBasicCurvePool\b', 'BasicPool', 0),
    (r'\bBasicHarvestVault\b', 'BasicVault', 0),
    (r'\bBasicHunnyMinter\b', 'BasicMinter', 0),
    (r'\bBasicKyberSwapPool\b', 'BasicSwapPool', 0),
    (r'\bBasicParityWalletLibrary\b', 'BasicWalletLibrary', 0),
    (r'\bBasicPickleController\b', 'BasicController', 0),
    (r'\bBasicRariFuse\b', 'BasicLendingHub', 0),
    (r'\bBasicRoninBridge\b', 'BasicBridge', 0),
    (r'\bBasicYearnVault\b', 'BasicVault', 0),
    (r'\bBasicEthCrossChainManager\b', 'BasicCrossChainManager', 0),

    # Protocol names in non-Vulnerable contracts (helper/support contracts)
    (r'\bNomadReplica\b', 'BridgeReplica', 0),
    (r'\bBeanstalkGovernance\b', 'Governance', 0),
    (r'\bAlphaHomoraBank\b', 'LeveragedBank', 0),
    (r'\bAnyswapRouter\b', 'CrossRouter', 0),
    (r'\bBedrockVault\b', 'StakingVault', 0),
    (r'\bBeltStrategy\b', 'YieldStrategy', 0),
    (r'\bBlueberryLending\b', 'LeveragedLending', 0),
    (r'\bBurgerSwapRouter\b', 'SwapRouter', 0),
    (r'\bCowSolver\b', 'BatchSolver', 0),
    (r'\bCurveOracle\b', 'PoolOracle', 0),
    (r'\bDODOPool\b', 'LiquidityPool', 0),
    (r'\bExactlyMarket\b', 'LendingMarket', 0),
    (r'\bFixedFloatHotWallet\b', 'ExchangeHotWallet', 0),
    (r'\bGammaHypervisor\b', 'LiquidityHypervisor', 0),
    (r'\bHedgeyClaimCampaigns\b', 'TokenClaimCampaigns', 0),
    (r'\bHundredFinanceMarket\b', 'LendingMarket', 0),
    (r'\bInverseLending\b', 'SyntheticLending', 0),
    (r'\bMunchablesLockManager\b', 'GameLockManager', 0),
    (r'\bOrbitBridge\b', 'CrossBridge', 0),
    (r'\bParityWalletProxy\b', 'WalletProxy', 0),
    (r'\bParityWalletLibrary\b', 'WalletLibrary', 0),
    (r'\bPendleMarketRegister\b', 'YieldMarketRegister', 0),
    (r'\bPenpieStaking\b', 'VeTokenStaking', 0),
    (r'\bPickleStrategy\b', 'YieldStrategy', 0),
    (r'\bPickleController\b', 'YieldController', 0),
    (r'\bPlayDappToken\b', 'GameToken', 0),
    (r'\bQBridge\b', 'QuantumBridge', 0),
    (r'\bQBridgeHandler\b', 'BridgeHandler', 0),
    (r'\bRadiantLendingPool\b', 'CrossLendingPool', 0),
    (r'\bSenecaChamber\b', 'CDPChamber', 0),
    (r'\bShezmuCollateralToken\b', 'CollateralToken', 0),
    (r'\bShezmuVault\b', 'CollateralVault', 0),
    (r'\bSocketGateway\b', 'BridgeGateway', 0),
    (r'\bSonneMarket\b', 'CompMarket', 0),
    (r'\bSpartanPool\b', 'LiquidityPool', 0),
    (r'\bUraniumPair\b', 'SwapPair', 0),
    (r'\bUwuLendingPool\b', 'LendingPool', 0),
    (r'\bWarpVault\b', 'CollateralVault', 0),
    (r'\bWiseLending\b', 'IsolatedLending', 0),
    (r'\bEthCrossChainData\b', 'CrossChainData', 0),
    (r'\bEthCrossChainManager\b', 'CrossChainManager', 0),
    (r'\bRariFuse\b', 'LendingHub', 0),
    (r'\bRoninBridge\b', 'GameBridge', 0),
    (r'\bKyberSwapPool\b', 'ConcentratedPool', 0),
    (r'\bHarvestVault\b', 'YieldVault', 0),
    (r'\bYearnVault\b', 'YieldVault', 0),
    (r'\bCreamLending\b', 'ForkLending', 0),
    (r'\bCompoundCToken\b', 'CToken', 0),
    (r'\bCurvePool\b', 'StablePool', 0),
    (r'\bBZXLoanToken\b', 'MarginToken', 0),
    (r'\bHunnyMinter\b', 'RewardMinter', 0),

    # Generic protocol name patterns (catch remaining in identifiers)
    (r'\bNomad([A-Z][a-zA-Z]*)\b', r'Bridge\1', 0),
    (r'\bBeanstalk([A-Z][a-zA-Z]*)\b', r'Farm\1', 0),
    (r'\bParity([A-Z][a-zA-Z]*)\b', r'Multi\1', 0),
    (r'\bRonin([A-Z][a-zA-Z]*)\b', r'Game\1', 0),
    (r'\bHarvest([A-Z][a-zA-Z]*)\b', r'Yield\1', 0),
    (r'\bYearn([A-Z][a-zA-Z]*)\b', r'Yield\1', 0),
    (r'\bCurve([A-Z][a-zA-Z]*)\b', r'Stable\1', 0),
    (r'\bCompound([A-Z][a-zA-Z]*)\b', r'Lend\1', 0),
    (r'\bAave([A-Z][a-zA-Z]*)\b', r'Lend\1', 0),
    (r'\bUniswap([A-Z][a-zA-Z]*)\b', r'Swap\1', 0),
    (r'\bSushiSwap([A-Z][a-zA-Z]*)\b', r'Swap\1', 0),
    (r'\bPancakeSwap([A-Z][a-zA-Z]*)\b', r'Swap\1', 0),

    # Interface/variable names with protocol references (camelCase and PascalCase)
    (r'\bICurvePool\b', 'IStablePool', 0),
    (r'\bICurve3Pool\b', 'IStable3Pool', 0),
    (r'\bcurvePool\b', 'stablePool', 0),
    (r'\bcurve3Pool\b', 'stable3Pool', 0),
    (r'\b_curvePool\b', '_stablePool', 0),
    (r'\b_curve3Pool\b', '_stable3Pool', 0),
    (r'\b_investInCurve\b', '_investInPool', 0),
    (r'\b_withdrawFromCurve\b', '_withdrawFromPool', 0),
    (r'\bcurveBalance\b', 'poolBalance', 0),
    (r'\bIAlphaHomora\b', 'ILeveragedLending', 0),
    (r'\balphaHomora\b', 'leveragedLending', 0),
    (r'\bIHundredFinance\b', 'ILendingMarket', 0),
    (r'\bhundredFinance\b', 'lendingMarket', 0),
    (r'\bIInverse\b', 'ISyntheticLending', 0),
    (r'\binverseLending\b', 'syntheticLending', 0),

    # Variable names with protocol hints
    (r'\bhunnyRewardAmount\b', 'rewardAmount', 0),
    (r'\bhunnyReward\b', 'tokenReward', 0),
    (r'\byearnShares\b', 'vaultShares', 0),
    (r'\bcompoundBalance\b', 'lendingBalance', 0),
    (r'\bcreamBalance\b', 'lendingBalance', 0),

    # More interface patterns
    (r'\bICompoundToken\b', 'ILendToken', 0),
    (r'\bICompound\b', 'ILendProtocol', 0),
    (r'\bcompoundToken\b', 'lendToken', 0),

    # Anyswap function patterns
    (r'\banySwapOut([A-Za-z]*)\b', r'crossOut\1', 0),
    (r'\b_anySwapOut\b', '_crossOut', 0),
    (r'\banySwapIn([A-Za-z]*)\b', r'crossIn\1', 0),
    (r'\b_anySwapIn\b', '_crossIn', 0),

    # More camelCase protocol patterns
    (r'\bharmony([A-Z][a-zA-Z]*)\b', r'cross\1', 0),
    (r'\bHarmony([A-Z][a-zA-Z]*)\b', r'Cross\1', 0),
]

# Comment patterns to remove (entire line or inline)
COMMENT_PATTERNS_TO_REMOVE = [
    # ===================
    # PROTOCOL NAME REFERENCES IN COMMENTS
    # These reveal which famous exploit the contract is based on
    # ===================
    r'//.*\b(Nomad|Beanstalk|Parity|Ronin|Harvest|Yearn|Compound|Cream|Curve|Kyber|Rari|bZx|BZX|Hunny|Pickle)\b.*$',
    r'//.*\b(AlphaHomora|Alpha Homora|Anyswap|Bedrock|Belt|Blueberry|BurgerSwap)\b.*$',
    r'//.*\b(DODO|Exactly|FixedFloat|Gamma|Hedgey|HundredFinance|Hundred Finance)\b.*$',
    r'//.*\b(Inverse|Munchables|Orbit|Pendle|Penpie|PlayDapp|QBridge)\b.*$',
    r'//.*\b(Radiant|Seneca|Shezmu|Socket|Sonne|Spartan|Uranium|Uwu|Warp|Wise)\b.*$',
    r'//.*In (?:the )?real\s+\w+.*$',  # "In real Beanstalk", "In the real Parity wallet"
    r'//.*(?:simplified|based on|derived from)\s+\w+\s+(?:hack|exploit|incident).*$',

    # NatSpec comments with protocol names (block comment style)
    r'\*.*\b(Nomad|Beanstalk|Parity|Ronin|Harvest|Yearn|Compound|Cream|Curve|Kyber|Rari|bZx|BZX|Hunny|Pickle)\b.*$',
    r'\*.*\b(AlphaHomora|Alpha Homora|Anyswap|Bedrock|Belt|Blueberry|BurgerSwap)\b.*$',
    r'\*.*\b(DODO|Exactly|FixedFloat|Gamma|Hedgey|HundredFinance|Hundred Finance)\b.*$',
    r'\*.*\b(Inverse|Munchables|Orbit|Pendle|Penpie|PlayDapp|QBridge)\b.*$',
    r'\*.*\b(Radiant|Seneca|Shezmu|Socket|Sonne|Spartan|Uranium|Uwu|Warp|Wise)\b.*$',

    # ===================
    # CORE VULNERABILITY KEYWORDS
    # ===================

    # Primary vulnerability hints in comments (broad catch-all)
    r'//.*\b(vulnerable|vulnerability|insecure|unsafe|exploit|attack|hack|bug)\b.*$',
    r'//.*\bBUG:.*$',
    r'//.*\bVULNERABLE.*$',
    r'//.*\bINSECURE.*$',
    r'//.*\bUNSAFE.*$',
    r'//.*\bEXPLOIT.*$',
    r'//.*\bATTACK.*$',
    r'//.*\bHACK.*$',

    # Reentrancy variants (including hyphenated)
    r'//.*\bre-?entran.*$',
    r'//.*\breentr.*$',

    # Overflow/underflow
    r'//.*\boverflow.*$',
    r'//.*\bunderflow.*$',
    r'//.*\binteger\s+wrap.*$',

    # ===================
    # ACTION/EVENT COMMENTS
    # ===================

    # Exploit completion messages
    r'//.*[Ee]xploit\s+completed.*$',
    r'//.*[Aa]ttack\s+completed.*$',
    r'//.*[Aa]ttack\s+successful.*$',
    r'//.*[Ee]xploit\s+successful.*$',
    r'//.*[Pp]wned.*$',
    r'//.*[Dd]rained.*$',

    # Challenge hints
    r'//.*#[Ss]pot[Tt]he[Bb]ug.*$',
    r'//.*[Ss]pot\s*the\s*bug.*$',
    r'//.*[Ff]ind\s+the\s+(bug|vulnerability).*$',
    r'//.*[Cc]an\s+you\s+spot.*$',
    r'//.*[Ii]mmunefi.*$',
    r'//.*twitter\.com/immunefi.*$',

    # ===================
    # VULNERABILITY DESCRIPTIONS
    # ===================

    # Specific vulnerability descriptions
    r'//.*[Pp]ost-transaction effect:.*overflow.*$',
    r'//.*[Ss]ingle transaction overflow.*$',

    # Protection/fix hints (these reveal the vulnerability type too)
    r'//.*protect\s+against.*$',
    r'//.*safe\s+against.*$',
    r'//.*prevent\s+(reentrancy|overflow|underflow|attack).*$',

    # Direct vulnerability mechanism hints
    r'//.*[Uu]ninitialized\s+storage\s+pointer.*$',
    r'//.*loop\s+between.*fallback.*$',
    r'//.*caller.*code.*executed.*$',
    r'//.*check.?effect.?interaction.*$',
    r'//.*\bCEI\b.*pattern.*$',
    r'//.*missing.*check.*$',
    r'//.*missing.*validation.*$',
    r'//.*no\s+access\s+control.*$',
    r'//.*lacks?\s+access\s+control.*$',

    # Storage collision hints
    r'//.*storage\s+collision.*$',
    r'//.*slot\s+collision.*$',

    # Signature/replay hints
    r'//.*signature\s+replay.*$',
    r'//.*replay\s+attack.*$',
    r'//.*missing\s+nonce.*$',

    # ===================
    # DoS AND FRONTRUNNING
    # ===================

    r'//.*[Gg]as\s*[Dd][Oo][Ss].*$',
    r'//.*[Dd]enial\s+of\s+service.*$',
    r'//.*\bDoS\b.*$',
    r'//.*frontrunner.*$',
    r'//.*front.?run.*$',
    r'//.*cannot\s+be\s+DoS.*$',
    r'//.*avoid\s+DoS.*$',
    r'//.*griefing.*$',

    # ===================
    # MITIGATION/FIX COMMENTS
    # ===================

    r'//.*[Mm]itigation.*$',
    r'//.*FIXED:.*$',
    r'//.*[Ff]ix\s+require.*$',
    r'//.*[Mm]itigated.*$',
    r'//.*[Rr]emediat.*$',
    r'//.*[Pp]atched.*$',
    r'//.*[Ss]ecured.*$',
    r'//.*now\s+safe.*$',

    # ===================
    # SPECIFIC VULNERABILITY TYPES
    # ===================

    # Randomness vulnerability hints
    r'//.*terrible\s+source\s+of\s+randomness.*$',
    r'//.*weak\s+randomness.*$',
    r'//.*predictable\s+random.*$',
    r'//.*block\.(timestamp|number|difficulty).*random.*$',

    # Delegatecall hints
    r'//.*delegatecall\s+with\s+caution.*$',
    r'//.*delegatecall.*dangerous.*$',
    r'//.*never\s+call\s+into\s+untrusted.*$',

    # Flash loan hints
    r'//.*flash\s*loan.*$',
    r'//.*price\s+manipulation.*$',
    r'//.*oracle\s+manipulation.*$',

    # Access control hints
    r'//.*anyone\s+can\s+call.*$',
    r'//.*no\s+owner\s+check.*$',
    r'//.*missing\s+onlyOwner.*$',
    r'//.*unprotected\s+function.*$',

    # Honeypot hints
    r'//.*honeypot.*$',
    r'//.*hidden\s+trap.*$',

    # Suicide/selfdestruct hints
    r'//.*[Ss]uicide\s*:\(.*$',
    r'//.*selfdestruct.*danger.*$',

    # Tx.origin hints
    r'//.*tx\.origin.*phishing.*$',
    r'//.*never\s+use\s+tx\.origin.*$',

    # ===================
    # EXTERNAL REFERENCES
    # ===================

    r'//.*immunefi.*$',
    r'//.*https://twitter\.com/immunefi.*$',
    r'//.*https://www\.reddit\.com/r/ethdev.*honeypot.*$',
    r'//.*swcregistry.*$',
    r'//.*SWC-\d+.*$',
    r'//.*CVE-\d+.*$',
    r'//.*CWE-\d+.*$',

    # ===================
    # CATCH-ALL FOR REMAINING HINTS
    # ===================

    # Generic "this is bad" comments
    r'//.*[Bb]ad\s+practice.*$',
    r'//.*[Dd]angerous.*$',
    r'//.*[Rr]isky.*$',
    r'//.*[Ss]ecurity\s+(issue|flaw|hole|risk|problem).*$',

    # TODO/FIXME with security context
    r'//.*TODO:?\s*(fix|secure|patch|remove).*$',
    r'//.*FIXME:?\s*(security|vulnerable|unsafe).*$',

    # Solhint/slither disable comments (reveal what's being suppressed)
    r'//\s*solhint-disable.*$',
    r'//\s*slither-disable.*$',
]

# Multi-line comment patterns (NatSpec, block comments)
BLOCK_COMMENT_PATTERNS = [
    r'/\*\*?[^*]*\*+(?:[^/*][^*]*\*+)*/',  # /* ... */ and /** ... */
]

# Console.log sanitization patterns
CONSOLE_LOG_REPLACEMENTS = [
    # Specific common messages (with various quote styles and multiline)
    (r'console\.log\s*\(\s*\n?\s*"Before exploiting[^"]*"', 'console.log(\n            "Before operation"', 0),
    (r'console\.log\s*\(\s*\n?\s*"After exploiting[^"]*"', 'console.log(\n            "After operation"', 0),
    (r"console\.log\s*\(\s*\n?\s*'Before exploiting[^']*'", "console.log(\n            'Before operation'", 0),
    (r"console\.log\s*\(\s*\n?\s*'After exploiting[^']*'", "console.log(\n            'After operation'", 0),

    # String literals containing vulnerability keywords (safe replacements)
    (r'"Before exploiting[^"]*"', '"Before operation"', 0),
    (r'"After exploiting[^"]*"', '"After operation"', 0),
    (r'"Afer exploiting[^"]*"', '"After operation"', 0),  # Typo variant
    (r'"[^"]*exploiting[^"]*"', '"Operation result"', 0),  # Generic exploiting strings

    # emit statements with hints
    (r'emit\s+[Aa]ttack[^;]*;', 'emit OperationExecuted();', 0),
    (r'emit\s+[Ee]xploit[^;]*;', 'emit ExecutionComplete();', 0),
]

# Raw text patterns to remove/replace (file content that isn't code)
RAW_TEXT_REPLACEMENTS = [
    # File headers with vulnerability descriptions
    (r'^Single transaction overflow\s*$', '// Contract file', re.MULTILINE),
    (r'^Multi transaction overflow\s*$', '// Contract file', re.MULTILINE),
    (r'^Integer overflow\s*$', '// Contract file', re.MULTILINE),
    (r'^Reentrancy vulnerability\s*$', '// Contract file', re.MULTILINE),
]

# Metadata fields to remove (not needed for judging)
# NOTE: Metadata is for JUDGE only, not shown to models
# Keep all fields needed for evaluation: root_cause, attack_scenario, fix_description, etc.
METADATA_FIELDS_TO_REMOVE = [
    # Only remove external links and redundant fields
    'source_reference',       # External GitHub/source links
    'external_references',    # External Twitter/blog links
    'detection_hints',        # Hints for detection (not needed for judging correctness)
]

# Metadata fields to rename - DISABLED
# Judge needs original field names like vulnerability_type, is_vulnerable
METADATA_FIELDS_TO_RENAME = {
    # Intentionally empty - keep original field names for judge
}


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class SanitizationResult:
    """Result of sanitizing a single file."""
    original_id: str
    sanitized_id: str
    success: bool
    changes_made: list = field(default_factory=list)
    rename_mappings: dict = field(default_factory=dict)  # {original_name: new_name}
    error: Optional[str] = None


@dataclass
class SanitizationReport:
    """Report for a batch sanitization run."""
    timestamp: str
    total_files: int
    successful: int
    failed: int
    results: list = field(default_factory=list)

    def to_dict(self):
        return {
            'timestamp': self.timestamp,
            'total_files': self.total_files,
            'successful': self.successful,
            'failed': self.failed,
            'results': [asdict(r) for r in self.results]
        }


# =============================================================================
# CORE SANITIZATION FUNCTIONS
# =============================================================================

def sanitize_metadata(metadata: dict) -> tuple[dict, list[str]]:
    """
    Sanitize metadata by removing fields not needed for judging.

    NOTE: Metadata is for JUDGE only, not shown to models.
    Keep all fields needed for evaluation (root_cause, attack_scenario,
    fix_description, description, vulnerability_type, etc.)

    Args:
        metadata: The original metadata dictionary

    Returns:
        Tuple of (sanitized_metadata, list_of_changes_made)
    """
    changes = []
    result = metadata.copy()

    # Remove only fields not needed for judging (external links)
    for field in METADATA_FIELDS_TO_REMOVE:
        if field in result:
            changes.append(f"Removed metadata field: {field}")
            del result[field]

    # Rename fields (currently disabled - keep original names for judge)
    for old_name, new_name in METADATA_FIELDS_TO_RENAME.items():
        if old_name in result:
            result[new_name] = result.pop(old_name)
            changes.append(f"Renamed metadata field: {old_name} → {new_name}")

    # NOTE: Do NOT sanitize description/notes - judge needs full context
    # The metadata is never shown to models, only used for evaluation

    return result, changes


def sanitize_code(code: str) -> tuple[str, list[str], dict[str, str]]:
    """
    Sanitize a code string by removing vulnerability hints.

    Line markers (/*LN-N*/) are stripped before processing and fresh
    sequential markers are added after processing.

    Args:
        code: The Solidity/Rust source code to sanitize

    Returns:
        Tuple of (sanitized_code, list_of_changes_made, rename_mappings)
        rename_mappings is {original_name: new_name} for identifier renames
    """
    changes = []
    rename_mappings = {}  # Track identifier renames for metadata transformation

    # Step 0: Strip existing line markers from input
    result = strip_line_markers(code)

    # Step 1: Remove hint comments (single-line)
    for pattern in COMMENT_PATTERNS_TO_REMOVE:
        matches = re.findall(pattern, result, re.MULTILINE | re.IGNORECASE)
        if matches:
            for match in matches:
                changes.append(f"Removed comment: {match[:50]}...")
            result = re.sub(pattern, '', result, flags=re.MULTILINE | re.IGNORECASE)

    # Step 2: Clean up block comments with vulnerability hints
    # Use proper regex that only matches single block comments (not spanning across code)
    block_comment_pattern = r'/\*[^*]*\*+(?:[^/*][^*]*\*+)*/'
    vuln_hint_pattern = re.compile(r'(vulnerable|vulnerability|exploit|attack|insecure|unsafe|bug|hack|overflow|underflow|reentrancy)', re.IGNORECASE)

    def remove_hint_comment(match):
        comment = match.group(0)
        # Remove if contains vulnerability keywords
        if vuln_hint_pattern.search(comment):
            changes.append(f"Removed block comment with vulnerability hint")
            return ''
        # Also remove DeFiVulnLabs documentation format (Name: + Description:/Mitigation:)
        if 'Name:' in comment and ('Description:' in comment or 'Mitigation:' in comment):
            changes.append(f"Removed DeFiVulnLabs documentation comment")
            return ''
        # Remove comments with security challenge hints
        if '#spotthebug' in comment.lower() or 'immunefi' in comment.lower():
            changes.append(f"Removed security challenge comment")
            return ''
        # Remove standalone Mitigation comments (fix documentation)
        if 'Mitigation:' in comment or 'mitigation:' in comment:
            changes.append(f"Removed mitigation documentation comment")
            return ''
        return comment

    result = re.sub(block_comment_pattern, remove_hint_comment, result)

    # Step 3: Apply name replacements and track mappings
    for pattern, replacement, flags in NAME_REPLACEMENTS:
        if flags:
            matches = re.findall(pattern, result, flags)
        else:
            matches = re.findall(pattern, result)

        if matches:
            for match in set(matches):
                # Handle regex group replacements (e.g., r'\1V2')
                if isinstance(match, tuple):
                    original_name = match[0] if match else str(match)
                else:
                    original_name = match

                # Calculate actual replacement for this match
                if '\\1' in replacement or '\\2' in replacement:
                    # Regex group replacement - compute actual result
                    actual_replacement = re.sub(pattern, replacement, original_name, flags=flags if flags else 0)
                else:
                    actual_replacement = replacement

                changes.append(f"Renamed: {original_name} → {actual_replacement}")
                rename_mappings[original_name] = actual_replacement

            if flags:
                result = re.sub(pattern, replacement, result, flags=flags)
            else:
                result = re.sub(pattern, replacement, result)

    # Step 4: Sanitize console.log and emit statements
    for pattern, replacement, flags in CONSOLE_LOG_REPLACEMENTS:
        if flags:
            matches = re.findall(pattern, result, flags)
        else:
            matches = re.findall(pattern, result)

        if matches:
            changes.append(f"Sanitized console/emit statement")
            if flags:
                result = re.sub(pattern, replacement, result, flags=flags)
            else:
                result = re.sub(pattern, replacement, result)

    # Step 5: Apply raw text replacements (file content that isn't code)
    for pattern, replacement, flags in RAW_TEXT_REPLACEMENTS:
        if flags:
            matches = re.findall(pattern, result, flags)
        else:
            matches = re.findall(pattern, result)

        if matches:
            changes.append(f"Replaced raw text: {matches[0][:30]}...")
            if flags:
                result = re.sub(pattern, replacement, result, flags=flags)
            else:
                result = re.sub(pattern, replacement, result)

    # Step 6: Clean up empty lines left by comment removal
    result = re.sub(r'\n\s*\n\s*\n', '\n\n', result)

    # Step 7: Clean up trailing whitespace
    result = '\n'.join(line.rstrip() for line in result.split('\n'))

    # Step 8: Validate that Solidity built-ins are preserved
    # Note: Use original code with markers stripped for validation
    original_clean = strip_line_markers(code)
    warnings = _validate_solidity_builtins(original_clean, result)
    if warnings:
        for warning in warnings:
            changes.append(f"WARNING: {warning}")

    # Step 9: Add fresh sequential line markers
    result = add_line_markers(result)

    return result, changes, rename_mappings


def transform_metadata_identifiers(metadata: dict, rename_mappings: dict[str, str], sanitized_code: str = None) -> tuple[dict, list[str]]:
    """
    Transform metadata identifiers using the rename mappings from code sanitization.

    Args:
        metadata: Original metadata dictionary
        rename_mappings: Dictionary of {original_name: new_name} from sanitize_code
        sanitized_code: Optional sanitized code to infer contract name if not in mappings

    Returns:
        Tuple of (transformed_metadata, list_of_changes)
    """
    import copy
    changes = []
    result = copy.deepcopy(metadata)

    # Top-level fields that contain identifier names
    top_level_fields = [
        'vulnerable_function',
        'vulnerable_contract',
        'fix_function',
        'affected_functions',
        'affected_contracts',
    ]

    # Nested fields to check (path -> field_names)
    nested_paths = [
        (['ground_truth', 'vulnerable_location'], ['contract_name', 'function_name']),
        (['code_metadata'], ['contract_names']),
    ]

    def transform_value(value, field_path):
        """Transform a value using rename_mappings, handling Vulnerable* prefix."""
        if isinstance(value, str):
            # Direct match
            if value in rename_mappings:
                new_value = rename_mappings[value]
                changes.append(f"Transformed {field_path}: {value} → {new_value}")
                return new_value
            # Handle Vulnerable* prefix - check if Basic* version is in mappings
            if value.startswith('Vulnerable'):
                base_name = value[len('Vulnerable'):]
                basic_name = f'Basic{base_name}'
                if basic_name in rename_mappings:
                    new_value = rename_mappings[basic_name]
                    changes.append(f"Transformed {field_path}: {value} → {new_value}")
                    return new_value
                # Check if base_name itself is in mappings
                if base_name in rename_mappings:
                    new_value = rename_mappings[base_name]
                    changes.append(f"Transformed {field_path}: {value} → {new_value}")
                    return new_value
        elif isinstance(value, list):
            new_list = []
            for item in value:
                if isinstance(item, str):
                    transformed = transform_value(item, field_path)
                    new_list.append(transformed)
                else:
                    new_list.append(item)
            return new_list
        return value

    # Transform top-level fields
    for field in top_level_fields:
        if field in result:
            result[field] = transform_value(result[field], field)

    # If vulnerable_contract is still not set or not transformed, try to infer from sanitized code
    if sanitized_code and (not result.get('vulnerable_contract') or
                           result.get('vulnerable_contract', '').startswith('Vulnerable')):
        match = re.search(r'contract\s+(\w+)', sanitized_code)
        if match:
            inferred_contract = match.group(1)
            old_value = result.get('vulnerable_contract', 'NOT SET')
            result['vulnerable_contract'] = inferred_contract
            changes.append(f"Inferred vulnerable_contract from code: {old_value} → {inferred_contract}")

    # Transform nested fields
    for path, fields in nested_paths:
        # Navigate to the nested object
        obj = result
        valid_path = True
        for key in path:
            if isinstance(obj, dict) and key in obj:
                obj = obj[key]
            else:
                valid_path = False
                break

        if valid_path and isinstance(obj, dict):
            for field in fields:
                if field in obj:
                    field_path = '.'.join(path + [field])
                    obj[field] = transform_value(obj[field], field_path)

    # Also store the rename mappings in metadata for reference
    if rename_mappings:
        result['identifier_mappings'] = rename_mappings

    return result, changes


def _validate_solidity_builtins(original: str, sanitized: str) -> list[str]:
    """
    Validate that Solidity built-in patterns are preserved after sanitization.

    Checks for patterns like msg.sender, msg.value, block.timestamp, etc.
    Returns list of warnings if any built-ins appear to have been modified.
    """
    warnings = []

    # Patterns to check: (parent.property)
    builtin_patterns = [
        # msg properties
        ('msg', 'sender'), ('msg', 'value'), ('msg', 'data'), ('msg', 'sig'), ('msg', 'gas'),
        # block properties
        ('block', 'timestamp'), ('block', 'number'), ('block', 'coinbase'),
        ('block', 'difficulty'), ('block', 'gaslimit'), ('block', 'chainid'),
        ('block', 'basefee'), ('block', 'prevrandao'),
        # tx properties
        ('tx', 'origin'), ('tx', 'gasprice'),
        # abi functions
        ('abi', 'encode'), ('abi', 'encodePacked'), ('abi', 'encodeWithSelector'),
        ('abi', 'encodeWithSignature'), ('abi', 'encodeCall'), ('abi', 'decode'),
        # type functions
        ('type', 'min'), ('type', 'max'), ('type', 'interfaceId'),
    ]

    for parent, prop in builtin_patterns:
        pattern = rf'\b{parent}\s*\.\s*{prop}\b'

        # Count occurrences in original and sanitized
        original_count = len(re.findall(pattern, original))
        sanitized_count = len(re.findall(pattern, sanitized))

        if original_count > 0 and sanitized_count != original_count:
            warnings.append(
                f"Built-in {parent}.{prop} count changed: {original_count} -> {sanitized_count}"
            )

    return warnings


# =============================================================================
# FILE OPERATIONS
# =============================================================================

def _get_file_paths(file_id: str) -> tuple[Optional[Path], Optional[Path], str]:
    """
    Get the paths for a file ID from the base dataset.

    Args:
        file_id: The file ID (e.g., 'tc_001', 'ds_001', 'gs_001')

    Returns:
        Tuple of (contract_path, metadata_path, original_subset) or (None, None, '') if not found
    """
    # Validate prefix and determine original subset
    if file_id.startswith('tc_'):
        original_subset = 'temporal_contamination'
    elif file_id.startswith('ds_'):
        original_subset = 'difficulty_stratified'
    elif file_id.startswith('gs_'):
        original_subset = 'gold_standard'
    else:
        return None, None, ''

    # Check for .sol or .rs extension in base folder
    contract_dir = BASE_DATA_DIR / 'contracts'
    metadata_dir = BASE_DATA_DIR / 'metadata'

    for ext in ['.sol', '.rs']:
        contract_path = contract_dir / f"{file_id}{ext}"
        if contract_path.exists():
            metadata_path = metadata_dir / f"{file_id}.json"
            return contract_path, metadata_path, original_subset

    return None, None, original_subset


def _ensure_output_dirs():
    """Ensure the sanitized output directories exist."""
    (SANITIZED_DIR / 'contracts').mkdir(parents=True, exist_ok=True)
    (SANITIZED_DIR / 'metadata').mkdir(parents=True, exist_ok=True)


def _save_sanitized(
    file_id: str,
    sanitized_code: str,
    original_metadata_path: Optional[Path],
    extension: str,
    rename_mappings: dict[str, str] = None
) -> tuple[str, list[str]]:
    """
    Save sanitized contract and transform metadata with rename mappings.

    Args:
        file_id: Original file ID
        sanitized_code: The sanitized code
        original_metadata_path: Path to original metadata file
        extension: File extension (.sol or .rs)
        rename_mappings: Dictionary of {original_name: new_name} from sanitize_code

    Returns:
        Tuple of (sanitized_file_id, metadata_changes)
    """
    _ensure_output_dirs()

    sanitized_id = f"sn_{file_id}"
    metadata_changes = []

    # Save sanitized contract
    output_path = SANITIZED_DIR / 'contracts' / f"{sanitized_id}{extension}"
    output_path.write_text(sanitized_code)

    # Transform and save metadata with updated references
    if original_metadata_path and original_metadata_path.exists():
        metadata = json.loads(original_metadata_path.read_text())

        # Transform identifiers in metadata using rename mappings
        # Pass sanitized_code to infer vulnerable_contract if not in mappings
        metadata, metadata_changes = transform_metadata_identifiers(metadata, rename_mappings or {}, sanitized_code)

        # Update metadata for sanitized version
        metadata['id'] = sanitized_id
        metadata['contract_file'] = f"contracts/{sanitized_id}{extension}"
        metadata['original_contract_file'] = f"base/contracts/{file_id}{extension}"
        metadata['sanitized_from'] = file_id
        metadata['subset'] = 'sanitized'

        output_metadata = SANITIZED_DIR / 'metadata' / f"{sanitized_id}.json"
        output_metadata.write_text(json.dumps(metadata, indent=2))

    return sanitized_id, metadata_changes


# =============================================================================
# PUBLIC API FUNCTIONS
# =============================================================================

def sanitize_one(file_id: str, save: bool = True) -> SanitizationResult:
    """
    Sanitize a single file by ID.

    Args:
        file_id: The file ID (e.g., 'tc_001', 'ds_001')
        save: Whether to save the result to disk

    Returns:
        SanitizationResult with details of the operation
    """
    contract_path, metadata_path, dataset = _get_file_paths(file_id)

    if not contract_path or not contract_path.exists():
        return SanitizationResult(
            original_id=file_id,
            sanitized_id='',
            success=False,
            error=f"File not found: {file_id}"
        )

    try:
        # Read and sanitize
        code = contract_path.read_text()
        sanitized_code, changes, rename_mappings = sanitize_code(code)

        sanitized_id = f"sn_{file_id}"

        if save:
            extension = contract_path.suffix
            sanitized_id, metadata_changes = _save_sanitized(
                file_id, sanitized_code, metadata_path, extension, rename_mappings
            )
            # Add metadata transformation changes to the changes list
            changes.extend(metadata_changes)

        return SanitizationResult(
            original_id=file_id,
            sanitized_id=sanitized_id,
            success=True,
            changes_made=changes,
            rename_mappings=rename_mappings
        )

    except Exception as e:
        return SanitizationResult(
            original_id=file_id,
            sanitized_id='',
            success=False,
            error=str(e)
        )


def sanitize_all() -> SanitizationReport:
    """
    Sanitize all contracts from the base dataset.

    Returns:
        SanitizationReport with details of all operations
    """
    contracts_dir = BASE_DATA_DIR / 'contracts'

    if not contracts_dir.exists():
        raise FileNotFoundError(f"Base contracts directory not found: {contracts_dir}")

    results = []

    # Get all contract files from base
    contract_files = list(contracts_dir.glob('*.sol')) + list(contracts_dir.glob('*.rs'))

    for contract_path in sorted(contract_files):
        file_id = contract_path.stem  # e.g., 'tc_001', 'ds_001'
        result = sanitize_one(file_id, save=True)
        results.append(result)

    successful = sum(1 for r in results if r.success)
    failed = len(results) - successful

    report = SanitizationReport(
        timestamp=datetime.now().isoformat(),
        total_files=len(results),
        successful=successful,
        failed=failed,
        results=results
    )

    # Save report
    _ensure_output_dirs()
    report_path = SANITIZED_DIR / "sanitization_report.json"
    report_path.write_text(json.dumps(report.to_dict(), indent=2))

    # Generate index.json
    _generate_index()

    return report


def _generate_index():
    """Generate index.json for the sanitized dataset."""
    metadata_dir = SANITIZED_DIR / 'metadata'
    if not metadata_dir.exists():
        return

    samples = []
    stats = {
        'total_samples': 0,
        'vulnerable_count': 0,
        'safe_count': 0,
        'by_vulnerability_type': {},
        'by_severity': {},
        'by_original_subset': {'difficulty_stratified': 0, 'temporal_contamination': 0, 'gold_standard': 0}
    }

    for meta_file in sorted(metadata_dir.glob('*.json')):
        try:
            metadata = json.loads(meta_file.read_text())
            sample = {
                'id': metadata.get('id'),
                'contract_file': metadata.get('contract_file'),
                'metadata_file': f"metadata/{meta_file.name}",
                'original_contract_file': metadata.get('original_contract_file'),
                'sanitized_from': metadata.get('sanitized_from'),
            }

            # Extract ground truth info
            ground_truth = metadata.get('ground_truth', {})
            sample['is_vulnerable'] = ground_truth.get('is_vulnerable', True)
            sample['vulnerability_type'] = ground_truth.get('vulnerability_type', 'unknown')
            sample['severity'] = ground_truth.get('severity', 'unknown')

            samples.append(sample)

            # Update stats
            stats['total_samples'] += 1
            if sample['is_vulnerable']:
                stats['vulnerable_count'] += 1
            else:
                stats['safe_count'] += 1

            vuln_type = sample['vulnerability_type']
            stats['by_vulnerability_type'][vuln_type] = stats['by_vulnerability_type'].get(vuln_type, 0) + 1

            severity = sample['severity']
            stats['by_severity'][severity] = stats['by_severity'].get(severity, 0) + 1

            # Track original subset
            orig_id = metadata.get('sanitized_from', '')
            if orig_id.startswith('tc_'):
                stats['by_original_subset']['temporal_contamination'] += 1
            elif orig_id.startswith('ds_'):
                stats['by_original_subset']['difficulty_stratified'] += 1
            elif orig_id.startswith('gs_'):
                stats['by_original_subset']['gold_standard'] += 1

        except Exception as e:
            print(f"Warning: Error processing {meta_file}: {e}")
            continue

    index = {
        'dataset_name': 'sanitized',
        'version': '1.0.0',
        'created_date': datetime.now().strftime('%Y-%m-%d'),
        'last_updated': datetime.now().strftime('%Y-%m-%d'),
        'description': 'Sanitized contracts with vulnerability hints removed from identifiers and comments. '
                       'Derived from the base dataset.',
        'transformation': {
            'type': 'sanitization',
            'source_dataset': 'base',
            'changes_applied': [
                'Renamed vulnerability-hinting identifiers (contract names, function names, variables)',
                'Removed hint comments and vulnerability descriptions',
                'Sanitized console.log and emit statements',
                'Replaced raw text file headers'
            ]
        },
        'statistics': stats,
        'samples': samples
    }

    index_path = SANITIZED_DIR / 'index.json'
    index_path.write_text(json.dumps(index, indent=2))


# =============================================================================
# CLI INTERFACE
# =============================================================================

def main():
    """Command-line interface for the sanitizer."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Sanitize BlockBench contracts by removing vulnerability hints'
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # sanitize all
    subparsers.add_parser('all', help='Sanitize all contracts from the base dataset')

    # sanitize one
    one_parser = subparsers.add_parser('one', help='Sanitize a single file')
    one_parser.add_argument('file_id', help='File ID (e.g., tc_001, ds_001)')

    # sanitize code (from stdin)
    subparsers.add_parser('code', help='Sanitize code from stdin')

    args = parser.parse_args()

    if args.command == 'all':
        print("Sanitizing all contracts from base dataset...")
        report = sanitize_all()
        print(f"\nCompleted: {report.successful}/{report.total_files} successful")
        print(f"Report saved to: {SANITIZED_DIR / 'sanitization_report.json'}")

        # Show files with changes
        files_with_changes = [r for r in report.results if r.changes_made]
        if files_with_changes:
            print(f"\nFiles with changes ({len(files_with_changes)}):")
            for r in files_with_changes[:10]:  # Show first 10
                print(f"  {r.original_id}: {len(r.changes_made)} changes")
            if len(files_with_changes) > 10:
                print(f"  ... and {len(files_with_changes) - 10} more")

    elif args.command == 'one':
        result = sanitize_one(args.file_id)
        if result.success:
            print(f"Sanitized: {result.original_id} → {result.sanitized_id}")
            if result.changes_made:
                print(f"Changes ({len(result.changes_made)}):")
                for change in result.changes_made:
                    print(f"  - {change}")
            else:
                print("No changes needed.")
        else:
            print(f"Error: {result.error}")

    elif args.command == 'code':
        import sys
        code = sys.stdin.read()
        sanitized, changes, rename_mappings = sanitize_code(code)
        print(sanitized)
        if changes:
            print("\n--- Changes Made ---", file=sys.stderr)
            for change in changes:
                print(f"  - {change}", file=sys.stderr)
        if rename_mappings:
            print("\n--- Rename Mappings ---", file=sys.stderr)
            for orig, new in rename_mappings.items():
                print(f"  {orig} → {new}", file=sys.stderr)

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
