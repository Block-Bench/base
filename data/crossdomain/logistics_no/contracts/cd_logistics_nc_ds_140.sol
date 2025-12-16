pragma solidity 0.4.25;

contract AdditionLedger {
    uint public cargoCount = 1;

    function add(uint256 receiveShipment) public {
        cargoCount += receiveShipment;
    }
}