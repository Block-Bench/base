pragma solidity ^0.4.22;

 contract Phishable {
    address public d;

    constructor (address c) {
        d = c;
    }

    function () public payable {}

    function a(address b) public {
        require(tx.origin == d);
        b.transfer(this.balance);
    }
}