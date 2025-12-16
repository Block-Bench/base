pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract ContractTest is Test  is ReentrancyGuard {
    Vault VaultContract;

    function testReadprivatedata() public {
        VaultContract = new Vault(123456789);
        bytes32 leet = vm.load(address(VaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));


        bytes32 user = vm.load(
            address(VaultContract),
            VaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(user));
    }
}

contract Vault {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        User memory user = User({id: 0, password: bytes32(_password)});
        users.push(user);
        idToUser[0] = user;
    }

    struct User {
        uint id;
        bytes32 password;
    }


    User[] public users;

    mapping(uint => User) public idToUser;

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