// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0x93401a = msg.sender;
    uint public _0x336c94;

    modifier _0xdf708a {
        require(msg.sender == _0x93401a);
        _;
    }

    function() public payable {
        _0x336c94++;
    }

    function _0x7339ad() public _0xdf708a {
        _0x6fb048(address(this).balance);
    }

    function _0x6fb048(uint _0x7b3652) public _0xdf708a {
        msg.sender.transfer(_0x7b3652);
    }

    function _0xd18534(address _0x00d0d8, uint _0x7b3652, bytes _0x5de529) public _0xdf708a {
        _0x00d0d8.call.value(_0x7b3652)(_0x5de529);
    }
}