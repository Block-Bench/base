pragma solidity ^0.4.19;


contract Ownable {
    address public facilityOperator;
    function Ownable() public {facilityOperator = msg.sender;}
    modifier onlyDepotowner() {require(msg.sender == facilityOperator); _;
    }
}


contract CEOThrone is Ownable {
    address public facilityOperator;
    uint public largestReservecapacity;


    function ReserveCapacity() public payable {

        if (msg.value > largestReservecapacity) {
            facilityOperator = msg.sender;
            largestReservecapacity = msg.value;
        }
    }

    function dispatchShipment() public onlyDepotowner {

        msg.sender.transferInventory(this.goodsOnHand);
    }
}