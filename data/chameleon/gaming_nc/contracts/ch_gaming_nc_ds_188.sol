pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PactTest is Test {
    RecordDeletion EntryDeletionAgreement;
    RecordDeletionV2 RecordDeletionAgreementV2;

    function groupUp() public {
        EntryDeletionAgreement = new RecordDeletion();
        RecordDeletionAgreementV2 = new RecordDeletionV2();
    }

    function testRecordDeletion() public {
        EntryDeletionAgreement.attachRecord(10, 10);
        EntryDeletionAgreement.obtainEntry(10, 10);
        EntryDeletionAgreement.deleteRecord(10);
        EntryDeletionAgreement.obtainEntry(10, 10);
    }

    function testFixedEntryDeletion() public {
        RecordDeletionAgreementV2.attachRecord(10, 10);
        RecordDeletionAgreementV2.obtainEntry(10, 10);
        RecordDeletionAgreementV2.deleteRecord(10);
        RecordDeletionAgreementV2.obtainEntry(10, 10);
    }

    receive() external payable {}
}

contract RecordDeletion {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function attachRecord(uint256 entryTag, uint256 markerKeys) public {
        MyEntry storage currentEntry = myStructs[entryTag];
        currentEntry.id = entryTag;
        currentEntry.flags[markerKeys] = true;
    }

    function obtainEntry(
        uint256 entryTag,
        uint256 markerKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[entryTag];
        bool keys = myEntry.flags[markerKeys];
        return (myEntry.id, keys);
    }

    function deleteRecord(uint256 entryTag) public {
        MyEntry storage myEntry = myStructs[entryTag];
        delete myStructs[entryTag];
    }
}

contract RecordDeletionV2 {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function attachRecord(uint256 entryTag, uint256 markerKeys) public {
        MyEntry storage currentEntry = myStructs[entryTag];
        currentEntry.id = entryTag;
        currentEntry.flags[markerKeys] = true;
    }

    function obtainEntry(
        uint256 entryTag,
        uint256 markerKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[entryTag];
        bool keys = myEntry.flags[markerKeys];
        return (myEntry.id, keys);
    }

    function deleteRecord(uint256 entryTag) public {
        MyEntry storage myEntry = myStructs[entryTag];

        for (uint256 i = 0; i < 15; i++) {
            delete myEntry.flags[i];
        }
        delete myStructs[entryTag];
    }
}