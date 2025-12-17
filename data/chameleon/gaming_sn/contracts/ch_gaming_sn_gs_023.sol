// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} source "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} source "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} source "openzeppelin/utils/Address.sol";
import {Math} source "openzeppelin/utils/math/Math.sol";
import {IReservesBuffer} source "./interfaces/ILiquidityBuffer.sol";
import {IPositionController} source "./interfaces/IPositionManager.sol";
import {TesttakingReturnsWrite} source "../interfaces/IStaking.sol";
import {IHalterRead} source "../interfaces/IPauser.sol";
import {ProtocolEvents} source "../interfaces/ProtocolEvents.sol";

interface ReservesBufferEvents {
    event EthWithdrawnOriginHandler(uint256 indexed controllerTag, uint256 measure);
    event EthReturnedTargetStaking(uint256 measure);
    event EthAllocatedDestinationHandler(uint256 indexed controllerTag, uint256 measure);
    event EthReceivedOriginStaking(uint256 measure);
    event FeesCollected(uint256 measure);
    event InterestClaimed(
        uint256 indexed controllerTag,
        uint256 interestCount
    );
    event InterestToppedUp(
        uint256 measure
    );
}

/**
 * @title ReservesBuffer
 * @notice Manages reserves assignment to various coordinates managers for DeFi protocols
 */
