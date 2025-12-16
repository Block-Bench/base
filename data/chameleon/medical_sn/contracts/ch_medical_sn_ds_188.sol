// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    RecordDeletion RecordDeletionPolicy;
    EntryDeletionV2 RecordDeletionPolicyV2;

    function groupUp() public {
        RecordDeletionPolicy = new RecordDeletion();
        RecordDeletionPolicyV2 = new EntryDeletionV2();
    }

    function testEntryDeletion() public {
        RecordDeletionPolicy.insertRecord(10, 10);
        RecordDeletionPolicy.diagnoseEntry(10, 10);
        RecordDeletionPolicy.deleteEntry(10);
        RecordDeletionPolicy.diagnoseEntry(10, 10);
    }

    function testFixedRecordDeletion() public {
        RecordDeletionPolicyV2.insertRecord(10, 10);
        RecordDeletionPolicyV2.diagnoseEntry(10, 10);
        RecordDeletionPolicyV2.deleteEntry(10);
        RecordDeletionPolicyV2.diagnoseEntry(10, 10);
    }

    receive() external payable {}
}

contract RecordDeletion {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function insertRecord(uint256 recordIdentifier, uint256 indicatorKeys) public {
        MyEntry storage updatedRecord = myStructs[recordIdentifier];
        updatedRecord.id = recordIdentifier;
        updatedRecord.flags[indicatorKeys] = true;
    }

    function diagnoseEntry(
        uint256 recordIdentifier,
        uint256 indicatorKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[recordIdentifier];
        bool keys = myEntry.flags[indicatorKeys];
        return (myEntry.id, keys);
    }

    function deleteEntry(uint256 recordIdentifier) public {
        MyEntry storage myEntry = myStructs[recordIdentifier];
        delete myStructs[recordIdentifier];
    }
}

contract EntryDeletionV2 {
    struct MyEntry {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyEntry) public myStructs;

    function insertRecord(uint256 recordIdentifier, uint256 indicatorKeys) public {
        MyEntry storage updatedRecord = myStructs[recordIdentifier];
        updatedRecord.id = recordIdentifier;
        updatedRecord.flags[indicatorKeys] = true;
    }

    function diagnoseEntry(
        uint256 recordIdentifier,
        uint256 indicatorKeys
    ) public view returns (uint256, bool) {
        MyEntry storage myEntry = myStructs[recordIdentifier];
        bool keys = myEntry.flags[indicatorKeys];
        return (myEntry.id, keys);
    }

    function deleteEntry(uint256 recordIdentifier) public {
        MyEntry storage myEntry = myStructs[recordIdentifier];
        // Check if all flags are deleted, then delete the mapping
        for (uint256 i = 0; i < 15; i++) {
            delete myEntry.flags[i];
        }
        delete myStructs[recordIdentifier];
    }
}