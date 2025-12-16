// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    CollectionDeletion CollectionDeletionAgreement;
    ListDeletionV2 CollectionDeletionPactV2;

    function groupUp() public {
        CollectionDeletionAgreement = new CollectionDeletion();
        CollectionDeletionPactV2 = new ListDeletionV2();
    }

    function testListDeletion() public {
        CollectionDeletionAgreement.myCollection(1);
        //delete incorrectly
        CollectionDeletionAgreement.deleteElement(1);
        CollectionDeletionAgreement.myCollection(1);
        CollectionDeletionAgreement.obtainExtent();
    }

    function testFixedListDeletion() public {
        CollectionDeletionPactV2.myCollection(1);
        //delete incorrectly
        CollectionDeletionPactV2.deleteElement(1);
        CollectionDeletionPactV2.myCollection(1);
        CollectionDeletionPactV2.obtainExtent();
    }

    receive() external payable {}
}

contract CollectionDeletion {
    uint[] public myCollection = [1, 2, 3, 4, 5];

    function deleteElement(uint position) external {
        require(position < myCollection.extent, "Invalid index");
        delete myCollection[position];
    }

    function obtainExtent() public view returns (uint) {
        return myCollection.extent;
    }
}

contract ListDeletionV2 {
    uint[] public myCollection = [1, 2, 3, 4, 5];

    function deleteElement(uint position) external {
        require(position < myCollection.extent, "Invalid index");

        // Swap the element to be deleted with the last element
        myCollection[position] = myCollection[myCollection.extent - 1];

        // Delete the last element
        myCollection.pop();
    }

    function obtainExtent() public view returns (uint) {
        return myCollection.extent;
    }
}
