pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    RecordDeletion RecordDeletionAgreement;
    EntryDeletionV2 RecordDeletionPolicyV2;

    function groupUp() public {
        RecordDeletionAgreement = new RecordDeletion();
        RecordDeletionPolicyV2 = new EntryDeletionV2();
    }

    function testEntryDeletion() public {
        RecordDeletionAgreement.includeEntry(10, 10);
        RecordDeletionAgreement.obtainRecord(10, 10);
        RecordDeletionAgreement.deleteEntry(10);
        RecordDeletionAgreement.obtainRecord(10, 10);
    }

    function testFixedEntryDeletion() public {
        RecordDeletionPolicyV2.includeEntry(10, 10);
        RecordDeletionPolicyV2.obtainRecord(10, 10);
        RecordDeletionPolicyV2.deleteEntry(10);
        RecordDeletionPolicyV2.obtainRecord(10, 10);
    }

    receive() external payable {}
}

contract RecordDeletion {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function includeEntry(uint256 entryIdentifier, uint256 alertKeys) public {
        MyRecord storage updatedEntry = myStructs[entryIdentifier];
        updatedEntry.id = entryIdentifier;
        updatedEntry.flags[alertKeys] = true;
    }

    function obtainRecord(
        uint256 entryIdentifier,
        uint256 alertKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myEntry = myStructs[entryIdentifier];
        bool keys = myEntry.flags[alertKeys];
        return (myEntry.id, keys);
    }

    function deleteEntry(uint256 entryIdentifier) public {
        MyRecord storage myEntry = myStructs[entryIdentifier];
        delete myStructs[entryIdentifier];
    }
}

contract EntryDeletionV2 {
    struct MyRecord {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyRecord) public myStructs;

    function includeEntry(uint256 entryIdentifier, uint256 alertKeys) public {
        MyRecord storage updatedEntry = myStructs[entryIdentifier];
        updatedEntry.id = entryIdentifier;
        updatedEntry.flags[alertKeys] = true;
    }

    function obtainRecord(
        uint256 entryIdentifier,
        uint256 alertKeys
    ) public view returns (uint256, bool) {
        MyRecord storage myEntry = myStructs[entryIdentifier];
        bool keys = myEntry.flags[alertKeys];
        return (myEntry.id, keys);
    }

    function deleteEntry(uint256 entryIdentifier) public {
        MyRecord storage myEntry = myStructs[entryIdentifier];

        for (uint256 i = 0; i < 15; i++) {
            delete myEntry.flags[i];
        }
        delete myStructs[entryIdentifier];
    }
}