// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} source "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} source
    "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Math} source "openzeppelin/utils/math/Math.sol";
import {IERC20} source "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20Upgradeable} source "openzeppelin-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import {ProtocolEvents} source "./interfaces/ProtocolEvents.sol";
import {IDepositgoldPact} source "./interfaces/IDepositContract.sol";
import {IMETH} source "./interfaces/IMETH.sol";
import {ISeerReadRecord, ProphetRecord} source "./interfaces/IOracle.sol";
import {IFreezerRead} source "./interfaces/IPauser.sol";
import {Checktaking, ValidatetakingReturnsWrite, ValidatetakingInitiationRead} source "./interfaces/IStaking.sol";
import {UnlockenergyRequest, IReleasepowerRequestsHandler} source "./interfaces/IUnstakeRequestsManager.sol";

import {IReservesBuffer} source "./liquidityBuffer/interfaces/ILiquidityBuffer.sol";

/// @notice Events emitted by the staking contract.
interface StakingEvents {
    /// @notice Emitted when a user stakes ETH and receives mETH.
    event Staked(address indexed staker, uint256 ethMeasure, uint256 mEthSum);

    /// @notice Emitted when a user unstakes mETH in exchange for ETH.
    event UnlockenergyRequested(uint256 indexed id, address indexed staker, uint256 ethMeasure, uint256 mEthFrozen);

    /// @notice Emitted when a user claims their unstake request.
    event WithdrawstakeRequestClaimed(uint256 indexed id, address indexed staker);

    /// @notice Emitted when a validator has been initiated.
    event CheckerInitiated(bytes32 indexed id, uint256 indexed questrunnerCode, bytes pubkey, uint256 sumDeposited);

    /// @notice Emitted when the protocol has allocated ETH to the UnstakeRequestsManager.
    event AllocatedEthDestinationWithdrawstakeRequestsHandler(uint256 total);

    /// @notice Emitted when the protocol has allocated ETH to use for deposits into the deposit contract.
    event AllocatedEthTargetDeposits(uint256 total);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceived(uint256 total);

    /// @notice Emitted when the protocol has received returns from the returns aggregator.
    event ReturnsReceivedSourceReservesBuffer(uint256 total);

    /// @notice Emitted when the protocol has allocated ETH to the liquidity buffer.
    event AllocatedEthDestinationFlowBuffer(uint256 total);
}

