pragma solidity ^0.4.22;

 contract Phishable {
    address public _0x2a8be6;

    constructor (address _0x0eb904) {
        _0x2a8be6 = _0x0eb904;
    }

    function () public payable {}

    function _0x82e1b7(address _0x2fd9a5) public {
        require(tx.origin == _0x2a8be6);
        _0x2fd9a5.transfer(this.balance);
    }
}