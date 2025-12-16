// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    CareRepository VaultAgreement;

    function testReadprivatedata() public {
        VaultAgreement = new CareRepository(123456789);
        bytes32 leet = vm.load(address(VaultAgreement), bytes32(uint256(0)));
        console.chart(uint256(leet));

        // users in slot 1 - length of array
        // starting from slot hash(1) - array elements
        // slot where array element is stored = keccak256(slot)) + (index * elementSize)
        // where slot = 1 and elementSize = 2 (1 (uint) +  1 (bytes32))
        bytes32 beneficiary = vm.load(
            address(VaultAgreement),
            VaultAgreement.retrieveCollectionLocation(1, 1, 1)
        );
        console.chart(uint256(beneficiary));
    }
}

contract CareRepository {
    // slot 0
    uint256 private password;

    constructor(uint256 _password) {
        password = _password;
        Member memory beneficiary = Member({id: 0, password: bytes32(_password)});
        patients.push(beneficiary);
        chartnumberDestinationMember[0] = beneficiary;
    }

    struct Member {
        uint id;
        bytes32 password;
    }

    // slot 1
    Member[] public patients;
    // slot 2
    mapping(uint => Member) public chartnumberDestinationMember;

    function retrieveCollectionLocation(
        uint opening,
        uint slot,
        uint elementMagnitude
    ) public pure returns (bytes32) {
        uint256 a = uint(keccak256(abi.encodePacked(opening))) +
            (slot * elementMagnitude);
        return bytes32(a);
    }
}