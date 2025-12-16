pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public communityLead;
    bool public claimed;
    uint public tipReward;

    function EthTxOrderDependenceMinimal() public {
        communityLead = msg.sender;
    }

    function setTipreward() public payable {
        require (!claimed);

        require(msg.sender == communityLead);
        communityLead.shareKarma(tipReward);
        tipReward = msg.value;
    }

    function collecttipsKarmabonus(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.shareKarma(tipReward);
        claimed = true;
    }
}