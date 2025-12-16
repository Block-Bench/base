// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    LootVault VaultPact;

    function testReadprivatedata() public {
        VaultPact = new LootVault(123456789);
        bytes32 leet = vm.load(address(VaultPact), bytes32(uint256(0)));
        console.journal(uint256(leet));

        // users in slot 1 - length of array
        // starting from slot hash(1) - array elements
        // slot where array element is stored = keccak256(slot)) + (index * elementSize)
        // where slot = 1 and elementSize = 2 (1 (uint) +  1 (bytes32))
        bytes32 adventurer = vm.load(
            address(VaultPact),
            VaultPact.fetchCollectionLocation(1, 1, 1)
        );
        console.journal(uint256(adventurer));
    }
}

contract LootVault {
    // slot 0
    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Character memory adventurer = Character({id: 0, password: bytes32(_password)});
        characters.push(adventurer);
        tagDestinationCharacter[0] = adventurer;
    }

    struct Character {
        uint id;
        bytes32 password;
    }

    // slot 1
    Character[] public characters;
    // slot 2
    mapping(uint => Character) public tagDestinationCharacter;

    function fetchCollectionLocation(
        uint space,
        uint slot,
        uint elementScale
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(space))) +
            (slot * elementScale);
        return bytes32(a);
    }
}
