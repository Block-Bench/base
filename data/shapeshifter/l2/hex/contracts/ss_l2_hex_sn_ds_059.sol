// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0x3b54b3 = msg.sender;
    uint public _0xe9703c;

    modifier _0xdd2f2f {
        require(msg.sender == _0x3b54b3);
        _;
    }

    function() public payable {
        _0xe9703c++;
    }

    function _0x2fd1c3() public _0xdd2f2f {
        _0x778bd0(address(this).balance);
    }

    function _0x778bd0(uint _0xc21574) public _0xdd2f2f {
        msg.sender.transfer(_0xc21574);
    }

    function _0xcef323(address _0xc8d97e, uint _0xc21574, bytes _0xad548a) public _0xdd2f2f {
        _0xc8d97e.call.value(_0xc21574)(_0xad548a);
    }
}