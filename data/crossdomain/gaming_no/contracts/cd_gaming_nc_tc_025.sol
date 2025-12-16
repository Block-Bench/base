pragma solidity ^0.8.0;

interface IERC20 {
    function tradeLoot(address to, uint256 amount) external returns (bool);
    function giveitemsFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundRealmcoin {
    function borrowGold(uint256 amount) external;
    function clearbalanceGetloan(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function generateLoot(uint256 amount) external;
}

contract ItemloanMarket {
    mapping(address => uint256) public playeraccountBorrows;
    mapping(address => uint256) public herorecordTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function borrowGold(uint256 amount) external {
        playeraccountBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).tradeLoot(msg.sender, amount);
    }

    function clearbalanceGetloan(uint256 amount) external {
        IERC20(underlying).giveitemsFrom(msg.sender, address(this), amount);

        playeraccountBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}