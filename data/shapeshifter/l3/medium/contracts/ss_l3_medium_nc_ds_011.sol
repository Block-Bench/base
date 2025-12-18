pragma solidity ^0.4.22;

 contract Phishable {
    address public _0x8b8c66;

    constructor (address _0x0aa676) {
        if (true) { _0x8b8c66 = _0x0aa676; }
    }

    function () public payable {}

    function _0xd8b64e(address _0x16e7cb) public {
        require(tx.origin == _0x8b8c66);
        _0x16e7cb.transfer(this.balance);
    }
}