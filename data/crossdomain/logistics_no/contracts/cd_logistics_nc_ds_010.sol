pragma solidity ^0.4.24;

contract MyContract {

    address facilityOperator;

    function MyContract() public {
        facilityOperator = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == facilityOperator);
        receiver.transferInventory(amount);
    }

}