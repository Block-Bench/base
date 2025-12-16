// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";


contract ContractTest is Test {
    StructDeletionBug StructDeletionBugContract;
    FixedStructDeletion FixedStructDeletionContract;

    function setUp() public {
        StructDeletionBugContract = new StructDeletionBug();
        FixedStructDeletionContract = new FixedStructDeletion();
    }

    function testStructDeletion() public {
        StructDeletionBugContract.addStruct(10, 10);
        StructDeletionBugContract.getStruct(10, 10);
        StructDeletionBugContract.deleteStruct(10);
        StructDeletionBugContract.getStruct(10, 10);
    }

    function testFixedStructDeletion() public {
        FixedStructDeletionContract.addStruct(10, 10);
        FixedStructDeletionContract.getStruct(10, 10);
        FixedStructDeletionContract.deleteStruct(10);
        FixedStructDeletionContract.getStruct(10, 10);
    }

    receive() external payable {}
}

contract StructDeletionBug {
    struct MyStruct {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyStruct) public myStructs;

    function addStruct(uint256 structId, uint256 flagKeys) public {
        MyStruct storage newStruct = myStructs[structId];
        newStruct.id = structId;
        newStruct.flags[flagKeys] = true;
    }

    function getStruct(
        uint256 structId,
        uint256 flagKeys
    ) public view returns (uint256, bool) {
        MyStruct storage myStruct = myStructs[structId];
        bool keys = myStruct.flags[flagKeys];
        return (myStruct.id, keys);
    }

    function deleteStruct(uint256 structId) public {
        MyStruct storage myStruct = myStructs[structId];
        delete myStructs[structId];
    }
}

contract FixedStructDeletion {
    struct MyStruct {
        uint256 id;
        mapping(uint256 => bool) flags;
    }

    mapping(uint256 => MyStruct) public myStructs;

    function addStruct(uint256 structId, uint256 flagKeys) public {
        MyStruct storage newStruct = myStructs[structId];
        newStruct.id = structId;
        newStruct.flags[flagKeys] = true;
    }

    function getStruct(
        uint256 structId,
        uint256 flagKeys
    ) public view returns (uint256, bool) {
        MyStruct storage myStruct = myStructs[structId];
        bool keys = myStruct.flags[flagKeys];
        return (myStruct.id, keys);
    }

    function deleteStruct(uint256 structId) public {
        MyStruct storage myStruct = myStructs[structId];
        // Check if all flags are deleted, then delete the mapping
        for (uint256 i = 0; i < 15; i++) {
            delete myStruct.flags[i];
        }
        delete myStructs[structId];
    }
}
