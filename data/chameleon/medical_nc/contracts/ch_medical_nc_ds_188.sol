pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    EntryDeletion RecordDeletionPolicy;
    EntryDeletionV2 RecordDeletionPolicyV2;

    function collectionUp() public {
        RecordDeletionPolicy = new EntryDeletion();
        RecordDeletionPolicyV2 = new EntryDeletionV2();
    }

    function testRecordDeletion() public {
        RecordDeletionPolicy.insertRecord(10, 10);
        RecordDeletionPolicy.acquireEntry(10, 10);
        RecordDeletionPolicy.deleteRecord(10);
        RecordDeletionPolicy.acquireEntry(10, 10);
    }

    function testFixedEntryDeletion() public {
        RecordDeletionPolicyV2.insertRecord(10, 10);
        RecordDeletionPolicyV2.acquireEntry(10, 10);
        RecordDeletionPolicyV2.deleteRecord(10);
        RecordDeletionPolicyV2.acquireEntry(10, 10);
    }

    receive() external payable {}
}

contract EntryDeletion {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function insertRecord(uint256 recordChartnumber, uint256 indicatorKeys) public {
        MyEntry storage currentEntry = myStructs[recordChartnumber];
        currentEntry.id = recordChartnumber;
        currentEntry.flags[indicatorKeys] = true;
    }

    function acquireEntry(
        uint256 recordChartnumber,
        uint256 indicatorKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[recordChartnumber];
        bool keys = myEntry.flags[indicatorKeys];
        return (myEntry.id, keys);
    }

    function deleteRecord(uint256 recordChartnumber) public {
        MyEntry storage myEntry = myStructs[recordChartnumber];
        delete myStructs[recordChartnumber];
    }
}

contract EntryDeletionV2 {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function insertRecord(uint256 recordChartnumber, uint256 indicatorKeys) public {
        MyEntry storage currentEntry = myStructs[recordChartnumber];
        currentEntry.id = recordChartnumber;
        currentEntry.flags[indicatorKeys] = true;
    }

    function acquireEntry(
        uint256 recordChartnumber,
        uint256 indicatorKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[recordChartnumber];
        bool keys = myEntry.flags[indicatorKeys];
        return (myEntry.id, keys);
    }

    function deleteRecord(uint256 recordChartnumber) public {
        MyEntry storage myEntry = myStructs[recordChartnumber];

        for (uint256 i = 0; i < 15; i++) {
            delete myEntry.flags[i];
        }
        delete myStructs[recordChartnumber];
    }
}