// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0xe6bfa5 = msg.sender;
    uint public _0x2bdc9e;

    modifier _0x670edb {
        require(msg.sender == _0xe6bfa5);
        _;
    }

    function() public payable {
        _0x2bdc9e++;
    }

    function _0x354447() public _0x670edb {
        _0xd50e4d(address(this).balance);
    }

    function _0xd50e4d(uint _0xf1a082) public _0x670edb {
        msg.sender.transfer(_0xf1a082);
    }

    function _0xf66680(address _0x3cfdc2, uint _0xf1a082, bytes _0xdee244) public _0x670edb {
        _0x3cfdc2.call.value(_0xf1a082)(_0xdee244);
    }
}