// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract NumberRegistry {

    uint _0x2f9d1e = 0;
    uint[] array;

    function _0xc861ef(uint value,uint _0xcdf614) public {

        for(uint i=0;i<_0xcdf614;i++) {
            if(_0x2f9d1e == array.length) {
                array.length += 1;
            }
            array[_0x2f9d1e++] = value;
        }
    }

    function _0x45fdb2() public {
        require(_0x2f9d1e>1500);
        _0x2f9d1e = 0;
    }

    function _0x85195a() public {

        // number depends on actual gas limit
        require(_0x2f9d1e>1500);
        array = new uint[](0);
        _0x2f9d1e = 0;
    }

    function _0xd6d14f() public view returns(uint) {
        return _0x2f9d1e;
    }

    function _0x729ebb() public view returns(uint) {
        return array.length;
    }
}