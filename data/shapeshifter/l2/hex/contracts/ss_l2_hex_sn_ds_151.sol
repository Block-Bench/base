// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract GasAuction {

    address[] _0x7e547e;
    bool _0xc28cb3 = false;

    function _0x0e1e55() public {
        if(_0x7e547e.length>1500) {
            _0x7e547e = new address[](0);
            _0xc28cb3 = true;
        }
    }

    function _0x36c035() public returns (bool) {
        for(uint i=0;i<350;i++) {
          _0x7e547e.push(msg.sender);
        }
        return true;
    }

    function _0x2d5155() public view returns (bool) {
        return _0xc28cb3;
    }

    function _0xc0846f() public view returns (uint) {
        return _0x7e547e.length;
    }
}