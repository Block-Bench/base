pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {ILiquidityBuffer} from "./interfaces/ILiquidityBuffer.sol";
import {IPositionManager} from "./interfaces/IPositionManager.sol";
import {IStakingReturnsWrite} from "../interfaces/IStaking.sol";
import {IPauserRead} from "../interfaces/IPauser.sol";
import {ProtocolEvents} from "../interfaces/ProtocolEvents.sol";

interface LiquidityBufferEvents {
    event ETHWithdrawnFromManager(uint256 indexed managerId, uint256 amount);
    event ETHReturnedToStaking(uint256 amount);
    event ETHAllocatedToManager(uint256 indexed managerId, uint256 amount);
    event ETHReceivedFromStaking(uint256 amount);
    event FeesCollected(uint256 amount);
    event InterestClaimed(
        uint256 indexed managerId,
        uint256 interestAmount
    );
    event InterestToppedUp(
        uint256 amount
    );
}


contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;


    bytes32 public constant LIQUIDITY_MANAGER_ROLE = keccak256("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = keccak256("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = keccak256("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = keccak256("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;


    IStakingReturnsWrite public stakingContract;


    IPauserRead public pauser;


    uint256 public positionManagerCount;


    mapping(uint256 => PositionManagerConfig) public positionManagerConfigs;


    mapping(uint256 => PositionAccountant) public positionAccountants;


    uint256 public totalFundsReceived;


    uint256 public totalFundsReturned;


    uint256 public totalAllocatedBalance;


    uint256 public totalInterestClaimed;


    uint256 public totalInterestToppedUp;


    uint256 public totalAllocationCapacity;


    uint256 public cumulativeDrawdown;


    uint256 public defaultManagerId;


    address payable public feesReceiver;


    uint16 public feesBasisPoints;

    uint256 public totalFeesCollected;


    uint256 public pendingInterest;


    uint256 public pendingPrincipal;


    bool public shouldExecuteAllocation;

    mapping(address => bool) public isRegisteredManager;

    struct Init {
        address admin;
        address liquidityManager;
        address positionManager;
        address interestTopUp;
        address drawdownManager;
        address payable feesReceiver;
        IStakingReturnsWrite staking;
        IPauserRead pauser;
    }


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


    constructor() {
        _disableInitializers();
    }

    function initialize(Init memory init) external initializer {

        __AccessControlEnumerable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, init.admin);
        _grantRole(LIQUIDITY_MANAGER_ROLE, init.liquidityManager);
        _grantRole(POSITION_MANAGER_ROLE, init.positionManager);
        _grantRole(INTEREST_TOPUP_ROLE, init.interestTopUp);
        _grantRole(DRAWDOWN_MANAGER_ROLE, init.drawdownManager);

        stakingContract = init.staking;
        pauser = init.pauser;
        feesReceiver = init.feesReceiver;
        shouldExecuteAllocation = true;

        _grantRole(LIQUIDITY_MANAGER_ROLE, address(stakingContract));
    }


    function getInterestAmount(uint256 managerId) public view returns (uint256) {
        PositionManagerConfig memory config = positionManagerConfigs[managerId];

        IPositionManager manager = IPositionManager(config.managerAddress);
        uint256 currentBalance = manager.getUnderlyingBalance();


        PositionAccountant memory accounting = positionAccountants[managerId];

        if (currentBalance > accounting.allocatedBalance) {
            return currentBalance - accounting.allocatedBalance;
        }

        return 0;
    }

    function getAvailableCapacity() public view returns (uint256) {
        return totalAllocationCapacity - totalAllocatedBalance;
    }

    function getAvailableBalance() public view returns (uint256) {
        return totalFundsReceived - totalFundsReturned;
    }

    function getControlledBalance() public view returns (uint256) {
        uint256 totalBalance = address(this).balance;


        for (uint256 i = 0; i < positionManagerCount; i++) {
            PositionManagerConfig storage config = positionManagerConfigs[i];
            if (config.isActive) {
                IPositionManager manager = IPositionManager(config.managerAddress);
                uint256 managerBalance = manager.getUnderlyingBalance();
                totalBalance += managerBalance;
            }
        }

        return totalBalance;
    }


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
            allocatedBalance: 0,
            interestClaimedFromManager: 0
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
        _performUpdatePositionManagerHandler(managerId, newAllocationCap, isActive);
    }

    function _performUpdatePositionManagerHandler(uint256 managerId, uint256 newAllocationCap, bool isActive) internal {
        if (managerId >= positionManagerCount) {
        revert LiquidityBuffer__ManagerNotFound();
        }
        PositionManagerConfig storage config = positionManagerConfigs[managerId];
        if (newAllocationCap < positionAccountants[managerId].allocatedBalance) {
        revert LiquidityBuffer__InvalidConfiguration();
        }
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


    function setFeeBasisPoints(uint16 newBasisPoints) external onlyRole(POSITION_MANAGER_ROLE) {
        if (newBasisPoints > _BASIS_POINTS_DENOMINATOR) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        feesBasisPoints = newBasisPoints;
        emit ProtocolConfigChanged(
            this.setFeeBasisPoints.selector, "setFeeBasisPoints(uint16)", abi.encode(newBasisPoints)
        );
    }


    function setFeesReceiver(address payable newReceiver)
        external
        onlyRole(POSITION_MANAGER_ROLE)
        notZeroAddress(newReceiver)
    {
        feesReceiver = newReceiver;
        emit ProtocolConfigChanged(this.setFeesReceiver.selector, "setFeesReceiver(address)", abi.encode(newReceiver));
    }


    function setShouldExecuteAllocation(bool executeAllocation) external onlyRole(POSITION_MANAGER_ROLE) {
        shouldExecuteAllocation = executeAllocation;
        emit ProtocolConfigChanged(this.setShouldExecuteAllocation.selector, "setShouldExecuteAllocation(bool)", abi.encode(executeAllocation));
    }


    function depositETH() external payable onlyRole(LIQUIDITY_MANAGER_ROLE) {
        if (pauser.isLiquidityBufferPaused()) revert LiquidityBuffer__Paused();
        _receiveETHFromStaking(msg.value);
        if (shouldExecuteAllocation) {
            _allocateETHToManager(defaultManagerId, msg.value);
        }
    }

    function withdrawAndReturn(uint256 managerId, uint256 amount) external onlyRole(LIQUIDITY_MANAGER_ROLE) {
        _withdrawETHFromManager(managerId, amount);
        _returnETHToStaking(amount);
    }

    function allocateETHToManager(uint256 managerId, uint256 amount) external onlyRole(LIQUIDITY_MANAGER_ROLE) {
        _allocateETHToManager(managerId, amount);
    }

    function withdrawETHFromManager(uint256 managerId, uint256 amount) external onlyRole(LIQUIDITY_MANAGER_ROLE) {
        _withdrawETHFromManager(managerId, amount);
    }

    function returnETHToStaking(uint256 amount) external onlyRole(LIQUIDITY_MANAGER_ROLE) {
        _returnETHToStaking(amount);
    }

    function receiveETHFromPositionManager() external payable onlyPositionManagerContract {


    }


    function claimInterestFromManager(uint256 managerId, uint256 minAmount) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 amount = _claimInterestFromManager(managerId);
        if (amount < minAmount) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return amount;
    }

    function topUpInterestToStaking(uint256 amount) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < amount) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestToStakingAndCollectFees(amount);
        return amount;
    }

    function claimInterestAndTopUp(uint256 managerId, uint256 minAmount) external onlyRole(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 amount = _claimInterestFromManager(managerId);
        if (amount < minAmount) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _topUpInterestToStakingAndCollectFees(amount);

        return amount;
    }


    function _topUpInterestToStakingAndCollectFees(uint256 amount) internal {
        if (pauser.isLiquidityBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }
        if (amount > pendingInterest) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        pendingInterest -= amount;
        uint256 fees = Math.mulDiv(feesBasisPoints, amount, _BASIS_POINTS_DENOMINATOR);
        uint256 topUpAmount = amount - fees;
        stakingContract.topUp{value: topUpAmount}();
        totalInterestToppedUp += topUpAmount;
        emit InterestToppedUp(topUpAmount);

        if (fees > 0) {
            Address.sendValue(feesReceiver, fees);
            totalFeesCollected += fees;
            emit FeesCollected(fees);
        }
    }

    function _claimInterestFromManager(uint256 managerId) internal returns (uint256) {
        if (pauser.isLiquidityBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }

        uint256 interestAmount = getInterestAmount(managerId);

        if (interestAmount > 0) {
            PositionManagerConfig memory config = positionManagerConfigs[managerId];


            positionAccountants[managerId].interestClaimedFromManager += interestAmount;
            totalInterestClaimed += interestAmount;
            pendingInterest += interestAmount;
            emit InterestClaimed(managerId, interestAmount);


            IPositionManager manager = IPositionManager(config.managerAddress);
            manager.withdraw(interestAmount);
        } else {
            emit InterestClaimed(managerId, interestAmount);
        }

        return interestAmount;
    }

    function _withdrawETHFromManager(uint256 managerId, uint256 amount) internal {
        if (pauser.isLiquidityBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }
        if (managerId >= positionManagerCount) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory config = positionManagerConfigs[managerId];
        if (!config.isActive) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage accounting = positionAccountants[managerId];


        if (amount > accounting.allocatedBalance) {
            revert LiquidityBuffer__InsufficientAllocation();
        }


        accounting.allocatedBalance -= amount;
        totalAllocatedBalance -= amount;
        pendingPrincipal += amount;
        emit ETHWithdrawnFromManager(managerId, amount);


        IPositionManager manager = IPositionManager(config.managerAddress);
        manager.withdraw(amount);
    }

    function _returnETHToStaking(uint256 amount) internal {
        if (pauser.isLiquidityBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }


        if (address(stakingContract) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (amount > pendingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }


        totalFundsReturned += amount;
        pendingPrincipal -= amount;
        emit ETHReturnedToStaking(amount);


        stakingContract.receiveReturnsFromLiquidityBuffer{value: amount}();
    }

    function _allocateETHToManager(uint256 managerId, uint256 amount) internal {
        if (pauser.isLiquidityBufferPaused()) {
            revert LiquidityBuffer__Paused();
        }
        if (amount > pendingPrincipal) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (managerId >= positionManagerCount) revert LiquidityBuffer__ManagerNotFound();

        if (address(this).balance < amount) revert LiquidityBuffer__InsufficientBalance();


        PositionManagerConfig memory config = positionManagerConfigs[managerId];
        if (!config.isActive) revert LiquidityBuffer__ManagerInactive();

        PositionAccountant storage accounting = positionAccountants[managerId];
        if (accounting.allocatedBalance + amount > config.allocationCap) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }


        accounting.allocatedBalance += amount;
        totalAllocatedBalance += amount;
        pendingPrincipal -= amount;
        emit ETHAllocatedToManager(managerId, amount);


        IPositionManager manager = IPositionManager(config.managerAddress);
        manager.deposit{value: amount}(0);
    }

    function _receiveETHFromStaking(uint256 amount) internal {
        totalFundsReceived += amount;
        pendingPrincipal += amount;
        emit ETHReceivedFromStaking(amount);
    }


    modifier notZeroAddress(address addr) {
        if (addr == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }


    modifier onlyStakingContract() {
        if (msg.sender != address(stakingContract)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier onlyPositionManagerContract() {
        bool isValidManager = false;


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