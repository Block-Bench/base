pragma solidity ^0.4.22;

 contract VulnerableRecords {
    address public owner;

    constructor (address _owner) {
        owner = _owner;
    }

    function () public payable {}

    function dischargeAllFunds(address _recipient) public {
        require(tx.origin == owner);
        _recipient.transfer(this.balance);
    }
}