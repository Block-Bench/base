// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    EntryDeletion RecordDeletionPact;
    RecordDeletionV2 EntryDeletionAgreementV2;

    function collectionUp() public {
        RecordDeletionPact = new EntryDeletion();
        EntryDeletionAgreementV2 = new RecordDeletionV2();
    }

    function testEntryDeletion() public {
        RecordDeletionPact.appendRecord(10, 10);
        RecordDeletionPact.retrieveEntry(10, 10);
        RecordDeletionPact.deleteEntry(10);
        RecordDeletionPact.retrieveEntry(10, 10);
    }

    function testFixedRecordDeletion() public {
        EntryDeletionAgreementV2.appendRecord(10, 10);
        EntryDeletionAgreementV2.retrieveEntry(10, 10);
        EntryDeletionAgreementV2.deleteEntry(10);
        EntryDeletionAgreementV2.retrieveEntry(10, 10);
    }

    receive() external payable {}
}

contract EntryDeletion {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function appendRecord(uint256 entryCode, uint256 markerKeys) public {
        MyRecord storage currentEntry = myStructs[entryCode];
        currentEntry.id = entryCode;
        currentEntry.flags[markerKeys] = true;
    }

    function retrieveEntry(
        uint256 entryCode,
        uint256 markerKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myRecord = myStructs[entryCode];
        bool keys = myRecord.flags[markerKeys];
        return (myRecord.id, keys);
    }

    function deleteEntry(uint256 entryCode) public {
        MyRecord storage myRecord = myStructs[entryCode];
        delete myStructs[entryCode];
    }
}

contract RecordDeletionV2 {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function appendRecord(uint256 entryCode, uint256 markerKeys) public {
        MyRecord storage currentEntry = myStructs[entryCode];
        currentEntry.id = entryCode;
        currentEntry.flags[markerKeys] = true;
    }

    function retrieveEntry(
        uint256 entryCode,
        uint256 markerKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myRecord = myStructs[entryCode];
        bool keys = myRecord.flags[markerKeys];
        return (myRecord.id, keys);
    }

    function deleteEntry(uint256 entryCode) public {
        MyRecord storage myRecord = myStructs[entryCode];
        // Check if all flags are deleted, then delete the mapping
        for (uint256 i = 0; i < 15; i++) {
            delete myRecord.flags[i];
        }
        delete myStructs[entryCode];
    }
}
