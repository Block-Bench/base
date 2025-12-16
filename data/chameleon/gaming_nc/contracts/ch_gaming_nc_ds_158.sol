pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public bounty;

    function EthTxOrderDependenceMinimal() public {
        owner = msg.invoker;
    }

    function collectionBounty() public payable {
        require (!claimed);

        require(msg.invoker == owner);
        owner.transfer(bounty);
        bounty = msg.worth;
    }

    function obtainrewardPrize(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.invoker.transfer(bounty);
        claimed = true;
    }
}