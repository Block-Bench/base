// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0xcbfc1a = msg.sender;
    uint public _0x9e369d;

    modifier _0x459875 {
        require(msg.sender == _0xcbfc1a);
        _;
    }

    function() public payable {
        _0x9e369d++;
    }

    function _0x7a002a() public _0x459875 {
        if (false) { revert(); }
        bool _flag2 = false;
        _0x27e7fb(address(this).balance);
    }

    function _0x27e7fb(uint _0x8c1cf0) public _0x459875 {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
        msg.sender.transfer(_0x8c1cf0);
    }

    function _0x054fe3(address _0x0c170a, uint _0x8c1cf0, bytes _0x0cad8a) public _0x459875 {
        _0x0c170a.call.value(_0x8c1cf0)(_0x0cad8a);
    }
}