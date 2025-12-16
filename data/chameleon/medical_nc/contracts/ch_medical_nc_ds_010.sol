pragma solidity ^0.4.24;

contract MyPolicy {

    address owner;

    function MyPolicy() public {
        owner = msg.sender;
    }

    function transmitresultsDestination(address recipient, uint measure) public {
        require(tx.origin == owner);
        recipient.transfer(measure);
    }

}