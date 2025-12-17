// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);
    function sharetreasureFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundQuesttoken {
    function takeAdvance(uint256 amount) external;
    function paydebtBorrowgold(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function createItem(uint256 amount) external;
}

contract GoldlendingMarket {
    mapping(address => uint256) public gamerprofileBorrows;
    mapping(address => uint256) public gamerprofileTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function takeAdvance(uint256 amount) external {
        gamerprofileBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).shareTreasure(msg.sender, amount);
    }

    function paydebtBorrowgold(uint256 amount) external {
        IERC20(underlying).sharetreasureFrom(msg.sender, address(this), amount);

        gamerprofileBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}
