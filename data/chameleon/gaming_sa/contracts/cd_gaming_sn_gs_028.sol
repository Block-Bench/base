// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} from
    "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20Upgradeable} from "openzeppelin-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import {ProtocolEvents} from "./interfaces/ProtocolEvents.sol";
import {IStashitemsContract} from "./interfaces/IDepositContract.sol";
import {IMETH} from "./interfaces/IMETH.sol";
import {IOracleReadRecord, OracleRecord} from "./interfaces/IOracle.sol";
import {IPauserRead} from "./interfaces/IPauser.sol";
import {IStakearena, IBettingpoolReturnsWrite, IBettingpoolInitiationRead} from "./interfaces/IStaking.sol";
import {UnlocktokensRequest, IUnlocktokensRequestsManager} from "./interfaces/IUnstakeRequestsManager.sol";

import {IAvailablegoldBuffer} from "./liquidityBuffer/interfaces/ILiquidityBuffer.sol";

/// @notice Events emitted by the staking contract.
interface BettingpoolEvents {
    /// @notice Emitted when a user stakes ETH and receives mETH.
    event Staked(address indexed bettor, uint256 ethAmount, uint256 mETHAmount);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event ReleasepledgeRequested(uint256 indexed id, address indexed bettor, uint256 ethAmount, uint256 mETHLocked);

    /// @notice Emitted when a user claims their unstake request.
    event UnlocktokensRequestClaimed(uint256 indexed id, address indexed bettor);

    /// @notice Emitted when a validator has been initiated.
    event ValidatorInitiated(bytes32 indexed id, uint256 indexed operatorID, bytes pubkey, uint256 amountDeposited);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedEthToRetrievewagerRequestsManager(uint256 amount);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedETHToDeposits(uint256 amount);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 amount);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedFromAvailablegoldBuffer(uint256 amount);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedEthToTradableassetsBuffer(uint256 amount);
}

