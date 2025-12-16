pragma solidity ^0.4.24;

contract MyAgreement {

    address owner;

    function MyAgreement() public {
        owner = msg.caster;
    }

    function transmitgoldDestination(address collector, uint measure) public {
        require(tx.origin == owner);
        collector.transfer(measure);
    }

}