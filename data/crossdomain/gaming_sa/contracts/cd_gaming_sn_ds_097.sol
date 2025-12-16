// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ItemVault LootvaultContract;

    function testReadprivatedata() public {
        LootvaultContract = new ItemVault(123456789);
        bytes32 leet = vm.load(address(LootvaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));

        // users in slot 1 - length of array
        // starting from slot hash(1) - array elements
        // slot where array element is stored = keccak256(slot)) + (index * elementSize)
        // where slot = 1 and elementSize = 2 (1 (uint) +  1 (bytes32))
        bytes32 champion = vm.load(
            address(LootvaultContract),
            LootvaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(champion));
    }
}

contract ItemVault {
    // slot 0
    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Warrior memory champion = Warrior({id: 0, password: bytes32(_password)});
        users.push(champion);
        idToGamer[0] = champion;
    }

    struct Warrior {
        uint id;
        bytes32 password;
    }

    // slot 1
    Warrior[] public users;
    // slot 2
    mapping(uint => Warrior) public idToGamer;

    function getArrayLocation(
        uint slot,
        uint index,
        uint elementSize
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(slot))) +
            (index * elementSize);
        return bytes32(a);
    }
}
