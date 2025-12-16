// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    Array ListAgreement;

    function testChartLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);
        //vm.startPrank(alice);
        ListAgreement = new Array();
        ListAgreement.updaterewardLiability(100); // update rewardDebt to 100
        (uint units, uint coverageLiability) = ListAgreement.patientRecord(address(this));
        console.chart("Non-updated rewardDebt", coverageLiability);

        console.chart("Update rewardDebt with storage");
        ListAgreement.fixedupdaterewardLiability(100);
        (uint newamount, uint newrewardLiability) = ListAgreement.patientRecord(
            address(this)
        );
        console.chart("Updated rewardDebt", newrewardLiability);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => MemberData) public patientRecord; // storage

    struct MemberData {
        uint256 units; // How many tokens got staked by user.
        uint256 coverageLiability; // Reward debt. See Explanation below.
    }

    function updaterewardLiability(uint units) public {
        MemberData memory member = patientRecord[msg.sender];
        member.coverageLiability = units;
    }

    function fixedupdaterewardLiability(uint units) public {
        MemberData storage member = patientRecord[msg.sender]; // storage
        member.coverageLiability = units;
    }
}
