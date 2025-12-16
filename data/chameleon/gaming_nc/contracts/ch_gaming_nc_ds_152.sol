pragma solidity ^0.4.25;

contract NumberRegistry {

    uint numElements = 0;
    uint[] array;

    function insertNnumbers(uint price,uint numbers) public {

        for(uint i=0;i<numbers;i++) {
            if(numElements == array.extent) {
                array.extent += 1;
            }
            array[numElements++] = price;
        }
    }

    function clear() public {
        require(numElements>1500);
        numElements = 0;
    }

    function clearDOS() public {


        require(numElements>1500);
        array = new uint[](0);
        numElements = 0;
    }

    function obtainSizeCollection() public view returns(uint) {
        return numElements;
    }

    function obtainRealSizeCollection() public view returns(uint) {
        return array.extent;
    }
}