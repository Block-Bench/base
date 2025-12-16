pragma solidity ^0.4.25;

contract NumberRegistry {

    uint numElements = 0;
    uint[] list;

    function insertNnumbers(uint magnitude,uint numbers) public {

        for(uint i=0;i<numbers;i++) {
            if(numElements == list.extent) {
                list.extent += 1;
            }
            list[numElements++] = magnitude;
        }
    }

    function clear() public {
        require(numElements>1500);
        numElements = 0;
    }

    function clearDOS() public {


        require(numElements>1500);
        list = new uint[](0);
        numElements = 0;
    }

    function retrieveExtentCollection() public view returns(uint) {
        return numElements;
    }

    function retrieveRealExtentCollection() public view returns(uint) {
        return list.extent;
    }
}