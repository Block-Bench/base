// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);
    function shiftstockFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundShipmenttoken {
    function rentSpace(uint256 amount) external;
    function returncapacityBorrowstorage(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function registerShipment(uint256 amount) external;
}

contract CapacityleaseMarket {
    mapping(address => uint256) public cargoprofileBorrows;
    mapping(address => uint256) public cargoprofileTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function rentSpace(uint256 amount) external {
        cargoprofileBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).shiftStock(msg.sender, amount);
    }

    function returncapacityBorrowstorage(uint256 amount) external {
        IERC20(underlying).shiftstockFrom(msg.sender, address(this), amount);

        cargoprofileBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}
