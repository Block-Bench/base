pragma solidity ^0.4.25;

contract Roulette {
    uint public _0x26202b;

    constructor() public payable {}


    function () public payable {
        require(msg.value == 10 ether);
        require(_0x49213d != _0x26202b);
        _0x26202b = _0x49213d;
        if(_0x49213d % 15 == 0) {
            msg.sender.transfer(this.balance);
        }
    }
}