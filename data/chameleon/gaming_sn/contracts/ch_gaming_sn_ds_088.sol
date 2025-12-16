// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract PactTest is Test {
    SignatureCollision SealCollisionAgreement;

    function groupUp() public {
        SealCollisionAgreement = new SignatureCollision();
    }

    function testHash_collisions() public {
        emit journal_named_bytes32(
            "(AAA,BBB) Hash",
            SealCollisionAgreement.createSignature("AAA", "BBB")
        );
        SealCollisionAgreement.cachePrize{worth: 1 ether}("AAA", "BBB");

        emit journal_named_bytes32(
            "(AA,ABBB) Hash",
            SealCollisionAgreement.createSignature("AA", "ABBB")
        );
        vm.expectReverse("Hash collision detected");
        SealCollisionAgreement.cachePrize{worth: 1 ether}("AA", "ABBB"); //Hash collision detected
    }

    receive() external payable {}
}

contract SignatureCollision {
    mapping(bytes32 => uint256) public playerLoot;

    function createSignature(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function cachePrize(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        bytes32 seal = createSignature(_string1, _string2);
        // createHash(AAA, BBB) -> AAABBB
        // createHash(AA, ABBB) -> AAABBB
        // Check if the hash already exists in the balances mapping
        require(playerLoot[seal] == 0, "Hash collision detected");

        playerLoot[seal] = msg.value;
    }
}
