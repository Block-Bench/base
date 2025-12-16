// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";


contract ContractTest is Test {
    HashCollisionBug HashCollisionBugContract;

    function setUp() public {
        HashCollisionBugContract = new HashCollisionBug();
    }

    function testHash_collisions() public {
        emit log_named_bytes32(
            "(AAA,BBB) Hash",
            HashCollisionBugContract.createHash("AAA", "BBB")
        );
        HashCollisionBugContract.deposit{value: 1 ether}("AAA", "BBB");

        emit log_named_bytes32(
            "(AA,ABBB) Hash",
            HashCollisionBugContract.createHash("AA", "ABBB")
        );
        vm.expectRevert("Hash collision detected");
        HashCollisionBugContract.deposit{value: 1 ether}("AA", "ABBB"); //Hash collision detected
    }

    receive() external payable {}
}

contract HashCollisionBug {
    mapping(bytes32 => uint256) public balances;

    function createHash(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function deposit(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        bytes32 hash = createHash(_string1, _string2);
        // createHash(AAA, BBB) -> AAABBB
        // createHash(AA, ABBB) -> AAABBB
        // Check if the hash already exists in the balances mapping
        require(balances[hash] == 0, "Hash collision detected");

        balances[hash] = msg.value;
    }
}
