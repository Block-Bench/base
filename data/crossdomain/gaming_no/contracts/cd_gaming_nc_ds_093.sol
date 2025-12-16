pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Array ArrayContract;

    function testDataLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        ArrayContract = new Array();
        ArrayContract.updaterewardLoanamount(100);
        (uint amount, uint questrewardGolddebt) = ArrayContract.heroInfo(address(this));
        console.log("Non-updated rewardDebt", questrewardGolddebt);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardLoanamount(100);
        (uint newamount, uint newrewardGolddebt) = ArrayContract.heroInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardGolddebt);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => AdventurerInfo) public heroInfo;

    struct AdventurerInfo {
        uint256 amount;
        uint256 questrewardGolddebt;
    }

    function updaterewardLoanamount(uint amount) public {
        AdventurerInfo memory champion = heroInfo[msg.sender];
        champion.questrewardGolddebt = amount;
    }

    function fixedupdaterewardLoanamount(uint amount) public {
        AdventurerInfo storage champion = heroInfo[msg.sender];
        champion.questrewardGolddebt = amount;
    }
}