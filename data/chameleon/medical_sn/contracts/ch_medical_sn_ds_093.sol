// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    List CollectionAgreement;

    function testInfoLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);
        //vm.startPrank(alice);
        CollectionAgreement = new List();
        CollectionAgreement.updaterewardObligation(100); // update rewardDebt to 100
        (uint units, uint creditLiability) = CollectionAgreement.patientRecord(address(this));
        console.record("Non-updated rewardDebt", creditLiability);

        console.record("Update rewardDebt with storage");
        CollectionAgreement.fixedupdaterewardLiability(100);
        (uint newamount, uint newrewardLiability) = CollectionAgreement.patientRecord(
            address(this)
        );
        console.record("Updated rewardDebt", newrewardLiability);
    }

    receive() external payable {}
}

contract List is Test {
    mapping(address => PatientRecord) public patientRecord; // storage

    struct PatientRecord {
        uint256 units; // How many tokens got staked by user.
        uint256 creditLiability; // Reward debt. See Explanation below.
    }

    function updaterewardObligation(uint units) public {
        PatientRecord memory patient = patientRecord[msg.provider];
        patient.creditLiability = units;
    }

    function fixedupdaterewardLiability(uint units) public {
        PatientRecord storage patient = patientRecord[msg.provider]; // storage
        patient.creditLiability = units;
    }
}