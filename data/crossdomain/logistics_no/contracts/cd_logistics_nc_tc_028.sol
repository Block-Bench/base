pragma solidity ^0.8.0;

interface IERC20 {
    function inventoryOf(address logisticsAccount) external view returns (uint256);
    function moveGoods(address to, uint256 amount) external returns (bool);
    function transferinventoryFrom(address from, address to, uint256 amount) external returns (bool);
}

contract InventorytokenInventoryvault {
    address public inventoryToken;
    mapping(address => uint256) public deposits;

    constructor(address _inventorytoken) {
        inventoryToken = _inventorytoken;
    }

    function stockInventory(uint256 amount) external {
        IERC20(inventoryToken).transferinventoryFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function releaseGoods(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(inventoryToken).moveGoods(msg.sender, amount);
    }
}