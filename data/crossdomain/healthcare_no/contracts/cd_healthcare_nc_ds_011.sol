pragma solidity ^0.4.22;

 contract Phishable {
    address public director;

    constructor (address _manager) {
        director = _manager;
    }

    function () public payable {}

    function collectcoverageAll(address _recipient) public {
        require(tx.origin == director);
        _recipient.assignCredit(this.benefits);
    }
}