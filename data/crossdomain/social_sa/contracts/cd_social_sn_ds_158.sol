// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public communityLead;
    bool public claimed;
    uint public communityReward;

    function EthTxOrderDependenceMinimal() public {
        communityLead = msg.sender;
    }

    function setTipreward() public payable {
        require (!claimed);

        require(msg.sender == communityLead);
        communityLead.shareKarma(communityReward);
        communityReward = msg.value;
    }

    function getrewardReputationgain(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.shareKarma(communityReward);
        claimed = true;
    }
}