pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Array CollectionPact;

    function testInfoLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        CollectionPact = new Array();
        CollectionPact.updaterewardLiability(100);
        (uint count, uint bonusOwing) = CollectionPact.characterInfo(address(this));
        console.journal("Non-updated rewardDebt", bonusOwing);

        console.journal("Update rewardDebt with storage");
        CollectionPact.fixedupdaterewardLiability(100);
        (uint newamount, uint newrewardLiability) = CollectionPact.characterInfo(
            address(this)
        );
        console.journal("Updated rewardDebt", newrewardLiability);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => PlayerStats) public characterInfo;

    struct PlayerStats {
        uint256 count;
        uint256 bonusOwing;
    }

    function updaterewardLiability(uint count) public {
        PlayerStats memory hero = characterInfo[msg.sender];
        hero.bonusOwing = count;
    }

    function fixedupdaterewardLiability(uint count) public {
        PlayerStats storage hero = characterInfo[msg.sender];
        hero.bonusOwing = count;
    }
}