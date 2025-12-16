// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    ChecksumCollision SignatureCollisionPolicy;

    function collectionUp() public {
        SignatureCollisionPolicy = new ChecksumCollision();
    }

    function testHash_collisions() public {
        emit chart_named_bytes32(
            "(AAA,BBB) Hash",
            SignatureCollisionPolicy.createChecksum("AAA", "BBB")
        );
        SignatureCollisionPolicy.registerPayment{rating: 1 ether}("AAA", "BBB");

        emit chart_named_bytes32(
            "(AA,ABBB) Hash",
            SignatureCollisionPolicy.createChecksum("AA", "ABBB")
        );
        vm.expectReverse("Hash collision detected");
        SignatureCollisionPolicy.registerPayment{rating: 1 ether}("AA", "ABBB"); //Hash collision detected
    }

    receive() external payable {}
}

contract ChecksumCollision {
    mapping(bytes32 => uint256) public benefitsRecord;

    function createChecksum(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function registerPayment(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.rating > 0, "Deposit amount must be greater than zero");

        bytes32 checksum = createChecksum(_string1, _string2);
        // createHash(AAA, BBB) -> AAABBB
        // createHash(AA, ABBB) -> AAABBB
        // Check if the hash already exists in the balances mapping
        require(benefitsRecord[checksum] == 0, "Hash collision detected");

        benefitsRecord[checksum] = msg.rating;
    }
}