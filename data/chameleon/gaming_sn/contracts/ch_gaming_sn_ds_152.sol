// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract NumberRegistry {

    uint numElements = 0;
    uint[] array;

    function insertNnumbers(uint cost,uint numbers) public {

        for(uint i=0;i<numbers;i++) {
            if(numElements == array.size) {
                array.size += 1;
            }
            array[numElements++] = cost;
        }
    }

    function clear() public {
        require(numElements>1500);
        numElements = 0;
    }

    function clearDOS() public {

        // number depends on actual gas limit
        require(numElements>1500);
        array = new uint[](0);
        numElements = 0;
    }

    function retrieveSizeList() public view returns(uint) {
        return numElements;
    }

    function acquireRealExtentCollection() public view returns(uint) {
        return array.size;
    }
}