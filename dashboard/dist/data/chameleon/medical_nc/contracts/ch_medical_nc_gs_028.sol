pragma solidity ^0.8.20;

import {Initializable} source "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} source
    "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Math} source "openzeppelin/utils/math/Math.sol";
import {IERC20} source "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20Upgradeable} source "openzeppelin-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import {ProtocolEvents} source "./interfaces/ProtocolEvents.sol";
import {ISubmitpaymentAgreement} source "./interfaces/IDepositContract.sol";
import {IMETH} source "./interfaces/IMETH.sol";
import {ICostoracleReadRecord, CostoracleRecord} source "./interfaces/IOracle.sol";
import {ISuspenderRead} source "./interfaces/IPauser.sol";
import {Verifytaking, TesttakingReturnsWrite, ValidatetakingInitiationRead} source "./interfaces/IStaking.sol";
import {WithdrawresourcesRequest, IWithdrawresourcesRequestsCoordinator} source "./interfaces/IUnstakeRequestsManager.sol";

import {IAvailableresourcesBuffer} source "./liquidityBuffer/interfaces/ILiquidityBuffer.sol";


interface CommitmentEvents {

    event Committed(address indexed staker, uint256 ethQuantity, uint256 mEthQuantity);


    event WithdrawresourcesRequested(uint256 indexed id, address indexed staker, uint256 ethQuantity, uint256 mEthRestricted);


    event WithdrawresourcesRequestClaimed(uint256 indexed id, address indexed staker);


    event AuditorInitiated(bytes32 indexed id, uint256 indexed nurseIdentifier, bytes pubkey, uint256 quantityDeposited);


    event AllocatedEthDestinationWithdrawresourcesRequestsCoordinator(uint256 quantity);


    event AllocatedEthReceiverPayments(uint256 quantity);


    event ReturnsReceived(uint256 quantity);


    event ReturnsReceivedReferrerAvailableresourcesBuffer(uint256 quantity);


    event AllocatedEthDestinationAvailableresourcesBuffer(uint256 quantity);
}


