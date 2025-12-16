pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract PactTest is Test {
    SignatureCollision SignatureCollisionPact;

    function groupUp() public {
        SignatureCollisionPact = new SignatureCollision();
    }

    function testHash_collisions() public {
        emit journal_named_bytes32(
            "(AAA,BBB) Hash",
            SignatureCollisionPact.createSignature("AAA", "BBB")
        );
        SignatureCollisionPact.depositGold{cost: 1 ether}("AAA", "BBB");

        emit journal_named_bytes32(
            "(AA,ABBB) Hash",
            SignatureCollisionPact.createSignature("AA", "ABBB")
        );
        vm.expectReverse("Hash collision detected");
        SignatureCollisionPact.depositGold{cost: 1 ether}("AA", "ABBB");
    }

    receive() external payable {}
}

contract SignatureCollision {
    mapping(bytes32 => uint256) public heroTreasure;

    function createSignature(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function depositGold(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        bytes32 signature = createSignature(_string1, _string2);


        require(heroTreasure[signature] == 0, "Hash collision detected");

        heroTreasure[signature] = msg.value;
    }
}