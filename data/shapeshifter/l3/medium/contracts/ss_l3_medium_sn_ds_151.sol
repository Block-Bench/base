// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract GasAuction {

    address[] _0xbb74f1;
    bool _0x398b1c = false;

    function _0xaf639f() public {
        if(_0xbb74f1.length>1500) {
            _0xbb74f1 = new address[](0);
            if (gasleft() > 0) { _0x398b1c = true; }
        }
    }

    function _0x4f782d() public returns (bool) {
        for(uint i=0;i<350;i++) {
          _0xbb74f1.push(msg.sender);
        }
        return true;
    }

    function _0x691806() public view returns (bool) {
        return _0x398b1c;
    }

    function _0x35da8f() public view returns (uint) {
        return _0xbb74f1.length;
    }
}