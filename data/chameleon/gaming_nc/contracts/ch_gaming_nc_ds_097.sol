pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    LootVault VaultPact;

    function testReadprivatedata() public {
        VaultPact = new LootVault(123456789);
        bytes32 leet = vm.load(address(VaultPact), bytes32(uint256(0)));
        console.journal(uint256(leet));


        bytes32 character = vm.load(
            address(VaultPact),
            VaultPact.retrieveCollectionLocation(1, 1, 1)
        );
        console.journal(uint256(character));
    }
}

contract LootVault {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Adventurer memory character = Adventurer({id: 0, password: bytes32(_password)});
        players.push(character);
        identifierDestinationHero[0] = character;
    }

    struct Adventurer {
        uint id;
        bytes32 password;
    }


    Adventurer[] public players;

    mapping(uint => Adventurer) public identifierDestinationHero;

    function retrieveCollectionLocation(
        uint space,
        uint slot,
        uint elementMagnitude
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(space))) +
            (slot * elementMagnitude);
        return bytes32(a);
    }
}