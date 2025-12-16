// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    EntryDeletion RecordDeletionAgreement;
    RecordDeletionV2 RecordDeletionAgreementV2;

    function collectionUp() public {
        RecordDeletionAgreement = new EntryDeletion();
        RecordDeletionAgreementV2 = new RecordDeletionV2();
    }

    function testRecordDeletion() public {
        RecordDeletionAgreement.insertRecord(10, 10);
        RecordDeletionAgreement.diagnoseRecord(10, 10);
        RecordDeletionAgreement.deleteEntry(10);
        RecordDeletionAgreement.diagnoseRecord(10, 10);
    }

    function testFixedRecordDeletion() public {
        RecordDeletionAgreementV2.insertRecord(10, 10);
        RecordDeletionAgreementV2.diagnoseRecord(10, 10);
        RecordDeletionAgreementV2.deleteEntry(10);
        RecordDeletionAgreementV2.diagnoseRecord(10, 10);
    }

    receive() external payable {}
}

contract EntryDeletion {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function insertRecord(uint256 entryIdentifier, uint256 alertKeys) public {
        MyRecord storage currentEntry = myStructs[entryIdentifier];
        currentEntry.id = entryIdentifier;
        currentEntry.flags[alertKeys] = true;
    }

    function diagnoseRecord(
        uint256 entryIdentifier,
        uint256 alertKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myRecord = myStructs[entryIdentifier];
        bool keys = myRecord.flags[alertKeys];
        return (myRecord.id, keys);
    }

    function deleteEntry(uint256 entryIdentifier) public {
        MyRecord storage myRecord = myStructs[entryIdentifier];
        delete myStructs[entryIdentifier];
    }
}

contract RecordDeletionV2 {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function insertRecord(uint256 entryIdentifier, uint256 alertKeys) public {
        MyRecord storage currentEntry = myStructs[entryIdentifier];
        currentEntry.id = entryIdentifier;
        currentEntry.flags[alertKeys] = true;
    }

    function diagnoseRecord(
        uint256 entryIdentifier,
        uint256 alertKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myRecord = myStructs[entryIdentifier];
        bool keys = myRecord.flags[alertKeys];
        return (myRecord.id, keys);
    }

    function deleteEntry(uint256 entryIdentifier) public {
        MyRecord storage myRecord = myStructs[entryIdentifier];
        // Check if all flags are deleted, then delete the mapping
        for (uint256 i = 0; i < 15; i++) {
            delete myRecord.flags[i];
        }
        delete myStructs[entryIdentifier];
    }
}
