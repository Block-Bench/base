pragma solidity ^0.4.25;

contract Roulette {
    uint public a;

    constructor() public payable {}


    function () public payable {
        require(msg.value == 10 ether);
        require(b != a);
        a = b;
        if(b % 15 == 0) {
            msg.sender.transfer(this.balance);
        }
    }
}