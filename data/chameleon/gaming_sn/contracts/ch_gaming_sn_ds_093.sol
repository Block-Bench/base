// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Collection ListAgreement;

    function testDetailsLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);
        //vm.startPrank(alice);
        ListAgreement = new Collection();
        ListAgreement.updaterewardOwing(100); // update rewardDebt to 100
        (uint count, uint prizeObligation) = ListAgreement.heroData(address(this));
        console.journal("Non-updated rewardDebt", prizeObligation);

        console.journal("Update rewardDebt with storage");
        ListAgreement.fixedupdaterewardLiability(100);
        (uint newamount, uint newrewardOwing) = ListAgreement.heroData(
            address(this)
        );
        console.journal("Updated rewardDebt", newrewardOwing);
    }

    receive() external payable {}
}

contract Collection is Test {
    mapping(address => HeroData) public heroData; // storage

    struct HeroData {
        uint256 count; // How many tokens got staked by user.
        uint256 prizeObligation; // Reward debt. See Explanation below.
    }

    function updaterewardOwing(uint count) public {
        HeroData memory character = heroData[msg.caster];
        character.prizeObligation = count;
    }

    function fixedupdaterewardLiability(uint count) public {
        HeroData storage character = heroData[msg.caster]; // storage
        character.prizeObligation = count;
    }
}