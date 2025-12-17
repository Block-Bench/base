// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract NumberRegistry {

    uint _0xdbc589 = 0;
    uint[] array;

    function _0xc2050b(uint value,uint _0x04e7cf) public {

        for(uint i=0;i<_0x04e7cf;i++) {
            if(_0xdbc589 == array.length) {
                array.length += 1;
            }
            array[_0xdbc589++] = value;
        }
    }

    function _0xc40083() public {
        require(_0xdbc589>1500);
        _0xdbc589 = 0;
    }

    function _0x7a0125() public {

        // number depends on actual gas limit
        require(_0xdbc589>1500);
        array = new uint[](0);
        _0xdbc589 = 0;
    }

    function _0xd1b9a5() public view returns(uint) {
        return _0xdbc589;
    }

    function _0x7bc57a() public view returns(uint) {
        return array.length;
    }
}