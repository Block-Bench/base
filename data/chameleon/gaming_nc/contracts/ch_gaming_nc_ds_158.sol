pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public bounty;

    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function collectionBounty() public payable {
        require (!claimed);

        require(msg.sender == owner);
        owner.transfer(bounty);
        bounty = msg.value;
    }

    function obtainrewardPrize(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.transfer(bounty);
        claimed = true;
    }
}