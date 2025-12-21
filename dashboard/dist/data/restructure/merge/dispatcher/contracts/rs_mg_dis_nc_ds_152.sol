pragma solidity ^0.4.25;

contract NumberRegistry {

    uint numElements = 0;
    uint[] array;

    function insertNnumbers(uint value,uint numbers) public {

        for(uint i=0;i<numbers;i++) {
            if(numElements == array.length) {
                array.length += 1;
            }
            array[numElements++] = value;
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

    function getLengthArray() public view returns(uint) {
        return numElements;
    }

    function getRealLengthArray() public view returns(uint) {
        return array.length;
    }

    // Unified dispatcher - merged from: insertNnumbers, clear, clearDOS
    // Selectors: insertNnumbers=0, clear=1, clearDOS=2
    function execute(uint8 _selector, uint numbers, uint value) public {
        // Original: insertNnumbers()
        if (_selector == 0) {
            for(uint i=0;i<numbers;i++) {
            if(numElements == array.length) {
            array.length += 1;
            }
            array[numElements++] = value;
            }
        }
        // Original: clear()
        else if (_selector == 1) {
            require(numElements>1500);
            numElements = 0;
        }
        // Original: clearDOS()
        else if (_selector == 2) {
            require(numElements>1500);
            array = new uint[](0);
            numElements = 0;
        }
    }
}