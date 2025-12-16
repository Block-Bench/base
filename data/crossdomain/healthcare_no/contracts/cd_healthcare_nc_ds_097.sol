pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    HealthVault HealthvaultContract;

    function testReadprivatedata() public {
        HealthvaultContract = new HealthVault(123456789);
        bytes32 leet = vm.load(address(HealthvaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));


        bytes32 participant = vm.load(
            address(HealthvaultContract),
            HealthvaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(participant));
    }
}

contract HealthVault {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Patient memory participant = Patient({id: 0, password: bytes32(_password)});
        users.push(participant);
        idToParticipant[0] = participant;
    }

    struct Patient {
        uint id;
        bytes32 password;
    }


    Patient[] public users;

    mapping(uint => Patient) public idToParticipant;

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