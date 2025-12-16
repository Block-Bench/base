// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    ListDeletion ListDeletionPolicy;
    ListDeletionV2 ListDeletionAgreementV2;

    function groupUp() public {
        ListDeletionPolicy = new ListDeletion();
        ListDeletionAgreementV2 = new ListDeletionV2();
    }

    function testListDeletion() public {
        ListDeletionPolicy.myCollection(1);
        //delete incorrectly
        ListDeletionPolicy.deleteElement(1);
        ListDeletionPolicy.myCollection(1);
        ListDeletionPolicy.obtainDuration();
    }

    function testFixedListDeletion() public {
        ListDeletionAgreementV2.myCollection(1);
        //delete incorrectly
        ListDeletionAgreementV2.deleteElement(1);
        ListDeletionAgreementV2.myCollection(1);
        ListDeletionAgreementV2.obtainDuration();
    }

    receive() external payable {}
}

contract ListDeletion {
    uint[] public myCollection = [1, 2, 3, 4, 5];

    function deleteElement(uint position) external {
        require(position < myCollection.extent, "Invalid index");
        delete myCollection[position];
    }

    function obtainDuration() public view returns (uint) {
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

    function obtainDuration() public view returns (uint) {
        return myCollection.extent;
    }
}
