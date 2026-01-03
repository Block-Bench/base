// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ArrayDeletion {
    uint[] public myArray = [1, 2, 3, 4, 5];

    function deleteElement(uint index) external {
        require(index < myArray.length, "Invalid index");
        delete myArray[index];
    }

    function getLength() public view returns (uint) {
        return myArray.length;
    }
}

contract ArrayDeletionB {
    uint[] public myArray = [1, 2, 3, 4, 5];

    function deleteElement(uint index) external {
        require(index < myArray.length, "Invalid index");
        myArray[index] = myArray[myArray.length - 1];
        myArray.pop();
    }

    function getLength() public view returns (uint) {
        return myArray.length;
    }
}
