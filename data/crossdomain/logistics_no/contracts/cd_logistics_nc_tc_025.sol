pragma solidity ^0.8.0;

interface IERC20 {
    function transferInventory(address to, uint256 amount) external returns (bool);
    function relocatecargoFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundFreightcredit {
    function borrowStorage(uint256 amount) external;
    function clearrentalLeasecapacity(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function recordCargo(uint256 amount) external;
}

contract StoragerentalMarket {
    mapping(address => uint256) public shipperaccountBorrows;
    mapping(address => uint256) public logisticsaccountTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function borrowStorage(uint256 amount) external {
        shipperaccountBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).transferInventory(msg.sender, amount);
    }

    function clearrentalLeasecapacity(uint256 amount) external {
        IERC20(underlying).relocatecargoFrom(msg.sender, address(this), amount);

        shipperaccountBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}