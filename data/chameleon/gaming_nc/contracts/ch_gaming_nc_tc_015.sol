pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public serverOp;

    mapping(address => uint256) public characterCoins;
    uint256 public totalSupply;

    address public constant previous_tusd =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant current_tusd =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        serverOp = msg.sender;
        underlying = previous_tusd;
    }

    function craft(uint256 measure) external {
        IERC20(current_tusd).transfer(address(this), measure);
        characterCoins[msg.sender] += measure;
        totalSupply += measure;
    }

    function sweepCoin(address gem) external {
        require(gem != underlying, "Cannot sweep underlying token");

        uint256 balance = IERC20(gem).balanceOf(address(this));
        IERC20(gem).transfer(msg.sender, balance);
    }

    function exchangeTokens(uint256 measure) external {
        require(characterCoins[msg.sender] >= measure, "Insufficient balance");

        characterCoins[msg.sender] -= measure;
        totalSupply -= measure;

        IERC20(current_tusd).transfer(msg.sender, measure);
    }
}