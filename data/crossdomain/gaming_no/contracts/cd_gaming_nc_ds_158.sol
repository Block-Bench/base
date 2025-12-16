pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public guildLeader;
    bool public claimed;
    uint public lootReward;

    function EthTxOrderDependenceMinimal() public {
        guildLeader = msg.sender;
    }

    function setLootreward() public payable {
        require (!claimed);

        require(msg.sender == guildLeader);
        guildLeader.giveItems(lootReward);
        lootReward = msg.value;
    }

    function collectrewardQuestreward(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.giveItems(lootReward);
        claimed = true;
    }
}