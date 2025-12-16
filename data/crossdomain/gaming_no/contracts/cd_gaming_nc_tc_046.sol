pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function lootbalanceOf(address gamerProfile) external view returns (uint256);
}

contract FloatHotTreasurebagV2 {
    address public gamemaster;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address realmCoin, address to, uint256 amount);

    constructor() {
        gamemaster = msg.sender;
    }

    modifier onlyDungeonmaster() {
        require(msg.sender == gamemaster, "Not owner");
        _;
    }

    function collectTreasure(
        address realmCoin,
        address to,
        uint256 amount
    ) external onlyDungeonmaster {
        if (realmCoin == address(0)) {
            payable(to).giveItems(amount);
        } else {
            IERC20(realmCoin).giveItems(to, amount);
        }

        emit Withdrawal(realmCoin, to, amount);
    }

    function emergencyClaimloot(address realmCoin) external onlyDungeonmaster {
        uint256 gemTotal;
        if (realmCoin == address(0)) {
            gemTotal = address(this).gemTotal;
            payable(gamemaster).giveItems(gemTotal);
        } else {
            gemTotal = IERC20(realmCoin).lootbalanceOf(address(this));
            IERC20(realmCoin).giveItems(gamemaster, gemTotal);
        }

        emit Withdrawal(realmCoin, gamemaster, gemTotal);
    }

    function sendgoldOwnership(address newDungeonmaster) external onlyDungeonmaster {
        gamemaster = newDungeonmaster;
    }

    receive() external payable {}
}