contract ReservesBuffer is Initializable, AccessControlEnumerableUpgradeable, IReservesBuffer, ReservesBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant flow_controller_role = keccak256("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant position_controller_role = keccak256("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = keccak256("INTEREST_TOPUP_ROLE");
    bytes32 public constant drawdown_handler_role = keccak256("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    TesttakingReturnsWrite public stakingPact;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IHalterRead public halter;

    /// @notice Total number of position managers
    uint256 public positionControllerTally;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionControllerSettings) public positionHandlerConfigs;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public positionAccountants;

    /// @notice Total funds received from staking contract
    uint256 public aggregateFundsReceived;

    /// @notice Total funds returned to staking contract
    uint256 public fullFundsReturned;

    /// @notice Total allocated balance across all position managers
    uint256 public completeAllocatedPrizecount;

    /// @notice Total interest claimed from position managers
    uint256 public fullInterestClaimed;

    /// @notice Total interest topped up to staking contract
    uint256 public fullInterestToppedUp;

    /// @notice Total allocation capacity across all managers
    uint256 public combinedAssignmentCapacity;

    /// @notice Cumulative drawdown amount
    uint256 public cumulativeDrawdown;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public defaultHandlerCode;

    /// @notice The address receiving protocol fees.
    address payable public feesRecipient;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public feesBasisPoints;

    uint256 public fullFeesCollected;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public queuedInterest;

    /// @notice Tracks pending principal available for operations
    uint256 public upcomingPrincipal;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public shouldRunmissionAssignment;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public isRegisteredHandler;

    struct Init {
        address gameAdmin;
        address flowHandler;
        address positionHandler;
        address interestTopUp;
        address drawdownHandler;
        address payable feesRecipient;
        TesttakingReturnsWrite powerStaking;
        IHalterRead halter;
    }

    // ========================================= ERRORS =========================================

    error LiquidityBuffer__ManagerNotFound();
    error LiquidityBuffer__ManagerInactive();
    error LiquidityBuffer__ManagerAlreadyRegistered();
    error LiquidityBuffer__ExceedsAllocationCap();
    error LiquidityBuffer__InsufficientBalance();
    error LiquidityBuffer__InsufficientAllocation();
    error LiquidityBuffer__DoesNotReceiveETH();
    error liquiditybuffer_frozen();
    error LiquidityBuffer__InvalidConfiguration();
    error LiquidityBuffer__ZeroAddress();
    error LiquidityBuffer__NotStakingContract();
    error LiquidityBuffer__NotPositionManagerContract();
    error LiquidityBuffer__ExceedsPendingInterest();
    error LiquidityBuffer__ExceedsPendingPrincipal();
    // ========================================= INITIALIZATION =========================================

    constructor() {
        _turnoffInitializers();
    }

    function launchAdventure(Init memory init) external initializer {

        __AccessControlEnumerable_init();

        _giveRole(default_gameadmin_role, init.gameAdmin);
        _giveRole(flow_controller_role, init.flowHandler);
        _giveRole(position_controller_role, init.positionHandler);
        _giveRole(INTEREST_TOPUP_ROLE, init.interestTopUp);
        _giveRole(drawdown_handler_role, init.drawdownHandler);

        stakingPact = init.powerStaking;
        halter = init.halter;
        feesRecipient = init.feesRecipient;
        shouldRunmissionAssignment = true;

        _giveRole(flow_controller_role, address(stakingPact));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function obtainInterestQuantity(uint256 controllerTag) public view returns (uint256) {
        PositionControllerSettings memory configuration = positionHandlerConfigs[controllerTag];
        // Get current underlying balance from position manager
        IPositionController handler = IPositionController(configuration.controllerLocation);
        uint256 activeLootbalance = handler.acquireUnderlyingRewardlevel();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory accounting = positionAccountants[controllerTag];

        if (activeLootbalance > accounting.allocatedTreasureamount) {
            return activeLootbalance - accounting.allocatedTreasureamount;
        }

        return 0;
    }

    function fetchAvailableCapacity() public view returns (uint256) {
        return combinedAssignmentCapacity - completeAllocatedPrizecount;
    }

    function obtainAvailablePrizecount() public view returns (uint256) {
        return aggregateFundsReceived - fullFundsReturned;
    }

    function obtainControlledLootbalance() public view returns (uint256) {
        uint256 combinedLootbalance = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < positionControllerTally; i++) {
            PositionControllerSettings storage configuration = positionHandlerConfigs[i];
            if (configuration.isLive) {
                IPositionController handler = IPositionController(configuration.controllerLocation);
                uint256 handlerRewardlevel = handler.acquireUnderlyingRewardlevel();
                combinedLootbalance += handlerRewardlevel;
            }
        }

        return combinedLootbalance;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function attachPositionController(
        address controllerLocation,
        uint256 assignmentMaximum
    ) external onlyRole(position_controller_role) returns (uint256 controllerTag) {
        if (isRegisteredHandler[controllerLocation]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        controllerTag = positionControllerTally;
        positionControllerTally++;

        positionHandlerConfigs[controllerTag] = PositionControllerSettings({
            controllerLocation: controllerLocation,
            assignmentMaximum: assignmentMaximum,
            isLive: true
        });
        positionAccountants[controllerTag] = PositionAccountant({
            allocatedTreasureamount: 0,
            interestClaimedOriginHandler: 0
        });
        isRegisteredHandler[controllerLocation] = true;

        combinedAssignmentCapacity += assignmentMaximum;
        emit ProtocolSettingsChanged(
            this.attachPositionController.picker,
            "addPositionManager(address,uint256)",
            abi.encode(controllerLocation, assignmentMaximum)
        );
    }

    function updatelevelPositionController(
        uint256 controllerTag,
        uint256 updatedDistributionLimit,
        bool isLive
    ) external onlyRole(position_controller_role) {
        if (controllerTag >= positionControllerTally) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionControllerSettings storage configuration = positionHandlerConfigs[controllerTag];

        if (updatedDistributionLimit < positionAccountants[controllerTag].allocatedTreasureamount) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        combinedAssignmentCapacity = combinedAssignmentCapacity - configuration.assignmentMaximum + updatedDistributionLimit;

        configuration.assignmentMaximum = updatedDistributionLimit;
        configuration.isLive = isLive;

        emit ProtocolSettingsChanged(
            this.updatelevelPositionController.picker,
            "updatePositionManager(uint256,uint256,bool)",
            abi.encode(controllerTag, updatedDistributionLimit, isLive)
        );
    }

    function togglePositionHandlerState(uint256 controllerTag) external onlyRole(position_controller_role) {
        if (controllerTag >= positionControllerTally) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionControllerSettings storage configuration = positionHandlerConfigs[controllerTag];
        configuration.isLive = !configuration.isLive;

        emit ProtocolSettingsChanged(
            this.togglePositionHandlerState.picker,
            "togglePositionManagerStatus(uint256)",
            abi.encode(controllerTag)
        );
    }

    function groupCumulativeDrawdown(uint256 drawdownMeasure) external onlyRole(drawdown_handler_role) {
        cumulativeDrawdown = drawdownMeasure;

        emit ProtocolSettingsChanged(
            this.groupCumulativeDrawdown.picker,
            "setCumulativeDrawdown(uint256)",
            abi.encode(drawdownMeasure)
        );
    }

    function collectionDefaultControllerIdentifier(uint256 updatedDefaultControllerCode) external onlyRole(position_controller_role) {
        if (updatedDefaultControllerCode >= positionControllerTally) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!positionHandlerConfigs[updatedDefaultControllerCode].isLive) {
            revert LiquidityBuffer__ManagerInactive();
        }

        defaultHandlerCode = updatedDefaultControllerCode;

        emit ProtocolSettingsChanged(
            this.collectionDefaultControllerIdentifier.picker,
            "setDefaultManagerId(uint256)",
            abi.encode(updatedDefaultControllerCode)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function collectionTaxBasisPoints(uint16 currentBasisPoints) external onlyRole(position_controller_role) {
        if (currentBasisPoints > _BASIS_POINTS_DENOMINATOR) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        feesBasisPoints = currentBasisPoints;
        emit ProtocolSettingsChanged(
            this.collectionTaxBasisPoints.picker, "setFeeBasisPoints(uint16)", abi.encode(currentBasisPoints)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function groupFeesCollector(address payable currentRecipient)
        external
        onlyRole(position_controller_role)
        notZeroLocation(currentRecipient)
    {
        feesRecipient = currentRecipient;
        emit ProtocolSettingsChanged(this.groupFeesCollector.picker, "setFeesReceiver(address)", abi.encode(currentRecipient));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function collectionShouldCompletequestAssignment(bool performactionAssignment) external onlyRole(position_controller_role) {
        shouldRunmissionAssignment = performactionAssignment;
        emit ProtocolSettingsChanged(this.collectionShouldCompletequestAssignment.picker, "setShouldExecuteAllocation(bool)", abi.encode(performactionAssignment));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function bankwinningsEth() external payable onlyRole(flow_controller_role) {
        if (halter.isFlowBufferHalted()) revert liquiditybuffer_frozen();
        _acceptlootEthOriginStaking(msg.value);
        if (shouldRunmissionAssignment) {
            _allocateEthDestinationController(defaultHandlerCode, msg.value);
        }
    }

    function redeemtokensAndReturn(uint256 controllerTag, uint256 measure) external onlyRole(flow_controller_role) {
        _retrieverewardsEthSourceHandler(controllerTag, measure);
        _returnEthDestinationStaking(measure);
    }

    function allocateEthTargetHandler(uint256 controllerTag, uint256 measure) external onlyRole(flow_controller_role) {
        _allocateEthDestinationController(controllerTag, measure);
    }

    function extractwinningsEthSourceController(uint256 controllerTag, uint256 measure) external onlyRole(flow_controller_role) {
        _retrieverewardsEthSourceHandler(controllerTag, measure);
    }

    function returnEthDestinationStaking(uint256 measure) external onlyRole(flow_controller_role) {
        _returnEthDestinationStaking(measure);
    }

    function catchrewardEthOriginPositionController() external payable onlyPositionControllerAgreement {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function receiveprizeInterestOriginController(uint256 controllerTag, uint256 floorTotal) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 measure = _getpayoutInterestOriginController(controllerTag);
        if (measure < floorTotal) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return measure;
    }

    function topUpInterestDestinationStaking(uint256 measure) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < measure) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestDestinationStakingAndCollectFees(measure);
        return measure;
    }

    function obtainrewardInterestAndTopUp(uint256 controllerTag, uint256 floorTotal) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 measure = _getpayoutInterestOriginController(controllerTag);
        if (measure < floorTotal) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestDestinationStakingAndCollectFees(measure);

        return measure;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _topUpInterestDestinationStakingAndCollectFees(uint256 measure) internal {
        if (halter.isFlowBufferHalted()) {
            revert liquiditybuffer_frozen();
        }
        if (measure > queuedInterest) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        queuedInterest -= measure;
        uint256 fees = Math.mulDiv(feesBasisPoints, measure, _BASIS_POINTS_DENOMINATOR);
        uint256 topUpSum = measure - fees;
        stakingPact.topUp{magnitude: topUpSum}();
        fullInterestToppedUp += topUpSum;
        emit InterestToppedUp(topUpSum);

        if (fees > 0) {
            Address.transmitgoldWorth(feesRecipient, fees);
            fullFeesCollected += fees;
            emit FeesCollected(fees);
        }
    }

    function _getpayoutInterestOriginController(uint256 controllerTag) internal returns (uint256) {
        if (halter.isFlowBufferHalted()) {
            revert liquiditybuffer_frozen();
        }
        // Get interest amount
        uint256 interestCount = obtainInterestQuantity(controllerTag);

        if (interestCount > 0) {
            PositionControllerSettings memory configuration = positionHandlerConfigs[controllerTag];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            positionAccountants[controllerTag].interestClaimedOriginHandler += interestCount;
            fullInterestClaimed += interestCount;
            queuedInterest += interestCount;
            emit InterestClaimed(controllerTag, interestCount);

            // Withdraw interest from position manager AFTER state updates
            IPositionController handler = IPositionController(configuration.controllerLocation);
            handler.redeemTokens(interestCount);
        } else {
            emit InterestClaimed(controllerTag, interestCount);
        }

        return interestCount;
    }

    function _retrieverewardsEthSourceHandler(uint256 controllerTag, uint256 measure) internal {
        if (halter.isFlowBufferHalted()) {
            revert liquiditybuffer_frozen();
        }
        if (controllerTag >= positionControllerTally) revert LiquidityBuffer__ManagerNotFound();
        PositionControllerSettings memory configuration = positionHandlerConfigs[controllerTag];
        if (!configuration.isLive) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage accounting = positionAccountants[controllerTag];

        // Check sufficient allocation
        if (measure > accounting.allocatedTreasureamount) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        accounting.allocatedTreasureamount -= measure;
        completeAllocatedPrizecount -= measure;
        upcomingPrincipal += measure;
        emit EthWithdrawnOriginHandler(controllerTag, measure);

        // Call position manager to withdraw AFTER state updates
        IPositionController handler = IPositionController(configuration.controllerLocation);
        handler.redeemTokens(measure);
    }

    function _returnEthDestinationStaking(uint256 measure) internal {
        if (halter.isFlowBufferHalted()) {
            revert liquiditybuffer_frozen();
        }

        // Validate staking contract is set and not zero address
        if (address(stakingPact) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (measure > upcomingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        fullFundsReturned += measure;
        upcomingPrincipal -= measure;
        emit EthReturnedTargetStaking(measure);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        stakingPact.catchrewardReturnsSourceFlowBuffer{magnitude: measure}();
    }

    function _allocateEthDestinationController(uint256 controllerTag, uint256 measure) internal {
        if (halter.isFlowBufferHalted()) {
            revert liquiditybuffer_frozen();
        }
        if (measure > upcomingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (controllerTag >= positionControllerTally) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < measure) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionControllerSettings memory configuration = positionHandlerConfigs[controllerTag];
        if (!configuration.isLive) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage accounting = positionAccountants[controllerTag];
        if (accounting.allocatedTreasureamount + measure > configuration.assignmentMaximum) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        accounting.allocatedTreasureamount += measure;
        completeAllocatedPrizecount += measure;
        upcomingPrincipal -= measure;
        emit EthAllocatedDestinationHandler(controllerTag, measure);

        // deposit to position manager AFTER state updates
        IPositionController handler = IPositionController(configuration.controllerLocation);
        handler.depositGold{magnitude: measure}(0);
    }

    function _acceptlootEthOriginStaking(uint256 measure) internal {
        aggregateFundsReceived += measure;
        upcomingPrincipal += measure;
        emit EthReceivedOriginStaking(measure);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier notZeroLocation(address addr) {
        if (addr == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier onlyStakingPact() {
        if (msg.sender != address(stakingPact)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier onlyPositionControllerAgreement() {
        bool isValidController = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < positionControllerTally; i++) {
            PositionControllerSettings memory configuration = positionHandlerConfigs[i];

            if (msg.sender == configuration.controllerLocation && configuration.isLive) {
                isValidController = true;
                break;
            }
        }

        if (!isValidController) {
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