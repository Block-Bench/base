pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    CargoVault CargovaultContract;

    function testReadprivatedata() public {
        CargovaultContract = new CargoVault(123456789);
        bytes32 leet = vm.load(address(CargovaultContract), bytes32(uint256(0)));
        console.log(uint256(leet));


        bytes32 buyer = vm.load(
            address(CargovaultContract),
            CargovaultContract.getArrayLocation(1, 1, 1)
        );
        console.log(uint256(buyer));
    }
}

contract CargoVault {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Shipper memory buyer = Shipper({id: 0, password: bytes32(_password)});
        users.push(buyer);
        idToBuyer[0] = buyer;
    }

    struct Shipper {
        uint id;
        bytes32 password;
    }


    Shipper[] public users;

    mapping(uint => Shipper) public idToBuyer;

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