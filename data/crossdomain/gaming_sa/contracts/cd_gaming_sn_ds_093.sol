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
        ArrayContract.updaterewardOwedgold(100); // update rewardDebt to 100
        (uint amount, uint lootrewardLoanamount) = ArrayContract.warriorInfo(address(this));
        console.log("Non-updated rewardDebt", lootrewardLoanamount);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardOwedgold(100);
        (uint newamount, uint newrewardLoanamount) = ArrayContract.warriorInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardLoanamount);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => HeroInfo) public warriorInfo; // storage

    struct HeroInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 lootrewardLoanamount; // Reward debt. See Explanation below.
    }

    function updaterewardOwedgold(uint amount) public {
        HeroInfo memory hero = warriorInfo[msg.sender];
        hero.lootrewardLoanamount = amount;
    }

    function fixedupdaterewardOwedgold(uint amount) public {
        HeroInfo storage hero = warriorInfo[msg.sender]; // storage
        hero.lootrewardLoanamount = amount;
    }
}
