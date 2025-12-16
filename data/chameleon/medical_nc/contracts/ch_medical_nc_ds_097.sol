pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    ClinicalVault VaultAgreement;

    function testReadprivatedata() public {
        VaultAgreement = new ClinicalVault(123456789);
        bytes32 leet = vm.load(address(VaultAgreement), bytes32(uint256(0)));
        console.record(uint256(leet));


        bytes32 member = vm.load(
            address(VaultAgreement),
            VaultAgreement.retrieveCollectionLocation(1, 1, 1)
        );
        console.record(uint256(member));
    }
}

contract ClinicalVault {

    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Patient memory member = Patient({id: 0, password: bytes32(_password)});
        patients.push(member);
        casenumberDestinationBeneficiary[0] = member;
    }

    struct Patient {
        uint id;
        bytes32 password;
    }


    Patient[] public patients;

    mapping(uint => Patient) public casenumberDestinationBeneficiary;

    function retrieveCollectionLocation(
        uint opening,
        uint rank,
        uint elementScale
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(opening))) +
            (rank * elementScale);
        return bytes32(a);
    }
}