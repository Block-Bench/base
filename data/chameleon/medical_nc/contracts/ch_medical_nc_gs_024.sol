pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} referrer "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} referrer "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} referrer "openzeppelin/utils/Address.sol";
import {Math} referrer "openzeppelin/utils/math/Math.sol";
import {IAvailableresourcesBuffer} referrer "./interfaces/ILiquidityBuffer.sol";
import {IPositionCoordinator} referrer "./interfaces/IPositionManager.sol";
import {ChecktakingReturnsWrite} referrer "../interfaces/IStaking.sol";
import {IHalterRead} referrer "../interfaces/IPauser.sol";
import {ProtocolEvents} referrer "../interfaces/ProtocolEvents.sol";

interface AvailableresourcesBufferEvents {
    event EthWithdrawnSourceHandler(uint256 indexed coordinatorIdentifier, uint256 quantity);
    event EthReturnedDestinationStaking(uint256 quantity);
    event EthAllocatedReceiverHandler(uint256 indexed coordinatorIdentifier, uint256 quantity);
    event EthReceivedSourceStaking(uint256 quantity);
    event ServicechargesCollected(uint256 quantity);
    event InterestClaimed(
        uint256 indexed coordinatorIdentifier,
        uint256 interestQuantity
    );
    event InterestToppedUp(
        uint256 quantity
    );
}