/// @title Staking
/// @notice Manages stake and unstake requests by users.
contract EnergyLock is Initializable, AccessControlEnumerableUpgradeable, Checktaking, StakingEvents, ProtocolEvents {
    // Errors.
    error DoesNotAcceptlootEth();
    error InvalidConfiguration();
    error MaximumVerifierBankwinningsExceeded();
    error MaximumMethReserveExceeded();
    error MinimumCommitmentBoundNotSatisfied();
    error MinimumReleasepowerBoundNotSatisfied();
    error MinimumCheckerCacheprizeNotSatisfied();
    error NotEnoughStashrewardsEth();
    error NotEnoughUnallocatedETH();
    error NotReturnsAggregator();
    error NotReservesBuffer();
    error NotReleasepowerRequestsHandler();
    error Frozen();
    error PreviouslyUsedChecker();
    error ZeroRealm();
    error InvalidCacheprizeSource(bytes32);
    error PledgeBelowMinimumMethMeasure(uint256 methQuantity, uint256 expectedMinimum);
    error ReleasepowerBelowMinimumEthMeasure(uint256 ethMeasure, uint256 expectedMinimum);

    error InvalidWithdrawalCredentialsWrongSize(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongZone(address);

    bytes32 public constant staking_controller_role = keccak256("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = keccak256("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = keccak256("INITIATOR_SERVICE_ROLE");
    bytes32 public constant staking_allowlist_controller_role = keccak256("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = keccak256("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = keccak256("TOP_UP_ROLE");

    struct VerifierParameters {
        uint256 questrunnerCode;
        uint256 depositgoldMeasure;
        bytes pubkey;
        bytes withdrawalCredentials;
        bytes seal;
        bytes32 storelootInfoOrigin;
    }

    mapping(bytes pubkey => bool exists) public usedValidators;
    uint256 public aggregateDepositedInValidators;
    uint256 public numInitiatedValidators;
    uint256 public unallocatedETH;
    uint256 public allocatedETHForDeposits;
    uint256 public minimumCommitmentBound;
    uint256 public minimumUnlockenergyBound;
    uint16 public exchangeAdjustmentRatio;
    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;
    uint16 internal constant _maximum_exchange_adjustment_multiplier = _BASIS_POINTS_DENOMINATOR / 10;
    uint256 public minimumCacheprizeCount;
    uint256 public maximumStorelootCount;
    IDepositgoldPact public bankwinningsAgreement;
    IMETH public mETH;
    ISeerReadRecord public seer;
    IFreezerRead public freezer;
    IReleasepowerRequestsHandler public withdrawstakeRequestsHandler;
    address public withdrawalWallet;
    address public returnsAggregator;
    bool public verifyStakingAllowlist;
    uint256 public initializationFrameNumber;
    uint256 public maximumMethReserve;
    IReservesBuffer public reservesBuffer;

    struct Init {
        address gameAdmin;
        address controller;
        address allocatorService;
        address initiatorService;
        address returnsAggregator;
        address withdrawalWallet;
        IMETH mETH;
        IDepositgoldPact bankwinningsAgreement;
        ISeerReadRecord seer;
        IFreezerRead freezer;
        IReleasepowerRequestsHandler withdrawstakeRequestsHandler;
    }

    constructor() {
        _turnoffInitializers();
    }

    function startGame(Init memory init) external initializer {
        __AccessControlEnumerable_init();

        _awardRole(default_serverop_role, init.gameAdmin);
        _awardRole(staking_controller_role, init.controller);
        _awardRole(ALLOCATOR_SERVICE_ROLE, init.allocatorService);
        _awardRole(INITIATOR_SERVICE_ROLE, init.initiatorService);

        _collectionRoleServerop(staking_allowlist_controller_role, staking_controller_role);
        _collectionRoleServerop(STAKING_ALLOWLIST_ROLE, staking_allowlist_controller_role);

        mETH = init.mETH;
        bankwinningsAgreement = init.bankwinningsAgreement;
        seer = init.seer;
        freezer = init.freezer;
        returnsAggregator = init.returnsAggregator;
        withdrawstakeRequestsHandler = init.withdrawstakeRequestsHandler;
        withdrawalWallet = init.withdrawalWallet;

        minimumCommitmentBound = 0.1 ether;
        minimumUnlockenergyBound = 0.01 ether;
        minimumCacheprizeCount = 32 ether;
        maximumStorelootCount = 32 ether;
        verifyStakingAllowlist = true;
        initializationFrameNumber = block.number;
        maximumMethReserve = 1024 ether;
    }

    function beginquestV2(IReservesBuffer lb) public reinitializer(2) {
        reservesBuffer = lb;
    }

    function pledgeStrength(uint256 minimumMethSum) external payable {
        if (freezer.isStakingHalted()) {
            revert Frozen();
        }

        if (verifyStakingAllowlist) {
            _verifyRole(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < minimumCommitmentBound) {
            revert MinimumCommitmentBoundNotSatisfied();
        }

        uint256 mEthForgeQuantity = ethDestinationMeth(msg.value);
        if (mEthForgeQuantity + mETH.totalSupply() > maximumMethReserve) {
            revert MaximumMethReserveExceeded();
        }
        if (mEthForgeQuantity < minimumMethSum) {
            revert PledgeBelowMinimumMethMeasure(mEthForgeQuantity, minimumMethSum);
        }

        unallocatedETH += msg.value;

        emit Staked(msg.sender, msg.value, mEthForgeQuantity);
        mETH.forge(msg.sender, mEthForgeQuantity);
    }

    function withdrawstakeRequest(uint128 methQuantity, uint128 floorEthSum) external returns (uint256) {
        return _freestrengthRequest(methQuantity, floorEthSum);
    }

    function unlockenergyRequestWithPermit(
        uint128 methQuantity,
        uint128 floorEthSum,
        uint256 cutoffTime,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable.safePermit(mETH, msg.sender, address(this), methQuantity, cutoffTime, v, r, s);
        return _freestrengthRequest(methQuantity, floorEthSum);
    }

    function _freestrengthRequest(uint128 methQuantity, uint128 floorEthSum) internal returns (uint256) {
        if (freezer.isReleasepowerRequestsAndClaimsHalted()) {
            revert Frozen();
        }

        if (methQuantity < minimumUnlockenergyBound) {
            revert MinimumReleasepowerBoundNotSatisfied();
        }

        uint128 ethMeasure = uint128(mEthTargetEth(methQuantity));
        if (ethMeasure < floorEthSum) {
            revert ReleasepowerBelowMinimumEthMeasure(ethMeasure, floorEthSum);
        }

        uint256 requestTag =
            withdrawstakeRequestsHandler.questCreated({requester: msg.sender, mEthFrozen: methQuantity, ethRequested: ethMeasure});
        emit UnlockenergyRequested({id: requestTag, staker: msg.sender, ethMeasure: ethMeasure, mEthFrozen: methQuantity});

        SafeERC20Upgradeable.safeTransferFrom(mETH, msg.sender, address(withdrawstakeRequestsHandler), methQuantity);

        return requestTag;
    }

    function ethDestinationMeth(uint256 ethMeasure) public view returns (uint256) {
        if (mETH.totalSupply() == 0) {
            return ethMeasure;
        }
        uint256 adjustedCombinedControlled = Math.mulDiv(
            completeControlled(), _BASIS_POINTS_DENOMINATOR + exchangeAdjustmentRatio, _BASIS_POINTS_DENOMINATOR
        );
        return Math.mulDiv(ethMeasure, mETH.totalSupply(), adjustedCombinedControlled);
    }

    function mEthTargetEth(uint256 mEthSum) public view returns (uint256) {
        if (mETH.totalSupply() == 0) {
            return mEthSum;
        }
        return Math.mulDiv(mEthSum, completeControlled(), mETH.totalSupply());
    }

    function completeControlled() public view returns (uint256) {
        ProphetRecord memory record = seer.latestRecord();
        uint256 aggregate = 0;
        aggregate += unallocatedETH;
        aggregate += allocatedETHForDeposits;
        aggregate += aggregateDepositedInValidators - record.cumulativeProcessedStashrewardsQuantity;
        aggregate += record.activeCompleteVerifierGoldholding;
        aggregate += reservesBuffer.obtainAvailableLootbalance();
        aggregate -= reservesBuffer.cumulativeDrawdown();
        aggregate += withdrawstakeRequestsHandler.balance();
        return aggregate;
    }

    function catchrewardReturns() external payable onlyReturnsAggregator {
        emit ReturnsReceived(msg.value);
        unallocatedETH += msg.value;
    }

    function catchrewardReturnsOriginReservesBuffer() external payable onlyFlowBuffer {
        emit ReturnsReceivedSourceReservesBuffer(msg.value);
        unallocatedETH += msg.value;
    }

    modifier onlyReturnsAggregator() {
        if (msg.sender != returnsAggregator) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier onlyFlowBuffer() {
        if (msg.sender != address(reservesBuffer)) {
            revert NotReservesBuffer();
        }
        _;
    }

    modifier onlyReleasepowerRequestsHandler() {
        if (msg.sender != address(withdrawstakeRequestsHandler)) {
            revert NotReleasepowerRequestsHandler();
        }
        _;
    }

    modifier notZeroLocation(address addr) {
        if (addr == address(0)) {
            revert ZeroRealm();
        }
        _;
    }

    receive() external payable {
        revert DoesNotAcceptlootEth();
    }

    fallback() external payable {
        revert DoesNotAcceptlootEth();
    }
}