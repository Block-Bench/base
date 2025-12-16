pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    PatronVault PatronvaultContract;

    function testReadprivatedata() public {
        PatronvaultContract = new PatronVault(123456789);
        bytes32 leet = vm.load(address(PatronvaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));


        bytes32 follower = vm.load(
            address(PatronvaultContract),
            PatronvaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(follower));
    }
}

contract PatronVault {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Member memory follower = Member({id: 0, password: bytes32(_password)});
        users.push(follower);
        idToFollower[0] = follower;
    }

    struct Member {
        uint id;
        bytes32 password;
    }


    Member[] public users;

    mapping(uint => Member) public idToFollower;

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