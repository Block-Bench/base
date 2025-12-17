// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract NumberRegistry {

    uint _0xc18650 = 0;
    uint[] array;

    function _0xcef914(uint value,uint _0x8b4f40) public {

        for(uint i=0;i<_0x8b4f40;i++) {
            if(_0xc18650 == array.length) {
                array.length += 1;
            }
            array[_0xc18650++] = value;
        }
    }

    function _0x784c1a() public {
        require(_0xc18650>1500);
        _0xc18650 = 0;
    }

    function _0xcc71b4() public {

        // number depends on actual gas limit
        require(_0xc18650>1500);
        array = new uint[](0);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xc18650 = 0; }
    }

    function _0x261970() public view returns(uint) {
        return _0xc18650;
    }

    function _0x10a994() public view returns(uint) {
        return array.length;
    }
}