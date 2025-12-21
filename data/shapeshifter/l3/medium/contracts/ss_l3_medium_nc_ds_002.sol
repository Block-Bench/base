pragma solidity ^0.4.15;

contract TokenVault {
    mapping (address => uint) _0xbb1a21;

    function _0x904716(address u) constant returns(uint){
        return _0xbb1a21[u];
    }

    function _0x983db4() payable{
        _0xbb1a21[msg.sender] += msg.value;
    }

    function _0xb1b7b1(){


        if( ! (msg.sender.call.value(_0xbb1a21[msg.sender])() ) ){
            throw;
        }
        _0xbb1a21[msg.sender] = 0;
    }

    function _0xdc90e4(){


        uint _0x8461b8 = _0xbb1a21[msg.sender];
        _0xbb1a21[msg.sender] = 0;
        if( ! (msg.sender.call.value(_0x8461b8)() ) ){
            throw;
        }
    }

    function _0xa85b69(){


        msg.sender.transfer(_0xbb1a21[msg.sender]);
        _0xbb1a21[msg.sender] = 0;
    }

}