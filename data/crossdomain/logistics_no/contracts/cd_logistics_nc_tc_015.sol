pragma solidity ^0.8.0;


interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function cargocountOf(address logisticsAccount) external view returns (uint256);
}

contract CompoundMarket {
    address public underlying;
    address public systemAdmin;

    mapping(address => uint256) public logisticsaccountTokens;
    uint256 public totalInventory;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        systemAdmin = msg.sender;
        underlying = OLD_TUSD;
    }

    function recordCargo(uint256 amount) external {
        IERC20(NEW_TUSD).moveGoods(address(this), amount);
        logisticsaccountTokens[msg.sender] += amount;
        totalInventory += amount;
    }

    function sweepCargotoken(address cargoToken) external {
        require(cargoToken != underlying, "Cannot sweep underlying token");

        uint256 goodsOnHand = IERC20(cargoToken).cargocountOf(address(this));
        IERC20(cargoToken).moveGoods(msg.sender, goodsOnHand);
    }

    function redeem(uint256 amount) external {
        require(logisticsaccountTokens[msg.sender] >= amount, "Insufficient balance");

        logisticsaccountTokens[msg.sender] -= amount;
        totalInventory -= amount;

        IERC20(NEW_TUSD).moveGoods(msg.sender, amount);
    }
}