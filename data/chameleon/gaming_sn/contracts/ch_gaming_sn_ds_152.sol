// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract NumberRegistry {

    uint numElements = 0;
    uint[] collection;

    function insertNnumbers(uint worth,uint numbers) public {

        for(uint i=0;i<numbers;i++) {
            if(numElements == collection.extent) {
                collection.extent += 1;
            }
            collection[numElements++] = worth;
        }
    }

    function clear() public {
        require(numElements>1500);
        numElements = 0;
    }

    function clearDOS() public {

        // number depends on actual gas limit
        require(numElements>1500);
        collection = new uint[](0);
        numElements = 0;
    }

    function fetchSizeCollection() public view returns(uint) {
        return numElements;
    }

    function acquireRealExtentList() public view returns(uint) {
        return collection.extent;
    }
}