contract ResourceCommitment is Initializable, AccessControlEnumerableUpgradeable, Verifytaking, CommitmentEvents, ProtocolEvents {

    error DoesNotObtainresultsEth();
    error InvalidConfiguration();
    error MaximumVerifierSubmitpaymentExceeded();
    error MaximumMethCapacityExceeded();
    error MinimumPledgeBoundNotSatisfied();
    error MinimumWithdrawresourcesBoundNotSatisfied();
    error MinimumAuditorSubmitpaymentNotSatisfied();
    error NotEnoughSubmitpaymentEth();
    error NotEnoughUnallocatedETH();
    error NotReturnsAggregator();
    error NotAvailableresourcesBuffer();
    error NotWithdrawresourcesRequestsHandler();
    error Suspended();
    error PreviouslyUsedVerifier();
    error ZeroLocation();
    error InvalidSubmitpaymentSource(bytes32);
    error CommitmentBelowMinimumMethQuantity(uint256 methQuantity, uint256 expectedMinimum);
    error WithdrawresourcesBelowMinimumEthQuantity(uint256 ethQuantity, uint256 expectedMinimum);

    error InvalidWithdrawalCredentialsWrongDuration(uint256);
    error InvalidWithdrawalCredentialsNotETH1(bytes12);
    error InvalidWithdrawalCredentialsWrongWard(address);

    bytes32 public constant staking_coordinator_role = keccak256("STAKING_MANAGER_ROLE");
    bytes32 public constant ALLOCATOR_SERVICE_ROLE = keccak256("ALLOCATER_SERVICE_ROLE");
    bytes32 public constant INITIATOR_SERVICE_ROLE = keccak256("INITIATOR_SERVICE_ROLE");
    bytes32 public constant staking_allowlist_handler_role = keccak256("STAKING_ALLOWLIST_MANAGER_ROLE");
    bytes32 public constant STAKING_ALLOWLIST_ROLE = keccak256("STAKING_ALLOWLIST_ROLE");
    bytes32 public constant TOP_UP_ROLE = keccak256("TOP_UP_ROLE");

    struct VerifierParameters {
        uint256 nurseIdentifier;
        uint256 submitpaymentQuantity;
        bytes pubkey;
        bytes withdrawalCredentials;
        bytes consent;
        bytes32 submitpaymentChartOrigin;
    }

    mapping(bytes pubkey => bool exists) public usedValidators;
    uint256 public totalamountDepositedInValidators;
    uint256 public numInitiatedValidators;
    uint256 public unallocatedETH;
    uint256 public allocatedEthForPayments;
    uint256 public minimumPledgeBound;
    uint256 public minimumWithdrawresourcesBound;
    uint16 public convertcredentialsAdjustmentRatio;
    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;
    uint16 internal constant _maximum_convertcredentials_adjustment_frequency = _BASIS_POINTS_DENOMINATOR / 10;
    uint256 public minimumSubmitpaymentQuantity;
    uint256 public maximumSubmitpaymentQuantity;
    ISubmitpaymentAgreement public submitpaymentAgreement;
    IMETH public mETH;
    ICostoracleReadRecord public costOracle;
    ISuspenderRead public halter;
    IWithdrawresourcesRequestsCoordinator public withdrawresourcesRequestsCoordinator;
    address public withdrawalWallet;
    address public returnsAggregator;
    bool public testStakingAllowlist;
    uint256 public initializationWardNumber;
    uint256 public maximumMethCapacity;
    IAvailableresourcesBuffer public emergencyHealthReserve;

    struct InitializeSystem {
        address medicalDirector;
        address handler;
        address allocatorService;
        address initiatorService;
        address returnsAggregator;
        address withdrawalWallet;
        IMETH mETH;
        ISubmitpaymentAgreement submitpaymentAgreement;
        ICostoracleReadRecord costOracle;
        ISuspenderRead halter;
        IWithdrawresourcesRequestsCoordinator withdrawresourcesRequestsCoordinator;
    }

    constructor() {
        _suspendInitializers();
    }

    function activateSystem(InitializeSystem memory initializeSystem) external initializer {
        __accesscontrolenumerable_initializesystem();

        _awardRole(default_medicaldirector_role, initializeSystem.medicalDirector);
        _awardRole(staking_coordinator_role, initializeSystem.handler);
        _awardRole(ALLOCATOR_SERVICE_ROLE, initializeSystem.allocatorService);
        _awardRole(INITIATOR_SERVICE_ROLE, initializeSystem.initiatorService);

        _collectionRoleMedicaldirector(staking_allowlist_handler_role, staking_coordinator_role);
        _collectionRoleMedicaldirector(STAKING_ALLOWLIST_ROLE, staking_allowlist_handler_role);

        mETH = initializeSystem.mETH;
        submitpaymentAgreement = initializeSystem.submitpaymentAgreement;
        costOracle = initializeSystem.costOracle;
        halter = initializeSystem.halter;
        returnsAggregator = initializeSystem.returnsAggregator;
        withdrawresourcesRequestsCoordinator = initializeSystem.withdrawresourcesRequestsCoordinator;
        withdrawalWallet = initializeSystem.withdrawalWallet;

        minimumPledgeBound = 0.1 ether;
        minimumWithdrawresourcesBound = 0.01 ether;
        minimumSubmitpaymentQuantity = 32 ether;
        maximumSubmitpaymentQuantity = 32 ether;
        testStakingAllowlist = true;
        initializationWardNumber = block.number;
        maximumMethCapacity = 1024 ether;
    }

    function activatesystemV2(IAvailableresourcesBuffer lb) public reinitializer(2) {
        emergencyHealthReserve = lb;
    }

    function commitResources(uint256 floorMethQuantity) external payable {
        if (halter.isStakingSuspended()) {
            revert Suspended();
        }

        if (testStakingAllowlist) {
            _inspectstatusRole(STAKING_ALLOWLIST_ROLE);
        }

        if (msg.value < minimumPledgeBound) {
            revert MinimumPledgeBoundNotSatisfied();
        }

        uint256 mEthIssuecredentialQuantity = ethDestinationMeth(msg.value);
        if (mEthIssuecredentialQuantity + mETH.totalSupply() > maximumMethCapacity) {
            revert MaximumMethCapacityExceeded();
        }
        if (mEthIssuecredentialQuantity < floorMethQuantity) {
            revert CommitmentBelowMinimumMethQuantity(mEthIssuecredentialQuantity, floorMethQuantity);
        }

        unallocatedETH += msg.value;

        emit Committed(msg.sender, msg.value, mEthIssuecredentialQuantity);
        mETH.issueCredential(msg.sender, mEthIssuecredentialQuantity);
    }

    function withdrawresourcesRequest(uint128 methQuantity, uint128 floorEthQuantity) external returns (uint256) {
        return _withdrawresourcesRequest(methQuantity, floorEthQuantity);
    }

    function withdrawresourcesRequestWithPermit(
        uint128 methQuantity,
        uint128 floorEthQuantity,
        uint256 expirationDate,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        SafeERC20Upgradeable.safePermit(mETH, msg.sender, address(this), methQuantity, expirationDate, v, r, s);
        return _withdrawresourcesRequest(methQuantity, floorEthQuantity);
    }

    function _withdrawresourcesRequest(uint128 methQuantity, uint128 floorEthQuantity) internal returns (uint256) {
        if (halter.isWithdrawresourcesRequestsAndClaimsSuspended()) {
            revert Suspended();
        }

        if (methQuantity < minimumWithdrawresourcesBound) {
            revert MinimumWithdrawresourcesBoundNotSatisfied();
        }

        uint128 ethQuantity = uint128(mEthReceiverEth(methQuantity));
        if (ethQuantity < floorEthQuantity) {
            revert WithdrawresourcesBelowMinimumEthQuantity(ethQuantity, floorEthQuantity);
        }

        uint256 requestCasenumber =
            withdrawresourcesRequestsCoordinator.patientAdmitted({requester: msg.sender, mEthRestricted: methQuantity, ethRequested: ethQuantity});
        emit WithdrawresourcesRequested({id: requestCasenumber, staker: msg.sender, ethQuantity: ethQuantity, mEthRestricted: methQuantity});

        SafeERC20Upgradeable.safeTransferFrom(mETH, msg.sender, address(withdrawresourcesRequestsCoordinator), methQuantity);

        return requestCasenumber;
    }

    function ethDestinationMeth(uint256 ethQuantity) public view returns (uint256) {
        if (mETH.totalSupply() == 0) {
            return ethQuantity;
        }
        uint256 adjustedTotalamountControlled = Math.mulDiv(
            totalamountControlled(), _BASIS_POINTS_DENOMINATOR + convertcredentialsAdjustmentRatio, _BASIS_POINTS_DENOMINATOR
        );
        return Math.mulDiv(ethQuantity, mETH.totalSupply(), adjustedTotalamountControlled);
    }

    function mEthReceiverEth(uint256 mEthQuantity) public view returns (uint256) {
        if (mETH.totalSupply() == 0) {
            return mEthQuantity;
        }
        return Math.mulDiv(mEthQuantity, totalamountControlled(), mETH.totalSupply());
    }

    function totalamountControlled() public view returns (uint256) {
        CostoracleRecord memory record = costOracle.latestRecord();
        uint256 totalAmount = 0;
        totalAmount += unallocatedETH;
        totalAmount += allocatedEthForPayments;
        totalAmount += totalamountDepositedInValidators - record.cumulativeProcessedSubmitpaymentQuantity;
        totalAmount += record.presentTotalamountAuditorAccountcredits;
        totalAmount += emergencyHealthReserve.acquireAvailableAccountcredits();
        totalAmount -= emergencyHealthReserve.cumulativeDrawdown();
        totalAmount += withdrawresourcesRequestsCoordinator.balance();
        return totalAmount;
    }

    function obtainresultsReturns() external payable onlyReturnsAggregator {
        emit ReturnsReceived(msg.value);
        unallocatedETH += msg.value;
    }

    function obtainresultsReturnsReferrerAvailableresourcesBuffer() external payable onlyAvailableresourcesBuffer {
        emit ReturnsReceivedReferrerAvailableresourcesBuffer(msg.value);
        unallocatedETH += msg.value;
    }

    modifier onlyReturnsAggregator() {
        if (msg.sender != returnsAggregator) {
            revert NotReturnsAggregator();
        }
        _;
    }

    modifier onlyAvailableresourcesBuffer() {
        if (msg.sender != address(emergencyHealthReserve)) {
            revert NotAvailableresourcesBuffer();
        }
        _;
    }

    modifier onlyWithdrawresourcesRequestsCoordinator() {
        if (msg.sender != address(withdrawresourcesRequestsCoordinator)) {
            revert NotWithdrawresourcesRequestsHandler();
        }
        _;
    }

    modifier nonNullRecipient(address addr) {
        if (addr == address(0)) {
            revert ZeroLocation();
        }
        _;
    }

    receive() external payable {
        revert DoesNotObtainresultsEth();
    }

    fallback() external payable {
        revert DoesNotObtainresultsEth();
    }
}