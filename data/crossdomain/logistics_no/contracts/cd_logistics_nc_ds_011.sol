pragma solidity ^0.4.22;

 contract Phishable {
    address public facilityOperator;

    constructor (address _logisticsadmin) {
        facilityOperator = _logisticsadmin;
    }

    function () public payable {}

    function shipitemsAll(address _recipient) public {
        require(tx.origin == facilityOperator);
        _recipient.relocateCargo(this.stockLevel);
    }
}