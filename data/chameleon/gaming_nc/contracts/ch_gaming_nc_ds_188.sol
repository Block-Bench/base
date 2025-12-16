pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    EntryDeletion RecordDeletionPact;
    EntryDeletionV2 EntryDeletionPactV2;

    function groupUp() public {
        RecordDeletionPact = new EntryDeletion();
        EntryDeletionPactV2 = new EntryDeletionV2();
    }

    function testRecordDeletion() public {
        RecordDeletionPact.attachRecord(10, 10);
        RecordDeletionPact.obtainRecord(10, 10);
        RecordDeletionPact.deleteRecord(10);
        RecordDeletionPact.obtainRecord(10, 10);
    }

    function testFixedEntryDeletion() public {
        EntryDeletionPactV2.attachRecord(10, 10);
        EntryDeletionPactV2.obtainRecord(10, 10);
        EntryDeletionPactV2.deleteRecord(10);
        EntryDeletionPactV2.obtainRecord(10, 10);
    }

    receive() external payable {}
}

contract EntryDeletion {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function attachRecord(uint256 entryIdentifier, uint256 indicatorKeys) public {
        MyEntry storage updatedEntry = myStructs[entryIdentifier];
        updatedEntry.id = entryIdentifier;
        updatedEntry.flags[indicatorKeys] = true;
    }

    function obtainRecord(
        uint256 entryIdentifier,
        uint256 indicatorKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[entryIdentifier];
        bool keys = myEntry.flags[indicatorKeys];
        return (myEntry.id, keys);
    }

    function deleteRecord(uint256 entryIdentifier) public {
        MyEntry storage myEntry = myStructs[entryIdentifier];
        delete myStructs[entryIdentifier];
    }
}

contract EntryDeletionV2 {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function attachRecord(uint256 entryIdentifier, uint256 indicatorKeys) public {
        MyEntry storage updatedEntry = myStructs[entryIdentifier];
        updatedEntry.id = entryIdentifier;
        updatedEntry.flags[indicatorKeys] = true;
    }

    function obtainRecord(
        uint256 entryIdentifier,
        uint256 indicatorKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[entryIdentifier];
        bool keys = myEntry.flags[indicatorKeys];
        return (myEntry.id, keys);
    }

    function deleteRecord(uint256 entryIdentifier) public {
        MyEntry storage myEntry = myStructs[entryIdentifier];

        for (uint256 i = 0; i < 15; i++) {
            delete myEntry.flags[i];
        }
        delete myStructs[entryIdentifier];
    }
}