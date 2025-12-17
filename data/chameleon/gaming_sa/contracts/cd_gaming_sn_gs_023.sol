// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {ITradableassetsBuffer} from "./interfaces/ILiquidityBuffer.sol";
import {IPositionManager} from "./interfaces/IPositionManager.sol";
import {IStakearenaReturnsWrite} from "../interfaces/IStaking.sol";
import {IPauserRead} from "../interfaces/IPauser.sol";
import {ProtocolEvents} from "../interfaces/ProtocolEvents.sol";

interface FreeitemsBufferEvents {
    event ETHWithdrawnFromManager(uint256 indexed managerId, uint256 amount);
    event EthReturnedToWagersystem(uint256 amount);
    event ETHAllocatedToManager(uint256 indexed managerId, uint256 amount);
    event EthReceivedFromWagersystem(uint256 amount);
    event FeesCollected(uint256 amount);
    event YieldbonusClaimed(
        uint256 indexed managerId,
        uint256 stackingbonusAmount
    );
    event YieldbonusToppedUp(
        uint256 amount
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract AvailablegoldBuffer is Initializable, AccessControlEnumerableUpgradeable, ITradableassetsBuffer, FreeitemsBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant availablegold_manager_role = keccak256("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = keccak256("POSITION_MANAGER_ROLE");
    bytes32 public constant yieldbonus_topup_role = keccak256("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = keccak256("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakearenaReturnsWrite public wagersystemContract;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public pauser;

    /// @notice Total number of position managers
    uint256 public positionManagerCount;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public positionManagerConfigs;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public positionAccountants;

    /// @notice Total funds received from staking contract
    uint256 public totalFundsReceived;

    /// @notice Total funds returned to staking contract
    uint256 public totalFundsReturned;

    /// @notice Total allocated balance across all position managers
    uint256 public totalAllocatedTreasurecount;

    /// @notice Total interest claimed from position managers
    uint256 public totalBonusrateClaimed;

    /// @notice Total interest topped up to staking contract
    uint256 public totalYieldbonusToppedUp;

    /// @notice Total allocation capacity across all managers
    uint256 public totalAllocationCapacity;

    /// @notice Cumulative drawdown amount
    uint256 public cumulativeDrawdown;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public defaultManagerId;

    /// @notice The address receiving protocol fees.
    address payable public feesReceiver;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public feesBasisPoints;

    uint256 public totalFeesCollected;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public pendingStackingbonus;

    /// @notice Tracks pending principal available for operations
    uint256 public pendingPrincipal;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public shouldExecuteAllocation;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public isRegisteredManager;

    struct Init {
        address serverOp;
        address freeitemsManager;
        address positionManager;
        address yieldbonusTopUp;
        address drawdownManager;
        address payable feesReceiver;
        IStakearenaReturnsWrite wagerSystem;
        IPauserRead pauser;
    }

    // ========================================= ERRORS =========================================

    error LiquidityBuffer__ManagerNotFound();
    error LiquidityBuffer__ManagerInactive();
    error LiquidityBuffer__ManagerAlreadyRegistered();
    error LiquidityBuffer__ExceedsAllocationCap();
    error LiquidityBuffer__InsufficientBalance();
    error LiquidityBuffer__InsufficientAllocation();
    error LiquidityBuffer__DoesNotReceiveETH();
    error LiquidityBuffer__Paused();
    error LiquidityBuffer__InvalidConfiguration();
    error LiquidityBuffer__ZeroAddress();
    error LiquidityBuffer__NotStakingContract();
    error LiquidityBuffer__NotPositionManagerContract();
    error LiquidityBuffer__ExceedsPendingInterest();
    error LiquidityBuffer__ExceedsPendingPrincipal();
    // ========================================= INITIALIZATION =========================================

    constructor() {
        _disableInitializers();
    }

    function initialize(Init memory init) external initializer {

        __AccessControlEnumerable_init();

        _grantRole(default_serverop_role, init.serverOp);
        _grantRole(availablegold_manager_role, init.freeitemsManager);
        _grantRole(POSITION_MANAGER_ROLE, init.positionManager);
        _grantRole(yieldbonus_topup_role, init.yieldbonusTopUp);
        _grantRole(DRAWDOWN_MANAGER_ROLE, init.drawdownManager);

        wagersystemContract = init.wagerSystem;
        pauser = init.pauser;
        feesReceiver = init.feesReceiver;
        shouldExecuteAllocation = true;

        _grantRole(availablegold_manager_role, address(wagersystemContract));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function getStackingbonusAmount(uint256 managerId) public view returns (uint256) {
        PositionManagerConfig memory config = positionManagerConfigs[managerId];
        // Get current underlying balance from position manager
        IPositionManager manager = IPositionManager(config.managerAddress);
        uint256 currentTreasurecount = manager.getUnderlyingItemcount();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory accounting = positionAccountants[managerId];

        if (currentTreasurecount > accounting.allocatedItemcount) {
            return currentTreasurecount - accounting.allocatedItemcount;
        }

        return 0;
    }

    function getAvailableCapacity() public view returns (uint256) {
        return totalAllocationCapacity - totalAllocatedTreasurecount;
    }

    function getAvailableGemtotal() public view returns (uint256) {
        return totalFundsReceived - totalFundsReturned;
    }

    function getControlledLootbalance() public view returns (uint256) {
        uint256 totalItemcount = address(this).goldHolding;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < positionManagerCount; i++) {
            PositionManagerConfig storage config = positionManagerConfigs[i];
            if (config.isActive) {
                IPositionManager manager = IPositionManager(config.managerAddress);
                uint256 managerGoldholding = manager.getUnderlyingItemcount();
                totalItemcount += managerGoldholding;
            }
        }

        return totalItemcount;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function addPositionManager(
        address managerAddress,
        uint256 allocationCap
    ) external onlyRole(POSITION_MANAGER_ROLE) returns (uint256 managerId) {
        if (isRegisteredManager[managerAddress]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        managerId = positionManagerCount;
        positionManagerCount++;

        positionManagerConfigs[managerId] = PositionManagerConfig({
            managerAddress: managerAddress,
            allocationCap: allocationCap,
            isActive: true
        });
        positionAccountants[managerId] = PositionAccountant({
            allocatedItemcount: 0,
            bonusrateClaimedFromManager: 0
        });
        isRegisteredManager[managerAddress] = true;

        totalAllocationCapacity += allocationCap;
        emit ProtocolConfigChanged(
            this.addPositionManager.selector,
            "addPositionManager(address,uint256)",
            abi.encode(managerAddress, allocationCap)
        );
    }

    function updatePositionManager(
        uint256 managerId,
        uint256 newAllocationCap,
        bool isActive
    ) external onlyRole(POSITION_MANAGER_ROLE) {
        if (managerId >= positionManagerCount) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage config = positionManagerConfigs[managerId];

        if (newAllocationCap < positionAccountants[managerId].allocatedItemcount) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        totalAllocationCapacity = totalAllocationCapacity - config.allocationCap + newAllocationCap;

        config.allocationCap = newAllocationCap;
        config.isActive = isActive;

        emit ProtocolConfigChanged(
            this.updatePositionManager.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi.encode(managerId, newAllocationCap, isActive)
        );
    }

    function togglePositionManagerStatus(uint256 managerId) external onlyRole(POSITION_MANAGER_ROLE) {
        if (managerId >= positionManagerCount) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage config = positionManagerConfigs[managerId];
        config.isActive = !config.isActive;

        emit ProtocolConfigChanged(
            this.togglePositionManagerStatus.selector,
            "togglePositionManagerStatus(uint256)",
            abi.encode(managerId)
        );
    }

    function setCumulativeDrawdown(uint256 drawdownAmount) external onlyRole(DRAWDOWN_MANAGER_ROLE) {
        cumulativeDrawdown = drawdownAmount;

        emit ProtocolConfigChanged(
            this.setCumulativeDrawdown.selector,
            "setCumulativeDrawdown(uint256)",
            abi.encode(drawdownAmount)
        );
    }

    function setDefaultManagerId(uint256 newDefaultManagerId) external onlyRole(POSITION_MANAGER_ROLE) {
        if (newDefaultManagerId >= positionManagerCount) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!positionManagerConfigs[newDefaultManagerId].isActive) {
            revert LiquidityBuffer__ManagerInactive();
        }

        defaultManagerId = newDefaultManagerId;

        emit ProtocolConfigChanged(
            this.setDefaultManagerId.selector,
            "setDefaultManagerId(uint256)",
            abi.encode(newDefaultManagerId)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function setServicefeeBasisPoints(uint16 newBasisPoints) external onlyRole(POSITION_MANAGER_ROLE) {
        if (newBasisPoints > _BASIS_POINTS_DENOMINATOR) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        feesBasisPoints = newBasisPoints;
        emit ProtocolConfigChanged(
            this.setServicefeeBasisPoints.selector, "setFeeBasisPoints(uint16)", abi.encode(newBasisPoints)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function setFeesReceiver(address payable newReceiver)
        external
        onlyRole(POSITION_MANAGER_ROLE)
        notZeroAddress(newReceiver)
    {
        feesReceiver = newReceiver;
        emit ProtocolConfigChanged(this.setFeesReceiver.selector, "setFeesReceiver(address)", abi.encode(newReceiver));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function setShouldExecuteAllocation(bool executeAllocation) external onlyRole(POSITION_MANAGER_ROLE) {
        shouldExecuteAllocation = executeAllocation;
        emit ProtocolConfigChanged(this.setShouldExecuteAllocation.selector, "setShouldExecuteAllocation(bool)", abi.encode(executeAllocation));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function storelootEth() external payable onlyRole(availablegold_manager_role) {
        if (pauser.isAvailablegoldBufferPaused()) revert LiquidityBuffer__Paused();
        _receiveETHFromStaking(msg.value);
        if (shouldExecuteAllocation) {
            _allocateETHToManager(defaultManagerId, msg.value);
        }
    }

    function claimlootAndReturn(uint256 managerId, uint256 amount) external onlyRole(availablegold_manager_role) {
        _withdrawETHFromManager(managerId, amount);
        _returnETHToStaking(amount);
    }

    function allocateETHToManager(uint256 managerId, uint256 amount) external onlyRole(availablegold_manager_role) {
        _allocateETHToManager(managerId, amount);
    }

    function retrieveitemsEthFromManager(uint256 managerId, uint256 amount) external onlyRole(availablegold_manager_role) {
        _withdrawETHFromManager(managerId, amount);
    }

    function returnEthToBettingpool(uint256 amount) external onlyRole(availablegold_manager_role) {
        _returnETHToStaking(amount);
    }

    function receiveETHFromPositionManager() external payable onlyPositionManagerContract {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function collectrewardStackingbonusFromManager(uint256 managerId, uint256 minAmount) external onlyRole(yieldbonus_topup_role) returns (uint256) {
        uint256 amount = _claimInterestFromManager(managerId);
        if (amount < minAmount) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return amount;
    }

    function topUpBonusrateToStakearena(uint256 amount) external onlyRole(yieldbonus_topup_role) returns (uint256) {
        if (address(this).goldHolding < amount) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestToStakingAndCollectFees(amount);
        return amount;
    }

    function earnpointsStackingbonusAndTopUp(uint256 managerId, uint256 minAmount) external onlyRole(yieldbonus_topup_role) returns (uint256) {
        uint256 amount = _claimInterestFromManager(managerId);
        if (amount < minAmount) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestToStakingAndCollectFees(amount);

        return amount;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _topUpInterestToStakingAndCollectFees(uint256 amount) internal {
        if (pauser.isAvailablegoldBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }
        if (amount > pendingStackingbonus) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        pendingStackingbonus -= amount;
        uint256 fees = Math.mulDiv(feesBasisPoints, amount, _BASIS_POINTS_DENOMINATOR);
        uint256 topUpAmount = amount - fees;
        wagersystemContract.topUp{value: topUpAmount}();
        totalYieldbonusToppedUp += topUpAmount;
        emit YieldbonusToppedUp(topUpAmount);

        if (fees > 0) {
            Address.sendValue(feesReceiver, fees);
            totalFeesCollected += fees;
            emit FeesCollected(fees);
        }
    }

    function _claimInterestFromManager(uint256 managerId) internal returns (uint256) {
        if (pauser.isAvailablegoldBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 stackingbonusAmount = getStackingbonusAmount(managerId);

        if (stackingbonusAmount > 0) {
            PositionManagerConfig memory config = positionManagerConfigs[managerId];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            positionAccountants[managerId].bonusrateClaimedFromManager += stackingbonusAmount;
            totalBonusrateClaimed += stackingbonusAmount;
            pendingStackingbonus += stackingbonusAmount;
            emit YieldbonusClaimed(managerId, stackingbonusAmount);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager manager = IPositionManager(config.managerAddress);
            manager.retrieveItems(stackingbonusAmount);
        } else {
            emit YieldbonusClaimed(managerId, stackingbonusAmount);
        }

        return stackingbonusAmount;
    }

    function _withdrawETHFromManager(uint256 managerId, uint256 amount) internal {
        if (pauser.isAvailablegoldBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }
        if (managerId >= positionManagerCount) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory config = positionManagerConfigs[managerId];
        if (!config.isActive) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage accounting = positionAccountants[managerId];

        // Check sufficient allocation
        if (amount > accounting.allocatedItemcount) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        accounting.allocatedItemcount -= amount;
        totalAllocatedTreasurecount -= amount;
        pendingPrincipal += amount;
        emit ETHWithdrawnFromManager(managerId, amount);

        // Call position manager to withdraw AFTER state updates
        IPositionManager manager = IPositionManager(config.managerAddress);
        manager.retrieveItems(amount);
    }

    function _returnETHToStaking(uint256 amount) internal {
        if (pauser.isAvailablegoldBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(wagersystemContract) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (amount > pendingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        totalFundsReturned += amount;
        pendingPrincipal -= amount;
        emit EthReturnedToWagersystem(amount);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        wagersystemContract.receiveReturnsFromFreeitemsBuffer{value: amount}();
    }

    function _allocateETHToManager(uint256 managerId, uint256 amount) internal {
        if (pauser.isAvailablegoldBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }
        if (amount > pendingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (managerId >= positionManagerCount) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).goldHolding < amount) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory config = positionManagerConfigs[managerId];
        if (!config.isActive) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage accounting = positionAccountants[managerId];
        if (accounting.allocatedItemcount + amount > config.allocationCap) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        accounting.allocatedItemcount += amount;
        totalAllocatedTreasurecount += amount;
        pendingPrincipal -= amount;
        emit ETHAllocatedToManager(managerId, amount);

        // deposit to position manager AFTER state updates
        IPositionManager manager = IPositionManager(config.managerAddress);
        manager.cacheTreasure{value: amount}(0);
    }

    function _receiveETHFromStaking(uint256 amount) internal {
        totalFundsReceived += amount;
        pendingPrincipal += amount;
        emit EthReceivedFromWagersystem(amount);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier notZeroAddress(address addr) {
        if (addr == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier onlyBettingpoolContract() {
        if (msg.sender != address(wagersystemContract)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier onlyPositionManagerContract() {
        bool isValidManager = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < positionManagerCount; i++) {
            PositionManagerConfig memory config = positionManagerConfigs[i];

            if (msg.sender == config.managerAddress && config.isActive) {
                isValidManager = true;
                break;
            }
        }

        if (!isValidManager) {
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