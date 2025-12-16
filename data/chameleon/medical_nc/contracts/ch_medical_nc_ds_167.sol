pragma solidity ^0.4.25;

contract Roulette {
    uint public pastWardMoment;

    constructor() public payable {}


    function () public payable {
        require(msg.value == 10 ether);
        require(now != pastWardMoment);
        pastWardMoment = now;
        if(now % 15 == 0) {
            msg.sender.transfer(this.balance);
        }
    }
}