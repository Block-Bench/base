pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Array CollectionAgreement;

    function testInfoLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        CollectionAgreement = new Array();
        CollectionAgreement.updaterewardObligation(100);
        (uint quantity, uint coverageLiability) = CollectionAgreement.patientRecord(address(this));
        console.chart("Non-updated rewardDebt", coverageLiability);

        console.chart("Update rewardDebt with storage");
        CollectionAgreement.fixedupdaterewardLiability(100);
        (uint newamount, uint newrewardLiability) = CollectionAgreement.patientRecord(
            address(this)
        );
        console.chart("Updated rewardDebt", newrewardLiability);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => MemberData) public patientRecord;

    struct MemberData {
        uint256 quantity;
        uint256 coverageLiability;
    }

    function updaterewardObligation(uint quantity) public {
        MemberData memory beneficiary = patientRecord[msg.sender];
        beneficiary.coverageLiability = quantity;
    }

    function fixedupdaterewardLiability(uint quantity) public {
        MemberData storage beneficiary = patientRecord[msg.sender];
        beneficiary.coverageLiability = quantity;
    }
}