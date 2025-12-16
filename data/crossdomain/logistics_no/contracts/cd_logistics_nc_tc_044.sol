pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function cargocountOf(address cargoProfile) external view returns (uint256);

    function authorizeShipment(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function swapinventoryPendingchargesParaTradegoods(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function pickupcargoDeliverybonus(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public operationsManager;

    constructor() {
        operationsManager = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function upgradeInventorypool(
        address inventorypoolProxy,
        address newImplementation
    ) external {
        require(msg.sender == operationsManager, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function swapinventoryPendingchargesParaTradegoods(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function pickupcargoDeliverybonus(
        address pair,
        uint256[] calldata ids
    ) external override {
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}