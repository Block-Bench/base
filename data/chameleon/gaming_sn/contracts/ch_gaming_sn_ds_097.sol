// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    WinningsBank VaultPact;

    function testReadprivatedata() public {
        VaultPact = new WinningsBank(123456789);
        bytes32 leet = vm.load(address(VaultPact), bytes32(uint256(0)));
        console.record(uint256(leet));

        // users in slot 1 - length of array
        // starting from slot hash(1) - array elements
        // slot where array element is stored = keccak256(slot)) + (index * elementSize)
        // where slot = 1 and elementSize = 2 (1 (uint) +  1 (bytes32))
        bytes32 character = vm.load(
            address(VaultPact),
            VaultPact.retrieveListLocation(1, 1, 1)
        );
        console.record(uint256(character));
    }
}

contract WinningsBank {
    // slot 0
    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Player memory character = Player({id: 0, password: bytes32(_password)});
        characters.push(character);
        tagTargetCharacter[0] = character;
    }

    struct Player {
        uint id;
        bytes32 password;
    }

    // slot 1
    Player[] public characters;
    // slot 2
    mapping(uint => Player) public tagTargetCharacter;

    function retrieveListLocation(
        uint position,
        uint slot,
        uint elementScale
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(position))) +
            (slot * elementScale);
        return bytes32(a);
    }
}