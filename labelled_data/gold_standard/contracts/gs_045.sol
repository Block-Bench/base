// SPDX-License-Identifier: BUSL-1.1
// Terms: https://liminal.money/xtokens/license

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {INAVOracle} from "./interfaces/INAVOracle.sol";
import {IShareManager} from "./interfaces/IShareManager.sol";

interface IFeeManager {
    function accruePerformanceFee() external;
}

contract RedemptionPipe is AccessControlUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;
    using Math for uint256;

    bytes32 public constant EMERGENCY_MANAGER_ROLE = keccak256("EMERGENCY_MANAGER_ROLE");
    bytes32 public constant FULFILL_MANAGER_ROLE = keccak256("FULFILL_MANAGER_ROLE");
    bytes32 public constant SAFE_MANAGER_ROLE = keccak256("SAFE_MANAGER_ROLE");

    uint256 public constant BASIS_POINTS = 10000;
    uint256 internal constant REQUEST_ID = 0;

    struct FeeConfig {
        uint256 instantRedeemFeeBps;
        uint256 fastRedeemFeeBps;
    }

    struct PendingRedeemRequest {
        uint256 shares;
        address receiver;
    }

    struct PendingFastRedeemRequest {
        uint256 shares;
        uint256 timestamp;
        address receiver;
    }

    struct RedemptionPipeStorage {
        IShareManager shareManager;
        INAVOracle navOracle;
        IERC20Metadata underlyingAsset;
        address liquidityProvider;
        FeeConfig fees;
        uint256 lastNAVForPerformance;
        uint24 recoveryDelay;
        uint72 lastRedemptionTime;
        address treasury;
        mapping(address => PendingRedeemRequest) pendingRedeem;
        mapping(address => PendingFastRedeemRequest) pendingFastRedeem;
        address timeLockController;
        uint256 MIN_AMOUNT_SHARES;
        IFeeManager feeManager;
        uint256 maxCustomFeeBps;
        bool fastRedeemEnabled;
    }

    bytes32 private constant REDEMPTION_PIPE_STORAGE_LOCATION = 0x29501c6d0a5cf7bef3f2db502c4a21ddfa1dc6ae30f842b9bba4cfdd2f8c2a00;

    function _getRedemptionPipeStorage() private pure returns (RedemptionPipeStorage storage $) {
        assembly {
            $.slot := REDEMPTION_PIPE_STORAGE_LOCATION
        }
    }

    event InstantRedeem(address indexed user, address indexed receiver, uint256 shares, uint256 assets, uint256 fee);
    event FastRedeemRequested(address indexed owner, address indexed receiver, uint256 shares, uint256 timestamp);
    event FastRedeemFulfilled(address indexed owner, address indexed receiver, uint256 assets, uint256 shares, uint256 fee);
    event RedeemRequested(address indexed owner, address indexed receiver, uint256 shares);
    event RedeemFulfilled(address indexed owner, address indexed receiver, uint256 assets, uint256 shares);
    event FeesUpdated(FeeConfig newFees);
    event RecoveryDelayUpdated(uint256 newDelay);
    event TreasuryUpdated(address indexed newTreasury);
    event AssetsRecovered(address indexed token, uint256 amount, address indexed treasury);
    event LiquidityProviderUpdated(address indexed oldProvider, address indexed newProvider);
    event MaxCustomFeeBpsUpdated(uint256 newMaxCustomFeeBps);
    event FastRedeemEnabledUpdated(bool enabled);
    event TimeLockControllerUpdated(address indexed oldTimeLockController, address indexed newTimeLockController);

    constructor() {
        _disableInitializers();
    }

    struct InitializeParams {
        address shareManager;
        address navOracle;
        address underlyingAsset;
        address liquidityProvider;
        address deployer;
        address safeManager;
        address emergencyManager;
        address requestManager;
        address treasury;
        uint256 recoveryDelay;
        address timeLockController;
        address feeManager;
        uint256 maxCustomFeeBps;
    }

    function initialize(InitializeParams calldata params) external initializer {
        require(params.shareManager != address(0));
        require(params.navOracle != address(0));
        require(params.underlyingAsset != address(0));
        require(params.deployer != address(0));
        require(params.safeManager != address(0));
        require(params.liquidityProvider != address(0));
        require(params.emergencyManager != address(0));
        require(params.timeLockController != address(0));
        require(params.requestManager != address(0));
        require(params.treasury != address(0));
        require(params.recoveryDelay > 0);
        require(params.feeManager != address(0));
        require(params.maxCustomFeeBps <= BASIS_POINTS);

        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        RedemptionPipeStorage storage $ = _getRedemptionPipeStorage();
        $.shareManager = IShareManager(params.shareManager);
        $.navOracle = INAVOracle(params.navOracle);
        $.underlyingAsset = IERC20Metadata(params.underlyingAsset);
        $.liquidityProvider = params.liquidityProvider;
        $.treasury = params.treasury;
        $.recoveryDelay = uint24(params.recoveryDelay);
        $.timeLockController = params.timeLockController;
        $.feeManager = IFeeManager(params.feeManager);
        $.maxCustomFeeBps = params.maxCustomFeeBps;
        $.fastRedeemEnabled = false;

        uint8 assetDecimals = IERC20Metadata(params.underlyingAsset).decimals();
        require(assetDecimals <= 18);
        $.MIN_AMOUNT_SHARES = 1000 * 10 ** (18 - assetDecimals);

        _grantRole(DEFAULT_ADMIN_ROLE, params.deployer);
        _grantRole(SAFE_MANAGER_ROLE, params.safeManager);
        _grantRole(EMERGENCY_MANAGER_ROLE, params.emergencyManager);
        _grantRole(FULFILL_MANAGER_ROLE, params.requestManager);

        $.lastNAVForPerformance = $.navOracle.getNAV();
    }

    function pause() external onlyRole(EMERGENCY_MANAGER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(EMERGENCY_MANAGER_ROLE) {
        _unpause();
    }

    function setFastRedeemEnabled(bool _enabled) external onlyRole(SAFE_MANAGER_ROLE) {
        RedemptionPipeStorage storage $ = _getRedemptionPipeStorage();
        $.fastRedeemEnabled = _enabled;
        emit FastRedeemEnabledUpdated(_enabled);
    }
}
