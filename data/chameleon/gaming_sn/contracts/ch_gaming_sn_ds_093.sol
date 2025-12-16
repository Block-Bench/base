// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Array CollectionAgreement;

    function testDetailsLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);
        //vm.startPrank(alice);
        CollectionAgreement = new Array();
        CollectionAgreement.updaterewardObligation(100); // update rewardDebt to 100
        (uint sum, uint treasureLiability) = CollectionAgreement.heroData(address(this));
        console.journal("Non-updated rewardDebt", treasureLiability);

        console.journal("Update rewardDebt with storage");
        CollectionAgreement.fixedupdaterewardLiability(100);
        (uint newamount, uint newrewardOwing) = CollectionAgreement.heroData(
            address(this)
        );
        console.journal("Updated rewardDebt", newrewardOwing);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => CharacterInfo) public heroData; // storage

    struct CharacterInfo {
        uint256 sum; // How many tokens got staked by user.
        uint256 treasureLiability; // Reward debt. See Explanation below.
    }

    function updaterewardObligation(uint sum) public {
        CharacterInfo memory character = heroData[msg.sender];
        character.treasureLiability = sum;
    }

    function fixedupdaterewardLiability(uint sum) public {
        CharacterInfo storage character = heroData[msg.sender]; // storage
        character.treasureLiability = sum;
    }
}
