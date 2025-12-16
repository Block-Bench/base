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
        ArrayContract.updaterewardPendingobligation(100); // update rewardDebt to 100
        (uint amount, uint tiprewardReputationdebt) = ArrayContract.followerInfo(address(this));
        console.log("Non-updated rewardDebt", tiprewardReputationdebt);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardPendingobligation(100);
        (uint newamount, uint newrewardReputationdebt) = ArrayContract.followerInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardReputationdebt);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => SupporterInfo) public followerInfo; // storage

    struct SupporterInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 tiprewardReputationdebt; // Reward debt. See Explanation below.
    }

    function updaterewardPendingobligation(uint amount) public {
        SupporterInfo memory supporter = followerInfo[msg.sender];
        supporter.tiprewardReputationdebt = amount;
    }

    function fixedupdaterewardPendingobligation(uint amount) public {
        SupporterInfo storage supporter = followerInfo[msg.sender]; // storage
        supporter.tiprewardReputationdebt = amount;
    }
}
