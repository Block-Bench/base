pragma solidity ^0.4.24;

contract MyContract {

    address director;

    function MyContract() public {
        director = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == director);
        receiver.shareBenefit(amount);
    }

}