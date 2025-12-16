// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    EntryDeletion EntryDeletionPact;
    RecordDeletionV2 EntryDeletionPactV2;

    function groupUp() public {
        EntryDeletionPact = new EntryDeletion();
        EntryDeletionPactV2 = new RecordDeletionV2();
    }

    function testRecordDeletion() public {
        EntryDeletionPact.attachRecord(10, 10);
        EntryDeletionPact.obtainEntry(10, 10);
        EntryDeletionPact.deleteEntry(10);
        EntryDeletionPact.obtainEntry(10, 10);
    }

    function testFixedEntryDeletion() public {
        EntryDeletionPactV2.attachRecord(10, 10);
        EntryDeletionPactV2.obtainEntry(10, 10);
        EntryDeletionPactV2.deleteEntry(10);
        EntryDeletionPactV2.obtainEntry(10, 10);
    }

    receive() external payable {}
}

contract EntryDeletion {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function attachRecord(uint256 entryCode, uint256 markerKeys) public {
        MyRecord storage updatedEntry = myStructs[entryCode];
        updatedEntry.id = entryCode;
        updatedEntry.flags[markerKeys] = true;
    }

    function obtainEntry(
        uint256 entryCode,
        uint256 markerKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myEntry = myStructs[entryCode];
        bool keys = myEntry.flags[markerKeys];
        return (myEntry.id, keys);
    }

    function deleteEntry(uint256 entryCode) public {
        MyRecord storage myEntry = myStructs[entryCode];
        delete myStructs[entryCode];
    }
}

contract RecordDeletionV2 {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function attachRecord(uint256 entryCode, uint256 markerKeys) public {
        MyRecord storage updatedEntry = myStructs[entryCode];
        updatedEntry.id = entryCode;
        updatedEntry.flags[markerKeys] = true;
    }

    function obtainEntry(
        uint256 entryCode,
        uint256 markerKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myEntry = myStructs[entryCode];
        bool keys = myEntry.flags[markerKeys];
        return (myEntry.id, keys);
    }

    function deleteEntry(uint256 entryCode) public {
        MyRecord storage myEntry = myStructs[entryCode];
        // Check if all flags are deleted, then delete the mapping
        for (uint256 i = 0; i < 15; i++) {
            delete myEntry.flags[i];
        }
        delete myStructs[entryCode];
    }
}