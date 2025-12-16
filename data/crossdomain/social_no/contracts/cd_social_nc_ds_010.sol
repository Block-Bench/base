pragma solidity ^0.4.24;

contract MyContract {

    address admin;

    function MyContract() public {
        admin = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == admin);
        receiver.giveCredit(amount);
    }

}