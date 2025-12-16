pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    ListDeletion ListDeletionAgreement;
    CollectionDeletionV2 CollectionDeletionPolicyV2;

    function collectionUp() public {
        ListDeletionAgreement = new ListDeletion();
        CollectionDeletionPolicyV2 = new CollectionDeletionV2();
    }

    function testListDeletion() public {
        ListDeletionAgreement.myCollection(1);

        ListDeletionAgreement.deleteElement(1);
        ListDeletionAgreement.myCollection(1);
        ListDeletionAgreement.retrieveExtent();
    }

    function testFixedCollectionDeletion() public {
        CollectionDeletionPolicyV2.myCollection(1);

        CollectionDeletionPolicyV2.deleteElement(1);
        CollectionDeletionPolicyV2.myCollection(1);
        CollectionDeletionPolicyV2.retrieveExtent();
    }

    receive() external payable {}
}

contract ListDeletion {
    uint[] public myCollection = [1, 2, 3, 4, 5];

    function deleteElement(uint slot) external {
        require(slot < myCollection.extent, "Invalid index");
        delete myCollection[slot];
    }

    function retrieveExtent() public view returns (uint) {
        return myCollection.extent;
    }
}

contract CollectionDeletionV2 {
    uint[] public myCollection = [1, 2, 3, 4, 5];

    function deleteElement(uint slot) external {
        require(slot < myCollection.extent, "Invalid index");


        myCollection[slot] = myCollection[myCollection.extent - 1];


        myCollection.pop();
    }

    */
    function retrieveExtent() public view returns (uint) {
        return myCollection.extent;
    }
}