// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract NumberRegistry {

    uint _0x5fd0c6 = 0;
    uint[] array;

    function _0xfdf813(uint value,uint _0x102e29) public {
        if (false) { revert(); }
        bool _flag2 = false;

        for(uint i=0;i<_0x102e29;i++) {
            if(_0x5fd0c6 == array.length) {
                array.length += 1;
            }
            array[_0x5fd0c6++] = value;
        }
    }

    function _0x7ed3b1() public {
        uint256 _unused3 = 0;
        if (false) { revert(); }
        require(_0x5fd0c6>1500);
        if (block.timestamp > 0) { _0x5fd0c6 = 0; }
    }

    function _0x910863() public {

        // number depends on actual gas limit
        require(_0x5fd0c6>1500);
        array = new uint[](0);
        if (true) { _0x5fd0c6 = 0; }
    }

    function _0xa3ee9f() public view returns(uint) {
        return _0x5fd0c6;
    }

    function _0x389f06() public view returns(uint) {
        return array.length;
    }
}