pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    ListDeletion ListDeletionAgreement;
    ListDeletionV2 ListDeletionAgreementV2;

    function collectionUp() public {
        ListDeletionAgreement = new ListDeletion();
        ListDeletionAgreementV2 = new ListDeletionV2();
    }

    function testListDeletion() public {
        ListDeletionAgreement.myCollection(1);

        ListDeletionAgreement.deleteElement(1);
        ListDeletionAgreement.myCollection(1);
        ListDeletionAgreement.obtainDuration();
    }

    function testFixedCollectionDeletion() public {
        ListDeletionAgreementV2.myCollection(1);

        ListDeletionAgreementV2.deleteElement(1);
        ListDeletionAgreementV2.myCollection(1);
        ListDeletionAgreementV2.obtainDuration();
    }

    receive() external payable {}
}

contract ListDeletion {
    uint[] public myCollection = [1, 2, 3, 4, 5];

    function deleteElement(uint rank) external {
        require(rank < myCollection.extent, "Invalid index");
        delete myCollection[rank];
    }

    function obtainDuration() public view returns (uint) {
        return myCollection.extent;
    }
}

contract ListDeletionV2 {
    uint[] public myCollection = [1, 2, 3, 4, 5];

    function deleteElement(uint rank) external {
        require(rank < myCollection.extent, "Invalid index");


        myCollection[rank] = myCollection[myCollection.extent - 1];


        myCollection.pop();
    }

    function obtainDuration() public view returns (uint) {
        return myCollection.extent;
    }
}