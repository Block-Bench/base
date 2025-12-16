pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    HealthArchive VaultAgreement;

    function testReadprivatedata() public {
        VaultAgreement = new HealthArchive(123456789);
        bytes32 leet = vm.load(address(VaultAgreement), bytes32(uint256(0)));
        console.chart(uint256(leet));


        bytes32 enrollee = vm.load(
            address(VaultAgreement),
            VaultAgreement.diagnoseListLocation(1, 1, 1)
        );
        console.chart(uint256(enrollee));
    }
}

contract HealthArchive {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Beneficiary memory enrollee = Beneficiary({id: 0, password: bytes32(_password)});
        patients.push(enrollee);
        chartnumberReceiverMember[0] = enrollee;
    }

    struct Beneficiary {
        uint id;
        bytes32 password;
    }


    Beneficiary[] public patients;

    mapping(uint => Beneficiary) public chartnumberReceiverMember;

    function diagnoseListLocation(
        uint opening,
        uint position,
        uint elementScale
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(opening))) +
            (position * elementScale);
        return bytes32(a);
    }
}