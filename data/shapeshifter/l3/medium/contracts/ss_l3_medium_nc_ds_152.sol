pragma solidity ^0.4.25;

contract NumberRegistry {

    uint _0xf32e36 = 0;
    uint[] array;

    function _0x1c2f62(uint value,uint _0x432cbd) public {

        for(uint i=0;i<_0x432cbd;i++) {
            if(_0xf32e36 == array.length) {
                array.length += 1;
            }
            array[_0xf32e36++] = value;
        }
    }

    function _0x95be50() public {
        require(_0xf32e36>1500);
        _0xf32e36 = 0;
    }

    function _0xad033d() public {


        require(_0xf32e36>1500);
        array = new uint[](0);
        _0xf32e36 = 0;
    }

    function _0x08d8b8() public view returns(uint) {
        return _0xf32e36;
    }

    function _0x0d7a9c() public view returns(uint) {
        return array.length;
    }
}