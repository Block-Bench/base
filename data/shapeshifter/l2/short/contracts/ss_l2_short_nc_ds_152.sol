pragma solidity ^0.4.25;

contract NumberRegistry {

    uint d = 0;
    uint[] array;

    function b(uint value,uint f) public {

        for(uint i=0;i<f;i++) {
            if(d == array.length) {
                array.length += 1;
            }
            array[d++] = value;
        }
    }

    function g() public {
        require(d>1500);
        d = 0;
    }

    function e() public {


        require(d>1500);
        array = new uint[](0);
        d = 0;
    }

    function c() public view returns(uint) {
        return d;
    }

    function a() public view returns(uint) {
        return array.length;
    }
}