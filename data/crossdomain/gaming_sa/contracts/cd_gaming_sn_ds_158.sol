// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public guildLeader;
    bool public claimed;
    uint public victoryBonus;

    function EthTxOrderDependenceMinimal() public {
        guildLeader = msg.sender;
    }

    function setLootreward() public payable {
        require (!claimed);

        require(msg.sender == guildLeader);
        guildLeader.giveItems(victoryBonus);
        victoryBonus = msg.value;
    }

    function earnpointsBattleprize(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.giveItems(victoryBonus);
        claimed = true;
    }
}