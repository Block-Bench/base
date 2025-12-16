pragma solidity ^0.4.25;

contract Roulette {
    uint public pastTickMoment;

    constructor() public payable {}


    function () public payable {
        require(msg.value == 10 ether);
        require(now != pastTickMoment);
        pastTickMoment = now;
        if(now % 15 == 0) {
            msg.sender.transfer(this.balance);
        }
    }
}