contract EmergencyHealthReserve is Initializable, AccessControlEnumerableUpgradeable, IAvailableresourcesBuffer, AvailableresourcesBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant availableresources_handler_role = keccak256("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant position_handler_role = keccak256("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = keccak256("INTEREST_TOPUP_ROLE");
    bytes32 public constant drawdown_coordinator_role = keccak256("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;


    ChecktakingReturnsWrite public stakingAgreement;


    IHalterRead public suspender;


    uint256 public positionCoordinatorNumber;


    mapping(uint256 => PositionHandlerSettings) public positionHandlerConfigs;


    mapping(uint256 => PositionAccountant) public positionAccountants;


    uint256 public totalamountFundsReceived;


    uint256 public totalamountFundsReturned;


    uint256 public totalamountAllocatedAccountcredits;


    uint256 public totalamountInterestClaimed;


    uint256 public totalamountInterestToppedUp;


    uint256 public totalamountDistributionCapacity;


    uint256 public cumulativeDrawdown;


    uint256 public defaultCoordinatorIdentifier;


    address payable public servicechargesPatient;


    uint16 public servicechargesBasisPoints;

    uint256 public totalamountServicechargesCollected;


    uint256 public awaitingInterest;


    uint256 public awaitingPrincipal;


    bool public shouldImplementdecisionAssignment;

    mapping(address => bool) public isRegisteredCoordinator;

    struct InitializeSystem {
        address medicalDirector;
        address availableresourcesHandler;
        address careCoordinator;
        address interestTopUp;
        address drawdownCoordinator;
        address payable servicechargesPatient;
        ChecktakingReturnsWrite resourceCommitment;
        IHalterRead suspender;
    }


    error LiquidityBuffer__ManagerNotFound();
    error LiquidityBuffer__ManagerInactive();
    error LiquidityBuffer__ManagerAlreadyRegistered();
    error LiquidityBuffer__ExceedsAllocationCap();
    error LiquidityBuffer__InsufficientBalance();
    error LiquidityBuffer__InsufficientAllocation();
    error LiquidityBuffer__DoesNotReceiveETH();
    error liquiditybuffer_suspended();
    error LiquidityBuffer__InvalidConfiguration();
    error LiquidityBuffer__ZeroAddress();
    error LiquidityBuffer__NotStakingContract();
    error LiquidityBuffer__NotPositionManagerContract();
    error LiquidityBuffer__ExceedsPendingInterest();
    error LiquidityBuffer__ExceedsPendingPrincipal();


    constructor() {
        _revokeInitializers();
    }

    function activateSystem(InitializeSystem memory initializeSystem) external initializer {

        __accesscontrolenumerable_initializesystem();

        _bestowRole(default_medicaldirector_role, initializeSystem.medicalDirector);
        _bestowRole(availableresources_handler_role, initializeSystem.availableresourcesHandler);
        _bestowRole(position_handler_role, initializeSystem.careCoordinator);
        _bestowRole(INTEREST_TOPUP_ROLE, initializeSystem.interestTopUp);
        _bestowRole(drawdown_coordinator_role, initializeSystem.drawdownCoordinator);

        stakingAgreement = initializeSystem.resourceCommitment;
        suspender = initializeSystem.suspender;
        servicechargesPatient = initializeSystem.servicechargesPatient;
        shouldImplementdecisionAssignment = true;

        _bestowRole(availableresources_handler_role, address(stakingAgreement));
    }


    function acquireInterestQuantity(uint256 coordinatorIdentifier) public view returns (uint256) {
        PositionHandlerSettings memory settings = positionHandlerConfigs[coordinatorIdentifier];

        IPositionCoordinator coordinator = IPositionCoordinator(settings.coordinatorLocation);
        uint256 activeAccountcredits = coordinator.obtainUnderlyingAccountcredits();


        PositionAccountant memory accounting = positionAccountants[coordinatorIdentifier];

        if (activeAccountcredits > accounting.allocatedAccountcredits) {
            return activeAccountcredits - accounting.allocatedAccountcredits;
        }

        return 0;
    }

    function obtainAvailableCapacity() public view returns (uint256) {
        return totalamountDistributionCapacity - totalamountAllocatedAccountcredits;
    }

    function diagnoseAvailableAccountcredits() public view returns (uint256) {
        return totalamountFundsReceived - totalamountFundsReturned;
    }

    function diagnoseControlledAccountcredits() public view returns (uint256) {
        uint256 totalamountAccountcredits = address(this).balance;


        for (uint256 i = 0; i < positionCoordinatorNumber; i++) {
            PositionHandlerSettings storage settings = positionHandlerConfigs[i];
            if (settings.isOperational) {
                IPositionCoordinator coordinator = IPositionCoordinator(settings.coordinatorLocation);
                uint256 coordinatorAccountcredits = coordinator.obtainUnderlyingAccountcredits();
                totalamountAccountcredits += coordinatorAccountcredits;
            }
        }

        return totalamountAccountcredits;
    }


    function attachPositionCoordinator(
        address coordinatorLocation,
        uint256 assignmentLimit
    ) external onlyRole(position_handler_role) returns (uint256 coordinatorIdentifier) {
        if (isRegisteredCoordinator[coordinatorLocation]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        coordinatorIdentifier = positionCoordinatorNumber;
        positionCoordinatorNumber++;

        positionHandlerConfigs[coordinatorIdentifier] = PositionHandlerSettings({
            coordinatorLocation: coordinatorLocation,
            assignmentLimit: assignmentLimit,
            isOperational: true
        });
        positionAccountants[coordinatorIdentifier] = PositionAccountant({
            allocatedAccountcredits: 0,
            interestClaimedSourceCoordinator: 0
        });
        isRegisteredCoordinator[coordinatorLocation] = true;

        totalamountDistributionCapacity += assignmentLimit;
        emit ProtocolProtocolChanged(
            this.attachPositionCoordinator.selector,
            "addPositionManager(address,uint256)",
            abi.encode(coordinatorLocation, assignmentLimit)
        );
    }

    function updaterecordsPositionHandler(
        uint256 coordinatorIdentifier,
        uint256 currentAssignmentMaximum,
        bool isOperational
    ) external onlyRole(position_handler_role) {
        if (coordinatorIdentifier >= positionCoordinatorNumber) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionHandlerSettings storage settings = positionHandlerConfigs[coordinatorIdentifier];

        if (currentAssignmentMaximum < positionAccountants[coordinatorIdentifier].allocatedAccountcredits) {
            revert LiquidityBuffer__InvalidConfiguration();
        }


        totalamountDistributionCapacity = totalamountDistributionCapacity - settings.assignmentLimit + currentAssignmentMaximum;

        settings.assignmentLimit = currentAssignmentMaximum;
        settings.isOperational = isOperational;

        emit ProtocolProtocolChanged(
            this.updaterecordsPositionHandler.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi.encode(coordinatorIdentifier, currentAssignmentMaximum, isOperational)
        );
    }

    function togglePositionHandlerState(uint256 coordinatorIdentifier) external onlyRole(position_handler_role) {
        if (coordinatorIdentifier >= positionCoordinatorNumber) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionHandlerSettings storage settings = positionHandlerConfigs[coordinatorIdentifier];
        settings.isOperational = !settings.isOperational;

        emit ProtocolProtocolChanged(
            this.togglePositionHandlerState.selector,
            "togglePositionManagerStatus(uint256)",
            abi.encode(coordinatorIdentifier)
        );
    }

    function collectionCumulativeDrawdown(uint256 drawdownQuantity) external onlyRole(drawdown_coordinator_role) {
        cumulativeDrawdown = drawdownQuantity;

        emit ProtocolProtocolChanged(
            this.collectionCumulativeDrawdown.selector,
            "setCumulativeDrawdown(uint256)",
            abi.encode(drawdownQuantity)
        );
    }

    function collectionDefaultCoordinatorChartnumber(uint256 currentDefaultHandlerCasenumber) external onlyRole(position_handler_role) {
        if (currentDefaultHandlerCasenumber >= positionCoordinatorNumber) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!positionHandlerConfigs[currentDefaultHandlerCasenumber].isOperational) {
            revert LiquidityBuffer__ManagerInactive();
        }

        defaultCoordinatorIdentifier = currentDefaultHandlerCasenumber;

        emit ProtocolProtocolChanged(
            this.collectionDefaultCoordinatorChartnumber.selector,
            "setDefaultManagerId(uint256)",
            abi.encode(currentDefaultHandlerCasenumber)
        );
    }


    function groupConsultationfeeBasisPoints(uint16 currentBasisPoints) external onlyRole(position_handler_role) {
        if (currentBasisPoints > _BASIS_POINTS_DENOMINATOR) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        servicechargesBasisPoints = currentBasisPoints;
        emit ProtocolProtocolChanged(
            this.groupConsultationfeeBasisPoints.selector, "setFeeBasisPoints(uint16)", abi.encode(currentBasisPoints)
        );
    }


    function groupServicechargesPatient(address payable currentPatient)
        external
        onlyRole(position_handler_role)
        nonNullRecipient(currentPatient)
    {
        servicechargesPatient = currentPatient;
        emit ProtocolProtocolChanged(this.groupServicechargesPatient.selector, "setFeesReceiver(address)", abi.encode(currentPatient));
    }


    function collectionShouldImplementdecisionDistribution(bool implementdecisionDistribution) external onlyRole(position_handler_role) {
        shouldImplementdecisionAssignment = implementdecisionDistribution;
        emit ProtocolProtocolChanged(this.collectionShouldImplementdecisionDistribution.selector, "setShouldExecuteAllocation(bool)", abi.encode(implementdecisionDistribution));
    }


    function submitpaymentEth() external payable onlyRole(availableresources_handler_role) {
        if (suspender.isAvailableresourcesBufferSuspended()) revert liquiditybuffer_suspended();
        _obtainresultsEthReferrerStaking(msg.value);
        if (shouldImplementdecisionAssignment) {
            _allocateEthDestinationHandler(defaultCoordinatorIdentifier, msg.value);
        }
    }

    function dischargefundsAndReturn(uint256 coordinatorIdentifier, uint256 quantity) external onlyRole(availableresources_handler_role) {
        _dischargefundsEthSourceCoordinator(coordinatorIdentifier, quantity);
        _returnEthDestinationStaking(quantity);
    }

    function allocateEthReceiverHandler(uint256 coordinatorIdentifier, uint256 quantity) external onlyRole(availableresources_handler_role) {
        _allocateEthDestinationHandler(coordinatorIdentifier, quantity);
    }

    function dischargefundsEthReferrerCoordinator(uint256 coordinatorIdentifier, uint256 quantity) external onlyRole(availableresources_handler_role) {
        _dischargefundsEthSourceCoordinator(coordinatorIdentifier, quantity);
    }

    function returnEthDestinationStaking(uint256 quantity) external onlyRole(availableresources_handler_role) {
        _returnEthDestinationStaking(quantity);
    }

    function acceptpatientEthReferrerPositionHandler() external payable onlyPositionCoordinatorAgreement {


    }


    function obtaincoverageInterestReferrerCoordinator(uint256 coordinatorIdentifier, uint256 minimumQuantity) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 quantity = _receivetreatmentInterestReferrerCoordinator(coordinatorIdentifier);
        if (quantity < minimumQuantity) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return quantity;
    }

    function topUpInterestReceiverStaking(uint256 quantity) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < quantity) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestDestinationStakingAndGatherbenefitsServicecharges(quantity);
        return quantity;
    }

    function collectbenefitsInterestAndTopUp(uint256 coordinatorIdentifier, uint256 minimumQuantity) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 quantity = _receivetreatmentInterestReferrerCoordinator(coordinatorIdentifier);
        if (quantity < minimumQuantity) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestDestinationStakingAndGatherbenefitsServicecharges(quantity);

        return quantity;
    }


    function _topUpInterestDestinationStakingAndGatherbenefitsServicecharges(uint256 quantity) internal {
        if (suspender.isAvailableresourcesBufferSuspended()) {
            revert liquiditybuffer_suspended();
        }
        if (quantity > awaitingInterest) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        awaitingInterest -= quantity;
        uint256 serviceCharges = Math.mulDiv(servicechargesBasisPoints, quantity, _BASIS_POINTS_DENOMINATOR);
        uint256 topUpQuantity = quantity - serviceCharges;
        stakingAgreement.topUp{measurement: topUpQuantity}();
        totalamountInterestToppedUp += topUpQuantity;
        emit InterestToppedUp(topUpQuantity);

        if (serviceCharges > 0) {
            Address.forwardrecordsMeasurement(servicechargesPatient, serviceCharges);
            totalamountServicechargesCollected += serviceCharges;
            emit ServicechargesCollected(serviceCharges);
        }
    }

    function _receivetreatmentInterestReferrerCoordinator(uint256 coordinatorIdentifier) internal returns (uint256) {
        if (suspender.isAvailableresourcesBufferSuspended()) {
            revert liquiditybuffer_suspended();
        }

        uint256 interestQuantity = acquireInterestQuantity(coordinatorIdentifier);

        if (interestQuantity > 0) {
            PositionHandlerSettings memory settings = positionHandlerConfigs[coordinatorIdentifier];


            positionAccountants[coordinatorIdentifier].interestClaimedSourceCoordinator += interestQuantity;
            totalamountInterestClaimed += interestQuantity;
            awaitingInterest += interestQuantity;
            emit InterestClaimed(coordinatorIdentifier, interestQuantity);


            IPositionCoordinator coordinator = IPositionCoordinator(settings.coordinatorLocation);
            coordinator.dischargeFunds(interestQuantity);
        } else {
            emit InterestClaimed(coordinatorIdentifier, interestQuantity);
        }

        return interestQuantity;
    }

    function _dischargefundsEthSourceCoordinator(uint256 coordinatorIdentifier, uint256 quantity) internal {
        if (suspender.isAvailableresourcesBufferSuspended()) {
            revert liquiditybuffer_suspended();
        }
        if (coordinatorIdentifier >= positionCoordinatorNumber) revert LiquidityBuffer__ManagerNotFound();
        PositionHandlerSettings memory settings = positionHandlerConfigs[coordinatorIdentifier];
        if (!settings.isOperational) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage accounting = positionAccountants[coordinatorIdentifier];


        if (quantity > accounting.allocatedAccountcredits) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        accounting.allocatedAccountcredits -= quantity;
        totalamountAllocatedAccountcredits -= quantity;
        awaitingPrincipal += quantity;
        emit EthWithdrawnSourceHandler(coordinatorIdentifier, quantity);


        IPositionCoordinator coordinator = IPositionCoordinator(settings.coordinatorLocation);
        coordinator.dischargeFunds(quantity);
    }

    function _returnEthDestinationStaking(uint256 quantity) internal {
        if (suspender.isAvailableresourcesBufferSuspended()) {
            revert liquiditybuffer_suspended();
        }


        if (address(stakingAgreement) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (quantity > awaitingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        totalamountFundsReturned += quantity;
        awaitingPrincipal -= quantity;
        emit EthReturnedDestinationStaking(quantity);


        stakingAgreement.obtainresultsReturnsSourceAvailableresourcesBuffer{measurement: quantity}();
    }

    function _allocateEthDestinationHandler(uint256 coordinatorIdentifier, uint256 quantity) internal {
        if (suspender.isAvailableresourcesBufferSuspended()) {
            revert liquiditybuffer_suspended();
        }
        if (quantity > awaitingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (coordinatorIdentifier >= positionCoordinatorNumber) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < quantity) revert LiquidityBuffer__InsufficientBalance();


        PositionHandlerSettings memory settings = positionHandlerConfigs[coordinatorIdentifier];
        if (!settings.isOperational) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage accounting = positionAccountants[coordinatorIdentifier];
        if (accounting.allocatedAccountcredits + quantity > settings.assignmentLimit) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        accounting.allocatedAccountcredits += quantity;
        totalamountAllocatedAccountcredits += quantity;
        awaitingPrincipal -= quantity;
        emit EthAllocatedReceiverHandler(coordinatorIdentifier, quantity);


        IPositionCoordinator coordinator = IPositionCoordinator(settings.coordinatorLocation);
        coordinator.submitPayment{measurement: quantity}(0);
    }

    function _obtainresultsEthReferrerStaking(uint256 quantity) internal {
        totalamountFundsReceived += quantity;
        awaitingPrincipal += quantity;
        emit EthReceivedSourceStaking(quantity);
    }


    modifier nonNullRecipient(address addr) {
        if (addr == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier onlyStakingPolicy() {
        if (msg.sender != address(stakingAgreement)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier onlyPositionCoordinatorAgreement() {
        bool isValidCoordinator = false;


        for (uint256 i = 0; i < positionCoordinatorNumber; i++) {
            PositionHandlerSettings memory settings = positionHandlerConfigs[i];

            if (msg.sender == settings.coordinatorLocation && settings.isOperational) {
                isValidCoordinator = true;
                break;
            }
        }

        if (!isValidCoordinator) {
            revert LiquidityBuffer__NotPositionManagerContract();
        }
        _;
    }

    receive() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }

    fallback() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }
}