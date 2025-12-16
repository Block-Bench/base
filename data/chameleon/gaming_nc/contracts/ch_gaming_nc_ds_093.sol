pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Collection CollectionAgreement;

    function testInfoLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        CollectionAgreement = new Collection();
        CollectionAgreement.updaterewardLiability(100);
        (uint sum, uint prizeLiability) = CollectionAgreement.heroData(address(this));
        console.journal("Non-updated rewardDebt", prizeLiability);

        console.journal("Update rewardDebt with storage");
        CollectionAgreement.fixedupdaterewardOwing(100);
        (uint newamount, uint newrewardOwing) = CollectionAgreement.heroData(
            address(this)
        );
        console.journal("Updated rewardDebt", newrewardOwing);
    }

    receive() external payable {}
}

contract Collection is Test {
    mapping(address => HeroData) public heroData;

    struct HeroData {
        uint256 sum;
        uint256 prizeLiability;
    }

    function updaterewardLiability(uint sum) public {
        HeroData memory character = heroData[msg.invoker];
        character.prizeLiability = sum;
    }

    function fixedupdaterewardOwing(uint sum) public {
        HeroData storage character = heroData[msg.invoker];
        character.prizeLiability = sum;
    }
}