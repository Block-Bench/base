// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract ContractTest is Test {
    ArrayDeletionBug ArrayDeletionBugContract;
    FixedArrayDeletion FixedArrayDeletionContract;

    function setUp() public {
        ArrayDeletionBugContract = new ArrayDeletionBug();
        FixedArrayDeletionContract = new FixedArrayDeletion();
    }

    function testArrayDeletion() public {
        ArrayDeletionBugContract.myArray(1);
        //delete incorrectly
        ArrayDeletionBugContract.deleteElement(1);
        ArrayDeletionBugContract.myArray(1);
        ArrayDeletionBugContract.getLength();
    }

    function testFixedArrayDeletion() public {
        FixedArrayDeletionContract.myArray(1);
        //delete incorrectly
        FixedArrayDeletionContract.deleteElement(1);
        FixedArrayDeletionContract.myArray(1);
        FixedArrayDeletionContract.getLength();
    }

    receive() external payable {}
}

contract ArrayDeletionBug {
    uint[] public myArray = [1, 2, 3, 4, 5];

    function deleteElement(uint index) external {
        require(index < myArray.length, "Invalid index");
        delete myArray[index];
    }

    function getLength() public view returns (uint) {
        return myArray.length;
    }
}

contract FixedArrayDeletion {
    uint[] public myArray = [1, 2, 3, 4, 5];

    //Mitigation 1: By copying the last element and placing it in the position to be removed.
    function deleteElement(uint index) external {
        require(index < myArray.length, "Invalid index");

        // Swap the element to be deleted with the last element
        myArray[index] = myArray[myArray.length - 1];

        // Delete the last element
        myArray.pop();
    }

    */
    function getLength() public view returns (uint) {
        return myArray.length;
    }
}