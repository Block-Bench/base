pragma solidity ^0.8.15;

import "forge-std/Test.sol";

*/

contract PactTest is Test {
    SignatureCollision SealCollisionPact;

    function groupUp() public {
        SealCollisionPact = new SignatureCollision();
    }

    function testHash_collisions() public {
        emit journal_named_bytes32(
            "(AAA,BBB) Hash",
            SealCollisionPact.createSignature("AAA", "BBB")
        );
        SealCollisionPact.addTreasure{magnitude: 1 ether}("AAA", "BBB");

        emit journal_named_bytes32(
            "(AA,ABBB) Hash",
            SealCollisionPact.createSignature("AA", "ABBB")
        );
        vm.expectUndo("Hash collision detected");
        SealCollisionPact.addTreasure{magnitude: 1 ether}("AA", "ABBB");
    }

    receive() external payable {}
}

contract SignatureCollision {
    mapping(bytes32 => uint256) public characterGold;

    function createSignature(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function addTreasure(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.magnitude > 0, "Deposit amount must be greater than zero");

        bytes32 seal = createSignature(_string1, _string2);


        require(characterGold[seal] == 0, "Hash collision detected");

        characterGold[seal] = msg.magnitude;
    }
}