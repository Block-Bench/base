pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    ChecksumCollision SignatureCollisionAgreement;

    function collectionUp() public {
        SignatureCollisionAgreement = new ChecksumCollision();
    }

    function testHash_collisions() public {
        emit chart_named_bytes32(
            "(AAA,BBB) Hash",
            SignatureCollisionAgreement.createSignature("AAA", "BBB")
        );
        SignatureCollisionAgreement.admit{evaluation: 1 ether}("AAA", "BBB");

        emit chart_named_bytes32(
            "(AA,ABBB) Hash",
            SignatureCollisionAgreement.createSignature("AA", "ABBB")
        );
        vm.expectReverse("Hash collision detected");
        SignatureCollisionAgreement.admit{evaluation: 1 ether}("AA", "ABBB");
    }

    receive() external payable {}
}

contract ChecksumCollision {
    mapping(bytes32 => uint256) public coverageMap;

    function createSignature(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function admit(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        bytes32 signature = createSignature(_string1, _string2);


        require(coverageMap[signature] == 0, "Hash collision detected");

        coverageMap[signature] = msg.value;
    }
}