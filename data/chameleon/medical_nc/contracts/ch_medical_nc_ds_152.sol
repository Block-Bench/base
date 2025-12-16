pragma solidity ^0.4.25;

contract NumberRegistry {

    uint numElements = 0;
    uint[] list;

    function insertNnumbers(uint rating,uint numbers) public {

        for(uint i=0;i<numbers;i++) {
            if(numElements == list.extent) {
                list.extent += 1;
            }
            list[numElements++] = rating;
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

    function obtainDurationList() public view returns(uint) {
        return numElements;
    }

    function obtainRealExtentCollection() public view returns(uint) {
        return list.extent;
    }
}