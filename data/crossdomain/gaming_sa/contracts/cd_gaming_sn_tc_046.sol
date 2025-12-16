// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function goldholdingOf(address playerAccount) external view returns (uint256);
}

contract FloatHotInventoryV2 {
    address public guildLeader;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address gameCoin, address to, uint256 amount);

    constructor() {
        guildLeader = msg.sender;
    }

    modifier onlyDungeonmaster() {
        require(msg.sender == guildLeader, "Not owner");
        _;
    }

    function collectTreasure(
        address gameCoin,
        address to,
        uint256 amount
    ) external onlyDungeonmaster {
        if (gameCoin == address(0)) {
            payable(to).shareTreasure(amount);
        } else {
            IERC20(gameCoin).shareTreasure(to, amount);
        }

        emit Withdrawal(gameCoin, to, amount);
    }

    function emergencyCollecttreasure(address gameCoin) external onlyDungeonmaster {
        uint256 treasureCount;
        if (gameCoin == address(0)) {
            treasureCount = address(this).treasureCount;
            payable(guildLeader).shareTreasure(treasureCount);
        } else {
            treasureCount = IERC20(gameCoin).goldholdingOf(address(this));
            IERC20(gameCoin).shareTreasure(guildLeader, treasureCount);
        }

        emit Withdrawal(gameCoin, guildLeader, treasureCount);
    }

    function sharetreasureOwnership(address newGuildleader) external onlyDungeonmaster {
        guildLeader = newGuildleader;
    }

    receive() external payable {}
}
