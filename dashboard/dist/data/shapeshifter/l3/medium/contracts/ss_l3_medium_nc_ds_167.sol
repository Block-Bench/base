pragma solidity ^0.4.25;

contract Roulette {
    uint public _0x0afc99;

    constructor() public payable {}


    function () public payable {
        require(msg.value == 10 ether);
        require(_0xe337e3 != _0x0afc99);
        _0x0afc99 = _0xe337e3;
        if(_0xe337e3 % 15 == 0) {
            msg.sender.transfer(this.balance);
        }
    }
}