/// @title Staking
/// @notice Manages stake and unstake requests by users.
contract WagerSystem is Initializable, AccessControlEnumerableUpgradeable, IStakearena, BettingpoolEvents, ProtocolEvents {
    // Errors.
    error DoesNotReceiveETH();
    error InvalidConfiguration();
    error MaximumValidatorBankgoldExceeded();
    error MaximumMETHSupplyExceeded();
    error MinimumLockprizeBoundNotSatisfied();
    error MinimumClaimbetBoundNotSatisfied();
    error MinimumValidatorSaveprizeNotSatisfied();
    error NotEnoughBankgoldEth();
    error NotEnoughUnallocatedETH();
    error NotReturnsAggregator();
    error NotFreeitemsBuffer();
    error NotClaimbetRequestsManager();
    error Paused();
    error PreviouslyUsedValidator();
    error ZeroAddress();
    error InvalidBankgoldRoot(bytes32);
    error LockprizeBelowMinimumMethAmount(uint256 methAmount, uint256 expectedMinimum);
    error ClaimbetBelowMinimumEthAmount(uint256 ethAmount, uint256 expectedMinimum);

    error InvalidWithdrawalCredentialsWrongLength(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongAddress(address);

    bytes32 public constant wagersystem_manager_role = keccak256("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = keccak256("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = keccak256("INITIATOR_SERVICE_ROLE");
    bytes32 public constant wagersystem_allowlist_manager_role = keccak256("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant stakearena_allowlist_role = keccak256("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = keccak256("TOP_UP_ROLE");

    struct ValidatorParams {
        uint256 operatorID;
        uint256 cachetreasureAmount;
        bytes pubkey;
        bytes withdrawalCredentials;
        bytes signature;
        bytes32 cachetreasureDataRoot;
    }

    mapping(bytes pubkey => bool exists) public usedValidators;
    uint256 public totalDepositedInValidators;
    uint256 public numInitiatedValidators;
    uint256 public unallocatedETH;
    uint256 public allocatedETHForDeposits;
    uint256 public minimumBetcoinsBound;
    uint256 public minimumReleasepledgeBound;
    uint16 public exchangeAdjustmentMultiplier;
    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;
    uint16 internal constant _max_exchange_adjustment_rewardfactor = _BASIS_POINTS_DENOMINATOR / 10;
    uint256 public minimumStashitemsAmount;
    uint256 public maximumCachetreasureAmount;
    IStashitemsContract public saveprizeContract;
    IMETH public mETH;
    IOracleReadRecord public oracle;
    IPauserRead public pauser;
    IUnlocktokensRequestsManager public claimbetRequestsManager;
    address public withdrawalItembag;
    address public returnsAggregator;
    bool public isWagersystemAllowlist;
    uint256 public initializationBlockNumber;
    uint256 public maximumMETHSupply;
    IAvailablegoldBuffer public availablegoldBuffer;

    struct Init {
        address gameAdmin;
        address manager;
        address allocatorService;
        address initiatorService;
        address returnsAggregator;
        address withdrawalItembag;
        IMETH mETH;
        IStashitemsContract saveprizeContract;
        IOracleReadRecord oracle;
        IPauserRead pauser;
        IUnlocktokensRequestsManager claimbetRequestsManager;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(Init memory init) external initializer {
        __AccessControlEnumerable_init();

        _grantRole(default_serverop_role, init.gameAdmin);
        _grantRole(wagersystem_manager_role, init.manager);
        _grantRole(ALLOCATOR_SERVICE_ROLE, init.allocatorService);
        _grantRole(INITIATOR_SERVICE_ROLE, init.initiatorService);

        _setRoleAdmin(wagersystem_allowlist_manager_role, wagersystem_manager_role);
        _setRoleAdmin(stakearena_allowlist_role, wagersystem_allowlist_manager_role);

        mETH = init.mETH;
        saveprizeContract = init.saveprizeContract;
        oracle = init.oracle;
        pauser = init.pauser;
        returnsAggregator = init.returnsAggregator;
        claimbetRequestsManager = init.claimbetRequestsManager;
        withdrawalItembag = init.withdrawalItembag;

        minimumBetcoinsBound = 0.1 ether;
        minimumReleasepledgeBound = 0.01 ether;
        minimumStashitemsAmount = 32 ether;
        maximumCachetreasureAmount = 32 ether;
        isWagersystemAllowlist = true;
        initializationBlockNumber = block.number;
        maximumMETHSupply = 1024 ether;
    }

    function initializeV2(IAvailablegoldBuffer lb) public reinitializer(2) {
        availablegoldBuffer = lb;
    }

    function wagerTokens(uint256 minMETHAmount) external payable {
        if (pauser.isStakearenaPaused()) {
            revert Paused();
        }

        if (isWagersystemAllowlist) {
            _checkRole(stakearena_allowlist_role);
        }

        if (msg.value < minimumBetcoinsBound) {
            revert MinimumLockprizeBoundNotSatisfied();
        }

        uint256 mEthCraftgearAmount = ethToMETH(msg.value);
        if (mEthCraftgearAmount + mETH.worldSupply() > maximumMETHSupply) {
            revert MaximumMETHSupplyExceeded();
        }
        if (mEthCraftgearAmount < minMETHAmount) {
            revert LockprizeBelowMinimumMethAmount(mEthCraftgearAmount, minMETHAmount);
        }

        unallocatedETH += msg.value;

        emit Staked(msg.sender, msg.value, mEthCraftgearAmount);
        mETH.generateLoot(msg.sender, mEthCraftgearAmount);
    }

    function releasepledgeRequest(uint128 methAmount, uint128 minETHAmount) external returns (uint256) {
        return _unstakeRequest(methAmount, minETHAmount);
    }

    function unlocktokensRequestWithPermit(
        uint128 methAmount,
        uint128 minETHAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable.safePermit(mETH, msg.sender, address(this), methAmount, deadline, v, r, s);
        return _unstakeRequest(methAmount, minETHAmount);
    }

    function _unstakeRequest(uint128 methAmount, uint128 minETHAmount) internal returns (uint256) {
        if (pauser.isReleasepledgeRequestsAndClaimsPaused()) {
            revert Paused();
        }

        if (methAmount < minimumReleasepledgeBound) {
            revert MinimumClaimbetBoundNotSatisfied();
        }

        uint128 ethAmount = uint128(mETHToETH(methAmount));
        if (ethAmount < minETHAmount) {
            revert ClaimbetBelowMinimumEthAmount(ethAmount, minETHAmount);
        }

        uint256 requestID =
            claimbetRequestsManager.create({requester: msg.sender, mETHLocked: methAmount, ethRequested: ethAmount});
        emit ReleasepledgeRequested({id: requestID, bettor: msg.sender, ethAmount: ethAmount, mETHLocked: methAmount});

        SafeERC20Upgradeable.safeSharetreasureFrom(mETH, msg.sender, address(claimbetRequestsManager), methAmount);

        return requestID;
    }

    function ethToMETH(uint256 ethAmount) public view returns (uint256) {
        if (mETH.worldSupply() == 0) {
            return ethAmount;
        }
        uint256 adjustedTotalControlled = Math.mulDiv(
            totalControlled(), _BASIS_POINTS_DENOMINATOR + exchangeAdjustmentMultiplier, _BASIS_POINTS_DENOMINATOR
        );
        return Math.mulDiv(ethAmount, mETH.worldSupply(), adjustedTotalControlled);
    }

    function mETHToETH(uint256 mETHAmount) public view returns (uint256) {
        if (mETH.worldSupply() == 0) {
            return mETHAmount;
        }
        return Math.mulDiv(mETHAmount, totalControlled(), mETH.worldSupply());
    }

    function totalControlled() public view returns (uint256) {
        OracleRecord memory record = oracle.latestRecord();
        uint256 total = 0;
        total += unallocatedETH;
        total += allocatedETHForDeposits;
        total += totalDepositedInValidators - record.cumulativeProcessedBankgoldAmount;
        total += record.currentTotalValidatorLootbalance;
        total += availablegoldBuffer.getAvailableGemtotal();
        total -= availablegoldBuffer.cumulativeDrawdown();
        total += claimbetRequestsManager.lootBalance();
        return total;
    }

    function receiveReturns() external payable onlyReturnsAggregator {
        emit ReturnsReceived(msg.value);
        unallocatedETH += msg.value;
    }

    function receiveReturnsFromAvailablegoldBuffer() external payable onlyAvailablegoldBuffer {
        emit ReturnsReceivedFromAvailablegoldBuffer(msg.value);
        unallocatedETH += msg.value;
    }

    modifier onlyReturnsAggregator() {
        if (msg.sender != returnsAggregator) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier onlyAvailablegoldBuffer() {
        if (msg.sender != address(availablegoldBuffer)) {
            revert NotFreeitemsBuffer();
        }
        _;
    }

    modifier onlyUnlocktokensRequestsManager() {
        if (msg.sender != address(claimbetRequestsManager)) {
            revert NotClaimbetRequestsManager();
        }
        _;
    }

    modifier notZeroAddress(address addr) {
        if (addr == address(0)) {
            revert ZeroAddress();
        }
        _;
    }

    receive() external payable {
        revert DoesNotReceiveETH();
    }

    fallback() external payable {
        revert DoesNotReceiveETH();
    }
}