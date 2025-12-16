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
        ArrayContract.updaterewardPendingcharges(100); // update rewardDebt to 100
        (uint amount, uint deliverybonusUnpaidstorage) = ArrayContract.buyerInfo(address(this));
        console.log("Non-updated rewardDebt", deliverybonusUnpaidstorage);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardPendingcharges(100);
        (uint newamount, uint newrewardUnpaidstorage) = ArrayContract.buyerInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardUnpaidstorage);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => MerchantInfo) public buyerInfo; // storage

    struct MerchantInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 deliverybonusUnpaidstorage; // Reward debt. See Explanation below.
    }

    function updaterewardPendingcharges(uint amount) public {
        MerchantInfo memory merchant = buyerInfo[msg.sender];
        merchant.deliverybonusUnpaidstorage = amount;
    }

    function fixedupdaterewardPendingcharges(uint amount) public {
        MerchantInfo storage merchant = buyerInfo[msg.sender]; // storage
        merchant.deliverybonusUnpaidstorage = amount;
    }
}
