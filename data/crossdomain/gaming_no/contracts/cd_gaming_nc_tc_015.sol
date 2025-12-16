pragma solidity ^0.8.0;


interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function treasurecountOf(address heroRecord) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public gameKeeper;

    mapping(address => uint256) public herorecordTokens;
    uint256 public totalGold;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        gameKeeper = msg.sender;
        underlying = OLD_TUSD;
    }

    function generateLoot(uint256 amount) external {
        IERC20(NEW_TUSD).sendGold(address(this), amount);
        herorecordTokens[msg.sender] += amount;
        totalGold += amount;
    }

    function sweepGamecoin(address gameCoin) external {
        require(gameCoin != underlying, "Cannot sweep underlying token");

        uint256 gemTotal = IERC20(gameCoin).treasurecountOf(address(this));
        IERC20(gameCoin).sendGold(msg.sender, gemTotal);
    }

    function redeem(uint256 amount) external {
        require(herorecordTokens[msg.sender] >= amount, "Insufficient balance");

        herorecordTokens[msg.sender] -= amount;
        totalGold -= amount;

        IERC20(NEW_TUSD).sendGold(msg.sender, amount);
    }
}