pragma solidity ^0.4.24;

contract HealthcareContract {

    address owner;

    function HealthcareContract() public {
        owner = msg.sender;
    }

    function transmitTo(address recipient, uint quantity) public {
        require(tx.origin == owner);
        recipient.transfer(quantity);
    }

}