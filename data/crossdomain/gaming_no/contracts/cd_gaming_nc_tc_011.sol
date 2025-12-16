pragma solidity ^0.8.0;


interface IERC777 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function lootbalanceOf(address playerAccount) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address playerAccount,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract QuestcreditLootpool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 goldToken = IERC777(asset);

        require(goldToken.giveItems(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function retrieveItems(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 championItemcount = supplied[msg.sender][asset];
        require(championItemcount > 0, "No balance");

        uint256 takeprizeAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            takeprizeAmount = championItemcount;
        }
        require(takeprizeAmount <= championItemcount, "Insufficient balance");

        IERC777(asset).giveItems(msg.sender, takeprizeAmount);

        supplied[msg.sender][asset] -= takeprizeAmount;
        totalSupplied[asset] -= takeprizeAmount;

        return takeprizeAmount;
    }

    function getSupplied(
        address champion,
        address asset
    ) external view returns (uint256) {
        return supplied[champion][asset];
    }
}