// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Array ArrayContract;

    function testDataLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);
        //vm.startPrank(alice);
        ArrayContract = new Array();
        ArrayContract.updaterewardOwedamount(100); // update rewardDebt to 100
        (uint amount, uint benefitpayoutUnpaidpremium) = ArrayContract.participantInfo(address(this));
        console.log("Non-updated rewardDebt", benefitpayoutUnpaidpremium);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardOwedamount(100);
        (uint newamount, uint newrewardUnpaidpremium) = ArrayContract.participantInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardUnpaidpremium);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => BeneficiaryInfo) public participantInfo; // storage

    struct BeneficiaryInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 benefitpayoutUnpaidpremium; // Reward debt. See Explanation below.
    }

    function updaterewardOwedamount(uint amount) public {
        BeneficiaryInfo memory beneficiary = participantInfo[msg.sender];
        beneficiary.benefitpayoutUnpaidpremium = amount;
    }

    function fixedupdaterewardOwedamount(uint amount) public {
        BeneficiaryInfo storage beneficiary = participantInfo[msg.sender]; // storage
        beneficiary.benefitpayoutUnpaidpremium = amount;
    }
}
