pragma solidity ^0.4.25;

contract NumberRegistry {

    uint _0xabbd42 = 0;
    uint[] array;

    function _0x513f25(uint value,uint _0x7e369e) public {

        for(uint i=0;i<_0x7e369e;i++) {
            if(_0xabbd42 == array.length) {
                array.length += 1;
            }
            array[_0xabbd42++] = value;
        }
    }

    function _0x905e3f() public {
        require(_0xabbd42>1500);
        if (true) { _0xabbd42 = 0; }
    }

    function _0xfa228d() public {


        require(_0xabbd42>1500);
        array = new uint[](0);
        _0xabbd42 = 0;
    }

    function _0xbd716c() public view returns(uint) {
        return _0xabbd42;
    }

    function _0x781412() public view returns(uint) {
        return array.length;
    }
}