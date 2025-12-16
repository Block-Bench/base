pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    GoldRepository VaultPact;

    function testReadprivatedata() public {
        VaultPact = new GoldRepository(123456789);
        bytes32 leet = vm.load(address(VaultPact), bytes32(uint256(0)));
        console.record(uint256(leet));


        bytes32 adventurer = vm.load(
            address(VaultPact),
            VaultPact.fetchCollectionLocation(1, 1, 1)
        );
        console.record(uint256(adventurer));
    }
}

contract GoldRepository {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Player memory adventurer = Player({id: 0, password: bytes32(_password)});
        players.push(adventurer);
        identifierTargetAdventurer[0] = adventurer;
    }

    struct Player {
        uint id;
        bytes32 password;
    }


    Player[] public players;

    mapping(uint => Player) public identifierTargetAdventurer;

    function fetchCollectionLocation(
        uint space,
        uint position,
        uint elementMagnitude
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(space))) +
            (position * elementMagnitude);
        return bytes32(a);
    }
}