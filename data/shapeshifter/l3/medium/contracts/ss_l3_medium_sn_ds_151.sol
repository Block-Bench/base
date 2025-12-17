// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract GasAuction {

    address[] _0x6cf68d;
    bool _0xc9e4ba = false;

    function _0x84eb19() public {
        if(_0x6cf68d.length>1500) {
            _0x6cf68d = new address[](0);
            _0xc9e4ba = true;
        }
    }

    function _0xcb995c() public returns (bool) {
        for(uint i=0;i<350;i++) {
          _0x6cf68d.push(msg.sender);
        }
        return true;
    }

    function _0xd0c4e7() public view returns (bool) {
        return _0xc9e4ba;
    }

    function _0x21d44b() public view returns (uint) {
        return _0x6cf68d.length;
    }
}