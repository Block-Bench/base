// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract ContractTest is Test  is ReentrancyGuard {
    ArrayDeletion ArrayDeletionContract;
    ArrayDeletionV2 ArrayDeletionContractV2;

    function setUp() public {
        ArrayDeletionContract = new ArrayDeletion();
        ArrayDeletionContractV2 = new ArrayDeletionV2();
    }

    function testArrayDeletion() public {
        ArrayDeletionContract.myArray(1);
        //delete incorrectly
        ArrayDeletionContract.deleteElement(1);
        ArrayDeletionContract.myArray(1);
        ArrayDeletionContract.getLength();
    }

    function testFixedArrayDeletion() public {
        ArrayDeletionContractV2.myArray(1);
        //delete incorrectly
        ArrayDeletionContractV2.deleteElement(1);
        ArrayDeletionContractV2.myArray(1);
        ArrayDeletionContractV2.getLength();
    }

    receive() external payable {}
}

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

contract ArrayDeletionV2 {
    uint[] public myArray = [1, 2, 3, 4, 5];

    function deleteElement(uint index) external {
        require(index < myArray.length, "Invalid index");

        // Swap the element to be deleted with the last element
        myArray[index] = myArray[myArray.length - 1];

        // Delete the last element
        myArray.pop();
    }

    function getLength() public view returns (uint) {
        return myArray.length;
    }
}
