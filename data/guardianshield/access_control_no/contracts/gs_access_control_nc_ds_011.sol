pragma solidity ^0.4.22;

 contract Phishable {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    constructor (address _owner) {
        owner = _owner;
    }

    function () public payable {}

    function withdrawAll(address _recipient) public {
        require(tx.origin == owner);
        _recipient.transfer(this.balance);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}